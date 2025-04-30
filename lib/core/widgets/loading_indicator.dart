import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// 앱 전체에서 사용할 수 있는 로딩 인디케이터 위젯
class LoadingIndicator extends StatelessWidget {
  final String? message;
  final bool isFullScreen;

  const LoadingIndicator({
    Key? key,
    this.message,
    this.isFullScreen = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loadingWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (isFullScreen) {
      return Container(
        color: Colors.white.withOpacity(0.8),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: loadingWidget,
            ),
          ),
        ),
      );
    }

    return Center(child: loadingWidget);
  }
}

/// 앱 전체에서 사용할 수 있는 페이지 로딩 인디케이터 위젯
class PageLoadingIndicator extends StatelessWidget {
  final String? message;

  const PageLoadingIndicator({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LoadingIndicator(
          message: message,
        ),
      ),
    );
  }
}
