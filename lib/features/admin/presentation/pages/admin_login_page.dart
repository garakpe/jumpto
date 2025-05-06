import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';

import '../../../../core/presentation/theme/app_colors.dart';
import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

/// 관리자 로그인 페이지
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자 로그인'),
        backgroundColor: AppColors.primary,
      ),
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminAuthenticated) {
            // 관리자 인증 성공 시 대시보드로 이동
            print('관리자 인증 성공: ${state.admin.displayName}');
            
            // 1. AppRouter에 현재 사용자 설정
            AppRouter.setCurrentUser(state.admin);
            print('라우터에 사용자 정보 직접 설정 확인');
            
            // 2. 라우터 새로고침
            AppRouter.router.refresh();
            
            // 3. 네비게이션 지연 처리
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // 4. 대시보드로 이동
              print('대시보드로 이동 시도');
              context.go('/admin/dashboard');
            });
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

          // 로그인 폼
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 로고 또는 아이콘
                    const Icon(
                      Icons.admin_panel_settings,
                      size: 80,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 16),
                    
                    // 제목
                    const Text(
                      '온라인 팝스 관리자',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // 사용자명 입력
                    AppTextField(
                      controller: _usernameController,
                      label: '관리자 아이디',
                      hintText: '관리자 아이디를 입력하세요',
                      prefixIcon: const Icon(Icons.person),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '관리자 아이디를 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // 비밀번호 입력
                    AppTextField(
                      controller: _passwordController,
                      label: '비밀번호',
                      hintText: '비밀번호를 입력하세요',
                      prefixIcon: const Icon(Icons.lock),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력하세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 로그인 버튼
                    AppButton(
                      text: '로그인',
                      onPressed: _login,
                      width: double.infinity,
                    ),
                    const SizedBox(height: 16),
                    
                    // 돌아가기 버튼
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('돌아가기'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 로그인 처리
  void _login() {
    // 폼 유효성 검사
    if (_formKey.currentState?.validate() ?? false) {
      // 로그인 요청
      context.read<AdminCubit>().signInAdmin(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }
}