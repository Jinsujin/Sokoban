import Foundation

struct MS {
    static let welcome =
"""
==================================
🤖 소코반의 세계에 오신 것을 환영합니다! 🤖
◽️w: 위          ◽️s: 아래
◽️a: 왼쪽         ◽️d: 오른쪽
♻️r: 스테이지 초기화
❌q: 게임 종료
==================================
"""
    static let prompt = "SOKOBAN>"
    static let stageTitle = "Stage"
    static let br = "\n"
    
    // 스텝1
    static let width = "가로크기"
    static let height = "세로크기"
    static let hallCount = "구멍의 수"
    static let playerPoint = "플레이어 위치"
    
    
    static let warning = "(경고!) 해당 명령을 수행할 수 없습니다!"
    
    
    static let clearGame = """
                            전체 게임을 클리어하셨습니다!
                            축하드립니다!
                            """
    static func clearStage(_ index: Int) -> String {
        return "빠밤! Stage \(index + 1) 클리어!"
    }
    
    static func turn(_ num: Int) -> String {
        return "턴수: \(num)"
    }
    
    static func notAvailableKey(_ key: Character) -> String {
        return "(경고!) \(key.uppercased()) 키는 가능한 입력이 아닙니다. 처리를 건너뜁니다."
    }
}
