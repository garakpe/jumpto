import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/loading_view.dart';
import '../../domain/entities/user.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/student_cubit.dart';

/// 학생 마이페이지
///
/// 학생의 계정 정보를 확인하고 관리할 수 있는 화면입니다.
/// 비밀번호 변경 및 성별 선택 기능을 제공합니다.
class StudentMyPage extends StatefulWidget {
  const StudentMyPage({super.key});

  @override
  State<StudentMyPage> createState() => _StudentMyPageState();
}

class _StudentMyPageState extends State<StudentMyPage> {
  // 비밀번호 변경 관련 상태
  bool _isChangingPassword = false;
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 성별 선택 상태
  String? _selectedGender;
  
  @override
  void initState() {
    super.initState();
    // 현재 사용자의 성별 정보 가져오기
    final currentUser = context.read<AuthCubit>().state;
    if (currentUser is AuthAuthenticated && currentUser.user.gender != null) {
      setState(() {
        _selectedGender = currentUser.user.gender;
      });
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingView(message: '로딩 중...');
          }

          if (state is AuthAuthenticated && state.user.isStudent) {
            return _buildStudentProfile(context, state.user);
          }

          return const Center(child: Text('인증된 학생 계정이 아닙니다.'));
        },
      ),
    );
  }

  /// 학생 프로필 화면
  Widget _buildStudentProfile(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 헤더
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.school,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '학교: ${user.schoolId ?? ""}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '학급: ${user.classNum ?? ""}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '학번: ${user.studentId ?? user.studentNum ?? ""}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '성별: ${user.gender ?? "미설정"}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 계정 관리 섹션
          Text('계정 관리', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          
          // 성별 선택 섹션
          _buildGenderSelection(context, user),
          const SizedBox(height: 16),

          // 비밀번호 변경 섹션
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '비밀번호 변경',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isChangingPassword
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                        onPressed: () {
                          setState(() {
                            _isChangingPassword = !_isChangingPassword;
                          });
                        },
                      ),
                    ],
                  ),
                  if (_isChangingPassword) ...[
                    const SizedBox(height: 16),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          AppTextField(
                            label: '현재 비밀번호',
                            hintText: '현재 비밀번호를 입력하세요',
                            controller: _currentPasswordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '현재 비밀번호를 입력해주세요';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '새 비밀번호',
                            hintText: '새 비밀번호를 입력하세요',
                            controller: _newPasswordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '새 비밀번호를 입력해주세요';
                              }
                              if (value.length < 4) {
                                return '비밀번호는 최소 4자 이상이어야 합니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '새 비밀번호 확인',
                            hintText: '새 비밀번호를 다시 입력하세요',
                            controller: _confirmPasswordController,
                            obscureText: true,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '새 비밀번호를 다시 입력해주세요';
                              }
                              if (value != _newPasswordController.text) {
                                return '비밀번호가 일치하지 않습니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            text: '비밀번호 변경',
                            onPressed: _changePassword,
                            icon: Icons.save,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 로그아웃 버튼
          AppButton(
            text: '로그아웃',
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }
  
  /// 성별 선택 섹션
  Widget _buildGenderSelection(BuildContext context, User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '성별 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'PAPS 측정 기준표 적용을 위해 성별 정보가 필요합니다.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('남자'),
                    value: '남',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('여자'),
                    value: '여',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: BlocConsumer<StudentCubit, StudentState>(
                listener: (context, state) {
                  if (state is StudentError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is StudentLoaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('성별 정보가 저장되었습니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is StudentLoading;
                  
                  return AppButton(
                    text: '성별 저장',
                    onPressed: _selectedGender == null 
                        ? null 
                        : () => _saveGender(context),
                    isLoading: isLoading,
                    icon: Icons.save,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 성별 저장 처리
  void _saveGender(BuildContext context) {
    if (_selectedGender != null) {
      context.read<StudentCubit>().updateGender(_selectedGender!);
    }
  }

  /// 비밀번호 변경 처리
  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      // 비밀번호 변경 로직 구현
      // TODO: 비밀번호 변경 API 호출
      
      // 임시 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('비밀번호가 변경되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // 비밀번호 변경 후 입력 필드 초기화
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      
      // 비밀번호 변경 폼 닫기
      setState(() {
        _isChangingPassword = false;
      });
    }
  }
}
