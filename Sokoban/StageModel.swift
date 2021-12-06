import Foundation

enum Command: Character, CaseIterable {
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

struct Stage {
    var map = [[Character]]()
    var dimensionalArray = [[Int]]()
    var 가로크기 = 0
    var 세로크기 = 0
    var 구멍의수 = 0
    var 공의수 = 0
    var 플레이어의위치 = CGPoint(x: 0, y: 0)
    
    func mapToString() -> String {
        let bb = map.compactMap({ String($0) }).joined(separator: "\n")
        return bb
    }
    
}


final class StageModel {
    var stages: [Stage] = []
    var currentStageIndex = 1
    
    init() {
        // 맵 문자열을 가져와 구조체롤 초기화
        stages = createMap(from: mapStringData)
    }
    
    func getStage(by num: Int) -> Stage {
        return stages[num - 1]
    }
    
    func getCurrentStage() -> Stage {
        return stages[currentStageIndex]
    }
    
    // input:
    // output: map 문자열 형태
    func move(to command: Character) -> (map: String?, systemInfo: String) {
        guard let command = Command(rawValue: command) else {
            return ("",MS.warning)
        }
        let result = movePlayer(to: command)
        let infoString: String = result.isSuccess ? command.message : MS.warning
        return (result.map, infoString)
    }
    
    // 부딪힘 처리
    func movePlayer(to command: Command) -> (map: String?, isSuccess: Bool) {
        // command: UP
        // 1. 플레이어의 현재위치, 이동할 위치 비교
        // => 장애물이 있다("#", "O", "o"): 움직이지 못했다 => 바로 지도문자열 리턴
        // => 장애물이 없다(" "): 이동을 처리 => 이동 하고 난후의 지도 문자열 리턴
        
        let currentPoint = stages[currentStageIndex].플레이어의위치
//        print("플레이어의 현재 위치: ", currentPoint)
        let targetPoint: CGPoint
        switch command {
        case .UP:
            // 잘 움직인 경우, 아닌경우로 나누어짐
            // 잘 움직인 경우
            // 플레이어가 움직이고 난 다음의 맵 반환
            targetPoint = CGPoint(x: currentPoint.x, y: currentPoint.y - 1)
        case .DOWN:
            targetPoint = CGPoint(x: currentPoint.x, y: currentPoint.y + 1)
        case .RIGHT:
            targetPoint = CGPoint(x: currentPoint.x + 1, y: currentPoint.y)
        case .LEFT:
            targetPoint = CGPoint(x: currentPoint.x - 1, y: currentPoint.y)
        case .QUIT: // 여기서는 안쓰는 커맨드
            return (stages[currentStageIndex].mapToString(), false)
        }
        
        // 플레이어 이동처리
        // 지도 데이터에서 targetPositon 이 " " 인지 확인한다(이동가능한 지역인지)
        // " ": 가능
        // 불가능
        
        var map = stages[currentStageIndex].map
//        map[y][x]
        let targetItem = map[Int(targetPoint.y) - 1][Int(targetPoint.x) - 1]
        
//        print("다음위치에\(targetPoint) 있는거:", targetItem)
        
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
    
    private let mapStringData = """
    Stage 1
    #####
    #OㅁP#
    #####
    =====
    Stage 2
      #######
    ###  O  ###
    #    ㅁ    #
    # Oㅁ P ㅁO #
    ###  ㅁ  ###
     #   O  #
     ########
    =====
    """
}



