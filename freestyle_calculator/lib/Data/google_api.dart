import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freestyle_calculator/Data/competition.dart';
import 'package:freestyle_calculator/Data/model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
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
  const SignInDemo(this.model, {super.key});

  final Model model;

  @override
  State createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false; // has granted permissions?
  String _debugText = '';
  String _errorMessage = '';
  ///String _serverAuthCode = '';
  GoogleSignInClientAuthorization? _authorization;

  @override
  void initState() {
    super.initState();

    // #docregion Setup
    final GoogleSignIn signIn = GoogleSignIn.instance;
    unawaited(
      signIn.initialize(clientId: clientId, serverClientId: serverClientId).then((
        _,
      ) {
        signIn.authenticationEvents
            .listen(_handleAuthenticationEvent)
            .onError(_handleAuthenticationError);

        /// This example always uses the stream-based approach to determining
        /// which UI state to show, rather than using the future returned here,
        /// if any, to conditionally skip directly to the signed-in state.
        signIn.attemptLightweightAuthentication();
      }),
    );
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
    _authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);
    // #enddocregion CheckAuthorization

    setState(() {
      _currentUser = user;
      _isAuthorized = _authorization != null;
      _errorMessage = '';
    });

    // If the user has already granted access to the required scopes, call the
    // REST API.
    if (user != null && _authorization != null) {
      unawaited(_handleGetSheets(user));
    }
  }

  Future<void> _handleAuthenticationError(Object e) async {
    setState(() {
      _currentUser = null;
      _isAuthorized = false;
      _errorMessage = e is GoogleSignInException
          ? _errorMessageFromSignInException(e)
          : 'Unknown error: $e';
    });
  }

  // Calls the People API REST endpoint for the signed-in user to retrieve information.
  Future<void> _handleGetSheets(GoogleSignInAccount user) async {
    setState(() {
      _debugText = 'Loading drive info...';
    });
    final Map<String, String>? headers = await user.authorizationClient
        .authorizationHeaders(scopes);
    if (headers == null) {
      setState(() {
        _debugText = '';
        _isAuthorized = false;
        _errorMessage = 'Разрешения не даны или токен протух';
      });
      return;
    }
    final uri = Uri.https(
      'www.googleapis.com','drive/v3/files', 
      {
        'corpus': 'user', 
        'includeItemsFromAllDrives': 'true',
        'q' : 'mimeType = \'application/vnd.google-apps.spreadsheet\' and trashed = false',
        'supportsAllDrives': 'true'
      }
    );
    final http.Response response = await http.get(
      uri,
      headers: headers,
    );
    if (response.statusCode != 200) {
      if (response.statusCode == 401 || response.statusCode == 403) {
        setState(() {
          _isAuthorized = false;
          _errorMessage =
              'Сервер вернул ошибку ${response.statusCode} response. '
              'Требуется повторная авторизация.';
        });
      } else {
        //print('People API ${response.statusCode} response: ${response.body}');
        setState(() {
          _debugText =
              'Сервер вернул ошибку ${response.statusCode} '
              ': ${response.body}.';
        });
      }
      return;
    }
    final data = json.decode(response.body) as Map<String, dynamic>;
    final String? fileName = _pickFirstFile(data);
    setState(() {
      if (fileName != null) {
        _debugText = 'Последняя таблица: $fileName';
      } else {
        _debugText = 'No files to display.';
      }
    });
  }

  Future<void> _handleSaveToSheet(GoogleSignInAccount user, Competition competition) async {
    setState(() {
      _debugText = 'Отправляем...';
    });
    _authorization = await user
        .authorizationClient
        .authorizeScopes(scopes);
    final authenticatedClient = _authorization!.authClient(scopes: scopes);
    final sheetsApi = sheets.SheetsApi(authenticatedClient);
    
    var newSpreadsheet = sheets.Spreadsheet(
      properties: sheets.SpreadsheetProperties(title: competition.name),
      sheets: [
        sheets.Sheet(properties: sheets.SheetProperties(title: "Результаты")),
        sheets.Sheet(properties: sheets.SheetProperties(title: "Участники")),
        sheets.Sheet(properties: sheets.SheetProperties(title: "Судьи")),
      ]
    );
    sheets.Spreadsheet response = await sheetsApi.spreadsheets.create(newSpreadsheet);
    final spreadsheetId = response.spreadsheetId;
    setState(() {
      _debugText = spreadsheetId != null ? "Таблица создана: $spreadsheetId" : "Таблица не создана!";
    });
    
    var pairsRange = sheets.ValueRange.fromJson({
      "values": [
        ["№", "Класс", "Проводник", "порода", "Кличка"],
        for (var pair in competition.pairs)
          [pair.startNumber.toString(), pair.classKind.toUserString(), pair.handlerName, pair.dogBreed, pair.dogName]
      ]
    });
    var judgesRange = sheets.ValueRange.fromJson({
      "values": [
        ["№", "ФИО судьи"],
        for (var (index, judge) in competition.judges.indexed)
          [(index + 1).toString(), judge.name]
      ]
    });

    await sheetsApi.spreadsheets.values.append(
      pairsRange, 
      spreadsheetId!, 
      '${response.sheets![1].properties!.title}!A1', 
      valueInputOption: 'USER_ENTERED'
    );
    await sheetsApi.spreadsheets.values.append(
      judgesRange, 
      spreadsheetId, 
      '${response.sheets![2].properties!.title}!A1', 
      valueInputOption: 'USER_ENTERED'
    );
  
      setState(() {
      _debugText = 'Данные успешно отправлены в новую таблицу $spreadsheetId';
    });
  }

  String? _pickFirstFile(Map<String, dynamic> data) {
    final files = data['files'] as List<dynamic>?;
    final file =
        files?.firstWhere(
              (dynamic contact) =>
                  (contact as Map<Object?, dynamic>)['name'] != null,
              orElse: () => null,
            )
            as Map<String, dynamic>?;
    if (file != null) {
      final name = file['name'] as String;
      if (name.isNotEmpty) {
        return name;
      }
    }
    return null;
  }

  // Prompts the user to authorize `scopes`.
  //
  // If authorizationRequiresUserInteraction() is true, this must be called from
  // a user interaction (button click). In this example app, a button is used
  // regardless, so authorizationRequiresUserInteraction() is not checked.
  Future<void> _handleAuthorizeScopes(GoogleSignInAccount user) async {
    try {
      // #docregion RequestScopes
      _authorization = await user
          .authorizationClient
          .authorizeScopes(scopes);
      // #enddocregion RequestScopes

      // The returned tokens are ignored since _handleGetSheets uses the
      // authorizationHeaders method to re-read the token cached by
      // authorizeScopes. The code above is used as a README excerpt, so shows
      // the simpler pattern of getting the authorization for immediate use.
      // That results in an unused variable, which this statement suppresses
      // (without adding an ignore: directive to the README excerpt).
      // ignore: unnecessary_statements
      //_authorization;

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
          _isAuthorized = true;
          _errorMessage = '';
        });
        unawaited(_handleGetSheets(_currentUser!));
      }
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
    }
  }

/*
  // Requests a server auth code for the authorized scopes.
  //
  // If authorizationRequiresUserInteraction() is true, this must be called from
  // a user interaction (button click). In this example app, a button is used
  // regardless, so authorizationRequiresUserInteraction() is not checked.
  Future<void> _handleGetAuthCode(GoogleSignInAccount user) async {
    try {
      // #docregion RequestServerAuth
      final GoogleSignInServerAuthorization? serverAuth = await user
          .authorizationClient
          .authorizeServer(scopes);
      // #enddocregion RequestServerAuth

      setState(() {
        _serverAuthCode = serverAuth == null ? '' : serverAuth.serverAuthCode;
      });
    } on GoogleSignInException catch (e) {
      _errorMessage = _errorMessageFromSignInException(e);
    }
  }
*/  

  Future<void> _handleSignOut() async {
    // Disconnect instead of just signing out, to reset the example state as
    // much as possible.
    await GoogleSignIn.instance.disconnect();
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;
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
      ListTile(
        leading: GoogleUserCircleAvatar(identity: user),
        title: Text(user.displayName ?? ''),
        subtitle: Text(user.email),
      ),
      const Text('Авторизация успешна.'),
      if (_isAuthorized) ...<Widget>[
        // The user has Authorized all required scopes.
        if (_debugText.isNotEmpty) Text(_debugText, textAlign: .center),
        ElevatedButton(
          child: const Text('Обновить инфо о последней таблице'),
          onPressed: () => _handleGetSheets(user),
        ),
        if (widget.model.competition != null)
        ElevatedButton(
          child: const Text('Отправить в гуглотаблицу'),
          onPressed: () => _handleSaveToSheet(user, widget.model.competition!),
        ),
        /*if (_serverAuthCode.isEmpty)
          ElevatedButton(
            child: const Text('REQUEST SERVER CODE'),
            onPressed: () => _handleGetAuthCode(user),
          )
        else
          Text('Server auth code:\n$_serverAuthCode'),*/
      ] else ...<Widget>[
        // The user has NOT Authorized all required scopes.
        const Text('Приложению нужны разрешения на доступ к таблицам через Google Диск.', textAlign: .center,),
        ElevatedButton(
          onPressed: () => _handleAuthorizeScopes(user),
          child: const Text('Дать разрешения'),
        ),
      ],
      ElevatedButton(onPressed: _handleSignOut, child: const Text('Выйти из Google аккаунта')),
    ];
  }

  /// Returns the list of widgets to include if the user is not authenticated.
  List<Widget> _buildUnauthenticatedWidgets() {
    return <Widget>[
      const Text('Авторизация не пройдена.'),
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
      // #enddocregion ExplicitSignIn
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Войти через Google')),
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
