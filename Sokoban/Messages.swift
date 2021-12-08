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
    
    static let warning = "(경고!) 해당 명령을 수행할 수 없습니다!"
    static func notAvailableKey(_ key: Character) -> String {
        return "(경고!) \(key.uppercased()) 키는 가능한 입력이 아닙니다. 처리를 건너뜁니다."
    }
}
