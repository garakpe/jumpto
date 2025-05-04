import 'package:flutter/material.dart';

/// 콘텐츠 선택 카드 위젯
///
/// 콘텐츠 선택 화면에서 각 콘텐츠를 카드 형식으로 표시하는 위젯입니다.
class ContentCard extends StatelessWidget {
  /// 콘텐츠 제목
  final String title;
  
  /// 콘텐츠 설명
  final String description;
  
  /// 콘텐츠 아이콘
  final IconData icon;
  
  /// 카드 배경 색상
  final Color color;
  
  /// 카드 탭 이벤트 콜백
  final VoidCallback onTap;
  
  /// 비활성화 여부
  final bool isDisabled;
  
  const ContentCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        child: Stack(
          children: [
            // 배경 색상
            Positioned.fill(
              child: Container(
                color: color,
              ),
            ),
            
            // 콘텐츠 정보
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 아이콘
                  Icon(
                    icon,
                    size: 48,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  
                  // 제목
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // 설명
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // 비활성화 효과
            if (isDisabled)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '준비 중',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
