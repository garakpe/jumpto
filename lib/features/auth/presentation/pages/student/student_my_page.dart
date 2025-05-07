import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/presentation/widgets/app_button.dart';
import '../../../../../core/presentation/widgets/app_text_field.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/auth_cubit.dart';
import '../../cubit/student_cubit.dart';

/// 학생 마이페이지
class StudentMyPage extends StatefulWidget {
  const StudentMyPage({super.key});

  @override
  State<StudentMyPage> createState() => _StudentMyPageState();
}

class _StudentMyPageState extends State<StudentMyPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 성별 선택 상태
  String? _selectedGender;
  
  // 비밀번호 변경 폼 키
  final _formKey = GlobalKey<FormState>();
  
  // 에러 메시지
  String? _errorMessage;
  
  @override
  void initState() {
    super.initState();
    // 현재 사용자의 성별 정보 가져오기
    final currentUser = context.read<AuthCubit>().state.user;
    if (currentUser != null && currentUser.gender != null) {
      _selectedGender = currentUser.gender;
    }
  }
  
  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  /// 비밀번호 변경 처리
  void _handleChangePassword() {
    if (_formKey.currentState!.validate()) {
      // 비밀번호 변경 로직 구현 (기존 changePassword 함수 호출)
      // TODO: 비밀번호 변경 함수 호출
    }
  }
  
  /// 성별 선택 변경 처리
  void _handleGenderChange(String? gender) {
    if (gender == null || gender == _selectedGender) return;
    
    setState(() {
      _selectedGender = gender;
    });
    
    // 선택한 성별 저장
    context.read<StudentCubit>().updateGender(gender);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
              context.go('/login');
            },
          ),
        ],
      ),
      body: BlocConsumer<StudentCubit, StudentState>(
        listener: (context, state) {
          if (state.status == StudentStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? '오류가 발생했습니다.')),
            );
          } else if (state.status == StudentStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('성공적으로 저장되었습니다.')),
            );
          }
        },
        builder: (context, state) {
          final currentUser = context.read<AuthCubit>().state.user;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 사용자 정보 표시
                _buildUserInfoCard(currentUser),
                
                const SizedBox(height: 24),
                
                // 성별 선택 섹션
                _buildGenderSection(),
                
                const SizedBox(height: 24),
                
                // 비밀번호 변경 섹션
                _buildPasswordChangeSection(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  /// 사용자 정보 카드 위젯
  Widget _buildUserInfoCard(User? user) {
    if (user == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('사용자 정보를 불러올 수 없습니다.'),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user.displayName} 학생',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('학교: ${user.schoolId ?? "정보 없음"}'),
            const SizedBox(height: 4),
            Text('학급: ${user.classNum ?? "정보 없음"}'),
            const SizedBox(height: 4),
            Text('학번: ${user.studentId ?? "정보 없음"}'),
            const SizedBox(height: 4),
            Text('성별: ${user.gender ?? "미설정"}'),
          ],
        ),
      ),
    );
  }
  
  /// 성별 선택 섹션 위젯
  Widget _buildGenderSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '성별 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text('PAPS 측정 기준표 적용을 위해 성별 정보가 필요합니다.'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('남자'),
                    value: '남',
                    groupValue: _selectedGender,
                    onChanged: _handleGenderChange,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('여자'),
                    value: '여',
                    groupValue: _selectedGender,
                    onChanged: _handleGenderChange,
                  ),
                ),
              ],
            ),
            if (_selectedGender == null) ...[
              const SizedBox(height: 8),
              const Text(
                '※ 성별을 선택해주세요.',
                style: TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            BlocBuilder<StudentCubit, StudentState>(
              builder: (context, state) {
                final isLoading = state.status == StudentStatus.loading;
                
                return SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    onPressed: _selectedGender == null 
                        ? null 
                        : () => _handleGenderChange(_selectedGender),
                    text: '성별 저장',
                    isLoading: isLoading,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 비밀번호 변경 섹션 위젯
  Widget _buildPasswordChangeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '비밀번호 변경',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _oldPasswordController,
                labelText: '현재 비밀번호',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _newPasswordController,
                labelText: '새 비밀번호',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요.';
                  }
                  if (value.length < 6) {
                    return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _confirmPasswordController,
                labelText: '새 비밀번호 확인',
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 다시 입력해주세요.';
                  }
                  if (value != _newPasswordController.text) {
                    return '비밀번호가 일치하지 않습니다.';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  onPressed: _handleChangePassword,
                  text: '비밀번호 변경',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
