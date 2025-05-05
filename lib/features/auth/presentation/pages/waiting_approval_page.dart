import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/theme/app_colors.dart';
import '../cubit/auth_cubit.dart';

/// 교사 계정 승인 대기 화면
class WaitingApprovalPage extends StatelessWidget {
  const WaitingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('승인 대기 중'),
        backgroundColor: AppColors.primary,
        actions: [
          // 로그아웃 버튼
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutConfirmDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthInitial) {
            // 로그아웃 성공 시 로그인 화면으로 이동
            context.go('/login');
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 대기 상태 아이콘
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.hourglass_top,
                      size: 72,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 제목
                  const Text(
                    '관리자 승인 대기 중',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 설명
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '귀하의 계정이 아직 관리자에 의해 승인되지 않았습니다.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '승인이 완료되면 이용하실 수 있습니다. 승인에는 최대 24시간이 소요될 수 있습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 새로고침 버튼
                  ElevatedButton.icon(
                    onPressed: () {
                      // 현재 사용자 정보 다시 로드
                      context.read<AuthCubit>().checkCurrentUser();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('새로고침'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 로그아웃 버튼
                  TextButton.icon(
                    onPressed: () => _showLogoutConfirmDialog(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('로그아웃'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
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
                  context.read<AuthCubit>().signOut();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('로그아웃'),
              ),
            ],
          ),
    );
  }
}
