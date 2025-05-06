import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/user.dart';
import '../cubit/auth_cubit.dart';

/// 계정 드롭다운 메뉴
///
/// 사용자 아이콘을 클릭했을 때 나타나는 드롭다운 메뉴입니다.
/// 사용자 역할에 따라 다른 메뉴 항목을 표시합니다.
class AccountDropdown extends StatelessWidget {
  final User user;
  
  const AccountDropdown({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle),
      tooltip: '계정 메뉴',
      onSelected: (value) => _handleMenuItemSelected(context, value),
      itemBuilder: (context) => [
        // 마이페이지 메뉴 항목
        const PopupMenuItem<String>(
          value: 'mypage',
          child: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 8),
              Text('마이페이지'),
            ],
          ),
        ),
        
        // 로그아웃 메뉴 항목
        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout),
              SizedBox(width: 8),
              Text('로그아웃'),
            ],
          ),
        ),
      ],
    );
  }
  
  // 메뉴 항목 선택 처리
  void _handleMenuItemSelected(BuildContext context, String value) {
    switch (value) {
      case 'mypage':
        if (user.isStudent) {
          // 학생 마이페이지로 이동
          context.go('/student-mypage');
        } else if (user.isTeacher) {
          // 교사 마이페이지로 이동 (미구현)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('교사 마이페이지는 아직 준비 중입니다.')),
          );
        }
        break;
      
      case 'logout':
        // 로그아웃
        context.read<AuthCubit>().signOut();
        break;
    }
  }
}
