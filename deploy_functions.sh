#!/bin/bash

# 현재 디렉토리를 Firebase Functions 경로로 이동
cd /Users/smartchoi/Desktop/jumpto/firebase/functions

# NPM 의존성 설치
echo "NPM 의존성을 설치하는 중..."
npm install

# Firebase Functions 배포
echo "Firebase Functions 배포 중..."
firebase deploy --only functions

echo "Firebase Functions 배포 완료!"
