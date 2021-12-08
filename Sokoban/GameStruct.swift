import Foundation

struct Stage {
    var map = GameMapType()
    var dimensionalArray = [[Int]]()
    var width = 0
    var height = 0
    var hallCount = 0
    var ballCount = 0
    var playerPoint = CGPoint(x: 0, y: 0)
    
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
        self.dimensionalArray = makeIntMap(gameMap)
    }
    
    
    // 숫자 배열 만들기
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



// MARK:- enums
enum GameItem: Int {
    case wall = 0
    case hall = 1
    case ball = 2
    case player = 3
    case stageDivide = 4
    case empty = 5
    
    var symbol: Character {
        switch self {
        case .wall: return "#"
        case .hall: return "O"
        case .ball: return "B"
        case .player: return "P"
        case .stageDivide: return "="
        case .empty: return " "
        }
    }
    
    static func convertItem(by char: Character) -> GameItem? {
        switch char {
        case GameItem.ball.symbol:
            return GameItem.ball
        case GameItem.wall.symbol:
            return GameItem.wall
        case GameItem.hall.symbol:
            return GameItem.hall
        case GameItem.player.symbol:
            return GameItem.player
        case GameItem.stageDivide.symbol:
            return GameItem.stageDivide
        case GameItem.empty.symbol:
            return GameItem.empty
        default:
            return nil
        }
    }
}
