import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/loading_view.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

/// 로그인 화면
/// 
/// 사용자가 이메일과 비밀번호로 로그인할 수 있는 화면입니다.
/// 교사와 학생 로그인 방식을 모두 지원합니다.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 로그인 타입 구분 (교사/학생)
  bool _isTeacherLogin = true;
  
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 컨트롤러
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _schoolIdController = TextEditingController();
  final _studentNumberController = TextEditingController();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _schoolIdController.dispose();
    _studentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // 로그인 성공 시 홈 화면으로 이동
            context.go('/home');
          } else if (state is AuthError) {
            // 로그인 실패 시 오류 메시지 표시
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
            return const LoadingView(message: '로그인 중...');
          }
          
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 로그인 헤더 (로고, 제목)
                    const LoginHeader(),
                    const SizedBox(height: 32),
                    
                    // 로그인 타입 선택 (교사/학생)
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('교사 로그인'),
                          icon: Icon(Icons.person),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('학생 로그인'),
                          icon: Icon(Icons.school),
                        ),
                      ],
                      selected: {_isTeacherLogin},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _isTeacherLogin = selected.first;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // 로그인 폼
                    Form(
                      key: _formKey,
                      child: _isTeacherLogin 
                          ? _buildTeacherLoginForm() 
                          : _buildStudentLoginForm(),
                    ),
                    
                    // 회원가입 안내
                    if (_isTeacherLogin) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('계정이 없으신가요?'),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: const Text('회원가입'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // 교사 로그인 폼
  Widget _buildTeacherLoginForm() {
    return Column(
      children: [
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
            return null;
          },
        ),
        const SizedBox(height: 24),
        AppButton(
          text: '로그인',
          onPressed: _onTeacherLogin,
          icon: Icons.login,
        ),
      ],
    );
  }
  
  // 학생 로그인 폼
  Widget _buildStudentLoginForm() {
    return Column(
      children: [
        AppTextField(
          label: '학교 코드',
          hintText: '학교 코드를 입력하세요',
          controller: _schoolIdController,
          prefixIcon: const Icon(Icons.school),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '학교 코드를 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: '학번',
          hintText: '학번을 입력하세요',
          controller: _studentNumberController,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '학번을 입력해주세요';
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
            return null;
          },
        ),
        const SizedBox(height: 24),
        AppButton(
          text: '로그인',
          onPressed: _onStudentLogin,
          icon: Icons.login,
        ),
      ],
    );
  }
  
  // 교사 로그인 처리
  void _onTeacherLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
  
  // 학생 로그인 처리
  void _onStudentLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInStudent(
        schoolId: _schoolIdController.text.trim(),
        studentNumber: _studentNumberController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}
