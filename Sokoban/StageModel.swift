import Foundation


final class StageModel {
    var stages: [Stage] = []
    var currentStageIndex: Int
    
    init() {
        // 처음부터 시작.
        self.currentStageIndex = 1
        loadMapFromTxtFile()
    }
    
    private func loadMapFromTxtFile() {
        guard let fetchString = fetchTextFile() else {
            fatalError("ERROR: fetch fail")
        }
        self.stages = createMap(from: fetchString)
    }
    
    
    private func fetchTextFile() -> String? {
        let fileName = "map"
        //file:///Users/jsj/Documents/
        guard let dir = try? FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask, appropriateFor: nil, create: true)
               else  {
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
    
    func getStage(by num: Int) -> Stage {
        return stages[num - 1]
    }
    
    func getCurrentStage() -> Stage {
        return stages[currentStageIndex]
    }
    
    func getCurrentTitle() -> String {
        return "\(MS.stageTitle) \(self.currentStageIndex + 1)"
    }
    
    // input:
    // output: map 문자열 형태
    func move(to command: Character) -> (map: String?, systemInfo: String) {
        guard let command = Command(rawValue: command) else {
            return (nil, MS.warning)
        }
        let result = action(to: command)
        let infoString: String = result.isSuccess ? command.message : MS.warning
        return (result.map, infoString)
    }
    
    
    // MARK:- Private functions
    private func calcTargetPoint(from currentPoint: CGPoint, command: Command) -> CGPoint? {
        // 계산한 타겟 지점이 현재 지도에서 유효범위 내 인지 체크
        
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
        print(validatePointFromMap(targetPoint))
        return (validatePointFromMap(targetPoint) ? targetPoint : nil)
    }
    
    // point 가 현재 지도에서 유효한 값인지 검사
    private func validatePointFromMap(_ point: CGPoint) -> Bool {
        let stage = self.stages[currentStageIndex]
        let y = Int(point.y)
        let x = Int(point.x)
        //1. 세로크기 확인, 2. 가로 크기 확인
        // 크기는 index보다 +1 크다
        if y < stage.세로크기 && x < stage.map[y].count {
            return true
        }
        return false
    }
    
    
    // 1. 플레이어의 현재위치, 이동할 위치 비교
    // => 장애물이 있다("#", "O", "o"): 움직이지 못했다 => 바로 지도문자열 리턴
    // => 장애물이 없다(" "): 이동을 처리 => 이동 하고 난후의 지도 문자열 리턴
    private func action(to command: Command) -> (map: String?, isSuccess: Bool) {
        switch command {
        case .QUIT: // 여기서는 처리안하는 커맨드
            return (stages[currentStageIndex].mapToString(), false)
        case .RELOAD:
            // txt 에서 다시 파일을 읽어서 맵을 새로고침
            loadMapFromTxtFile()
            return (stages[currentStageIndex].mapToString(), true)
        default: break
        }
        
        let currentPoint = stages[currentStageIndex].플레이어의위치
        
        // 이동할 위치가 맵밖의 영역일때
        guard let targetPoint: CGPoint = calcTargetPoint(from: currentPoint, command: command) else {
            return (stages[currentStageIndex].mapToString(), false)
        }
        
        guard let targetItem = convertItemFromCharacter(point: targetPoint) else {
            fatalError("ERROR:: Cannot converted item")
        }
        // 1. 플레이어가 미는 아이템 처리
        // 이동 가능한 아이템만 처리?
        // command 에서 오른쪽으로 갈지 왼쪽으로 갈지 정보가 있다
        // 지도를 넘어선 지점의 예외 처리 필요
        
        // 1-2. 밀 수 있는 지점인지 체크
        // 만약, 밀 수 없는 아이템일 경우, 플레이어의 위치는 변함없다
        // 플레이어 -> 박스 -> 벽

        // 아이템을 움직인다.
        // 아이템을 못움직인 경우, 플레이어 이동을 막음
        if !targetItem.isPassableByPlayer
            && !pushItem(item: targetItem, from: targetPoint, command: command) {
            return (stages[currentStageIndex].mapToString(), false)
        }
        
        // 2. 플레이어 처리
        movePlayer(from: currentPoint, to: targetPoint)
        
        return (stages[currentStageIndex].mapToString(), true)
    }
    
    private func movePlayer(from: CGPoint, to: CGPoint) {
        // 다음 위치가 플레이어가 통과할 수 있는 아이템인가
        // 플레이어는 O 구멍, empty 을 통과할 수 있다.
        // 현재 아이템
        // 다음 위치에 있는 아이템.
        guard let targetItem = convertItemFromCharacter(point: to) else {
            fatalError("ERROR:: Cannot converted item")
        }
        // 플레이어가 지나갈수 없는 아이템이면(empty, hall) 플레이어를 움직이지 않는다.
        if !targetItem.isPassableByPlayer {
            return
        }
        
        let 현재구멍밟음 = stages[currentStageIndex].구멍밟았나
        
        switch targetItem {
        case .empty: // 이동할 위치가 비어있다
            if 현재구멍밟음 {
                updateCurrentMapItem(target: from, item: GameItem.hall)
            } else {
                updateCurrentMapItem(target: from, item: targetItem)
            }
            stages[currentStageIndex].구멍밟았나 = false
            
        case .hall: // 이동할 위치가 구멍이다
            // 플레이어의 현재 위치가 구멍밟은 곳이다
            if 현재구멍밟음 {
                updateCurrentMapItem(target: from, item: GameItem.hall)
            } else {
                // 구멍 안밟음
                updateCurrentMapItem(target: from, item: GameItem.empty)
            }
            stages[currentStageIndex].구멍밟았나 = true
        default:
            fatalError()
        }
        updateCurrentMapItem(target: to, item: GameItem.player)
        stages[currentStageIndex].플레이어의위치 = to
        stages[currentStageIndex].턴수 += 1
        print("턴수: ", stages[currentStageIndex].턴수)
    }
    
    private func updateCurrentMapItem(target point: CGPoint, item: GameItem) {
        stages[currentStageIndex].map[Int(point.y) - 1][Int(point.x) - 1] = item.symbol
    }
    
    // 한개의 아이템을 민다, 변경사항이 적용된 맵을 반환한다
    private func pushItem(item: GameItem, from: CGPoint, command: Command) -> Bool {
        // 1. 플레이어가 미는 item에 대한 유효 체크
        // () -> empty -> ??
        // 현재 item 이 empty인 경우는 아이템을 밀 필요 없다
//        if item == .empty {
//            return true
//        }
        // 플레이어가 움직일 수 없는 아이템이면 종료
        if !item.isMoveableByPlayer {
            return false
        }
        print("===pushItem:", item)

        // 타겟아이템이 이동할 위치가 없다면 움직일 필요 없다.
        // error - 아래로 움직였을때, 갈수 있는 공간이 있는데 안가짐
        guard let nextPointOfPushItem = calcTargetPoint(from: from, command: command) else {
            return false
        }
        
        // 아이템이 움직일 지점에 뭐가 있나
        guard let nextItem = convertItemFromCharacter(point: nextPointOfPushItem) else {
            return false
        }
        
        // 아이템을 움직였는지 여부를 반환해야 함
        // 오른쪽키를 눌렀을때: (플레이어->) 공 -> nextItem
        switch nextItem {
        case .empty:
            // 현재 아이템이 공이고, nextItem 이 empty일때
            // 공을 to point 로 이동
            // 공이 있던 from 을 빈공간으로 변경
            updateCurrentMapItem(target: from, item: GameItem.empty)
            updateCurrentMapItem(target: nextPointOfPushItem, item: item)
            return true
        case .ball:
            break
        case .hall: // 구멍, 빈공간 이동 가능
            break
//        case .ball, .wall: // 이동 불가: 현재 맵을 반환하고 종료
//            break
//        case 빈공간//이동가능
        default:
            break
        }
        return false
    }
    
    // 맵의 point 지점에 있는 아이템을 enum으로 변환
    private func convertItemFromCharacter(point: CGPoint) -> GameItem? {
        let map = stages[currentStageIndex].map
        if !validatePointFromMap(point) {
            return nil
        }
        let itemChar = map[Int(point.y) - 1][Int(point.x) - 1]
        return GameItem.convertItem(by: itemChar)
    }
    
    private func createMap(from mapData: String) -> [Stage] {
        var stages: [Stage] = []
        
        var stage = Stage()
        var 문자열 = String()
        var 숫자배열 = [Int]()
        var x = 0
        var y = 0
        
        for (index, c) in mapData.enumerated() {
            // 줄바꾸지 않음
            if !c.isNewline {
                문자열.append(c)
                x += 1
                
                // 함수로 뺴기 가능?
                guard let item = GameItem.convertItem(by: c) else {
                    continue
                }
                숫자배열.append(item.rawValue)
                switch item {
                case GameItem.hall:
                    stage.구멍의수 += 1
                case GameItem.ball:
                    stage.공의수 += 1
                case GameItem.player:
                    // 0 부터 시작하기 때문에 y값 보정함 +1
                    stage.플레이어의위치 = CGPoint(x: x, y: y + 1)
                case GameItem.stageDivide:
                    break
                default:
                    break
                }
                // 다음 스테이지인가
                if 문자열 == "=====" {
                    stage.가로크기 = stage.map.map({ $0.count }).max() ?? 0
                    stage.세로크기 = stage.map.count
                    stages.append(stage)
                    stage = Stage()
                }
                continue
            }
            
            ////////// 줄바꿨음 ///////////
        //    print("줄바꾼 후에 현재문자:",c, 문자열)
            // 스테이지는 배열에 저장하지 않음
            if 문자열.hasPrefix("Stage") {
                문자열 = ""
                x = 0
                y = 0
                continue
            }
            
            if !문자열.hasPrefix("=") {
                stage.map.append(Array(문자열))
            }
            stage.dimensionalArray.append(숫자배열)
            
            문자열 = ""
            숫자배열 = []
            x = 0
            y += 1
        }
        
        return stages
    }
}
