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
    // 사용자 객체가 없으면 빈 위젯 반환
    if (user == null) {
      return const SizedBox.shrink();
    }
    
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
    // 안전하게 메뉴 처리
    try {
      // 사용자 객체 유효성 다시 확인
      if (user == null) {
        return;
      }
      
      switch (value) {
        case 'mypage':
          // 학생/교사에 따른 마이페이지 분기
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
          // 로그아웃 전 확인 다이얼로그
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('로그아웃'),
                content: const Text('정말 로그아웃 하시겠습니까?'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('취소'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('확인'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 로그아웃 쿼리
                      _performLogout(context);
                    },
                  ),
                ],
              );
            },
          );
          break;
      }
    } catch (e) {
      debugPrint('메뉴 항목 처리 중 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('작업 처리 중 오류가 발생했습니다: $e')),
      );
    }
  }
  
  // 실제 로그아웃 수행 함수
  Future<void> _performLogout(BuildContext context) async {
    try {
      // UI에 로딩 상태 표시
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그아웃 중...')),
      );
      
      // 로그아웃 로직 호출
      await context.read<AuthCubit>().signOut();
      
      // 로그아웃 성공 알림은 필요 없음 (이미 로그인 화면으로 이동)
    } catch (e) {
      // 로그아웃 중 오류 발생 시 처리
      debugPrint('로그아웃 중 오류 발생: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
    }
  }
}
