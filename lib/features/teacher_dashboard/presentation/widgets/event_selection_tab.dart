import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/domain/entities/user.dart';
import '../../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../../features/paps/domain/entities/index.dart';
import '../cubit/teacher_settings_cubit.dart';
import '../cubit/teacher_settings_state.dart';

/// 종목 선택 탭
///
/// 교사가 각 체력요인별로 측정 종목을 선택할 수 있는 탭입니다.
class EventSelectionTab extends StatelessWidget {
  const EventSelectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return _buildContent(context, authState.user);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildContent(BuildContext context, User user) {
    return BlocBuilder<TeacherSettingsCubit, TeacherSettingsState>(
      builder: (context, state) {
        if (state is TeacherSettingsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TeacherSettingsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TeacherSettingsCubit>().loadSettings(user.id);
                  },
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          );
        } else if (state is TeacherSettingsLoaded || state is TeacherSettingsSaved) {
          final settings = state is TeacherSettingsLoaded
              ? (state as TeacherSettingsLoaded).settings
              : (state as TeacherSettingsSaved).settings;
          
          return _buildSettingsForm(context, user, settings.selectedEvents);
        } else {
          // 초기 상태인 경우 설정 로드
          Future.microtask(() {
            context.read<TeacherSettingsCubit>().loadSettings(user.id);
          });
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSettingsForm(
    BuildContext context,
    User user,
    Map<FitnessFactor, String> selectedEvents,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          ...FitnessFactor.values.map((factor) {
            return _buildFactorCard(
              context,
              factor,
              selectedEvents[factor] ?? '왕복오래달리기',
              user.id,
            );
          }).toList(),
          
          // 저장 버튼
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('측정 종목이 저장되었습니다.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('저장하기'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorCard(
    BuildContext context,
    FitnessFactor factor,
    String selectedEvent,
    String teacherId,
  ) {
    // 해당 체력요인의 종목 목록
    final events = Event.findByFitnessFactor(factor);
    final eventNames = events.map((e) => e.koreanName).toList();
    
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
                  context.read<TeacherSettingsCubit>().updateSelectedEvent(
                    teacherId,
                    factor,
                    value,
                  );
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
}