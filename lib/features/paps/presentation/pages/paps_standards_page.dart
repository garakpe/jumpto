import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/widgets/error_view.dart';
import '../../../../core/presentation/widgets/loading_view.dart';
import '../../domain/entities/index.dart';
import '../cubit/paps_cubit.dart';
import '../widgets/grade_range_table.dart';

/// 팝스 기준표 조회 화면
class PapsStandardsPage extends StatefulWidget {
  const PapsStandardsPage({super.key});

  @override
  State<PapsStandardsPage> createState() => _PapsStandardsPageState();
}

class _PapsStandardsPageState extends State<PapsStandardsPage> {
  // 선택된 필터 값
  SchoolLevel _selectedSchoolLevel = SchoolLevel.elementary;
  int _selectedGradeNumber = 5;
  Gender _selectedGender = Gender.male;
  FitnessFactor _selectedFitnessFactor = FitnessFactor.cardioEndurance;
  String _selectedEventName = '왕복오래달리기';
  
  // 이벤트 목록
  List<String> _eventNames = ['왕복오래달리기'];
  
  @override
  void initState() {
    super.initState();
    _loadEventNames();
    _loadPapsStandard();
  }
  
  // 선택된 체력요인에 따른 이벤트 목록 로드
  void _loadEventNames() {
    final events = Event.findByFitnessFactor(_selectedFitnessFactor);
    setState(() {
      _eventNames = events.map((e) => e.koreanName).toList();
      _selectedEventName = _eventNames.first;
    });
  }
  
  // 팝스 기준표 로드
  void _loadPapsStandard() {
    context.read<PapsCubit>().loadPapsStandard(
      schoolLevel: _selectedSchoolLevel,
      gradeNumber: _selectedGradeNumber,
      gender: _selectedGender,
      fitnessFactor: _selectedFitnessFactor,
      eventName: _selectedEventName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('팝스 기준표 조회'),
      ),
      body: Column(
        children: [
          // 필터 섹션
          _buildFilterSection(),
          
          // 기준표 내용
          Expanded(
            child: BlocBuilder<PapsCubit, PapsState>(
              builder: (context, state) {
                if (state is PapsLoading) {
                  return const LoadingView(message: '기준표를 불러오는 중...');
                }
                
                if (state is PapsError) {
                  return ErrorView(
                    message: state.message,
                    onRetry: _loadPapsStandard,
                  );
                }
                
                if (state is PapsStandardsLoaded) {
                  return _buildStandardsContent(state.standard);
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '필터',
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
                      });
                      _loadPapsStandard();
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
                        });
                        _loadPapsStandard();
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
                      });
                      _loadPapsStandard();
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
                        });
                        _loadEventNames();
                        _loadPapsStandard();
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
                        });
                        _loadPapsStandard();
                      }
                    },
                  ),
                ),
              ],
            ),
            
            // 적용 버튼
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadPapsStandard,
                child: const Text('적용'),
              ),
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
  
  Widget _buildStandardsContent(PapsStandard standard) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기준표 제목
          Text(
            '${standard.schoolLevel.koreanName} ${standard.grade.koreanName} ${standard.gender.koreanName}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Text(
            '${standard.fitnessFactor.koreanName} - ${standard.event.koreanName}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // 기준표 테이블
          Expanded(
            child: GradeRangeTable(gradeRanges: standard.gradeRanges),
          ),
        ],
      ),
    );
  }
}
