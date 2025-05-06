import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/loading_view.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/account_dropdown.dart';
import '../widgets/content_card.dart';

/// 콘텐츠 선택 화면
///
/// 로그인 후 표시되는 콘텐츠 선택 화면으로, 사용자가 이용할 콘텐츠를 선택할 수 있습니다.
class ContentSelectionPage extends StatelessWidget {
  const ContentSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('콘텐츠 선택'),
        actions: [
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                // 계정 드롭다운 메뉴
                return AccountDropdown(user: state.user);
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingView();
          }
          
          if (state is AuthAuthenticated) {
            return _buildContent(context, state.user);
          }
          
          // 인증되지 않은 경우 로그인 화면으로 리디렉션
          Future.microtask(() => context.go('/login'));
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  Widget _buildContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 환영 메시지
          _buildWelcomeSection(context, user),
          const SizedBox(height: 24),
          
          // 교사인 경우 학생 업로드 버튼 표시
          if (user.isTeacher) 
            _buildStudentUploadSection(context),
          const SizedBox(height: 24),
          
          // 콘텐츠 선택 섹션
          Text(
            '사용할 콘텐츠 선택',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // 콘텐츠 카드 목록
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // 온라인 팝스 콘텐츠
              ContentCard(
                title: '온라인 팝스',
                description: '학생건강체력평가(PAPS) 교육 및 측정',
                icon: Icons.fitness_center,
                color: Colors.orange,
                onTap: () {
                  // 교사인 경우 교사 대시보드로, 학생인 경우 홈 화면으로 이동
                  if (user.isTeacher) {
                    context.go('/teacher-dashboard');
                  } else {
                    context.go('/home');
                  }
                },
              ),
              // 줄넘기 학습 관리 콘텐츠 (현재는 비활성화)
              ContentCard(
                title: '줄넘기 학습 관리',
                description: '현재 준비 중입니다',
                icon: Icons.sports,
                color: Colors.blue.withOpacity(0.5),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('줄넘기 학습 관리 콘텐츠는 준비 중입니다.')),
                  );
                },
                isDisabled: true,
              ),
              // 추가 콘텐츠를 위한 공간 (현재는 빈 카드로 표시)
              ContentCard(
                title: '향후 추가 예정',
                description: '준비 중입니다',
                icon: Icons.more_horiz,
                color: Colors.grey.withOpacity(0.3),
                onTap: () {},
                isDisabled: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // 학생 업로드 섹션
  Widget _buildStudentUploadSection(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '학생 관리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '학생 명단을 관리하고 업로드할 수 있습니다.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('학생 명단 업로드'),
                onPressed: () {
                  context.go('/student-upload');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWelcomeSection(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(
                user.isTeacher ? Icons.person : Icons.school,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.displayName}님, 환영합니다!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.isTeacher ? '교사' : '학생',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}