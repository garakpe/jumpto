#!/bin/bash

echo "===== 클라우드 함수 오류 디버깅 도구 ====="
echo "이 스크립트는 오류 트랙킹을 위한 도구입니다."

# 경로 확인
PROJECT_DIR="/Users/smartchoi/Desktop/jumpto"
BUILD_DIR="$PROJECT_DIR/build/web"

if [ ! -d "$PROJECT_DIR" ]; then
    echo "오류: 프로젝트 디렉토리가 존재하지 않습니다."
    exit 1
fi

# 클라우드 함수 로깅을 위한 도구 스크립트 추가
echo "===== 1단계: 웹 애플리케이션 디버깅 스크립트 추가 ====="

# build/web 디렉토리가 존재하는지 확인
if [ ! -d "$BUILD_DIR" ]; then
    echo "빌드 디렉토리가 없습니다. 먼저 애플리케이션을 빌드하세요."
    exit 1
fi

# debug.js 파일 생성
cat > "$BUILD_DIR/debug.js" << 'EOL'
/* 웹앱 디버깅 헬퍼 */
(function() {
    console.log("디버깅 헬퍼 로드됨");
    
    // 페이지 로드 완료 후 실행
    window.addEventListener('load', function() {
        // localStorage 초기화 함수
        window.clearAppCache = function() {
            const itemsToKeep = [];
            
            // 특정 항목을 제외한 모든 localStorage 항목 삭제
            const totalItems = localStorage.length;
            const deletedItems = [];
            
            for (let i = 0; i < totalItems; i++) {
                const key = localStorage.key(i);
                if (key && !itemsToKeep.includes(key)) {
                    deletedItems.push(key);
                    localStorage.removeItem(key);
                    i--; // 항목이 삭제되면 인덱스 조정
                }
            }
            
            console.log(`캐시 정리 완료: ${deletedItems.length}개 항목 삭제됨`);
            if (deletedItems.length > 0) {
                console.log("삭제된 항목:", deletedItems);
            }
            
            return `캐시 정리 완료: ${deletedItems.length}개 항목 삭제됨`;
        };
        
        // 에러 로깅 개선
        const originalConsoleError = console.error;
        console.error = function() {
            // 원래 에러 로깅 실행
            originalConsoleError.apply(console, arguments);
            
            // 추가 디버깅 정보
            const stack = new Error().stack;
            console.log("에러 발생 위치:", stack);
        };
        
        console.log("디버깅 도구가 설치되었습니다. 'window.clearAppCache()' 명령으로 앱 캐시를 정리할 수 있습니다.");
    });
})();
EOL

# index.html에 디버깅 스크립트 추가
echo "index.html 파일에 디버깅 스크립트 추가 중..."
if [ -f "$BUILD_DIR/index.html" ]; then
    # 기존 디버깅 스크립트 라인 제거
    sed -i '' '/debug\.js/d' "$BUILD_DIR/index.html"
    
    # </body> 태그 직전에 스크립트 삽입
    awk '/<\/body>/ { print "  <script src=\"debug.js\"></script>"; } { print }' "$BUILD_DIR/index.html" > "$BUILD_DIR/index.html.tmp"
    mv "$BUILD_DIR/index.html.tmp" "$BUILD_DIR/index.html"
    
    echo "index.html 파일 수정 완료"
else
    echo "오류: index.html 파일을 찾을 수 없습니다."
    exit 1
fi

echo "===== 완료 ====="
echo "디버깅 도구가 빌드에 추가되었습니다."
echo "앱에서 콘솔 명령 'window.clearAppCache()'를 실행하여 앱 캐시를 정리할 수 있습니다."
