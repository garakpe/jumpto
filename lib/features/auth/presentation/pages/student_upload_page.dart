import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/loading_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../cubit/student_cubit.dart';

/// 학생 업로드 페이지
///
/// 교사가 엑셀 파일을 통해 학생 정보를 일괄 업로드할 수 있는 화면입니다.
class StudentUploadPage extends StatefulWidget {
  const StudentUploadPage({super.key});

  @override
  State<StudentUploadPage> createState() => _StudentUploadPageState();
}

class _StudentUploadPageState extends State<StudentUploadPage> {
  bool _isUploading = false;
  bool _isDownloading = false;
  String _statusMessage = '';
  int _uploadedCount = 0;
  int _totalCount = 0;
  bool _showTemplate = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학생 일괄 등록')),
      body: BlocConsumer<StudentCubit, StudentState>(
        listener: (context, state) {
          if (state is StudentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is StudentUploading) {
            setState(() {
              _isUploading = true;
              _totalCount = state.totalCount;
              _uploadedCount = state.uploadedCount;
            });
          } else if (state is StudentUploadSuccess) {
            setState(() {
              _isUploading = false;
              _statusMessage =
                  '${state.uploadedStudents.length}명의 학생 등록이 완료되었습니다.';
            });
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '엑셀 파일을 업로드하여 학생 데이터를 일괄 등록할 수 있습니다.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '엑셀 파일은 다음과 같은 형식이어야 합니다:\n'
                    '- 첫 번째 열: 학년(1자리)\n'
                    '- 두 번째 열: 반(한자리 또는 두자리)\n'
                    '- 세 번째 열: 번호(한자리 또는 두자리)\n'
                    '- 네 번째 열: 이름\n'
                    '- 다섯 번째 열: 초기비밀번호(선택, 미입력시 1234)',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '* 학번은 "학년+반(두자리)+번호(두자리)"로 자동 생성됩니다.\n'
                    '* 한 자리 반/번호는 자동으로 두 자리로 변환됩니다. (예: 1학년 1반 1번 → 10101)\n'
                    '* 학생 로그인 시 학번과 이름과 초기 비밀번호를 사용합니다.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 엑셀 템플릿 예시
                  if (_showTemplate) _buildTemplateExample(),
                  const SizedBox(height: 16),

                  // 템플릿 다운로드 버튼
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: Text(_isDownloading ? '템플릿 준비 중...' : '엑셀 템플릿 다운로드'),
                    onPressed:
                        _isDownloading || _isUploading
                            ? null
                            : _downloadExcelTemplate,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file),
                    label: const Text('엑셀 파일 선택'),
                    onPressed:
                        _isUploading || _isDownloading ? null : _pickExcelFile,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 진행 상황 표시
                  if (_isUploading)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value:
                              _totalCount > 0
                                  ? _uploadedCount / _totalCount
                                  : 0,
                        ),
                        const SizedBox(height: 8),
                        Text('진행 상황: $_uploadedCount / $_totalCount'),
                      ],
                    ),
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      color:
                          _statusMessage.contains('오류')
                              ? Colors.red
                              : _statusMessage.contains('완료')
                              ? Colors.green
                              : Colors.black,
                    ),
                  ),

                  // 업로드 완료 후 안내 메시지
                  if (state is StudentUploadSuccess)
                    Container(
                      margin: const EdgeInsets.only(top: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '학생 등록 완료!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '다음 단계:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '1. 대시보드에서 학급을 선택하세요.\n'
                            '2. 학생들에게 학번(5자리)과 이름으로 로그인할 수 있다고 안내하세요.',
                          ),

                          // 학급별 업로드 결과 요약 표시
                          if (state.classCount.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '학급별 업로드 결과:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...state.classCount.entries.map(
                                    (entry) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '${entry.key}반: ${entry.value}명',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              child: const Text('교사 대시보드로 돌아가기'),
                              onPressed: () {
                                context.go('/teacher-dashboard');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 템플릿 다운로드 함수
  Future<void> _downloadExcelTemplate() async {
    try {
      setState(() {
        _isDownloading = true;
        _statusMessage = '템플릿 파일 생성 중...';
      });

      // StudentCubit을 통해 템플릿 생성
      final Uint8List? bytes =
          await context.read<StudentCubit>().createExcelTemplate();

      // FilePicker를 통해 파일 저장
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '엑셀 템플릿 저장',
        fileName: '학생명단_템플릿.xlsx',
      );

      if (outputFile != null) {
        // TODO: 파일 저장 로직 구현 (웹 환경에서는 자동 다운로드됨)
        _statusMessage = '템플릿 파일이 다운로드되었습니다. 데이터를 입력한 후 업로드해주세요.';
      } else {
        _statusMessage = '템플릿 다운로드가 취소되었습니다.';
      }

      setState(() {
        _isDownloading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = '템플릿 다운로드 오류: $e';
        _isDownloading = false;
      });
    }
  }

  /// 엑셀 파일 선택 및 처리
  Future<void> _pickExcelFile() async {
    try {
      setState(() {
        _statusMessage = '파일 선택 중...';
      });

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _statusMessage = '파일을 처리 중입니다...';
        });

        Uint8List? fileBytes = result.files.first.bytes;

        if (fileBytes != null) {
          // StudentCubit을 통해 엑셀 파일 처리
          await context.read<StudentCubit>().processExcelFile(fileBytes);
        } else {
          setState(() {
            _statusMessage = '파일을 읽을 수 없습니다.';
          });
        }
      } else {
        // 사용자가 파일 선택을 취소한 경우
        setState(() {
          _statusMessage = '파일 선택이 취소되었습니다.';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = '오류가 발생했습니다: $e';
      });
    }
  }

  /// 템플릿 예시 위젯
  Widget _buildTemplateExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '엑셀 형식 예시',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _showTemplate = false;
                  });
                },
                child: const Text('닫기'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                  label: Text(
                    '학년',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '반',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '번호',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '이름',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '초기비밀번호',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    '생성될 학번',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: const [
                DataRow(
                  cells: [
                    DataCell(Text('1')),
                    DataCell(Text('1')),
                    DataCell(Text('1')),
                    DataCell(Text('김코드')),
                    DataCell(Text('1234')),
                    DataCell(Text('10101')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('1')),
                    DataCell(Text('1')),
                    DataCell(Text('2')),
                    DataCell(Text('이영희')),
                    DataCell(Text('1234')),
                    DataCell(Text('10102')),
                  ],
                ),
                DataRow(
                  cells: [
                    DataCell(Text('1')),
                    DataCell(Text('2')),
                    DataCell(Text('1')),
                    DataCell(Text('박지민')),
                    DataCell(Text('1234')),
                    DataCell(Text('10201')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
