import Foundation

struct Stage {
    var map = [[Character]]()
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


enum GameItem: Int {
    case wall = 0
    case hall = 1
    case ball = 2
    case player = 3
    case stageDivide = 4
    
    var symbol: Character {
        switch self {
        case .wall: return "#"
        case .hall: return "O"
        case .ball: return "B"
        case .player: return "P"
        case .stageDivide: return "="
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
        default:
            return nil
        }
    }
}
