import Foundation

final class GameMap {
    var stages: [Stage] = []

    init() {
        self.stages = convertMapArray(from: mapStringData)
    }
    
    func printAllStageInfo() {
        for stage in stages {
            
        }
        
        print("\(MS.stageTitle) ")
        
    }
    
    // 하나의 스테이지에 대한 문자열 반환
    private func stageInfoToString(_ stage: Stage, index: Int) -> String {
        
        let result = """
        \(MS.stageTitle) \(index + 1)
        \(MS.br)
        \(stage.width)


        """

        return ""
    }
    
    private func convertMapArray(from mapData: String) -> [Stage] {
        var stages: [Stage] = []
        var stage = Stage()
        var 문자열 = String()
        var 숫자배열 = [Int]()
        var x = 0
        var y = 0
        
        for c in mapData {
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
                    print(stage)
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


    let mapStringData = """
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
