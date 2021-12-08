import Foundation

final class StageModel {
    var stages: [Stage] = []
    var currentStageIndex: Int
    var currentStage = Stage()

    init(stageNumber: Int) {
        self.currentStageIndex = stageNumber - 1
        let map = GameMap()
        self.stages = map.getAllStages()
    }
    
    
    func getStage(by num: Int) -> Stage {
        return stages[num - 1]
    }
    
    
    func getCurrentStage() -> Stage {
        return stages[currentStageIndex]
    }
    
    
    func getStageTitle() -> String {
        return MS.stageTitle + " \(self.currentStageIndex + 1)"
    }
    
    
    func move(to command: Command) -> (map: String?, systemInfo: String) {
        let result = movePlayer(to: command)
        let infoString: String = result.isSuccess ? command.message : MS.warning
        return (result.map, infoString)
    }
    
    
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
}
