import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;

class SimpleExcelHelper {
  /// 가장 단순한 학생 엑셀 템플릿 생성
  static Uint8List createBasicStudentExcelTemplate() {
    // 엑셀 객체 생성 - 생성시 파일명 제거
    final excel = Excel.createExcel(); // null을 넘겨서 기본 파일명 제거
    final sheet = excel['Sheet1'];

    // 헤더 추가 - 가장 단순한 방식으로
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('학년');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('반');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('번호');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('이름');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('초기비밀번호');

    // 샘플 데이터 추가
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('1');
    sheet.cell(CellIndex.indexByString('B2')).value = TextCellValue('1');
    sheet.cell(CellIndex.indexByString('C2')).value = TextCellValue('1');
    sheet.cell(CellIndex.indexByString('D2')).value = TextCellValue('김민준');
    sheet.cell(CellIndex.indexByString('E2')).value = TextCellValue('1234');

    // 열 너비 설정 - 간단한 방식
    sheet.setColumnWidth(0, 15);
    sheet.setColumnWidth(1, 15);
    sheet.setColumnWidth(2, 15);
    sheet.setColumnWidth(3, 20);
    sheet.setColumnWidth(4, 20);

    // 엑셀 파일을 바이트 배열로 변환
    final List<int>? fileBytes = excel.encode();
    if (fileBytes == null) {
      throw Exception('엑셀 파일 생성에 실패했습니다.');
    }

    return Uint8List.fromList(fileBytes);
  }

  /// 웹에서 파일 다운로드 실행
  static void downloadFileForWeb(Uint8List bytes, String fileName) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

    html.document.body!.append(anchor);
    anchor.click();

    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
