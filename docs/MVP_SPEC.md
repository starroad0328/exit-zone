# Exit Zone - MVP 스펙 문서

## 0. 한 줄 정의
> **Exit Zone** - 기지에서 준비 → 파밍존 돌입 → 시간 제한 파밍 & 전투 → 탈출 → 디펜스 웨이브 → 기지 복귀 후 성장하는 2D 탑다운 추출 슈터

---

## 1. 코어 게임 루프

```
[메뉴] → [기지] → [파밍존] → [디펜스 레이드] → [결과] → [기지]
              ↑                                              ↓
              └──────────────────────────────────────────────┘
```

### 1.1 기지 (Base)
- 퀘스트 수락/완료
- 스태시 확인
- 제작(크래프트)
- 로드아웃 구성
- 레이드 출발

### 1.2 파밍존 (Field Raid)
- 랜덤 스폰 위치
- **시간 제한: 3분**
- 적과 전투, 루트박스 파밍
- 시간 초과 시 **시련(TRIAL)** 발동
- 탈출 지점 도달 → 디펜스 존 이동

### 1.3 디펜스 레이드 (Defense Raid)
- 웨이브 디펜스 (2~3웨이브)
- 사망 시 파밍분 전부 손실
- 웨이브 생존 → 기지 도착

### 1.4 기지 복귀
- 파밍분 → 스태시 저장
- 퀘스트 진행/완료
- XP → 레벨업
- 제작법 해금

---

## 2. 플레이어 시스템

### 2.1 조작
| 키 | 동작 |
|---|---|
| WASD | 이동 |
| 마우스 | 조준 |
| 좌클릭 | 사격 |
| R | 리로드 |
| F | 상호작용 |
| Q | 붕대 사용 |
| E | 에너지 드링크 사용 |
| Space | 회피(대쉬) |
| Shift | 스프린트 |

### 2.2 스탯
- HP: 100
- 스테미나: 100
- 이동 속도: 220 (스프린트: 330)

### 2.3 스테미나
- **소모**
  - 스프린트: 초당 12
  - 회피: 25
- **회복**
  - 기본: 초당 5
  - 에너지 드링크: 즉시 +40

### 2.4 회피
- 방향 + Space
- 0.2초 대쉬, 0.15초 무적
- 스테미나 25 소모

### 2.5 회복
- 붕대: HP +30
- 쿨타임: 3초

---

## 3. 아이템 시스템

### 3.1 무기
| ID | 이름 | 탄종 |
|---|---|---|
| p1_sidearm | P1 Sidearm | 9mm |
| smg_alpha | SMG-Alpha | 9mm |
| ar15_ranger | AR-15 Ranger | 5.56mm |

### 3.2 소모품
- ammo_9mm: 9mm 탄약
- ammo_556: 5.56mm 탄약
- bandage: 붕대
- energy_drink: 에너지 드링크

### 3.3 재료
| ID | 이름 | 용도 |
|---|---|---|
| scrap_metal | 고철 | 탄약/무기 제작 |
| gun_parts | 총기부품 | 무기 제작 |
| cloth | 천 | 붕대 제작 |
| chemicals | 화학물질 | 탄약/에너지 드링크 |

### 3.4 인벤토리 구조
- **레이드 인벤토리**: 레이드 중 획득, 사망 시 삭제
- **스태시**: 기지 영구 저장소
- **로드아웃**: 레이드 출발 전 설정

---

## 4. 기지 시스템

### 4.1 퀘스트
| ID | 이름 | 타입 | 목표 | 보상 |
|---|---|---|---|---|
| kill_scav_10 | Scav 사냥꾼 | kill | 10마리 | 100 XP, 9mm 30발 |
| survive_3 | 생존 전문가 | raid_survive | 3회 | 150 XP, SMG 해금 |
| collect_scrap_20 | 재료 수집가 | collect | 고철 20개 | 80 XP, 부품 5개 |

### 4.2 제작 레시피
| 결과물 | 재료 | 블루프린트 필요 |
|---|---|---|
| 붕대 x2 | 천 2 | bandage |
| 에너지 드링크 | 화학물질 2 | energy_drink |
| 9mm 탄약 x15 | 고철 2, 화학물질 1 | p1_sidearm |
| 5.56mm 탄약 x10 | 고철 3, 화학물질 2 | ar15_ranger |
| SMG-Alpha | 고철 10, 부품 5 | smg_alpha |
| AR-15 Ranger | 고철 15, 부품 8, 화학물질 3 | ar15_ranger |

### 4.3 레벨업 해금
| 레벨 | 해금 |
|---|---|
| 2 | smg_alpha |
| 3 | energy_drink |
| 5 | ar15_ranger |
| 7 | armor_light |

---

## 5. 파밍존 - 시련(TRIAL)

### 5.1 시간 제한
- 기본 시간: 180초 (3분)
- UI 카운트다운 표시
- 30초 이하: 빨간색 경고

### 5.2 시련 발동 (시간 초과)
- Phase 1 (0~10초): 강화 Scav 3마리
- Phase 2 (10~20초): 강화 Scav + 러너 5마리
- Phase 3 (20~30초): 대량 스폰 8마리

### 5.3 러너
- HP: 20
- 속도: 180 (매우 빠름)
- 데미지: 8
- 녹색 표시

---

## 6. 적 AI

### 6.1 Scav (기본)
- HP: 30
- 속도: 90
- 데미지: 10
- 감지 범위: 200
- XP: 10

### 6.2 강화 Scav
- HP: 40
- 속도: 117 (+30%)
- 데미지: 12
- 빨간색 표시
- XP: 15

### 6.3 러너
- HP: 20
- 속도: 180
- 데미지: 8
- 녹색 표시
- XP: 10

---

## 7. 저장 시스템

### 7.1 저장 데이터
```json
{
  "player_level": 1,
  "player_xp": 0,
  "total_kills": 0,
  "successful_raids": 0,
  "unlocked_blueprints": ["p1_sidearm", "bandage"],
  "completed_quest_ids": [],
  "active_quests": [],
  "stash": {
    "weapons": ["p1_sidearm"],
    "ammo_9mm": 60,
    "ammo_556": 30,
    "bandage": 5,
    "energy_drink": 2,
    "scrap_metal": 10,
    "gun_parts": 5,
    "cloth": 8,
    "chemicals": 3
  }
}
```

### 7.2 저장 시점
- 레이드 성공 시
- 퀘스트 완료 시
- 제작 완료 시

---

## 8. 씬 구조

```
scenes/
├── main/
│   ├── menu.tscn          # 메인 메뉴
│   ├── base.tscn          # 기지
│   ├── field_raid.tscn    # 파밍존
│   ├── defense_raid.tscn  # 디펜스 레이드
│   └── result_screen.tscn # 결과 화면
├── entities/
│   ├── player.tscn
│   ├── scav.tscn
│   ├── projectile.tscn
│   ├── loot_box.tscn
│   └── extraction_zone.tscn
```

---

## 9. 스크립트 구조

```
scripts/
├── autoload/
│   ├── game_state.gd       # 게임 상태, 레벨, 퀘스트, 저장
│   └── inventory_manager.gd # 인벤토리, 스태시, 크래프팅
├── player/
│   └── player.gd           # 이동, 사격, 스테미나, 회피
├── enemies/
│   └── scav.gd             # 적 AI
├── items/
│   ├── loot_box.gd
│   └── extraction_zone.gd
├── main/
│   ├── base.gd
│   ├── field_raid.gd       # 시간제한, 시련
│   ├── defense_raid.gd     # 웨이브 스폰
│   └── field_map_generator.gd
├── ui/
│   ├── hud.gd
│   ├── menu.gd
│   ├── result_screen.gd
│   ├── quest_panel.gd
│   ├── craft_panel.gd
│   ├── stash_panel.gd
│   └── loadout_panel.gd
└── weapons/
    ├── weapon_data.gd
    └── projectile.gd
```

---

## 10. 입력 액션

| 액션명 | 키 |
|---|---|
| move_up | W |
| move_down | S |
| move_left | A |
| move_right | D |
| shoot | 마우스 좌클릭 |
| reload | R |
| interact | F |
| heal | Q |
| use_energy | E |
| sprint | Shift |
| dodge | Space |

---

## 11. 구현 완료 체크리스트

- [x] GameState 확장 (레벨, XP, 퀘스트, 블루프린트, 저장/로드)
- [x] InventoryManager 확장 (재료, 크래프팅, 스태시 관리)
- [x] 플레이어 스테미나 시스템
- [x] 플레이어 회피(대쉬) 시스템
- [x] 에너지 드링크 사용
- [x] 기지 씬 (퀘스트/제작/스태시/로드아웃 UI)
- [x] 퀘스트 시스템 (수락/진행/완료)
- [x] 크래프팅 시스템
- [x] 파밍존 시간 제한
- [x] 시련(TRIAL) 시스템 (3페이즈)
- [x] 러너 적 타입
- [x] 루트박스 재료 드롭
- [x] HUD 업데이트 (스테미나, 타이머, 시련 경고)
- [x] 메뉴 화면 업데이트
- [x] 결과 화면 업데이트

---

## 12. 향후 확장 가능

- 미니맵
- 더 많은 무기/적 종류
- 방어구 시스템
- 보스 몹
- 멀티플레이어
- 추가 맵
