import 'package:flutter/material.dart';

import '../../domain/entities/index.dart';

/// 교사용 측정 종목 선택 화면
///
/// 교사가 각 체력요인별로 측정 종목을 선택할 수 있는 화면입니다.
class TeacherEventSelectionPage extends StatefulWidget {
  const TeacherEventSelectionPage({super.key});

  @override
  State<TeacherEventSelectionPage> createState() => _TeacherEventSelectionPageState();
}

class _TeacherEventSelectionPageState extends State<TeacherEventSelectionPage> {
  // 선택된 종목 맵
  final Map<FitnessFactor, String> _selectedEvents = {};
  
  @override
  void initState() {
    super.initState();
    _initSelectedEvents();
  }
  
  // 초기 선택 종목 설정
  void _initSelectedEvents() {
    // 각 체력요인별 기본 종목 설정
    _selectedEvents[FitnessFactor.cardioEndurance] = '왕복오래달리기';
    _selectedEvents[FitnessFactor.flexibility] = '앉아윗몸앞으로굽히기';
    _selectedEvents[FitnessFactor.muscularStrength] = '윗몸말아올리기';
    _selectedEvents[FitnessFactor.power] = '50m달리기';
    _selectedEvents[FitnessFactor.bmi] = '체질량지수';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('측정 종목 선택'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목 및 설명
            Text(
              '팝스 측정 종목 선택',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '각 체력요인별로 측정할 종목을 선택해주세요. 학생들은 선택된 종목으로만 측정을 진행할 수 있습니다.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // 체력요인별 종목 선택 카드
            ...FitnessFactor.values.map((factor) => _buildFactorCard(context, factor)).toList(),
            
            // 저장 버튼
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSelectedEvents,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFactorCard(BuildContext context, FitnessFactor factor) {
    // 해당 체력요인의 종목 목록
    final events = Event.findByFitnessFactor(factor);
    final eventNames = events.map((e) => e.koreanName).toList();
    
    // 선택된 종목
    final selectedEvent = _selectedEvents[factor] ?? eventNames.first;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 체력요인 제목
            Row(
              children: [
                _getFactorIcon(factor),
                const SizedBox(width: 12),
                Text(
                  factor.koreanName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 24),
            
            // 종목 선택 드롭다운
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '측정 종목',
                border: OutlineInputBorder(),
              ),
              value: selectedEvent,
              items: eventNames.map((eventName) {
                return DropdownMenuItem<String>(
                  value: eventName,
                  child: Text(eventName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedEvents[factor] = value;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // 체력요인별 아이콘
  Widget _getFactorIcon(FitnessFactor factor) {
    IconData iconData;
    Color iconColor;
    
    switch (factor) {
      case FitnessFactor.cardioEndurance:
        iconData = Icons.directions_run;
        iconColor = Colors.blue;
        break;
      case FitnessFactor.flexibility:
        iconData = Icons.accessibility_new;
        iconColor = Colors.green;
        break;
      case FitnessFactor.muscularStrength:
        iconData = Icons.fitness_center;
        iconColor = Colors.red;
        break;
      case FitnessFactor.power:
        iconData = Icons.flash_on;
        iconColor = Colors.orange;
        break;
      case FitnessFactor.bmi:
        iconData = Icons.monitor_weight;
        iconColor = Colors.purple;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
  
  // 선택된 종목 저장
  void _saveSelectedEvents() {
    // 저장 성공 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('측정 종목이 저장되었습니다.'),
        backgroundColor: Colors.green,
      ),
    );
    
    // 선택 결과 출력
    print('선택된 종목:');
    _selectedEvents.forEach((factor, eventName) {
      print('${factor.koreanName}: $eventName');
    });
    
    // 홈 화면으로 이동
    Navigator.pop(context);
  }
}
