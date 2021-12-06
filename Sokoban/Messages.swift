import Foundation


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
        case .ball: return "o"
        case .player: return "P"
        case .stageDivide: return "="
        }
    }
    
    // Character 값을 받아서 타입 반환하기
    static func convertItem(by char: Character) -> GameItem? {
        if char == " " {
            return nil
        }
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


struct MS {

    static let prompt = "SOKOBAN>"
    static let warning = "(경고!) 해당 명령을 수행할 수 없습니다!"
    
    static let space = " "
    
    static func notAvailableKey(_ key: Character) -> String {
        return "(경고!) \(key.uppercased()) 키는 가능한 입력이 아닙니다. 처리를 건너뜁니다."
    }
    
    private let mapStringData = """
    Stage 1
    #####
    #OoP#
    #####
    =====
    Stage 2
      #######
    ###  O  ###
    #    o    #
    # Oo P oO #
    ###  o  ###
     #   O  #
     ########
    =====
    """
}
