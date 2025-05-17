#!/bin/bash

echo "==== 온라인 팝스 웹앱 빌드 및 배포 스크립트 ===="
echo "이 스크립트는 Flutter 웹앱을 빌드하고 Firebase에 배포합니다."
echo "실행 전 환경 확인 중..."

# Flutter 및 Firebase CLI 확인
if ! command -v flutter &> /dev/null; then
    echo "오류: Flutter가 설치되어 있지 않습니다."
    exit 1
fi

if ! command -v firebase &> /dev/null; then
    echo "오류: Firebase CLI가 설치되어 있지 않습니다."
    exit 1
fi

# 현재 디렉토리 저장
CURRENT_DIR=$(pwd)

# 프로젝트 디렉토리로 이동
cd /Users/smartchoi/Desktop/jumpto || { echo "프로젝트 폴더를 찾을 수 없습니다"; exit 1; }
echo "프로젝트 디렉토리: $(pwd)"
echo ""

# 현재 Git 상태 출력
if [ -d ".git" ]; then
    echo "Git 브랜치 정보:"
    git branch -v
    echo ""
    echo "Git 변경 사항:"
    git status -s
    echo ""
fi

# 사용자 확인
echo "계속 진행하시겠습니까? (y/n)"
read -r confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "빌드를 취소합니다."
    exit 0
fi

echo "===== 1단계: 기존 빌드 정리 ====="
flutter clean
if [ $? -ne 0 ]; then
    echo "Flutter clean 실패"
    exit 1
fi
echo ""

echo "===== 2단계: 의존성 다운로드 ====="
flutter pub get
if [ $? -ne 0 ]; then
    echo "Flutter pub get 실패"
    exit 1
fi
echo ""

echo "===== 3단계: 웹 빌드 생성 ====="
# 수정된 빌드 명령어 - web-renderer 옵션 제거
flutter build web --release
if [ $? -ne 0 ]; then
    echo "Flutter 웹 빌드 실패"
    exit 1
fi
echo ""

echo "===== 4단계: 에셋 처리 ====="
echo "필요한 데이터 디렉토리 생성 중..."
mkdir -p build/web/assets/data
mkdir -p build/web/assets/school_code

echo "에셋 파일 복사 중..."
cp assets/data/paps_standards.json build/web/assets/data/
cp assets/data/paps_standards.json build/web/

# 학교 코드 데이터 복사
if [ -d "assets/school_code" ]; then
    cp -r assets/school_code/*.json build/web/assets/school_code/
    echo "학교 코드 데이터 복사 완료"
else
    echo "경고: 학교 코드 데이터 폴더가 없습니다."
fi

echo "===== 5단계: 디버깅 도구 추가 ====="
# debug.js 파일 생성
cat > "build/web/debug.js" << 'EOL'
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
if [ -f "build/web/index.html" ]; then
    # 기존 디버깅 스크립트 라인 제거
    sed -i '' '/debug\.js/d' "build/web/index.html"
    
    # </body> 태그 직전에 스크립트 삽입
    awk '/<\/body>/ { print "  <script src=\"debug.js\"></script>"; } { print }' "build/web/index.html" > "build/web/index.html.tmp"
    mv "build/web/index.html.tmp" "build/web/index.html"
    
    echo "index.html 파일 수정 완료"
else
    echo "경고: index.html 파일을 찾을 수 없습니다."
fi

echo "===== 6단계: 파일 확인 ====="
echo "생성된 웹 파일:"
ls -la build/web/
echo ""
echo "에셋 데이터 파일:"
ls -la build/web/assets/data/
echo ""

echo "===== 7단계: Firebase 배포 ====="
echo "Firebase로 배포할까요? (y/n)"
read -r deploy_confirm

if [ "$deploy_confirm" == "y" ] || [ "$deploy_confirm" == "Y" ]; then
    echo "Firebase 배포 시작..."
    firebase deploy
    deploy_status=$?
    
    if [ $deploy_status -eq 0 ]; then
        echo "배포 성공!"
        echo "웹사이트: https://jumpto-web.web.app"
    else
        echo "배포 실패! 오류 코드: $deploy_status"
        exit 1
    fi
else
    echo "배포를 건너뜁니다. 빌드 파일은 build/web/ 폴더에 있습니다."
fi

echo "===== 8단계: 완료 ====="
echo "빌드 및 배포 프로세스가 완료되었습니다."
echo "참고: 브라우저에서 앱 사용 시 콘솔에 'window.clearAppCache()' 명령을 사용하여 앱 캐시를 정리할 수 있습니다."

# 원래 디렉토리로 돌아가기
cd "$CURRENT_DIR" || exit
