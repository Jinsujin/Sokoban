import Foundation

/**
 
 # : 벽 / 0
 O : 구멍 / 1
 o : 공  / 2
 P: 플레이어 / 3
 = : 스테이지 구분 / 4
 
 
 isWhitespace
 " ": 공백 true
 "": ?? 줄바꿈인듯
 isNewline: "" 줄바꿈 여부
 
 isLetter: 문자인가, (공백,숫자, 특수문자는 false)
 
 */




final class StageModel {
    var stages: [Stage] = []
    var currentStageIndex: Int
    
//    init(stageNumber: Int) {
//        self.currentStageIndex = stageNumber - 1
//
//        guard let fetchString = fetchTextFile() else {
//            fatalError("ERROR: fetch fail")
//        }
//        self.stages = createMap(from: fetchString)
//    }
  
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
        let result = movePlayer(to: command)
        let infoString: String = result.isSuccess ? command.message : MS.warning
        return (result.map, infoString)
    }
    
    
    private func getTargetPoint(from currentPoint: CGPoint, command: Command) -> CGPoint {
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
    
    // 부딪힘 처리
    private func movePlayer(to command: Command) -> (map: String?, isSuccess: Bool) {
        // command: UP
        // 1. 플레이어의 현재위치, 이동할 위치 비교
        // => 장애물이 있다("#", "O", "o"): 움직이지 못했다 => 바로 지도문자열 리턴
        // => 장애물이 없다(" "): 이동을 처리 => 이동 하고 난후의 지도 문자열 리턴
        
        let currentPoint = stages[currentStageIndex].플레이어의위치
//        print("플레이어의 현재 위치: ", currentPoint)
        let targetPoint: CGPoint = getTargetPoint(from: currentPoint, command: command)
        
        switch command {
        case .UP:
            // 잘 움직인 경우, 아닌경우로 나누어짐
            // 잘 움직인 경우
            // 플레이어가 움직이고 난 다음의 맵 반환
            break
        case .DOWN:
            break
        case .RIGHT:
            break
        case .LEFT:
            break
        case .QUIT: // 여기서는 처리안하는 커맨드
            return (stages[currentStageIndex].mapToString(), false)
        case .RELOAD:
            // txt 에서 다시 파일을 읽어서 맵을 새로고침
            loadMapFromTxtFile()
            return (stages[currentStageIndex].mapToString(), true)
        }
        
        // 플레이어 이동처리
        // 지도 데이터에서 targetPositon 이 " " 인지 확인한다(이동가능한 지역인지)
        // " ": 가능
        // 불가능
        
        var map = stages[currentStageIndex].map
//        map[y][x]
        let targetItem = map[Int(targetPoint.y) - 1][Int(targetPoint.x) - 1]
        
        // 이동불가
        if targetItem != " " {
            return (stages[currentStageIndex].mapToString(), false)
        }
        
//        if targetItem == " "
//            print("이동가능")
        // 1. 이동한 위치를 반영한 지도 업데이트
        // 지도에 현재 플레이어 위치를 " " 로 변경
        // 이동할 위치로 플레이어 이동 P
        map[Int(currentPoint.y) - 1][Int(currentPoint.x) - 1] = " "
        map[Int(targetPoint.y) - 1][Int(targetPoint.x) - 1] = GameItem.player.symbol
        stages[currentStageIndex].map = map
        
        // 2. 플레이어 데이터 업데이트
        stages[currentStageIndex].플레이어의위치 = targetPoint
        
        return (stages[currentStageIndex].mapToString(), true)
    }
    
    
    // 한개의 아이템을 민다, 변경사항이 적용된 맵을 반환한다
    private func pushItem(item: GameItem, from: CGPoint, to: CGPoint) -> [[Character]] {
        // 플레이어가 움직일 수 없는 아이템이면 종료
        if !item.isMoveableByPlayer {
            return self.stages[currentStageIndex].map
        }
        
        print("===pushItem:", item)
        // 플레이어가 움직일 수 있는 아이템 처리
        // 1. 공인 경우
        // to Point 로 공을 움직일 수 있는지 체크
        
        // 움직일 지점에 뭐가 있나
        guard let nextItem = convertItemFromCharacter(point: to) else {
            return self.stages[currentStageIndex].map
        }
        
        // 플레이어->공->?
        switch nextItem {
        case .ball, .wall: // 이동 불가
            break
//        case 빈공간//이동가능
        case .hall: // 구멍, 빈공간 이동 가능
            break
        default:
            break
        }
        
        return [[Character]]()
    }
    
    // 맵의 point 지점에 있는 아이템을 enum으로 변환
    private func convertItemFromCharacter(point: CGPoint) -> GameItem? {
        let map = stages[currentStageIndex].map
        let itemChar = map[Int(point.y) - 1][Int(point.x) - 1]
        return GameItem.convertItem(by: itemChar)
    }
    
    
    // 플레이어가 이동한 위치를 반영해 맵을 다시 그리고 2차원 배열로 반환.
    // model 에 맵 업데이트
//    private func updatedMap(from start: CGPoint, to end: CGPoint) -> [[Character]] {
//        var map = stages[currentStageIndex].map
//        map[Int(start.y) - 1][Int(start.x) - 1] = " "
//        map[Int(end.y) - 1][Int(end.x) - 1] = GameItem.player.symbol
////        stages[currentStageIndex].map = map
//
//        return map
//    }
    
    
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



