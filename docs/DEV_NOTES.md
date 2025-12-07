# Exit Zone 개발 노트

## 작업 규칙

### Git 브랜치 전략
- **새 기능 만들 때마다 새 브랜치 만들어서 작업할 것**
- 브랜치 네이밍: `feature/기능명` (예: `feature/minimap`, `feature/boss-enemy`)
- 작업 완료 후 `dev` 브랜치에 머지
- `main`은 안정 버전만

### 브랜치 예시
```
main          <- 안정 릴리즈
dev           <- 개발 통합
feature/xxx   <- 새 기능 작업
fix/xxx       <- 버그 수정
```

### 작업 흐름
1. `git checkout dev`
2. `git checkout -b feature/새기능`
3. 작업 + 커밋
4. `git checkout dev && git merge feature/새기능`
5. 브랜치 삭제 또는 유지

---

## 현재 브랜치
- `dev` - MVP 개발 중

## 완료된 기능 (dev)
- 기지 시스템 (퀘스트/제작/스태시/로드아웃)
- 플레이어 스테미나/회피
- 파밍존 시간제한 + 시련(TRIAL)
- 레벨/XP/저장 시스템
- 재료 드롭

## TODO
- [ ] 미니맵
- [ ] 추가 적 타입
- [ ] 방어구 시스템
- [ ] 보스 몹
