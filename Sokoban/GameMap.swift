import Foundation

final class GameMap {
    var stages: [Stage] = []

    init() {
//        self.stages = convertMapArray(from: mapStringData)
        convertMapArray(from: mapStringData)
    }
    
    func printAllStageInfo() {
        for (i, stage) in stages.enumerated() {
            let infoString = stageInfoToString(stage, index: i)
            print(infoString)
        }
    }
    

    
    // 입력된 문자열이 "=====" 인지 확인
    // 맞다: 다음 스테이지인것
    // 아니다:
    // return isNextStage: Bool
    private func appendStage(line: String, stage: Stage) -> Bool {
        if line != MS.divideLine {
            return false
        }
        var s = stage
        s.width = stage.map.map({ $0.count }).max() ?? 0
        s.height = stage.map.count
        stages.append(s)
        return true
    }
    
    private func updatedStageByItem(_ stage: Stage, by item: GameItem, point: (x: Int, y: Int)) -> Stage {
        var editedStage = stage
        switch item {
        case .hall:
            editedStage.hallCount += 1
        case .ball:
            editedStage.ballCount += 1
        case .player:
            // 0 부터 시작하기 때문에 y값 보정함 +1
            editedStage.playerPoint = CGPoint(x: point.x, y: point.y + 1)
        default:
            break
        }
        return editedStage
    }
    
    private func convertMapArray(from mapData: String) {
        var stage = Stage()
        var lineString = String()
        var intArr = [Int]()
        var x = 0
        var y = 0
        
        for c in mapData {
            // 줄바꾸지 않음
            // 한글자씩 가져와
            if !c.isNewline {
                lineString.append(c)
                x += 1
                
                // 함수로 뺴기 가능?
                guard let item = GameItem.convertItem(by: c) else {
                    continue
                }
                intArr.append(item.rawValue)
                stage = updatedStageByItem(stage, by: item, point: (x: x, y: y))

                // 다음 스테이지인가
                if appendStage(line: lineString, stage: stage) {
                    stage = Stage()
                }
                continue
            }
            
            ////////// 줄바꿨음 ///////////
            // 스테이지는 배열에 저장하지 않음
            if lineString.hasPrefix(MS.stageTitle) {
                lineString = ""
                x = 0
                y = 0
                continue
            }
            
            if !lineString.hasPrefix(String(GameItem.stageDivide.symbol)) {
                stage.map.append(Array(lineString))
            }
            stage.dimensionalArray.append(intArr)
            
            lineString = ""
            intArr = []
            x = 0
            y += 1
        }
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
    
    // 하나의 스테이지에 대한 문자열 반환
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
}
