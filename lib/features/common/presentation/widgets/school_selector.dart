import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/school.dart';
import '../cubit/school_cubit.dart';

/// 학교 선택 위젯
///
/// 지역 선택 드롭다운과 학교명 입력 필드가 있는 위젯입니다.
/// 학교명을 입력하면 자동으로 검색 결과가 표시됩니다.
class SchoolSelector extends StatefulWidget {
  /// 학교 선택 시 호출되는 콜백 함수
  final Function(School?) onSchoolSelected;
  
  /// 선택된 학교가 없을 때 표시할 힌트 텍스트
  final String hintText;
  
  /// 직접 입력 옵션 제공 여부
  final bool allowCustomInput;
  
  /// 생성자
  const SchoolSelector({
    Key? key,
    required this.onSchoolSelected,
    this.hintText = '학교를 선택하세요',
    this.allowCustomInput = true,
  }) : super(key: key);

  @override
  State<SchoolSelector> createState() => _SchoolSelectorState();
}

class _SchoolSelectorState extends State<SchoolSelector> {
  String? _selectedRegion;
  School? _selectedSchool;
  final _schoolNameController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSearching = false;
  bool _useCustomInput = false;  // 직접 입력 모드인지 여부
  
  // 직접 입력용 컨트롤러
  final _customRegionController = TextEditingController();
  final _customSchoolNameController = TextEditingController();
  
  // 학교명 변경 콜백 함수
  void _onSchoolNameChanged() {
    if (_selectedRegion != null && !_useCustomInput) {
      context.read<SchoolCubit>().searchSchoolsByName(
        _selectedRegion!,
        _schoolNameController.text,
      );
    }
  }
  
  @override
  void initState() {
    super.initState();
    context.read<SchoolCubit>().loadRegions();
    
    // 학교명 컨트롤러에 리스너 등록
    _schoolNameController.addListener(_onSchoolNameChanged);
    
    _focusNode.addListener(() {
      setState(() {
        _isSearching = _focusNode.hasFocus && !_useCustomInput;
      });
    });
  }
  
  @override
  void dispose() {
    _schoolNameController.dispose();
    _customRegionController.dispose();
    _customSchoolNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SchoolCubit, SchoolState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 지역 선택 드롭다운
            _buildRegionDropdown(state),
            const SizedBox(height: 16),
            
            if (_useCustomInput) 
              // 직접 입력 UI
              _buildCustomInputFields()
            else
              // 학교명 입력 필드
              _buildSchoolNameField(),
            
            // 검색 결과 목록
            if (_isSearching && state is SchoolsLoaded)
              _buildSearchResults(state),
            
            // 직접 입력 체크박스
            if (widget.allowCustomInput)
              Row(
                children: [
                  Checkbox(
                    value: _useCustomInput,
                    onChanged: (value) {
                      setState(() {
                        _useCustomInput = value ?? false;
                        // 직접 입력 모드로 전환할 때 기존 선택 학교 초기화
                        if (_useCustomInput) {
                          _selectedSchool = null;
                          
                          // 이미 입력된 값이 있으면 직접 입력 필드에 복사
                          if (_schoolNameController.text.isNotEmpty) {
                            _customSchoolNameController.text = _schoolNameController.text;
                          }
                          if (_selectedRegion != null) {
                            _customRegionController.text = _selectedRegion!;
                          }
                        } else {
                          // 직접 입력 모드에서 벗어날 때 입력 값 초기화
                          _customRegionController.clear();
                          _customSchoolNameController.clear();
                        }
                      });
                    },
                  ),
                  Text(
                    '목록에 학교가 없는 경우 직접 입력',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
  
  /// 지역 선택 드롭다운 빌드
  Widget _buildRegionDropdown(SchoolState state) {
    // 지역 목록 가져오기
    List<String> regions = [];
    
    if (state is RegionsLoaded) {
      regions = state.regions;
    } else if (state is SchoolsLoaded) {
      // 이미 선택된 지역이 있는 경우, 지역 목록 전체를 다시 불러오기
      regions = state.allRegions;
    }
    
    if (state is RegionsLoaded || state is SchoolsLoaded) {
      return DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: '지역',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        value: _selectedRegion,
        hint: const Text('지역을 선택하세요'),
        isExpanded: true,
        items: regions.map((region) {
          return DropdownMenuItem<String>(
            value: region,
            child: Text(region),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRegion = value;
            _selectedSchool = null;
            _schoolNameController.clear();
          });
          if (value != null) {
            context.read<SchoolCubit>().loadSchoolsByRegion(value);
          }
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '지역을 선택해주세요';
          }
          return null;
        },
      );
    } else if (state is SchoolLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is SchoolError) {
      // 에러 발생 시 로그 출력 및 재시도 버튼 제공
      return Column(
        children: [
          Text('지역 정보를 불러올 수 없습니다: ${state.message}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<SchoolCubit>().loadRegions();
            },
            child: const Text('다시 시도'),
          ),
        ],
      );
    } else {
      // 초기 상태나 다른 상태일 경우
      return Column(
        children: [
          const Text('지역 정보를 불러올 수 없습니다.'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<SchoolCubit>().loadRegions();
            },
            child: const Text('다시 시도'),
          ),
        ],
      );
    }
  }
  
  /// 학교명 입력 필드 빌드
  Widget _buildSchoolNameField() {
    return TextFormField(
      controller: _schoolNameController,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: '학교 이름',
        hintText: widget.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: _schoolNameController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _schoolNameController.clear();
                    _selectedSchool = null;
                  });
                  widget.onSchoolSelected(null);
                },
              )
            : null,
      ),
      validator: (value) {
        if (_selectedSchool == null && value!.isEmpty && !_useCustomInput) {
          return '학교를 선택해주세요';
        }
        return null;
      },
    );
  }
  
  /// 직접 입력 필드 빌드
  Widget _buildCustomInputFields() {
    return Column(
      children: [
        TextFormField(
          controller: _customRegionController,
          decoration: const InputDecoration(
            labelText: '지역',
            hintText: '지역을 입력하세요',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateCustomSchool();
          },
          validator: (value) {
            if (_useCustomInput && (value == null || value.isEmpty)) {
              return '지역을 입력해주세요';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _customSchoolNameController,
          decoration: const InputDecoration(
            labelText: '학교 이름',
            hintText: '학교 이름을 입력하세요',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateCustomSchool();
          },
          validator: (value) {
            if (_useCustomInput && (value == null || value.isEmpty)) {
              return '학교 이름을 입력해주세요';
            }
            return null;
          },
        ),
      ],
    );
  }
  
  /// 직접 입력한 정보로 School 객체 업데이트
  void _updateCustomSchool() {
    final region = _customRegionController.text.trim();
    final name = _customSchoolNameController.text.trim();
    
    if (region.isNotEmpty && name.isNotEmpty) {
      setState(() {
        _selectedSchool = School(
          code: 'custom',
          name: name,
          establishmentYear: '',
          genderType: '',
          dayNightType: '',
          region: region,
          schoolType: '',
          foundationType: '',
        );
      });
      widget.onSchoolSelected(_selectedSchool);
    }
  }
  
  /// 검색 결과 목록 빌드
  Widget _buildSearchResults(SchoolsLoaded state) {
    if (state.filteredSchools.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '검색 결과가 없습니다.',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    } else {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: state.filteredSchools.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final school = state.filteredSchools[index];
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // 학교 선택 시 입력 필드에 학교 이름 반영
                  print('학교 선택: ${school.name}');
                  
                  // 우선 상태를 업데이트
                  setState(() {
                    _selectedSchool = school;
                    _isSearching = false;
                  });
                  
                  // 콜백 호출
                  widget.onSchoolSelected(school);
                  
                  // 검색 결과를 선택한 후에 컨트롤러 업데이트 (포커스 해제 이후)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    // 포커스 해제
                    _focusNode.unfocus();
                    
                    // 리스너 일시 중지 후 텍스트 설정
                    _schoolNameController.removeListener(_onSchoolNameChanged);
                    _schoolNameController.text = school.name;
                    _schoolNameController.addListener(_onSchoolNameChanged);
                    
                    // UI 업데이트
                    setState(() {});
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        school.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${school.schoolType}, ${school.foundationType}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
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
  }
}