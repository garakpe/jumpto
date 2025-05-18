#!/bin/bash

# 웹 빌드 생성
echo "Flutter 웹 빌드 중..."
flutter clean && flutter pub get && flutter build web --release

# 중요: assets 폴더 복사
echo "assets 폴더 복사 중..."

# 1. paps_standards.json 복사
mkdir -p build/web/assets/data
cp -f assets/data/paps_standards.json build/web/assets/data/
cp -f assets/data/paps_standards.json build/web/

# 2. school_code 폴더 모든 JSON 파일 복사
mkdir -p build/web/assets/school_code
cp -f assets/school_code/*.json build/web/assets/school_code/

# assets 복사 확인
echo "복사된 파일 확인:"
ls -la build/web/assets/data/
ls -la build/web/assets/school_code/

# 배포 시작 (y/n 물어봄)
read -p "Firebase 배포 시작할까요? (y/n): " deploy
if [ "$deploy" = "y" ] || [ "$deploy" = "Y" ]; then
  firebase deploy
  echo "배포 완료!"
else
  echo "배포 건너뜀. 빌드는 build/web/ 폴더에 있습니다."
fi
