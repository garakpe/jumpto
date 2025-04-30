import 'package:flutter/material.dart';

import '../../domain/entities/grade_range.dart';

/// 등급 범위 테이블 위젯
///
/// 팝스 기준표의 등급, 점수, 범위를 표 형태로 표시합니다.
class GradeRangeTable extends StatelessWidget {
  final List<GradeRange> gradeRanges;
  
  const GradeRangeTable({
    super.key,
    required this.gradeRanges,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Table(
            border: TableBorder.all(
              color: Colors.grey.shade300,
              width: 1,
            ),
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // 테이블 헤더
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
                children: [
                  _buildHeaderCell(context, '등급'),
                  _buildHeaderCell(context, '점수'),
                  _buildHeaderCell(context, '범위'),
                ],
              ),
              
              // 등급별 행
              ...gradeRanges.map((range) => _buildGradeRow(context, range)).toList(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  TableRow _buildGradeRow(BuildContext context, GradeRange range) {
    // 등급에 따른 배경색 설정
    Color backgroundColor = Colors.white;
    
    if (range.grade is int) {
      final intGrade = range.grade as int;
      switch (intGrade) {
        case 1:
          backgroundColor = Colors.blue.withOpacity(0.1);
          break;
        case 2:
          backgroundColor = Colors.green.withOpacity(0.1);
          break;
        case 3:
          backgroundColor = Colors.yellow.withOpacity(0.1);
          break;
        case 4:
          backgroundColor = Colors.orange.withOpacity(0.1);
          break;
        case 5:
          backgroundColor = Colors.red.withOpacity(0.1);
          break;
      }
    } else {
      // 비만 관련 등급인 경우
      if (range.grade == '고도비만' || range.grade == '경도비만') {
        backgroundColor = Colors.red.withOpacity(0.1);
      } else if (range.grade == '과체중') {
        backgroundColor = Colors.orange.withOpacity(0.1);
      } else if (range.grade == '정상') {
        backgroundColor = Colors.green.withOpacity(0.1);
      } else if (range.grade == '마름') {
        backgroundColor = Colors.blue.withOpacity(0.1);
      }
    }
    
    return TableRow(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      children: [
        // 등급 셀
        _buildCell(context, range.grade.toString()),
        
        // 점수 셀
        _buildCell(context, range.score.toString()),
        
        // 범위 셀
        _buildCell(
          context, 
          _formatRange(range.start, range.end),
        ),
      ],
    );
  }
  
  Widget _buildCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
        textAlign: TextAlign.center,
      ),
    );
  }
  
  // 범위 형식화
  String _formatRange(double start, double end) {
    if (start == 0 && end < 1) {
      // 음수 범위인 경우
      return '$end 이하';
    } else if (start > 0 && end > 100) {
      // 최대값이 매우 큰 경우
      return '$start 이상';
    }
    
    return '$start ~ $end';
  }
}
