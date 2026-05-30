import 'package:freestyle_calculator/Data/judge.dart';
import 'package:freestyle_calculator/Data/mark_list.dart';
import 'package:freestyle_calculator/Data/pair_data.dart';
import 'package:googleapis/sheets/v4.dart' as sheets;
import 'package:freestyle_calculator/Data/competition.dart';

class SheetsUtil {

  Future<void> importPairsFromSheet(sheets.Sheet sheet, Competition competition) async {
    competition.pairs.clear();
    var rowDatas = sheet.data!.first.rowData!;
    for (var rowData in rowDatas)
    {
      var rowValues = rowData.values;
      if (rowValues != null) {
        var numStr = rowValues[0].formattedValue;
        if (numStr == null || numStr.isEmpty) continue;
        int? num = int.tryParse(numStr);
        if (num != null)
        {
          var pair = Pair(num);
          pair.classKind = ClassKind.parse(rowValues[1].formattedValue ?? "");
          pair.handlerName = rowValues[2].formattedValue ?? "";
          pair.dogBreed = rowValues[3].formattedValue ?? "";
          pair.dogName = rowValues[4].formattedValue ?? "";
          pair.handlerName = rowValues[2].formattedValue ?? "";
          competition.pairs.add(pair);
        }
      }
    }
  }

  Future<void> importJudgesFromSheet(sheets.Sheet sheet, Competition competition) async {
    competition.judges.clear();
    var rowDatas = sheet.data!.first.rowData!;
    for (var rowData in rowDatas)
    {
      var rowValues = rowData.values;
      if (rowValues != null) {
        var numStr = rowValues[0].formattedValue;
        if (numStr == null || numStr.isEmpty) continue;
        int? num = int.tryParse(numStr);
        if (num != null)
        {
          var judge = Judge();
          judge.name = rowValues[1].formattedValue ?? "";
          competition.judges.add(judge);
        }
      }
    }
  }

  Future<void> importResultsFromSheet(sheets.Sheet sheet, Competition competition) async {
    var rowDatas = sheet.data!.first.rowData!;
    for (var (index, rowData) in rowDatas.indexed)
    {
      var rowValues = rowData.values;
      if (rowValues != null) {
        var numStr = rowValues[0].formattedValue;
        if (numStr == null || numStr.isEmpty) continue;
        int? num = int.tryParse(numStr);
        if (num != null)
        {
          var pair = competition.pairs.firstWhere((p) => p.startNumber == num);
          pair.prepareMarks(competition);
          for (var (j, judge) in competition.judges.indexed) {
            var rowDataJ = rowDatas[index + j];
            var rowValuesJ = rowDataJ.values;
            if (rowValuesJ != null) {
              int i = 6; // столбец G
              for (var (b, block) in competition.marksList.blocks.indexed) {
                for (var (l, line) in block.lines.indexed) {
                  var markStr = rowValuesJ[i].formattedValue ?? "";
                  var mark = Mark.fromJson(markStr);
                  pair.judgesMarks[j].blocks[b].marks[l] = mark;
                  i++;
                }
                pair.judgesMarks[j].blocks[b].updateSum(block);
                i++;
              }
              pair.judgesMarks[j].updateSum();
            }
            pair.updateSum();
          }
        }
      }
    }
  }

  Future<void> exportToSheet(sheets.SheetsApi sheetsApi, sheets.Spreadsheet spreadsheet, Competition competition, String spreadsheetId) async {
    for (var pair in competition.pairs) {
      pair.prepareMarks(competition);
    }
    var line0 = ["№", "Класс", "Проводник", "Порода", "Кличка", "Судья"];
    for (var block in competition.marksList.blocks) {
      for (var (l, _) in block.lines.indexed) {
        line0.add(l == 0 ? block.name : "");
      }
      line0.add("");
    }
    line0.addAll(["Сумма", "Среднее", "Место"]);
    var line1 = ["", "", "", "", "", ""];
    for (var block in competition.marksList.blocks) {
      for (var line in block.lines) {
        line1.add(line.name);
      }
      line1.add("Σ");
    }
    line1.addAll(["", "", ""]);
    var line2 = ["", "", "", "", "", ""];
    for (var block in competition.marksList.blocks) {
      for (var line in block.lines) {
        line2.add(line.maxValue.toString());
      }
      line2.add("");
    }
    line2.addAll(["", "", ""]);
    var lines = [
        line0,
        line1,
        line2];
    for (var pair in competition.pairs) {
      for (var (j, judge) in competition.judges.indexed) {
        var line = [pair.startNumber.toString(), pair.classKind.toUserString(), pair.handlerName, pair.dogBreed, pair.dogName];
        line.add(judge.name);
        for (var (b, block) in competition.marksList.blocks.indexed) {
          for (var (l, _) in block.lines.indexed) {
            line.add(pair.judgesMarks[j].blocks[b].marks[l].markValue?.toString() ?? "");
          }
          line.add(pair.judgesMarks[j].blocks[b].sum.toString());
        }
        line.add(pair.judgesMarks[j].sum.toString());
        if (j == 0) { 
          line.add(pair.meanSum.toStringAsFixed(2)); 
          line.add(pair.place?.toString() ?? ""); 
        }
        else { line.add(""); line.add(""); }
        lines.add(line);
      }
    }
    var resultsRange = sheets.ValueRange.fromJson({
      "values": lines
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
      resultsRange, 
      spreadsheetId, 
      '${spreadsheet.sheets![0].properties!.title}!A1', 
      valueInputOption: 'USER_ENTERED'
    );
    final sheetId = spreadsheet.sheets![0].properties!.sheetId;
    final List<sheets.Request> mergeRequests = [];
    mergeRequests.add(sheets.Request(
      mergeCells: sheets.MergeCellsRequest(
        range: sheets.GridRange(
          sheetId: sheetId,
          startRowIndex: 0,
          startColumnIndex: 0,
          endRowIndex: 3,
          endColumnIndex: 6,
        ),
        mergeType: 'MERGE_COLUMNS',
      ),
    ));
    var columnIndex = 6;
    for (var block in competition.marksList.blocks) {
      mergeRequests.add(sheets.Request(
        mergeCells: sheets.MergeCellsRequest(
          range: sheets.GridRange(
            sheetId: sheetId,
            startRowIndex: 0,
            startColumnIndex: columnIndex,
            endRowIndex: 1,
            endColumnIndex: columnIndex + block.lines.length + 1,
          ),
          mergeType: 'MERGE_ALL',
        ),
      ));
      columnIndex += block.lines.length + 1;
    }
    var rowIndex = 3;
    for (var _ in competition.pairs) {
      mergeRequests.add(sheets.Request(
        mergeCells: sheets.MergeCellsRequest(
          range: sheets.GridRange(
            sheetId: sheetId,
            startRowIndex: rowIndex,
            startColumnIndex: 0,
            endRowIndex: rowIndex + competition.judges.length,
            endColumnIndex: 5,
          ),
          mergeType: 'MERGE_COLUMNS',
        ),
      ));
      mergeRequests.add(sheets.Request(
        mergeCells: sheets.MergeCellsRequest(
          range: sheets.GridRange(
            sheetId: sheetId,
            startRowIndex: rowIndex,
            startColumnIndex: columnIndex + 1,
            endRowIndex: rowIndex + competition.judges.length,
            endColumnIndex: columnIndex + 3,
          ),
          mergeType: 'MERGE_COLUMNS',
        ),
      ));
      rowIndex += competition.judges.length;
    }
    mergeRequests.add(sheets.Request(
      mergeCells: sheets.MergeCellsRequest(
        range: sheets.GridRange(
          sheetId: sheetId,
          startRowIndex: 0,
          startColumnIndex: columnIndex,
          endRowIndex: 3,
          endColumnIndex: columnIndex + 3,
        ),
        mergeType: 'MERGE_COLUMNS',
      ),
    ));
    final batchUpdateRequest = sheets.BatchUpdateSpreadsheetRequest(
      requests: mergeRequests,
    );
    await sheetsApi.spreadsheets.batchUpdate(batchUpdateRequest, spreadsheetId);

    await sheetsApi.spreadsheets.values.append(
      pairsRange, 
      spreadsheetId, 
      '${spreadsheet.sheets![1].properties!.title}!A1', 
      valueInputOption: 'USER_ENTERED'
    );
    await sheetsApi.spreadsheets.values.append(
      judgesRange, 
      spreadsheetId, 
      '${spreadsheet.sheets![2].properties!.title}!A1', 
      valueInputOption: 'USER_ENTERED'
    );
  }

}