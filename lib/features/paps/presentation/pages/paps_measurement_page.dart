import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

import '../../../../core/presentation/widgets/app_button.dart';
import '../../../../core/presentation/widgets/app_text_field.dart';
import '../../../../core/presentation/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/index.dart';
import '../cubit/paps_cubit.dart';
import '../widgets/measurement_result_card.dart';

/// 팝스 측정 화면
///
/// 학생이 팝스 측정 결과를 입력하고 등급과 점수를 확인할 수 있는 화면입니다.
class PapsMeasurementPage extends StatefulWidget {
  const PapsMeasurementPage({super.key});

  @override
  State<PapsMeasurementPage> createState() => _PapsMeasurementPageState();
}

class _PapsMeasurementPageState extends State<PapsMeasurementPage> {
  // 선택된 필터 값
  SchoolLevel _selectedSchoolLevel = SchoolLevel.elementary;
  int _selectedGradeNumber = 5;
  Gender _selectedGender = Gender.male;
  FitnessFactor _selectedFitnessFactor = FitnessFactor.cardioEndurance;
  String _selectedEventName = '왕복오래달리기';
  
  // 측정값 컨트롤러
  final _valueController = TextEditingController();
  
  // 계산된 등급과 점수
  int? _grade;
  int? _score;
  
  // 이벤트 목록
  List<String> _eventNames = ['왕복오래달리기'];
  
  // 폼 키
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _loadEventNames();
  }
  
  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }
  
  // 선택된 체력요인에 따른 이벤트 목록 로드
  void _loadEventNames() {
    final events = Event.findByFitnessFactor(_selectedFitnessFactor);
    setState(() {
      _eventNames = events.map((e) => e.koreanName).toList();
      _selectedEventName = _eventNames.first;
    });
  }
  
  // 측정값에 대한 등급과 점수 계산
  void _calculateGradeAndScore() {
    if (_formKey.currentState!.validate()) {
      // 측정값 가져오기
      final value = double.parse(_valueController.text);
      
      developer.log('등급/점수 계산 시도: ${_selectedSchoolLevel.koreanName} ${_selectedGradeNumber}학년 ${_selectedGender.koreanName} ${_selectedFitnessFactor.koreanName} ${_selectedEventName} = $value');
      
      // 등급과 점수 계산 요청
      context.read<PapsCubit>().calculateGradeAndScore(
        schoolLevel: _selectedSchoolLevel,
        gradeNumber: _selectedGradeNumber,
        gender: _selectedGender,
        fitnessFactor: _selectedFitnessFactor,
        eventName: _selectedEventName,
        value: value,
      );
    }
  }
  
  // 측정 기록 저장
  void _saveMeasurementRecord() {
    if (_grade == null || _score == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 측정값을 입력하고 계산 버튼을 클릭해주세요'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // 현재 사용자 정보 가져오기
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인이 필요합니다'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final user = authState.user;
    
    // 팝스 기록 생성
    final record = PapsRecord(
      id: const Uuid().v4(),
      studentId: user.id,
      schoolLevel: _selectedSchoolLevel,
      grade: Grade(_selectedSchoolLevel, _selectedGradeNumber),
      gender: _selectedGender,
      fitnessFactor: _selectedFitnessFactor,
      event: Event.findByName(_selectedEventName),
      value: double.parse(_valueController.text),
      recordGrade: _grade!,
      score: _score!,
      recordedAt: DateTime.now(),
    );
    
    // 기록 저장 요청
    context.read<PapsCubit>().savePapsRecord(record);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팝스 측정'),
      ),
      body: BlocConsumer<PapsCubit, PapsState>(
        listener: (context, state) {
          developer.log('팝스 측정 상태 변경: ${state.runtimeType}');
          
          if (state is PapsMeasurementCalculated) {
            // 등급과 점수 설정
            setState(() {
              _grade = state.grade;
              _score = state.score;
            });
            developer.log('계산 결과: 등급 $_grade, 점수 $_score');
          } else if (state is PapsRecordSaved) {
            // 저장 성공 메시지
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('측정 기록이 성공적으로 저장되었습니다'),
                backgroundColor: Colors.green,
              ),
            );
            
            // 입력 초기화
            setState(() {
              _valueController.clear();
              _grade = null;
              _score = null;
            });
          } else if (state is PapsError) {
            // 오류 메시지
            developer.log('오류 발생: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // 로딩 중일 때
          if (state is PapsLoading) {
            return const LoadingView();
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 필터 섹션
                _buildFilterSection(),
                const SizedBox(height: 24),
                
                // 측정값 입력 섹션
                _buildMeasurementInputSection(),
                const SizedBox(height: 24),
                
                // 계산 버튼
                AppButton(
                  text: '계산하기',
                  onPressed: _calculateGradeAndScore,
                  icon: Icons.calculate,
                ),
                const SizedBox(height: 24),
                
                // 결과 섹션
                if (_grade != null && _score != null)
                  _buildResultSection(),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '측정 조건',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            // 학교급 선택
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '학교급:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SegmentedButton<SchoolLevel>(
                    segments: const [
                      ButtonSegment<SchoolLevel>(
                        value: SchoolLevel.elementary,
                        label: Text('초등학교'),
                      ),
                      ButtonSegment<SchoolLevel>(
                        value: SchoolLevel.middle,
                        label: Text('중학교'),
                      ),
                      ButtonSegment<SchoolLevel>(
                        value: SchoolLevel.high,
                        label: Text('고등학교'),
                      ),
                    ],
                    selected: {_selectedSchoolLevel},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedSchoolLevel = selected.first;
                        // 학교급에 따라 기본 학년 설정
                        if (_selectedSchoolLevel == SchoolLevel.elementary) {
                          _selectedGradeNumber = 5;
                        } else {
                          _selectedGradeNumber = 1;
                        }
                        
                        // 계산된 결과 초기화
                        _grade = null;
                        _score = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 학년 선택
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '학년:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: DropdownButton<int>(
                    value: _selectedGradeNumber,
                    isExpanded: true,
                    items: _buildGradeItems(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGradeNumber = value;
                          // 계산된 결과 초기화
                          _grade = null;
                          _score = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 성별 선택
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '성별:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: SegmentedButton<Gender>(
                    segments: const [
                      ButtonSegment<Gender>(
                        value: Gender.male,
                        label: Text('남자'),
                      ),
                      ButtonSegment<Gender>(
                        value: Gender.female,
                        label: Text('여자'),
                      ),
                    ],
                    selected: {_selectedGender},
                    onSelectionChanged: (selected) {
                      setState(() {
                        _selectedGender = selected.first;
                        // 계산된 결과 초기화
                        _grade = null;
                        _score = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 체력요인 선택
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '체력요인:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: DropdownButton<FitnessFactor>(
                    value: _selectedFitnessFactor,
                    isExpanded: true,
                    items: FitnessFactor.values.map((factor) {
                      return DropdownMenuItem<FitnessFactor>(
                        value: factor,
                        child: Text(factor.koreanName),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedFitnessFactor = value;
                          // 계산된 결과 초기화
                          _grade = null;
                          _score = null;
                        });
                        _loadEventNames();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // 측정 종목 선택
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '측정 종목:',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: DropdownButton<String>(
                    value: _selectedEventName,
                    isExpanded: true,
                    items: _eventNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedEventName = value;
                          // 계산된 결과 초기화
                          _grade = null;
                          _score = null;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  List<DropdownMenuItem<int>> _buildGradeItems() {
    List<int> grades = [];
    
    switch (_selectedSchoolLevel) {
      case SchoolLevel.elementary:
        grades = [3, 4, 5, 6];
        break;
      case SchoolLevel.middle:
      case SchoolLevel.high:
        grades = [1, 2, 3];
        break;
    }
    
    return grades.map((grade) {
      return DropdownMenuItem<int>(
        value: grade,
        child: Text('$grade학년'),
      );
    }).toList();
  }
  
  Widget _buildMeasurementInputSection() {
    String hintText = '';
    TextInputType keyboardType = TextInputType.number;
    
    // 종목에 따른 힌트 텍스트 설정
    if (_selectedEventName.contains('달리기')) {
      if (_selectedEventName.contains('왕복')) {
        hintText = '왕복 횟수를 입력하세요';
      } else {
        hintText = '초 단위로 입력하세요';
      }
    } else if (_selectedEventName.contains('굽히기') || _selectedEventName.contains('유연성')) {
      hintText = 'cm 단위로 입력하세요';
    } else if (_selectedEventName.contains('말아올리기') || _selectedEventName.contains('팔굽혀펴기')) {
      hintText = '횟수를 입력하세요';
    } else if (_selectedEventName.contains('멀리뛰기')) {
      hintText = 'cm 단위로 입력하세요';
    } else if (_selectedEventName.contains('체질량') || _selectedEventName.contains('BMI')) {
      hintText = 'kg/m² 단위로 입력하세요';
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    } else if (_selectedEventName.contains('악력')) {
      hintText = 'kg 단위로 입력하세요';
      keyboardType = const TextInputType.numberWithOptions(decimal: true);
    }
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '측정값 입력',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          AppTextField(
            label: '${_selectedEventName} 측정값',
            hintText: hintText,
            controller: _valueController,
            keyboardType: keyboardType,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '측정값을 입력해주세요';
              }
              
              if (double.tryParse(value) == null) {
                return '유효한 숫자를 입력해주세요';
              }
              
              return null;
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '측정 결과',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // 결과 카드
        MeasurementResultCard(
          grade: _grade!,
          score: _score!,
          onSave: _saveMeasurementRecord,
        ),
      ],
    );
  }
}
