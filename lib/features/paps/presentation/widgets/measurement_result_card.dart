import 'package:flutter/material.dart';

/// 측정 결과 카드 위젯
class MeasurementResultCard extends StatelessWidget {
  final int grade;
  final int score;
  final VoidCallback onSave;
  
  const MeasurementResultCard({
    super.key,
    required this.grade,
    required this.score,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 등급 표시
            _buildGradeIndicator(context),
            const SizedBox(height: 24),
            
            // 점수 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '획득 점수: $score점',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 피드백 메시지
            Text(
              _getFeedbackMessage(),
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save),
                label: const Text('기록 저장하기'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGradeIndicator(BuildContext context) {
    // 등급에 따른 색상 및 아이콘 설정
    Color gradeColor;
    IconData gradeIcon;
    String gradeText;
    
    switch (grade) {
      case 1:
        gradeColor = Colors.blue;
        gradeIcon = Icons.emoji_events;
        gradeText = '최우수';
        break;
      case 2:
        gradeColor = Colors.green;
        gradeIcon = Icons.thumb_up;
        gradeText = '우수';
        break;
      case 3:
        gradeColor = Colors.amber;
        gradeIcon = Icons.check_circle;
        gradeText = '보통';
        break;
      case 4:
        gradeColor = Colors.orange;
        gradeIcon = Icons.warning;
        gradeText = '부족';
        break;
      case 5:
        gradeColor = Colors.red;
        gradeIcon = Icons.error;
        gradeText = '매우 부족';
        break;
      default:
        gradeColor = Colors.grey;
        gradeIcon = Icons.help;
        gradeText = '알 수 없음';
    }
    
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: gradeColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              gradeIcon,
              size: 60,
              color: gradeColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '$grade등급 ($gradeText)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: gradeColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  String _getFeedbackMessage() {
    switch (grade) {
      case 1:
        return '매우 우수한 결과입니다! 현재 체력 수준을 잘 유지하세요.';
      case 2:
        return '좋은 결과입니다. 조금만 더 노력하면 최고 등급에 도달할 수 있어요!';
      case 3:
        return '보통 수준의 결과입니다. 꾸준한 운동으로 체력을 향상시켜 보세요.';
      case 4:
        return '체력 향상이 필요합니다. 규칙적인 운동 습관을 기르는 것이 좋아요.';
      case 5:
        return '체력 향상을 위한 노력이 필요합니다. 선생님과 상담하여 맞춤형 운동 계획을 세워보세요.';
      default:
        return '결과를 확인할 수 없습니다.';
    }
  }
}
