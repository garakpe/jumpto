import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../cubit/auth_cubit.dart';

/// 교사 로그인 폼 위젯
class TeacherLoginForm extends StatefulWidget {
  const TeacherLoginForm({super.key});

  @override
  State<TeacherLoginForm> createState() => _TeacherLoginFormState();
}

class _TeacherLoginFormState extends State<TeacherLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
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
          AppButton(text: '로그인', onPressed: _login, icon: Icons.login),
        ],
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signInWithEmailPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }
}

/// 학생 로그인 폼 위젯
class StudentLoginForm extends StatefulWidget {
  const StudentLoginForm({super.key});

  @override
  State<StudentLoginForm> createState() => _StudentLoginFormState();
}

class _StudentLoginFormState extends State<StudentLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _schoolCodeController = TextEditingController();
  final _studentNumController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _schoolCodeController.dispose();
    _studentNumController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            label: '학교 코드',
            hintText: '학교 코드를 입력하세요',
            controller: _schoolCodeController,
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
            controller: _studentNumController,
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
          AppButton(text: '로그인', onPressed: _login, icon: Icons.login),
        ],
      ),
    );
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // 학생 로그인 기능 구현 예정
      // context.read<AuthCubit>().signInStudent(
      //   schoolCode: _schoolCodeController.text.trim(),
      //   studentNum: _studentNumController.text.trim(),
      //   password: _passwordController.text,
      // );

      // 현재는 알림만 표시
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('학생 로그인 기능은 아직 구현 중입니다.')));
    }
  }
}
