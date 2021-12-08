import Foundation

struct Stage {
    var map = GameMapType()
//    var dimensionalArray = [[Int]]()
    var width = 0
    var height = 0
    var hallCount = 0
    var ballCount = 0
    var playerPoint = CGPoint(x: 0, y: 0)
    var isAboveHall = false
    var turn = 0

    func mapToString() -> String {
        return map.compactMap({ String($0) }).joined(separator: "\n")
    }
}

extension Stage {
    init(_ gameMap: GameMapType) {
        self.map = gameMap
        self.width = gameMap.map({ $0.count }).max() ?? 0
        self.height = gameMap.count

        self.ballCount = gameMap.flatMap({ $0 })
            .filter({ $0 == GameItem.ball.symbol })
            .count
        self.hallCount = gameMap.flatMap({ $0 })
            .filter({ $0 == GameItem.hall.symbol })
            .count
        self.playerPoint = findPlayerPoint(gameMap)
//        self.dimensionalArray = makeIntMap(gameMap)
    }
    
    
    private func makeIntMap(_ map: GameMapType) -> [[Int]] {
        var resultArray = [[Int]]()
        for i in 0..<map.count {
            guard let convertedArray = convertIntArray(map[i]) else {
                continue
            }
            resultArray.append(convertedArray)
        }
        return resultArray
    }
    
    private func convertIntArray(_ lineString: [Character]) -> [Int]? {
        var resultArray = [Int]()
        for char in lineString {
            guard let item = GameItem.convertItem(by: char) else {
                continue
            }
            resultArray.append(item.rawValue)
        }
        return (resultArray.count > 0 ? resultArray : nil)
    }
    

    private func findPlayerPoint(_ map: GameMapType) -> CGPoint {
        var x = 0
        var y = 0
        for i in 0..<map.count {
            let str = String(map[i])
            guard let stringIdx = str.firstIndex(of: GameItem.player.symbol) else {
                continue
            }
            let playerIdx: Int = str.distance(from: str.startIndex, to: stringIdx)
            y = i
            x = playerIdx
        }
        return CGPoint(x: x + 1, y: y + 1)
    }
}
