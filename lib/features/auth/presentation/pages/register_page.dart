import 'package:flutter/material.dart';
import '../../../../features/common/domain/entities/school.dart';
import '../../../../features/common/presentation/cubit/school_cubit.dart';
import '../../../../features/common/presentation/widgets/school_selector.dart';
import 'package:flutter/services.dart';
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
  final _phoneController = TextEditingController();
  final _schoolNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 선택된 학교 정보 저장
  School? _selectedSchool;
  
  @override
  void initState() {
    super.initState();
    // _schoolNameController의 변경 감지 후 화면 업데이트
    _schoolNameController.addListener(() {
      print('학교 이름 필드 변경: ${_schoolNameController.text}');
    });
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                          // 학교 선택 위젯
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '학교 선택',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              SchoolSelector(
                                hintText: '근무 중인 학교를 선택하세요',
                                allowCustomInput: true,
                                onSchoolSelected: (school) {
                                  print('학교 선택 콜백: ${school?.name ?? "null"}');
                                  setState(() {
                                    _selectedSchool = school;
                                    if (school != null) {
                                      // 학교 이름을 설정하는 작업은 school_selector.dart에서 처리
                                      // 이미 컨트롤러가 school.name으로 설정됨
                                      print('학교 이름 선택됨: ${school.name}');
                                    } else {
                                      _schoolNameController.text = '';
                                    }
                                  });
                                },
                              ),
                            ],
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
                              // 이메일 형식 검사
                              final emailRegExp = RegExp(
                                r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
                              );
                              if (!emailRegExp.hasMatch(value)) {
                                return '유효한 이메일 형식이 아닙니다';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '핸드폰 번호',
                            hintText: '핸드폰 번호를 입력하세요 (예: 010-1234-5678)',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                              _PhoneNumberFormatter(),
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '핸드폰 번호를 입력해주세요';
                              }
                              // 핸드폰 번호 형식 검사 (숫자와 하이픈만)
                              final phoneRegExp = RegExp(
                                r'^010-\d{4}-\d{4}$',
                              );
                              if (!phoneRegExp.hasMatch(value)) {
                                return '유효한 핸드폰 번호 형식이 아닙니다 (예: 010-1234-5678)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: '비밀번호',
                            hintText: '비밀번호를 입력하세요 (6자 이상)',
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
                              // 비밀번호 복잡성 검사 (선택적)
                              final hasUppercase = value.contains(RegExp(r'[A-Z]'));
                              final hasDigits = value.contains(RegExp(r'[0-9]'));
                              final hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
                              
                              if (!hasUppercase && !hasDigits && !hasSpecialCharacters) {
                                return '대문자, 숫자, 특수문자 중 하나 이상을 포함해주세요';
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
                          
                          // 승인 필요 안내 메시지
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.amber),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '회원가입 후 관리자 승인이 필요합니다. 승인이 완료될 때까지 잠시 기다려주세요.',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
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
      print('등록 시 학교 이름: ${_schoolNameController.text}');
      print('등록 시 학교 객체: ${_selectedSchool?.name}');
    
      // 학교 정보 처리 - 선택된 학교가 있으면 학교 코드 사용
      final schoolId = _selectedSchool?.code != null 
          ? (_selectedSchool!.code != 'custom' ? _selectedSchool!.code : _selectedSchool!.name)
          : _schoolNameController.text.trim();
          
      final phoneNumber = _phoneController.text.trim();
      
      context.read<AuthCubit>().registerTeacher(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        displayName: _nameController.text.trim(),
        schoolId: schoolId,
        phoneNumber: phoneNumber,
      );
    }
  }
}

/// 전화번호 형식 입력을 위한 TextInputFormatter
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, 
    TextEditingValue newValue
  ) {
    // 숫자만 추출
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    final String newText;
    final int selectionIndex;
    
    // 자동 하이픈 추가
    if (digitsOnly.length >= 8) {
      // 010-1234-5678 형식
      newText = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7, digitsOnly.length.clamp(0, 11))}';
      selectionIndex = newText.length;
    } else if (digitsOnly.length >= 4) {
      // 010-1234 형식
      newText = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, digitsOnly.length)}';
      selectionIndex = newText.length;
    } else {
      // 숫자만 표시
      newText = digitsOnly;
      selectionIndex = newText.length;
    }
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
