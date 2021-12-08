import Foundation


enum GameItem: Int {
    case wall = 0
    case hall = 1
    case ball = 2
    case player = 3
    case stageDivide = 4
    case empty = 5
    case filled = 6 // 구멍에 박스가 들어간 상태
    
    var symbol: Character {
        switch self {
        case .wall: return "#"
        case .hall: return "O"
        case .ball: return "B" //"ㅇ"
        case .player: return "P"
        case .stageDivide: return "="
        case .empty: return " "
        case .filled: return "X"
        }
    }
    
    /// 플레이어가 움직일 수 있는 아이템인가
    var isMoveableByPlayer: Bool {
        switch self {
        case .ball: return true
        case .filled: return true
        case .empty: return false
        case .wall: return false
        case .hall: return false
        case .player: return false
        case .stageDivide: return false
        }
    }
    
    /// 플레이어가 통과할 수 있는 아이템인가
    var isPassableByPlayer: Bool {
        switch self {
        case .hall: return true
        case .empty: return true
        case .wall: return false
        case .player: return false
        case .stageDivide: return false
        case .ball: return false
        case .filled: return false
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
        case GameItem.filled.symbol:
            return GameItem.filled
        default:
            return nil
        }
    }
}
