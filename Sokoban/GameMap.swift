import Foundation

typealias GameMapType = [[Character]]

final class GameMap {
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
    private var stages: [Stage] = []
    
    init() {
        let mapArray = convertMapCharArray(from: mapStringData)
        
        // 데이터를 돌면서 구조체로 변환
        for map in mapArray {
//            print(map)
            let stage = Stage(map)
            self.stages.append(stage)
            print("===========")
        }
    }
    
    
    
    func printAllStageInfo() {
        for (i, stage) in stages.enumerated() {
            let infoString = stageInfoToString(stage, index: i)
            print(infoString)
        }
    }
    

    
    
    /**
     1. 문자열을 읽어 들인다
     2. [[Character]] 로 변환
     
     */
    
    private func convertMapCharArray(from mapData: String) -> [[[Character]]] {
        var mapArray = [[[Character]]]()
        var map = [[Character]]()
        var lineString = String()
        
        for char in mapData {
            if !char.isNewline {
                lineString.append(char)
                
                // 다음 스테이지인지 체크,
                if lineString == MS.divideLine {
                    // 새로운 맵 생성
                    mapArray.append(map)
                    map = [[Character]]()
                }
                continue
            }
            
            /// 줄바꿨음
            // 스테이지로 시작하면 제외
            if lineString.hasPrefix("Stage") {
                lineString = ""
                   continue
               }
            
            // 줄바꿈 문자로 시작한다 => mapArray에 추가
            if !lineString.hasPrefix(String(GameItem.stageDivide.symbol)) {
                map.append(Array(lineString))
            }
            lineString = ""
        }
        return mapArray
    }
    
    
    private func updatedStageByItem(_ stage: Stage, by item: GameItem, point: (x: Int, y: Int)) -> Stage {
        var editedStage = stage
        switch item {
        case .hall:
            editedStage.hallCount += 1
        case .ball:
            editedStage.ballCount += 1
        case .player:
            editedStage.playerPoint = CGPoint(x: point.x, y: point.y + 1)
        default:
            break
        }
        return editedStage
    }
    
    private func appendStage(line: String, stage: Stage) -> Bool {
        if line != MS.divideLine {
            return false
        }
        var editedStage = stage
        editedStage.width = stage.map.map({ $0.count }).max() ?? 0
        editedStage.height = stage.map.count
        stages.append(editedStage)
        return true
    }
    
    private func convertMapArray(from mapData: String) {
        var stage = Stage()
        var lineString = String()
        var intArr = [Int]()
        var x = 0
        var y = 0
        
        for c in mapData {
            if !c.isNewline {
                lineString.append(c)
                x += 1
                
                guard let item = GameItem.convertItem(by: c) else {
                    continue
                }
                intArr.append(item.rawValue)
                stage = updatedStageByItem(stage, by: item, point: (x: x, y: y))

                if appendStage(line: lineString, stage: stage) {
                    stage = Stage()
                }
                continue
            }
            
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
