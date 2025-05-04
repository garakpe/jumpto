import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/auth_cubit.dart';

/// 스플래시 화면
/// 
/// 앱이 시작될 때 표시되는 화면으로, 인증 상태를 확인하고 적절한 화면으로 리디렉션합니다.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // 인증 상태 확인
    context.read<AuthCubit>().checkAuthState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // 인증된 사용자인 경우 콘텐츠 선택 화면으로 이동
            context.go('/content-selection');
          } else if (state is AuthUnauthenticated) {
            // 인증되지 않은 사용자인 경우 로그인 화면으로 이동
            context.go('/login');
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 로고 이미지
              Image.asset(
                'assets/logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.fitness_center, size: 100),
              ),
              const SizedBox(height: 24),
              const Text(
                '온라인 팝스 교육 플랫폼',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '학생건강체력평가 관리 시스템',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
