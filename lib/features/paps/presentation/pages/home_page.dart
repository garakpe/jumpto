import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/loading_view.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../widgets/menu_card.dart';

/// 홈 화면
/// 
/// 로그인 후 표시되는 메인 화면으로, 사용자 유형(교사/학생)에 따라 다른 메뉴를 제공합니다.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('온라인 팝스'),
        actions: [
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
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
          
          // 메뉴 섹션
          Text(
            '팝스(PAPS) 메뉴',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          // 사용자 유형에 따른 메뉴 표시
          if (user.isTeacher)
            _buildTeacherMenus(context)
          else
            _buildStudentMenus(context),
        ],
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
  
  Widget _buildTeacherMenus(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // 측정 종목 선택 메뉴
        MenuCard(
          title: '측정 종목 선택',
          icon: Icons.fitness_center,
          color: Colors.orange,
          onTap: () => context.go('/teacher-event-selection'),
        ),
        // 팝스 기준표 조회 메뉴
        MenuCard(
          title: '팝스 기준표 조회',
          icon: Icons.table_chart,
          color: Colors.green,
          onTap: () => context.go('/paps-standards'),
        ),
        // 학생 기록 관리 메뉴
        MenuCard(
          title: '학생 기록 관리',
          icon: Icons.assignment,
          color: Colors.blue,
          onTap: () {
            // 학생 기록 관리 화면 구현 예정
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('학생 기록 관리 기능은 아직 구현 중입니다.')),
            );
          },
        ),
        // 보고서 생성 메뉴
        MenuCard(
          title: '보고서 생성',
          icon: Icons.bar_chart,
          color: Colors.purple,
          onTap: () {
            // 보고서 생성 화면 구현 예정
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('보고서 생성 기능은 아직 구현 중입니다.')),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildStudentMenus(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        // 팝스 측정 메뉴
        MenuCard(
          title: '팝스 측정',
          icon: Icons.fitness_center,
          color: Colors.orange,
          onTap: () => context.go('/paps-measurement'),
        ),
        // 팝스 기준표 조회 메뉴
        MenuCard(
          title: '팝스 기준표 조회',
          icon: Icons.table_chart,
          color: Colors.green,
          onTap: () => context.go('/paps-standards'),
        ),
        // 내 기록 조회 메뉴
        MenuCard(
          title: '내 기록 조회',
          icon: Icons.assignment,
          color: Colors.blue,
          onTap: () {
            // 내 기록 조회 화면 구현 예정
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('내 기록 조회 기능은 아직 구현 중입니다.')),
            );
          },
        ),
        // 결과 분석 메뉴
        MenuCard(
          title: '결과 분석',
          icon: Icons.bar_chart,
          color: Colors.purple,
          onTap: () {
            // 결과 분석 화면 구현 예정
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('결과 분석 기능은 아직 구현 중입니다.')),
            );
          },
        ),
      ],
    );
  }
}
