import Foundation

class GameMap {
    private var stages: [Stage] = []
    
    init() {
        self.stages = createMap(from: mapStringData)
    }
    
    func getAllStages() -> [Stage] {
        return self.stages
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
                
                // 함수로 뺴기 가능? => 구조체 내에서 처리하도록 빼기
                guard let item = GameItem.convertItem(by: c) else {
                    continue
                }
                숫자배열.append(item.rawValue)
                switch item {
                case GameItem.hall:
                    stage.hallCount += 1
                case GameItem.ball:
                    stage.ballCount += 1
                case GameItem.player:
                    // 0 부터 시작하기 때문에 y값 보정함 +1
                    stage.playerPoint = CGPoint(x: x, y: y + 1)
                case GameItem.stageDivide:
                    break
                default:
                    break
                }
                // 다음 스테이지인가
                if 문자열 == "=====" {
                    stage.width = stage.map.map({ $0.count }).max() ?? 0
                    stage.height = stage.map.count
                    stages.append(stage)
                    stage = Stage()
                }
                continue
            }
            
            ////////// 줄바꿨음 ///////////
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
        #OBP#
        #####
        =====
        Stage 2
          #######
        ###  O  ###
        #    B    #
        # OB P BO #
        ###  B  ###
         #   O  #
         ########
        =====
        """
}
