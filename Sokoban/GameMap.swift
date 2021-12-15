import Foundation

typealias GameMapType = [[Character]]

final class GameMap {
    private var stages: [Stage] = []
    
    init() {
        loadMapFromTxtFile()
    }
    
    
    func printAllStageInfo() {
        for (i, stage) in stages.enumerated() {
            let infoString = stageInfoToString(stage, index: i)
            print(infoString)
        }
    }
    
    
    func getAllStages() -> [Stage] {
        return self.stages
    }
    
    
    func reloadedStages() -> [Stage] {
        loadMapFromTxtFile()
        return self.stages
    }
    
    private func loadMapFromTxtFile() {
        guard let resultString = fetchTextFile() else {
            fatalError("ERROR: fetch fail")
        }
        self.stages = fetchMap(resultString)
    }
    
    
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
    
    
    private func fetchMap(_ stringData: String) -> [Stage] {
        let mapArray = convertMapCharArray(from: stringData)
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
                
                if lineString == MS.divideLine {
                    mapArray.append(map)
                    map = GameMapType()
                }
                continue
            }
            
            if lineString.hasPrefix(MS.stageTitle) {
                lineString = ""
                continue
            }
            if !lineString.hasPrefix(String(GameItem.stageDivide.symbol)) {
                map.append(Array(lineString)) // #OBP# 한줄을 2차 배열에 추가
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
        \(MS.playerPoint)\(colon) (\(stage.playerPointForPrint.x), \(stage.playerPointForPrint.y))
        """
    }
}
