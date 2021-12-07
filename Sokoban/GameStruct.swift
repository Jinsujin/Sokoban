import Foundation

struct Stage {
    var map = [[Character]]()
    var dimensionalArray = [[Int]]()
    var 가로크기 = 0
    var 세로크기 = 0
    var 구멍의수 = 0
    var 공의수 = 0
    var 플레이어의위치 = CGPoint(x: 0, y: 0)
    var 구멍밟았나 = false
    var 턴수 = 0
    
    func mapToString() -> String {
        return map.compactMap({ String($0) }).joined(separator: "\n")
    }
    
    //todo: 맵에 변경사항이 생기면(set), 맵 정보를 읽어서 구멍수 & 공의수 & 플레이어의 위치 다시 로드하기
}


enum Command: Character, CaseIterable {
    case UP = "w"
    case LEFT = "a"
    case DOWN = "s"
    case RIGHT = "d"
    case QUIT = "q"
    case RELOAD = "r"
    
    var message: String {
        switch self {
        case .UP:
            return "W: 위로 이동합니다.⬆︎"
        case .DOWN:
            return "S: 아래로 이동합니다.⬇︎"
        case .LEFT:
            return "A: 왼쪽으로 이동합니다.⬅︎"
        case .RIGHT:
            return "D: 오른쪽으로 이동합니다.►"
        case .QUIT:
            return "Bye👋"
        case .RELOAD:
            return "맵을 초기화 합니다."
        }
    }
}



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
    
    // 플레이어가 움직일 수 있는 아이템인가
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
    
    // 플레이어가 통과할 수 있는 아이템인가
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
        case GameItem.empty.symbol:
            return GameItem.empty
        default:
            return nil
        }
    }
}
