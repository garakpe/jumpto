import 'package:flutter/material.dart';

/// 평가 탭
///
/// 학생 평가를 위한 탭입니다. (기본 구조만 구현)
class EvaluationTab extends StatelessWidget {
  const EvaluationTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.grading,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            '평가 기능',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('이 기능은 현재 개발 중입니다.'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('이 기능은 아직 구현되지 않았습니다.')),
              );
            },
            child: const Text('개발 예정'),
          ),
        ],
      ),
    );
  }
}