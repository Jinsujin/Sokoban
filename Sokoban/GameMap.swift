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
        self.stages = fetchMap()
    }
    
    func printAllStageInfo() {
        for (i, stage) in stages.enumerated() {
            let infoString = stageInfoToString(stage, index: i)
            print(infoString)
        }
    }
    
    
    // 초기화
    private func fetchMap() -> [Stage] {
        let mapArray = convertMapCharArray(from: mapStringData)
        var stages = [Stage]()
        for map in mapArray {
            let stage = Stage(map)
            stages.append(stage)
        }
        return stages
    }
    
    
    private func convertMapCharArray(from mapData: String) -> [GameMapType] {
        var mapArray = [GameMapType]()
        var map = GameMapType()
        var lineString = String()
        
        for char in mapData {
            if !char.isNewline {
                lineString.append(char)
                
                // 다음 스테이지인지 체크,
                if lineString == MS.divideLine {
                    // 새로운 맵 생성
                    mapArray.append(map)
                    map = GameMapType()
                }
                continue
            }
            
            /// 줄바꿨음
            // 스테이지로 시작하면 제외
            if lineString.hasPrefix(MS.stageTitle) {
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
