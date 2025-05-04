import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/teacher_settings_cubit.dart';
import '../widgets/attendance_tab.dart';
import '../widgets/evaluation_tab.dart';
import '../widgets/event_selection_tab.dart';
import '../widgets/reflection_tab.dart';
import '../widgets/result_view_tab.dart';

/// 교사 대시보드 페이지
///
/// 교사용 대시보드 화면으로, 탭 형식으로 다양한 기능을 제공합니다.
class TeacherDashboardPage extends StatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교사 대시보드'),
        actions: [
          // 콘텐츠 선택으로 돌아가기
          IconButton(
            icon: const Icon(Icons.apps),
            onPressed: () => context.go('/content-selection'),
          ),
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '종목 선택', icon: Icon(Icons.settings)),
            Tab(text: '출석부', icon: Icon(Icons.group)),
            Tab(text: '측정결과조회', icon: Icon(Icons.insert_chart)),
            Tab(text: '평가', icon: Icon(Icons.grading)),
            Tab(text: '되돌아보기', icon: Icon(Icons.rate_review)),
          ],
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingView();
          }
          
          if (state is AuthAuthenticated) {
            return TabBarView(
              controller: _tabController,
              children: const [
                EventSelectionTab(),
                AttendanceTab(),
                ResultViewTab(),
                EvaluationTab(),
                ReflectionTab(),
              ],
            );
          }
          
          // 인증되지 않은 경우 로그인 화면으로 리디렉션
          Future.microtask(() => context.go('/login'));
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget? _buildFloatingActionButton() {
    // 현재 탭에 따라 다른 FAB 표시
    if (_tabController.index == 0) {
      return FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('종목 설정 안내'),
              content: const Text(
                '이 설정은 학생들이 측정할 수 있는 종목을 제한합니다. '
                '각 체력요인별로 하나의 종목만 선택할 수 있으며, '
                '학생들은 선택된 종목만 측정할 수 있습니다.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            ),
          );
        },
        tooltip: '도움말',
        child: const Icon(Icons.help_outline),
      );
    }
    
    return null;
  }
}