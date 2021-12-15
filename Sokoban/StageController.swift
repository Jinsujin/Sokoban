import Foundation


final class StageController {
    var stages: [Stage] = []
    var currentStageIndex: Int
    var isClearGame = false
    
    private let map = GameMap()
    
    
    init() {
        self.currentStageIndex = 0
        self.stages = map.getAllStages()
    }
    

    func getCurrentStage() -> Stage {
        return stages[currentStageIndex]
    }
    
    
    func getCurrentTitle() -> String {
        return "\(MS.stageTitle) \(self.currentStageIndex + 1)"
    }
    

    func move(to command: Command) -> (map: String?, systemInfo: String) {
        let result = action(to: command)
        let infoString: String = result.isSuccess ? command.message : MS.warning
        return (result.map, infoString)
    }
        
    
    func checkGameClear() -> Bool {
        return isClearGame
    }
    
    
    func checkStageClear() -> Bool {
        if !(stages[currentStageIndex].ballCount == 0) {
            return false
        }
        let prevIdx = currentStageIndex
        printResult(prevIdx)
        self.currentStageIndex = min(stages.count - 1, prevIdx + 1)
        
        if prevIdx == currentStageIndex {
            isClearGame = true
        }
        return true
    }
    
    
    func printStartStage() {
        print(MS.br)
        print(getCurrentTitle())
        let mapString = getCurrentStage().mapToString()
        print(mapString)
        print(MS.br)
    }
    
    
    // MARK:- Private functions
    private func calcTargetPoint(from currentPoint: CGPoint, command: Command) -> CGPoint? {
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
        return (validatePointFromMap(targetPoint) ? targetPoint : nil)
    }
    
    private func validatePointFromMap(_ point: CGPoint) -> Bool {
        let stage = self.stages[currentStageIndex]
        let y = Int(point.y)
        let x = Int(point.x)
        
        // 크기는 index보다 +1 크다
        if !(y < 0 || x < 0)
         && (y < stage.height) && (x < stage.map[y].count) {
            return true
        }
        return false
    }
    
    
    private func action(to command: Command) -> (map: String?, isSuccess: Bool) {
        switch command {
        case .QUIT:
            return (stages[currentStageIndex].mapToString(), false)
        case .RELOAD:
            self.stages = map.reloadedStages()
            return (stages[currentStageIndex].mapToString(), true)
        default: break
        }
        
        let currentPoint = stages[currentStageIndex].playerPoint
        
        // 이동할 위치가 맵밖의 영역일때
        guard let targetPoint: CGPoint = calcTargetPoint(from: currentPoint, command: command) else {
            return (stages[currentStageIndex].mapToString(), false)
        }
        
        guard let targetItem = convertItemFromCharacter(point: targetPoint) else {
            fatalError("ERROR:: Cannot converted item")
        }

        // 1. 아이템을 민다
        if !targetItem.isPassableByPlayer
            && !pushItem(item: targetItem, from: targetPoint, command: command) {
            return (stages[currentStageIndex].mapToString(), false)
        }
        
        // 2. 플레이어 이동
        movePlayer(from: currentPoint, to: targetPoint)
        return (stages[currentStageIndex].mapToString(), true)
    }
    
    
    private func movePlayer(from: CGPoint, to: CGPoint) {
        guard let targetItem = convertItemFromCharacter(point: to) else {
            fatalError("ERROR:: Cannot converted item")
        }
        if !targetItem.isPassableByPlayer {
            return
        }
        
        let isAboveHall = stages[currentStageIndex].isAboveHall
        
        switch targetItem {
        case .empty:
            if isAboveHall {
                updateCurrentMapItem(target: from, item: GameItem.hall)
            } else {
                updateCurrentMapItem(target: from, item: GameItem.empty)
            }
            stages[currentStageIndex].isAboveHall = false
            
        case .hall:
            if isAboveHall {
                updateCurrentMapItem(target: from, item: GameItem.hall)
            } else {
                updateCurrentMapItem(target: from, item: GameItem.empty)
            }
            stages[currentStageIndex].isAboveHall = true
        default:
            fatalError()
        }
        updateCurrentMapItem(target: to, item: GameItem.player)
        stages[currentStageIndex].playerPoint = to
        stages[currentStageIndex].turn += 1
    }
    
    private func updateHall(point: CGPoint, isEmpty: Bool) {
        let isPlayerAboveHall = stages[currentStageIndex].isAboveHall
        
        if isPlayerAboveHall {
            updateCurrentMapItem(target: point, item: GameItem.hall)
        } else {
            updateCurrentMapItem(target: point, item: GameItem.empty)
        }
        stages[currentStageIndex].isAboveHall = true
    }
    
    
    private func updateCurrentMapItem(target point: CGPoint, item: GameItem) {
        stages[currentStageIndex].map[Int(point.y)][Int(point.x)] = item.symbol
    }
    
    
    private func pushItem(item: GameItem, from: CGPoint, command: Command) -> Bool {
        guard let nextPointOfPushItem = calcTargetPoint(from: from, command: command),
              let nextItem = convertItemFromCharacter(point: nextPointOfPushItem) else {
            return false
        }

        if !item.isMoveableByPlayer && !nextItem.isPassableByPlayer  {
            return false
        }
        
        switch nextItem {
        case .empty:
            if item == .ball {
                updateCurrentMapItem(target: from, item: GameItem.empty)
                updateCurrentMapItem(target: nextPointOfPushItem, item: item)
            } else if item == .filled {
                updateCurrentMapItem(target: from, item: GameItem.hall)
                updateCurrentMapItem(target: nextPointOfPushItem, item: GameItem.ball)
                stages[currentStageIndex].ballCount += 1
            }
            return true
            
        case .hall:
            if item == .ball {
                // 1. 공(item)을 구멍(nextItem)에 넣는 경우
                updateCurrentMapItem(target: from, item: GameItem.empty)
                updateCurrentMapItem(target: nextPointOfPushItem, item: GameItem.filled)
                stages[currentStageIndex].ballCount -= 1
            } else if item == .filled {
                // 2. 공이있는구멍(item)을 구멍(nextItem)에 넣는 경우
                updateCurrentMapItem(target: from, item: GameItem.hall)
                updateCurrentMapItem(target: nextPointOfPushItem, item: GameItem.filled)
            }
            return true
        default:
            return false
        }
    }
    

    private func convertItemFromCharacter(point: CGPoint) -> GameItem? {
        let map = stages[currentStageIndex].map
        if !validatePointFromMap(point) {
            return nil
        }
        let x = max(Int(point.x), 0)
        let y = max(Int(point.y), 0)
        return GameItem.convertItem(by: map[y][x])
    }
    
    private func printResult(_ stageIndex: Int) {
        print(MS.clearStage(stageIndex))
        print(MS.turn(stages[stageIndex].turn))
    }
}
