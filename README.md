# STEP1. 지도 데이터 출력하기

### 파일

- main.swift: 게임에 사용할 데이터를 초기화 하고, 출력을 제어 합니다
- GameMap.swift: 맵을 2차원 배열로 저장하고 화면에 출력합니다.
- GameStruct.swift: 앱 내에서 로직에 사용 될 struct와 enum이 정의되어 있습니다.
- Messages.swift: 메시지를 관리합니다.

### 변경 사항

1. 각 아이템 구분이 어려워 문자를 변경했습니다.
   - ball: o ⇒ B
   - 공이 들어있는 구멍: 0 ⇒ X
2. 스테이지 구분을 위한 문자열을 하단에 추가했습니다

   ```
   Stage 1
   ...
   =====
   Stage 2
   ...
   =====
   ```

## 1. 초기화

맵 처리를 담당하는 GameMap 인스턴스를 생성합니다.

```swift
// main.swift
let gameMap = GameMap()
```

생성자를 호출하면, fetchMap 메서드를 통해 문자열을 구조체로 변환한 후, 배열에 저장합니다.

```swift
// GameMap.swift
	var stages: [Stage] = []

	init() {
		self.stages = fetchMap()
	}
	private func convertMapArray(from mapData: String) {
		...맵 변환 처리...
	}
}
```

## 2. 맵 변환

### 2-1. Stage 구조체 정의

Stage 구조체는 다음과 같이 정의되어 있습니다.

map 은 문자로 이루어진 2차원 배열이며, dimensionalArray 는 Int 로 이루어진 2차원 배열입니다.

```swift
typealias GameMapType = [[Character]]

struct Stage {
    var map = GameMapType()
    var dimensionalArray = [[Int]]()
    var width = 0
    var height = 0
    var hallCount = 0
    var ballCount = 0
    var playerPoint = CGPoint(x: 0, y: 0)
}
```

Stage 는 생성할때 게임맵을 인자로 받아 이를 기반으로 자신의 속성값을 갱신 합니다.

```swift
extension Stage {
    init(_ gameMap: GameMapType) {
        self.map = gameMap
        self.width = gameMap.map({ $0.count }).max() ?? 0
        self.height = gameMap.count

        self.ballCount = gameMap.flatMap({ $0 })
            .filter({ $0 == GameItem.ball.symbol })
            .count
        self.hallCount = gameMap.flatMap({ $0 })
            .filter({ $0 == GameItem.hall.symbol })
            .count
        self.playerPoint = findPlayerPoint(gameMap)
        self.dimensionalArray = makeIntMap(gameMap)
    }
}
```

### 2-2. 게임 맵 변환

먼저 convertMapCharArray 함수를 통해 String 으로 저장된 맵 데이터를 GameMapType 배열로 읽어 옵니다.

맵 정보만 들어 있는 배열을 사용해, Stage 를 생성할때 인자로 넘겨 나머지 속성값을 업데이트 하도록 설계했습니다.

```swift
private func fetchMap() -> [Stage] {
    let mapArray = convertMapCharArray(from: mapStringData)
    var stages = [Stage]()
    for map in mapArray {
        let stage = Stage(map)
        stages.append(stage)
    }
    return stages
}

private func convertMapCharArray(from mapData: String) -> [GameMapType] {...}
```

### 2-3. 문자열 맵 데이터 처리

반복문을 돌며 문자 하나씩을 읽습니다.

여기서는 맵 정보만 있으면 되므로 아래와 같은 txt 파일을 읽어야 할때

"Stage 1, =====" 를 제외하고 해당하는 문자만 필터링 하여 GameMapType 배열로 반환합니다.

```
Stage 1
#####
#OBP#
#####
=====
```

```swift
private func convertMapCharArray(from mapData: String) -> [GameMapType] {
    var mapArray = [GameMapType]()
    var map = GameMapType()
    var lineString = String()

    for char in mapData {
        if !char.isNewline {
            lineString.append(char)
            if lineString == MS.divideLine {
                mapArray.append(map)
                map = GameMapType()
            }
            continue
        }

        if lineString.hasPrefix(MS.stageTitle) {
            lineString = ""
               continue
           }
        if !lineString.hasPrefix(String(GameItem.stageDivide.symbol)) {
            map.append(Array(lineString)) // #OBP# 한줄을 2차 배열에 추가
        }
        lineString = ""
    }
    return mapArray
}
```

## 3. 화면 출력

main 에서 맵정보 출력을 위해 printAllStageInfo 메서드를 호출합니다.

```swift
// main.swift
gameMap.printAllStageInfo()
```

GameMap 인스턴스를 초기화 할때 저장해 두었던 속성인 stages 를 이용해

반복문을 돌며 각 stage 에 대한 정보를 출력합니다.

```swift
// GameMap.swift
var stages: [Stage] = []

func printAllStageInfo() {
    for (i, stage) in stages.enumerated() {
        let infoString = stageInfoToString(stage, index: i)
        print(infoString)
    }
}

private func stageInfoToString(_ stage: Stage, index: Int) -> String {
    let colon = ":"
    return """

    \(MS.stageTitle) \(index + 1)

    \(stage.mapToString())

    \(MS.width)\(colon) \(stage.width)
    \(MS.height)\(colon) \(stage.height)
    \(MS.hallCount)\(colon) \(stage.hallCount)
    \(MS.ballCount)\(colon) \(stage.ballCount)
    \(MS.playerPoint)\(colon) (\(stage.playerPoint.x), \(stage.playerPoint.y))
    """
}
```

출력에 필요한 메시지는 구조체로 정의해 사용했습니다.

```swift
// Messages.swift
struct MS {
    static let prompt = "SOKOBAN>"
    static let stageTitle = "Stage"
    static let br = "\n"

    static let width = "가로크기"
    static let height = "세로크기"
    static let hallCount = "구멍의 수"
    static let ballCount = "공의 수"
    static let playerPoint = "플레이어 위치"

    static let divideLine = "====="
}
```
