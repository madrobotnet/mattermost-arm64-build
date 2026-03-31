# mattermost-arm64-build

ARM64 서버용 Mattermost 이미지를 공식 Mattermost 릴리스 기준으로 빌드해서 GHCR에 푸시하는 빌드 전용 저장소입니다.

## 목적

- 업스트림 기준: `mattermost/mattermost` 릴리스 버전
- 빌드 소스: `https://releases.mattermost.com/<version>/mattermost-<version>-linux-arm64.tar.gz`
- 배포 대상: `ghcr.io/madrobot-collab/mattermost-arm64-build`
- 운영 원칙: 서버는 제3자 이미지를 직접 pull하지 않고, 이 저장소가 만든 이미지만 사용

## 이미지 태그 정책

워크플로우는 빌드 성공 시 다음 태그를 푸시합니다.

예: `11.5.1` 빌드 시

- `ghcr.io/madrobot-collab/mattermost-arm64-build:11.5.1`
- `ghcr.io/madrobot-collab/mattermost-arm64-build:11.5`
- `ghcr.io/madrobot-collab/mattermost-arm64-build:11`
- `ghcr.io/madrobot-collab/mattermost-arm64-build:latest`

## 권장 운영 방식

### 빌드
- `workflow_dispatch`로 특정 버전 수동 빌드 가능
- `schedule`로 최신 릴리스를 주기적으로 확인 후 빌드
- `push`(main) 시 Dockerfile/워크플로우 수정 검증 겸 재빌드 가능

### 배포
실서버 compose/.env는 항상 **정확한 패치 버전** 태그를 사용하세요.

```env
MATTERMOST_IMAGE=ghcr.io/madrobot-collab/mattermost-arm64-build:11.5.1
```

`latest`는 테스트용으로만 권장합니다.

## GitHub Actions 권한

이 저장소는 아래 권한이 필요합니다.

- Actions: Read and write permissions
- Packages: write
- Contents: read

## 수동 빌드

GitHub Actions → `Build and Publish Mattermost ARM64` → `Run workflow`

- version 비우면 최신 업스트림 릴리스 사용
- version 입력 시 해당 버전으로 고정 빌드

## 참고

- 이 저장소는 Mattermost 소스 저장소 fork가 아닙니다.
- 업스트림 릴리스를 참조해 ARM64 배포 이미지를 재패키징하는 운영 저장소입니다.
