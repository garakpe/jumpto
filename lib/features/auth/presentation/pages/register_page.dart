import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/loading_view.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_header.dart';

/// 회원가입 화면
///
/// 교사 계정 회원가입을 위한 화면입니다.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _schoolIdController = TextEditingController();
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _schoolIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('교사 회원가입'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // 회원가입 성공 시 콘텐츠 선택 화면으로 이동
            context.go('/content-selection');
          } else if (state is AuthError) {
            // 회원가입 실패 시 오류 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // 로딩 중일 때 로딩 화면 표시
          if (state is AuthLoading) {
            return const LoadingView(message: '회원가입 진행 중...');
          }
          
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 헤더
                    const LoginHeader(),
                    const SizedBox(height: 32),
                    
                    // 회원가입 폼
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            label: '이름',
                            hintText: '이름을 입력하세요',
                            controller: _nameController,
                            prefixIcon: const Icon(Icons.person),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이름을 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '이메일',
                            hintText: '이메일을 입력하세요',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '이메일을 입력해주세요';
                              }
                              if (!value.contains('@')) {
                                return '유효한 이메일 형식이 아닙니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '비밀번호',
                            hintText: '비밀번호를 입력하세요',
                            controller: _passwordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 입력해주세요';
                              }
                              if (value.length < 6) {
                                return '비밀번호는 6자 이상이어야 합니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '비밀번호 확인',
                            hintText: '비밀번호를 다시 입력하세요',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '비밀번호를 다시 입력해주세요';
                              }
                              if (value != _passwordController.text) {
                                return '비밀번호가 일치하지 않습니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '학교 코드 (선택)',
                            hintText: '학교 코드가 있다면 입력하세요',
                            controller: _schoolIdController,
                            prefixIcon: const Icon(Icons.school),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: '회원가입',
                            onPressed: _register,
                            icon: Icons.person_add,
                          ),
                        ],
                      ),
                    ),
                    
                    // 로그인 화면으로 돌아가기
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('이미 계정이 있으신가요?'),
                        TextButton(
                          onPressed: () => context.go('/login'),
                          child: const Text('로그인'),
                        ),
                      ],
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
  
  void _register() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().registerTeacher(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        schoolId: _schoolIdController.text.trim().isEmpty 
            ? null 
            : _schoolIdController.text.trim(),
      );
    }
  }
}
