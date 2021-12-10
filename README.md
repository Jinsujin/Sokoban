# STEP2. 플레이어 이동 구현하기

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

현재 스테이지를 2부터 보여 줄 수 있도록, 생성자에 인자를 넘겨 StageModel 인스턴스를 생성합니다.

```swift
let model = StageModel(stageNumber: 2)
printWelcome()
mainLoop(isContinueGame: true)

// Class StageModel.swift
init(stageNumber: Int) {
	self.currentStageIndex = stageNumber - 1
	let map = GameMap()
	self.stages = map.getAllStages()
}
```

## 2. 명령어 처리

mainLoop는 계속해서 prompt 를 통해 입력값을 받아 처리해야 하기에 재귀함수 형태로 되어 있습니다.

내부에서 자기자신을 부르는게 아닌, action 에서 입력값 처리 후 결정할 수 있도록 설계하였습니다.

action 함수에서 루프를 계속 돌지 isContinueGame 값을 통해 결정합니다.

```swift
// main.swift
func mainLoop(isContinueGame: Bool) {
    if !isContinueGame {
        print(Command.QUIT.message)
        return
    }
    print(MS.prompt, terminator: "")

    let input = readLine() ?? ""
    let inputLower = input.lowercased()
    action(by: inputLower, completion: mainLoop)
}
```

입력값을 처리하는 action 함수는 입력 문자열(inputString) 와, 키입력 처리후 실행 할 함수(completion)를 인자로 받습니다.

completion 를 통해 로직 수행 후 게임을 계속 진행할 것인지 여부를 결정합니다.

```swift
func action(by inputString: String, completion: (Bool)-> Void) {
    let inputArray = Array(inputString)
    var isContinueGame = true

    for input in inputArray {
        guard let command = Command(rawValue: input) else {
            print(MS.notAvailableKey(input))
            continue
        }

        if command == .QUIT {
            isContinueGame = false
            break
        }
        oneKeyAction(command)
    }
    completion(isContinueGame)
}

// Messages.swift- struct MS
static func notAvailableKey(_ key: Character) -> String {
    return "(경고!) \(key.uppercased()) 키는 가능한 입력이 아닙니다. 처리를 건너뜁니다."
}
```

하나의 입력키에 대한 액션을 처리합니다.

```swift
func oneKeyAction(_ command: Command) {
    let moveResult = model.move(to: command)
    if let map = moveResult.map {
        print(map)
    }
    print(moveResult.systemInfo)
}
```

## 3. 키 입력

게임에 대한 로직을 처리하는 StageModel 클래스는 2개의 멤버변수를 가집니다.

currentStageIndex 값에 따라 현재 스테이지가 무엇인지 판별됩니다.

```swift
final class StageModel {
    var stages: [Stage] = []
    var currentStageIndex: Int
...
```

### 3-1. 키 정의

Enum 으로 각각의 키를 정의 했습니다.

```swift
enum Command: Character {
    case UP = "w"
    case LEFT = "a"
    case DOWN = "s"
    case RIGHT = "d"
    case QUIT = "q"

    var message: String {
        switch self {
        case .UP:
            return "W: 위로 이동합니다.⬆︎"
        case .DOWN:
            return "S: 아래로 이동합니다.⬇︎"
        case .LEFT:
            return "A: 왼쪽으로 이동합니다.⬅︎"
        case .RIGHT:
            return "D: 오른쪽으로 이동합니다.►"
        case .QUIT:
            return "Bye👋"
        }
    }
}
```

### 3-2. 입력키에 따른 이동 처리

외부에서 접근 가능한 메서드인 move 에서 로직을 수행합니다.

movePlayer(to: command) 에서 플레이어를 이동시키고
이동이 성공했는지 여부와, 그 결과가 적용된 map 을 문자열 형태로 받아옵니다.

```swift
// StageModel.swift
func move(to command: Command) -> (map: String?, systemInfo: String) {
    let result = movePlayer(to: command)
    let infoString: String = result.isSuccess ? command.message : MS.warning
    return (result.map, infoString)
}
```

command 에 따라 다음 이동한 위치인 targetPoint를 계산합니다.

그리고 targetPoint 갈 수 있는지 판별하고, 플레이어 위치와 map 을 업데이트 합니다.

```swift
private func movePlayer(to command: Command) -> (map: String?, isSuccess: Bool) {
	var map = stages[currentStageIndex].map
	let currentPoint = stages[currentStageIndex].playerPoint
	let targetPoint: CGPoint = calcTargetPoint(from: currentPoint, command: command)
	let targetItem = map[Int(targetPoint.y) - 1][Int(targetPoint.x) - 1]

	if targetItem != GameItem.empty.symbol {
	    return (stages[currentStageIndex].mapToString(), false)
	}
	map[Int(currentPoint.y) - 1][Int(currentPoint.x) - 1] = " "
	map[Int(targetPoint.y) - 1][Int(targetPoint.x) - 1] = GameItem.player.symbol
	stages[currentStageIndex].map = map
	stages[currentStageIndex].playerPoint = targetPoint

	return (stages[currentStageIndex].mapToString(), true)
}
```

맵 데이터 저장은 다음과 같이 되어 있습니다:

```swift
---------------------------> x축
	0, 1, 2, 3, 4
[
	["#", "#", "#", "#", "#"], 0 |
	["#", "O", "B", "P", "#"], 1 |
	["#", "#", "#", "#", "#"]  2 |
]                             y축
```

2차원 배열에서는 x, y 가 반대가 되므로 map[y][x] 형태로 접근해야 합니다.

또한, 플레이어의 현재위치는 x, y 가 1씩 크게 저장되어 있으므로 -1 로 보정을 해주었습니다.

### 3-3. 이동할 위치 계산

키입력의 방향에 따라 x, y 축을 연산합니다.

```swift
private func calcTargetPoint(from currentPoint: CGPoint, command: Command) -> CGPoint {
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
    return targetPoint
}
```

## 4. 결과 출력

장애물이 있다면 현재 맵과 함께 이동실패(false) 를 반환합니다.

이동을 성공적으로 했다면, 업데이트된 현재맵과 true 를 반환합니다.

```swift
private func movePlayer(to command: Command) -> (map: String?, isSuccess: Bool) {
	...
	if targetItem != " " {
    return (stages[currentStageIndex].mapToString(), false)
  }
	...
	return (stages[currentStageIndex].mapToString(), true)
}
```

true, false 에 따라 화면에 출력할 메시지를 결정하고 반환합니다.

```swift
func move(to command: Command) -> (map: String?, systemInfo: String) {
    let result = movePlayer(to: command)
    let infoString: String = result.isSuccess ? command.message : MS.warning
    return (result.map, infoString)
}
```

그리고 반환받은 결과값을 main 에서 출력합니다.

```swift
// main.swift
func oneKeyAction(_ command: Command) {
    let moveResult = model.move(to: command)
    if let map = moveResult.map {
        print(map)
    }
    print(moveResult.systemInfo)
}
```
