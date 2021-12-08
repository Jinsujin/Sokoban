import Foundation

struct Stage {
    var map = [[Character]]()
    var dimensionalArray = [[Int]]()
    var width = 0 // 가로크기
    var height = 0 // 세로크기
    var hallCount = 0
    var ballCount = 0
    var playerPoint = CGPoint(x: 0, y: 0)
    var isAboveHall = false
    var turn = 0
    
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
        case .ball: return "B" //"ㅇ"
        case .player: return "P"
        case .stageDivide: return "="
        }
    }
    
    // Character 값을 받아서 타입 반환하기
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
