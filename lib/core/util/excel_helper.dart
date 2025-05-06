import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

class ExcelHelper {
  /// 학생 업로드용 엑셀 템플릿 생성
  static Uint8List createStudentExcelTemplate() {
    // 엑셀 객체 생성
    final excel = Excel.createExcel();

    // 기본 시트 이름 가져오기
    final defaultSheetName = excel.getDefaultSheet()!;
    final sheet = excel.sheets[defaultSheetName]!;

    // 시트 이름 변경
    excel.rename(defaultSheetName, '학생명단');

    // 헤더 스타일 정의
    final headerStyle = CellStyle(
      bold: true,
      horizontalAlign: HorizontalAlign.Center,
    );

    // 헤더 추가
    final headers = ['학년', '반', '번호', '이름', '초기비밀번호(선택)'];

    // 헤더 추가 및 스타일 적용
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // 샘플 데이터 추가 - 첫 번째 행
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 1))
        .value = TextCellValue('김민준');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 1))
        .value = TextCellValue('1234');

    // 샘플 데이터 추가 - 두 번째 행
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 2))
        .value = TextCellValue('2');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 2))
        .value = TextCellValue('이서연');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 2))
        .value = TextCellValue('1234');

    // 샘플 데이터 추가 - 세 번째 행
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 3))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3))
        .value = TextCellValue('2');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 3))
        .value = TextCellValue('1');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 3))
        .value = TextCellValue('박지원');
    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 3))
        .value = TextCellValue('1234');

    // 열 너비 설정
    sheet.setColumnWidth(0, 12.0); // 학년
    sheet.setColumnWidth(1, 12.0); // 반
    sheet.setColumnWidth(2, 12.0); // 번호
    sheet.setColumnWidth(3, 20.0); // 이름
    sheet.setColumnWidth(4, 25.0); // 초기비밀번호

    // 엑셀 파일을 바이트 배열로 변환
    final fileBytes = excel.encode();
    if (fileBytes == null) {
      throw Exception('엑셀 파일 생성에 실패했습니다.');
    }

    return Uint8List.fromList(fileBytes);
  }

  /// 웹에서 파일 다운로드 실행
  static void downloadForWeb(Uint8List bytes, String fileName) {
    // Blob 생성
    final blob = html.Blob([bytes]);

    // URL 생성
    final url = html.Url.createObjectUrlFromBlob(blob);

    // 앵커 엘리먼트 생성 및 설정
    final anchor =
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..style.display = 'none';

    // 문서에 추가
    html.document.body?.children.add(anchor);

    // 클릭 이벤트 발생시켜 다운로드
    anchor.click();

    // 앵커 제거
    html.document.body?.children.remove(anchor);

    // URL 해제
    html.Url.revokeObjectUrl(url);
  }
}
