import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/theme/app_colors.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

/// 관리자 대시보드 페이지
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  @override
  void initState() {
    super.initState();

    // 페이지 로드 시 승인 대기 중인 교사 목록 조회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminCubit>().getPendingTeachers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 대시보드'),
        backgroundColor: AppColors.primary,
        actions: [
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutConfirmDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminInitial) {
            // 로그아웃 성공 시 로그인 페이지로 이동
            context.go('/admin/login');
          } else if (state is TeacherApproved) {
            // 교사 승인 성공 시 스낵바 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('교사 승인이 완료되었습니다.'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is TeacherRejected) {
            // 교사 거부 성공 시 스낵바 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('교사 계정이 거부/삭제되었습니다.'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AdminError) {
            // 오류 발생 시 스낵바 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // 로딩 상태 처리
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 교사 목록 상태 처리
          if (state is TeachersLoaded) {
            final pendingTeachers =
                state.teachers.where((teacher) => !teacher.isApproved).toList();

            if (pendingTeachers.isEmpty) {
              return _buildEmptyState();
            }

            return _buildTeachersList(pendingTeachers);
          }

          // 기본 상태
          return _buildEmptyState();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 승인 대기 중인 교사 목록 새로고침
          context.read<AdminCubit>().getPendingTeachers();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            '승인 대기 중인 교사가 없습니다.',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // 모든 교사 목록 조회
              context.read<AdminCubit>().getAllTeachers();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('모든 교사 보기'),
          ),
        ],
      ),
    );
  }

  /// 교사 목록 위젯
  Widget _buildTeachersList(List<User> teachers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '승인 대기 중인 교사: ${teachers.length}명',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  // 모든 교사 목록 조회
                  context.read<AdminCubit>().getAllTeachers();
                },
                child: const Text('모든 교사 보기'),
              ),
            ],
          ),
        ),

        // 목록
        Expanded(
          child: ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  title: Text(
                    teacher.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('이메일: ${teacher.email ?? "없음"}'),
                      Text('학교: ${teacher.schoolCode ?? "없음"}'),
                      Text('연락처: ${teacher.phoneNumber ?? "없음"}'),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 승인 버튼
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          _showApproveConfirmDialog(context, teacher);
                        },
                      ),
                      // 거부 버튼
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          _showRejectConfirmDialog(context, teacher);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 로그아웃 확인 다이얼로그
  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('로그아웃'),
            content: const Text('정말 로그아웃하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminCubit>().signOut();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }

  /// 교사 승인 확인 다이얼로그
  void _showApproveConfirmDialog(BuildContext context, User teacher) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('교사 승인'),
            content: Text('${teacher.displayName} 교사를 승인하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminCubit>().approveTeacher(teacher.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.green),
                child: const Text('승인'),
              ),
            ],
          ),
    );
  }

  /// 교사 거부 확인 다이얼로그
  void _showRejectConfirmDialog(BuildContext context, User teacher) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('교사 거부'),
            content: Text('${teacher.displayName} 교사 계정을 거부/삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<AdminCubit>().rejectTeacher(teacher.id);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('거부/삭제'),
              ),
            ],
          ),
    );
  }
}
