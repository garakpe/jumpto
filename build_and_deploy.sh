#!/bin/bash

# 프로젝트 디렉토리로 이동
cd /Users/smartchoi/Desktop/jumpto

# 기존 빌드 정리
flutter clean

# 의존성 다운로드
flutter pub get

# 웹 빌드 생성
flutter build web

# 필요한 데이터 디렉토리 생성
mkdir -p build/web/assets/data
mkdir -p build/web/assets/school_code

# 에셋 파일 직접 복사
cp assets/data/paps_standards.json build/web/assets/data/
cp assets/data/paps_standards.json build/web/

# school_code 폴더 내 파일들 복사
cp assets/school_code/*.json build/web/assets/school_code/

# Firebase 배포
firebase deploy 

echo "빌드 및 배포 완료. 웹사이트에서 확인해보세요."
