import Foundation

enum Command: Character {
    case UP = "w"
    case LEFT = "a"
    case DOWN = "s"
    case RIGHT = "d"
    case QUIT = "q"
    
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
        }
    }
}
