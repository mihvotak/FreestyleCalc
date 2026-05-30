import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/model.dart';
import 'package:freestyle_calculator/Data/sheets_util.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:freestyle_calculator/google_api/web_wrapper.dart' as web;

import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart' as sheets;

/// The scopes used by this example.
final List<String> scopes = [drive.DriveApi.driveReadonlyScope, sheets.SheetsApi.spreadsheetsScope];

String? clientId = 
  kIsWeb ? '586269986709-6tl8or1tgii6ss9ilp9dpfhbfqb9nctu.apps.googleusercontent.com' : 
  Platform.isAndroid ? '586269986709-e9m729f37bqo70is1cd7gtfdg8o68acv.apps.googleusercontent.com' : null;

String? serverClientId = clientId = 
  kIsWeb ? null:
  Platform.isAndroid ? '586269986709-6tl8or1tgii6ss9ilp9dpfhbfqb9nctu.apps.googleusercontent.com' : null;



class SignInDemo extends StatefulWidget {
  const SignInDemo(this.model, this.isImport, this.createNew, this.exportToId, {super.key});

  final Model model;
  final bool isImport;
  final bool createNew;
  final bool exportToId;

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {

  Model get model => widget.model;
  String _debugText = '';
  String _errorMessage = '';
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
  List<drive.File>? _sheets;
  SheetsUtil sheetsUtil = SheetsUtil();
  
  static const String resultsSheetName = "Результаты";
  static const String pairsSheetName = "Участники";
  static const String judgesSheetName = "Судьи";

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // #docregion Setup
    final GoogleSignIn signIn = GoogleSignIn.instance;
    if (!model.initialized) {
      unawaited(
        signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((
          _,
        ) {
          model.initialized = true;
          _authSubscription = signIn.authenticationEvents.listen(
            _handleAuthenticationEvent,
            onError: _handleAuthenticationError
          );

          /// This example always uses the stream-based approach to determining
          /// which UI state to show, rather than using the future returned here,
          /// if any, to conditionally skip directly to the signed-in state.
          signIn.attemptLightweightAuthentication();
        }),
      );
    }
    else {
      _authSubscription = signIn.authenticationEvents.listen(
        _handleAuthenticationEvent,
        onError: _handleAuthenticationError
      );
      if (model.currentUser != null) {
        onReady(model.currentUser!);
      }
      else {
        setState(() {
          _debugText = "model.initialized == true, но model.currentUser == null";
        });
      }
    }
    // #enddocregion Setup
  }

  Future<void> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    // #docregion CheckAuthorization
    final GoogleSignInAccount? user = // ...
        // #enddocregion CheckAuthorization
        switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };

    // Check for existing authorization.
    // #docregion CheckAuthorization
    model.authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);
    // #enddocregion CheckAuthorization

    setState(() {
      model.currentUser = user;
      model.isAuthorized = model.authorization != null;
      _errorMessage = '';
    });

    // If the user has already granted access to the required scopes, call the
    // REST API.
    if (user != null && model.authorization != null) {
      onReady(user);
    }
  }

  void onReady(GoogleSignInAccount user)
  {
    if (widget.createNew) {
      _exportToNewSheet(user, model.competition!);
    }
    else if (widget.exportToId) {
      _exportToSheetWithId(user, model.competition!, model.competition!.sheetId!);
    }
    else {
      unawaited(_handleGetSheets(user));
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    setState(() {
      model.currentUser = null;
      model.isAuthorized = false;
      _errorMessage = e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Unknown error: $e';
    });
  }

  Future<void> _handleGetSheets(GoogleSignInAccount user) async {
    setState(() {
      _debugText = 'Запрашиваем список таблиц...';
    });
    final Map<String, String>? headers = await user.authorizationClient
        .authorizationHeaders(scopes);
    if (headers == null) {
      setState(() {
        _debugText = '';
        model.isAuthorized = false;
        _errorMessage = 'Разрешения не даны или токен просрочен';
      });
      return;
    }
    try {
      model.authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);
      final authenticatedClient = model.authorization!.authClient(scopes: scopes);
      final driveApi = drive.DriveApi(authenticatedClient);
      final filelist = await driveApi.files.list(corpus: 'user', includeItemsFromAllDrives: true, supportsAllDrives: true,
        q: 'mimeType = \'application/vnd.google-apps.spreadsheet\' and trashed = false and \'${model.currentUser!.email}\' in owners'
      );
      _sheets = filelist.files;
      setState(() {
        if (_sheets != null) {
          _debugText = '';
        } else {
          _debugText = 'Таблиц не найдено.';
        }
      });
    }
    catch(e) {
      setState(() {
        _debugText = '';
        model.isAuthorized = false;
        _errorMessage = 'Ошибка: ${e.toString()}';
      });
    }
  }

  Future<void> _exportToNewSheet(GoogleSignInAccount user, Competition competition) async {
    setState(() {
      _debugText = 'Создаём новую гуглотаблицу...';
    });
    try {
      model.authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);
      final authenticatedClient = model.authorization!.authClient(scopes: scopes);
      final sheetsApi = sheets.SheetsApi(authenticatedClient);
      
      var newSpreadsheet = sheets.Spreadsheet(
        properties: sheets.SpreadsheetProperties(title: competition.name),
        sheets: [
          sheets.Sheet(properties: sheets.SheetProperties(title: resultsSheetName)),
          sheets.Sheet(properties: sheets.SheetProperties(title: pairsSheetName)),
          sheets.Sheet(properties: sheets.SheetProperties(title: judgesSheetName)),
        ]
      );
      sheets.Spreadsheet response = await sheetsApi.spreadsheets.create(newSpreadsheet);
      final spreadsheetId = response.spreadsheetId;
      setState(() {
        _debugText = spreadsheetId != null ? "Таблица создана: $spreadsheetId" : "Таблица не создана!";
      });
      if (spreadsheetId != null) {
        await sheetsUtil.exportToSheet(sheetsApi, response, competition, spreadsheetId);
        model.competition!.sheetId = response.spreadsheetId;
        model.competition!.sheetName = response.properties!.title;
        setState(() {
          _debugText = 'Данные успешно отправлены в новую таблицу ${competition.name}';
        });
      }
    }
    catch(e)
    {
        setState(() {
          _debugText = 'Ошибка: ${e.toString()}';
        });
    }
  }

  Future<void> _exportToSheetWithId(GoogleSignInAccount user, Competition competition, String id) async {
    setState(() {
      _debugText = 'Отправляем...';
    });
    try {
      model.authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);
      final authenticatedClient = model.authorization!.authClient(scopes: scopes);
      final sheetsApi = sheets.SheetsApi(authenticatedClient);
      
      sheets.Spreadsheet response = await sheetsApi.spreadsheets.get(id);
      if (response.sheets == null) {
        setState(() {
          _debugText = "Ошибка. Таблица c id='$id' не найдена!";
        });
      }
      else if (response.sheets!.length < 3) {
        setState(() {
          _debugText = "Ошибка. В таблице должно быть три листа или больше!";
        });
      }
      else if (response.sheets![0].properties == null || response.sheets![0].properties!.title != resultsSheetName) {
        setState(() {
          _debugText = "Ошибка. В таблице первый лист должен называться '$resultsSheetName'";
        });
      }
      else if (response.sheets![1].properties == null || response.sheets![1].properties!.title != pairsSheetName) {
        setState(() {
          _debugText = "Ошибка. В таблице второй лист должен называться '$pairsSheetName'";
        });
      }
      else if (response.sheets![2].properties == null || response.sheets![2].properties!.title != judgesSheetName) {
        setState(() {
          _debugText = "Ошибка. В таблице третий лист должен называться '$judgesSheetName'";
        });
      }
      else {
        setState(() {
          _debugText = "Таблица найдена, отправляем данные...";
        });
        
        final batchUpdateRequest = sheets.BatchUpdateSpreadsheetRequest(
          requests: [
            sheets.Request(
              unmergeCells: sheets.UnmergeCellsRequest(
                range: sheets.GridRange(
                  sheetId: response.sheets![0].properties!.sheetId,
                  // Если вы хотите разгруппировать вообще все ячейки на листе:
                  startRowIndex: 0,
                  endRowIndex: 1000, 
                  startColumnIndex: 0,
                  endColumnIndex: 26,
                ),
              ),
            ),
          ],
        );

        await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, id);
        await sheetsApi.spreadsheets.values.clear(sheets.ClearValuesRequest(), id, '${response.sheets![0].properties!.title}!A1:z');
        await sheetsApi.spreadsheets.values.clear(sheets.ClearValuesRequest(), id, '${response.sheets![1].properties!.title}!A1:z');
        await sheetsApi.spreadsheets.values.clear(sheets.ClearValuesRequest(), id, '${response.sheets![2].properties!.title}!A1:z');
        await sheetsUtil.exportToSheet(sheetsApi, response, competition, id);
        model.competition!.sheetId = id;
        model.competition!.sheetName = response.properties!.title;
        setState(() {
          _debugText = "Таблица сохранена.";
        });
      }
    }
    catch (e)
    {
      setState(() {
        _debugText = "Ошибка при экспорте: ${e.toString()}";
      });
    }
  }

  Future<void> _importFromSheetWithId(GoogleSignInAccount user, String id) async {
    setState(() {
      _debugText = 'Загрузка гуглотаблицы...';
    });
    try{
      model.authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);
      final authenticatedClient = model.authorization!.authClient(scopes: scopes);
      final sheetsApi = sheets.SheetsApi(authenticatedClient);
      
      sheets.Spreadsheet response = await sheetsApi.spreadsheets.get(id, includeGridData: true);
      if (response.sheets == null) {
        setState(() {
          _debugText = "Ошибка. Таблица c id='$id' не найдена!";
        });
      }
      else if (response.sheets!.isEmpty) {
        setState(() {
          _debugText = "Ошибка. В таблице должен быть хотя бы один лист!";
        });
      }
      else {
        await model.createFromTemplate();
        model.competition!.name = response.properties!.title ?? "(no name)";
        sheets.Sheet? sheet = response.sheets?.firstWhereOrNull((s) => s.properties != null && s.properties!.title == pairsSheetName);
        sheet ??= response.sheets![0];
        await sheetsUtil.importPairsFromSheet(sheet, model.competition!);

        sheet = response.sheets?.firstWhereOrNull((s) => s.properties != null && s.properties!.title == judgesSheetName);
        if (sheet != null) {
          await sheetsUtil.importJudgesFromSheet(sheet, model.competition!);
        }

        sheet = response.sheets?.firstWhereOrNull((s) => s.properties != null && s.properties!.title == resultsSheetName);
        if (sheet != null && model.competition!.marksList.blocks.isNotEmpty) {
          await sheetsUtil.importResultsFromSheet(sheet, model.competition!);
        }

        model.competition!.sheetId = response.spreadsheetId;
        model.competition!.sheetName = response.properties!.title;
        setState(() {
          _debugText = "Загружено.";
        });
      }
    }
    catch (e){
        setState(() {
          _debugText = "Ошибка: ${e.toString()}";
        });
    }
  }

  // Prompts the user to authorize `scopes`.
  //
  // If authorizationRequiresUserInteraction() is true, this must be called from
  // a user interaction (button click). In this example app, a button is used
  // regardless, so authorizationRequiresUserInteraction() is not checked.
  Future<void> _handleAuthorizeScopes(GoogleSignInAccount user) async {
    try {
      model.authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);

      final Map<String, String>? headers = await user.authorizationClient
        .authorizationHeaders(scopes);
      if (headers == null) {
        setState(() {
          _debugText = '';
          _errorMessage = 'Даны не все разрешения!';
        });
      }
      else {
        setState(() {
          model.isAuthorized = true;
          _errorMessage = '';
          _debugText = '';
        });
        onReady(model.currentUser!);
      }
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
    }
  }

  Future<void> _handleSignOut() async {
    // Disconnect instead of just signing out, to reset the example state as
    // much as possible.
    await GoogleSignIn.instance.disconnect();
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = model.currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        if (user != null)
          ..._buildAuthenticatedWidgets(user)
        else
          ..._buildUnauthenticatedWidgets(),
        if (_errorMessage.isNotEmpty) Text(_errorMessage),
      ],
    );
  }

  /// Returns the list of widgets to include if the user is authenticated.
  List<Widget> _buildAuthenticatedWidgets(GoogleSignInAccount user) {
    return <Widget>[
      // The user is Authenticated.
        /*Column(
          children: [
          ListTile(
            leading: GoogleUserCircleAvatar(identity: user),
            title: Text(user.displayName ?? ''),
            subtitle: Text(user.email),
          ),
          ElevatedButton(onPressed: _handleSignOut, child: const Text('Выйти из Google аккаунта')),
        ]
      ),*/
      //const Text('Авторизация успешна.'),
      if (model.isAuthorized) ...<Widget>[
        // The user has Authorized all required scopes.
        Container(
          margin: EdgeInsetsDirectional.only( top: 20),
          child: Column(
            children: [
              /*if (_sheets == null)
              ElevatedButton(
                child: const Text('Сохранить в существующую таблицу...'),
                onPressed: () => _handleGetSheets(user),
              ),*/
              if (_sheets != null)
              Text(widget.isImport ? "Выберите из какой таблицы считать" : "Выберите в какую таблицу сохранить"),
              if (_sheets != null)
              for (var file in _sheets!.sublist(0, min(3, _sheets!.length)))
              ...<Widget>[
                if (widget.isImport)
                ElevatedButton(
                  child: Text('\'${file.name}\''),
                  onPressed: () => _importFromSheetWithId(user, file.id!),
                ),
                if (!widget.isImport)
                ElevatedButton(
                  child: Text('\'${file.name}\''),
                  onPressed: () => _exportToSheetWithId(user, widget.model.competition!, file.id!),
                ),
              ]
            ],
          ),
        ),
        if (_debugText.isNotEmpty) Text(_debugText, textAlign: .center),
      ] else ...<Widget>[
        // The user has NOT Authorized all required scopes.
        Column(
          spacing: 20,
          children: [
            Text('Приложению нужны разрешения на доступ к таблицам ${user.email} через Google Диск.', textAlign: .center,),
            ElevatedButton(
              onPressed: () => _handleAuthorizeScopes(user),
              child: const Text('Дать разрешения'),
            ),
          ]
        )
      ],
    ];
  }

  /// Returns the list of widgets to include if the user is not authenticated.
  List<Widget> _buildUnauthenticatedWidgets() {
    return <Widget>[
      Column(
        spacing: 20,
        children: [
          const Text('Необходима авторизация'),
          // #docregion ExplicitSignIn
          if (GoogleSignIn.instance.supportsAuthenticate())
            ElevatedButton(
              onPressed: () async {
                try {
                  await GoogleSignIn.instance.authenticate();
                } catch (e) {
                  // #enddocregion ExplicitSignIn
                  _errorMessage = e.toString();
                  // #docregion ExplicitSignIn
                }
              },
              child: const Text('Войти'),
            )
          else ...<Widget>[
            if (kIsWeb)
              web.renderButton()
            // #enddocregion ExplicitSignIn
            else
              const Text(
                'This platform does not have a known authentication method',
              ),
            // #docregion ExplicitSignIn
          ],
        ],
      ),
      // #enddocregion ExplicitSignIn
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google таблицы')),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }

  String _errorMessageFromSignInException(GoogleSignInException e) {
    // In practice, an application should likely have specific handling for most
    // or all of the, but for simplicity this just handles cancel, and reports
    // the rest as generic errors.
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in canceled,  ${e.code}: ${e.description}',
      _ => 'GoogleSignInException ${e.code}: ${e.description}',
    };
  }
}
