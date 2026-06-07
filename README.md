# mattermost-arm64-build

ARM64 서버용 Mattermost Team Edition 이미지를 공식 Mattermost 릴리스 기준으로 빌드해서 GHCR에 푸시하는 빌드 전용 저장소입니다.

## 목적

- 업스트림 기준: `mattermost/mattermost`의 stable GitHub release
- 버전 선택: draft/prerelease/RC 제외 후 semver 기준으로 가장 높은 `vX.Y.Z` 선택
- 빌드 소스: `https://releases.mattermost.com/<version>/mattermost-team-<version>-linux-arm64.tar.gz`
- 배포 대상: `ghcr.io/madrobotnet/mattermost-arm64-build`
- 운영 원칙: 서버는 제3자 이미지를 직접 pull하지 않고, 이 저장소가 만든 이미지만 사용

## 자동 업데이트 동작

워크플로우는 **하루 1회** Mattermost GitHub release 목록을 확인합니다.

- GitHub API로 `mattermost/mattermost` release 전체를 조회합니다.
- `draft`, `prerelease`, `rc` 버전은 제외합니다.
- 남은 `vX.Y.Z` stable 버전들을 semver 기준으로 정렬합니다.
- 저장소 루트의 `VERSION`보다 높은 버전이 있으면 ARM64 이미지를 빌드하고 GHCR에 푸시합니다.
- 새 stable 버전이 없거나, 더 낮은 유지보수 릴리스만 발견되면 빌드를 생략합니다.

즉, 이 저장소는 **공식 stable release 증가 감지 → 해당 버전의 공식 ARM64 tarball 검증 → GHCR 이미지 갱신** 흐름으로 동작합니다.

## 왜 `/releases/latest`를 쓰지 않나

Mattermost는 여러 release train을 동시에 유지합니다.
예를 들어 `11.7.x`, `11.6.x`, `11.5.x`, `10.11.x`가 비슷한 시점에 같이 올라올 수 있습니다.

GitHub의 `/releases/latest`는 이 상황에서 우리가 원하는 “가장 높은 stable Mattermost 버전”과 다르게 흔들릴 수 있습니다.
그래서 이 저장소는 `/releases/latest`를 믿지 않고, release 목록을 직접 조회해 **가장 높은 stable semver**만 추적합니다.

예:

```text
현재 VERSION = 11.7.2
감지된 stable 최고 = 11.5.8  → 빌드 생략
감지된 stable 최고 = 11.8.0  → 빌드/푸시
```

## 이미지 태그 정책

워크플로우는 빌드 성공 시 다음 태그를 푸시합니다.

예: `11.7.2` 빌드 시

- `ghcr.io/madrobotnet/mattermost-arm64-build:11.7.2`
- `ghcr.io/madrobotnet/mattermost-arm64-build:11.7`
- `ghcr.io/madrobotnet/mattermost-arm64-build:11`
- `ghcr.io/madrobotnet/mattermost-arm64-build:latest`

## 권장 운영 방식

### 빌드

- `schedule`: 매일 Mattermost stable release 목록을 확인하고, **VERSION보다 높은 버전이 있을 때만** 빌드합니다.
- `workflow_dispatch`: 특정 버전을 수동 입력해 강제 빌드할 수 있습니다.
- `push`: `Dockerfile` 또는 `.github/workflows/build.yml`이 바뀌면 현재 기록된 stable 버전을 재빌드합니다. README 수정만으로는 이미지를 재빌드하지 않습니다.

### 배포

서버는 `latest`를 사용해도 됩니다.

```env
MATTERMOST_IMAGE=ghcr.io/madrobotnet/mattermost-arm64-build
MATTERMOST_IMAGE_TAG=latest
```

다만 `latest`는 새 stable upstream release가 반영되면 다음 pull 때 바로 따라갑니다.
운영에서 더 보수적으로 가고 싶으면 `11.7.2`처럼 patch 버전 태그를 고정하세요.

## GitHub Actions 권한

이 저장소는 아래 권한이 필요합니다.

- Actions: Read and write permissions
- Packages: write
- Contents: write

## 수동 빌드

GitHub Actions → `Build and Publish Mattermost ARM64` → `Run workflow`

- `version` 비우기: 현재 가장 높은 stable release 빌드
- `version` 입력: 해당 버전으로 강제 빌드

## 참고

- 이 저장소는 Mattermost 소스 저장소 fork가 아닙니다.
- 업스트림 Mattermost Team Edition ARM64 릴리스 tarball을 Docker 이미지로 재패키징하는 운영 저장소입니다.
- 공식 Mattermost Docker 이미지가 ARM64를 안정적으로 제공하기 전까지 이 저장소의 GHCR 이미지를 사용합니다.
