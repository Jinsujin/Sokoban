# STEP3. 소코반 게임 완성하기

### 파일

프로그램 시작

- main: 게임에 사용할 데이터를 초기화 하고, 출력을 제어 합니다

Class

- GameMap: 맵을 2차원 배열로 저장하고 화면에 출력합니다.
- StageModel: 스테이지를 관리와 입력키에 대한 액션을 처리합니다.

Struct & Enum

- Stage: 게임 스테이지 하나를 Struct 로 관리합니다.
- Command: 키값에 대한 case 를 정의합니다.
- GameItem: 지도에 위치한 아이템의 case 를 정의합니다.

Message

- 메시지를 관리합니다.

## 1. 초기화

게임 시작 메시지를 출력하고, 게임 실행에 필요한 데이터와 로직을 구현한 StageModel 인스턴스를 생성합니다.

1. 게임 시작 메시지를 출력하고, StageModel 인스턴스를 생성합니다
2. StageModel 은 초기화시 GameMap을 통해 txt 파일로 부터 데이터를 읽어옵니다.
   그리고 String 형태의 데이터를 Stage 구조체로 변환하여 멤버변수인 stages에 할당합니다.
   클리어 조건(`isClearGame`)과 현재 몇번째 스테이지인지(`currentStageIndex`) 에 대한 정보를 변수로 가지고 있습니다.

```swift
// 1
print(MS.welcome)
let model = StageModel()
model.printStartStage()

mainLoop(isContinueGame: true, isClear: false)

// StageModel.swift
final class StageModel {
	var stages: [Stage] = []
	var currentStageIndex: Int
	var isClearGame = false
	let map = GameMap()

	// 2
	init() {
        self.currentStageIndex = 0
        self.stages = map.getAllStages()
    }
...
}
```

loadMapFromTxtFile 은 맵을 초기화 할때도 쓰이므로, 함수로 분리했습니다.

```swift
// GameMap.swift
func reloadedStages() -> [Stage] {
    loadMapFromTxtFile()
    return self.stages
}

private func loadMapFromTxtFile() {
    guard let fetchString = fetchTextFile() else {
        fatalError("ERROR: fetch fail")
    }
    self.stages = convertMapArray(from: fetchString)
}
```

## 2. 키 입력에 따른 분기

Step2 에서 플레이어만 처리하던 메서드를 변경했습니다.

action 메서드는 크게 3가지 과정으로 나뉩니다.

1. 입력 키가 종료, 스테이지 초기화 일때
   - 아이템이동, 플레이어 이동이 필요 없으므로 빠른 리턴을 합니다.
2. 아이템 밀기
   - `pushItem` 은 아이템을 성공적으로 이동했느냐를 Bool로 반환합니다.
   - 이동하지 못했을 경우에는, 아래의 플레이어 이동까지 처리하지 못하도록 return 합니다.
3. 플레이어 이동
   - 여기까지 왔다면, 아이템을 성공적으로 밀었으므로 플레이어를 이동시킵니다.

```swift
private func action(to command: Command) -> (map: String?, isSuccess: Bool) {
    // 1
    switch command {
    case .QUIT:
        return (stages[currentStageIndex].mapToString(), false)
    case .RELOAD:
				self.stages = map.reloadedStages()
        return (stages[currentStageIndex].mapToString(), true)
    default: break
    }

    let currentPoint = stages[currentStageIndex].playerPoint
    guard let targetPoint: CGPoint = calcTargetPoint(from: currentPoint, command: command) else {
        return (stages[currentStageIndex].mapToString(), false)
    }
    guard let targetItem = convertItemFromCharacter(point: targetPoint) else {
        fatalError("ERROR:: Cannot converted item")
    }
	// 2
    if !targetItem.isPassableByPlayer
        && !pushItem(item: targetItem, from: targetPoint, command: command) {
        return (stages[currentStageIndex].mapToString(), false)
    }

	// 3
    movePlayer(from: currentPoint, to: targetPoint)
    return (stages[currentStageIndex].mapToString(), true)
}
```

### 2-1. 아이템 밀기

```
// Command.Right
(플레이어->) item -> nextItem
(플레이어->) 공 -> 비어있다 //밀기 가능
(플레이어->) 공 -> 공     //밀기 불가
```

1. 먼저 item 을 이동시킬 지점(CGPoint)에 어떤 아이템이 자리하고 있는지 찾습니다.
2. item 이 움직일 수 있고(`isMoveableByPlayer`), nextItem 이 플레이어가 이동가능한(`isPassableByPlayer`) 경우에만 아이템을 밀 수 있습니다.
3. nextItem 이 무엇인지에 따라 이동하고, 현재 스테이지의 맵을 갱신합니다.

```swift
private func pushItem(item: GameItem, from: CGPoint, command: Command) -> Bool {
    // 1
    guard let nextPointOfPushItem = calcTargetPoint(from: from, command: command),
    let nextItem = convertItemFromCharacter(point: nextPointOfPushItem) else {
        return false
    }

    // 2
    if !item.isMoveableByPlayer && !item.isPassableByPlayer  {
        return false
    }

    switch nextItem {
    case .empty:
        if item == .ball {
            updateCurrentMapItem(target: from, item: GameItem.empty)
            updateCurrentMapItem(target: nextPointOfPushItem, item: item)
        } else if item == .filled { // 공을 구멍에서 빼낸다
            updateCurrentMapItem(target: from, item: GameItem.hall)
            updateCurrentMapItem(target: nextPointOfPushItem, item: GameItem.ball)
            stages[currentStageIndex].ballCount += 1
        }
        return true
    case .hall:
        updateCurrentMapItem(target: from, item: GameItem.empty)
        updateCurrentMapItem(target: nextPointOfPushItem, item: GameItem.filled)
        stages[currentStageIndex].ballCount -= 1
        return true
    default:
        break
    }
    return false
}
```

GameItem 에 구멍에 박스가 들어간 case filled 를 추가했습니다.

플레이어가 움직일 수 있는 아이템인지 플레이어가 통과할 수 있는 아이템인지에 대한 정보를 Boolean 으로 제공하도록 하였습니다.

```swift
enum GameItem: Int {
    ...
    case filled = 6

    var isMoveableByPlayer: Bool {
		switch self {
		case .ball: return true
		case .filled: return true
			...생략
	}

	var isPassableByPlayer: Bool {
		switch self {
		case .hall: return true
		case .empty: return true
			...생략
	}
}
```

### 2-2. 플레이어 이동

이동할 위치에 어떤 아이템(targetItem) 이 있느냐에 따라 분기처리 합니다.

```swift
private func movePlayer(from: CGPoint, to: CGPoint) {
    guard let targetItem = convertItemFromCharacter(point: to) else {
        fatalError("ERROR:: Cannot converted item")
    }

    if !targetItem.isPassableByPlayer {
        return
    }

    let isAboveHall = stages[currentStageIndex].isAboveHall

    switch targetItem {
    case .empty:
        if isAboveHall {
            updateCurrentMapItem(target: from, item: GameItem.hall)
        } else {
            updateCurrentMapItem(target: from, item: GameItem.empty)
        }
        stages[currentStageIndex].isAboveHall = false
    case .hall:
        if isAboveHall {
            updateCurrentMapItem(target: from, item: GameItem.hall)
        } else {
            updateCurrentMapItem(target: from, item: GameItem.empty)
        }
        stages[currentStageIndex].isAboveHall = true
    default:
        fatalError()
    }
    updateCurrentMapItem(target: to, item: GameItem.player)
    stages[currentStageIndex].playerPoint = to
    stages[currentStageIndex].turn += 1
}
```

Stage 구조체에 플레이어가 구멍 위에 있는지에 대한 속성을 추가했습니다.

```swift
struct Stage {
    ...
    var isAboveHall = false
    var turn = 0
}
```

## 3. 로직 처리를 도와주는 함수들

### 3-1. 이동할 좌표 계산

상하좌우 키에 따라 다음 위치를 연산하여 반환합니다.

```swift
private func calcTargetPoint(from currentPoint: CGPoint, command: Command) -> CGPoint? {
    let targetPoint: CGPoint
	switch command {
    case .UP:
	    targetPoint = CGPoint(x: currentPoint.x, y: currentPoint.y - 1)
    case .DOWN:
	    targetPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + 1)
	case .RIGHT:
	    targetPoint = CGPoint(x: currentPoint.x + 1, y: currentPoint.y)
	case .LEFT:
	    targetPoint = CGPoint(x: currentPoint.x - 1, y: currentPoint.y)
	default:
	    targetPoint = currentPoint
	}
	return (validatePointFromMap(targetPoint) ? targetPoint : nil)
}
```

### 3-2. 좌표의 유효성 검사

이동할 지점의 좌표가 현재 map 에서 유효한지 검사합니다.

```swift
private func validatePointFromMap(_ point: CGPoint) -> Bool {
    let stage = self.stages[currentStageIndex]
    let y = Int(point.y)
    let x = Int(point.x)
    if y < stage.height && x < stage.map[y].count {
        return true
    }
    return false
}
```

### 3-3. 맵의 특정좌표 업데이트

현재 스테이지 맵의 위치를 item 으로 변경합니다.

```swift
private func updateCurrentMapItem(target point: CGPoint, item: GameItem) {
    stages[currentStageIndex].map[Int(point.y) - 1][Int(point.x) - 1] = item.symbol
}
```

### 3-4. 맵의 특정좌표 아이템 얻기

현재 스테이지 맵에서 특정 좌표에 있는 문자를 GameItem 로 변환하여 반환합니다.

```swift
private func convertItemFromCharacter(point: CGPoint) -> GameItem? {
    let map = stages[currentStageIndex].map
    if !validatePointFromMap(point) {
        return nil
    }
    let x = max(Int(point.x) - 1, 0)
    let y = max(Int(point.y) - 1, 0)
    let itemChar = map[y][x]
    return GameItem.convertItem(by: itemChar)
}
```

## 4. 게임 클리어 & 종료

게임이 클리어 되었는지 처리하기 위해 `isClear` 플래그를 추가했습니다:

```swift
// main.swift
func mainLoop(isContinueGame: Bool, isClear: Bool) {
    if !isContinueGame {
        print(Command.QUIT.message)
        return
    }

    if isClear {
        print(MS.clearGame)
        return
    }
    ...
}
```

입력값을 처리하는 action 함수에서 각각의 키값을 처리한 후, 스테이지와 게임 클리어 조건을 확인하고 게임을 계속 진행 할건지에 대한 여부(`isClear`)를 결정합니다.

```swift
// main.swift
func oneKeyAction(_ command: Command) -> Bool {
    // ...하나의 키에 대한 로직 수행...
    if model.checkStageClear() {
        model.printStartStage()
    }

    if model.checkGameClear() {
        return true
    }
    return false
}

func action(by inputString: String, completion: (Bool, Bool)-> Void) {
    ...
		var isContinueGame = true
    var isClear = false
		// ...oneKeyAction()....
    completion(isContinueGame, isClear)
}
```

checkStageClear 는 현재 스테이지에서 공을 모두 넣어 완료 했는지 검사합니다.

1. 스테이지 결과를 출력합니다.
2. 다음 스테이지 index 를 설정합니다.
3. 클리어한 스테이지가 마지막 스테이지인지 체크하여 게임을 모두 끝마쳤는지 확인합니다.
   조건을 만족하면, isClearGame 를 true로 변경합니다.

```swift
// StageModel.swift
func checkStageClear() -> Bool {
    if !(stages[currentStageIndex].ballCount == 0) {
        return false
    }
    // 1
    let prevIdx = currentStageIndex
    printResult(prevIdx)

		// 2
    self.currentStageIndex = min(stages.count - 1, prevIdx + 1)

		// 3
    if prevIdx == currentStageIndex {
        isClearGame = true
    }
    return true
}

func checkGameClear() -> Bool {
    return isClearGame
}
```

## 5. Text 파일 읽기

"/file:///Users/사용자/Documents/map.txt" 경로의 파일을 읽어 문자열을 반환합니다.

```swift
// GameMap.swift
private func fetchTextFile() -> String? {
    let fileName = "map"
    guard let dir = try? FileManager
                        .default
                        .url(for: .documentDirectory,
                             in: .userDomainMask, appropriateFor: nil, create: true) else {
        return nil
    }
    let fileURL = dir.appendingPathComponent(fileName).appendingPathExtension("txt")
    do {
        let result = try String(contentsOf: fileURL)
        return result
    } catch {
        print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
    }
    return nil
}
```
