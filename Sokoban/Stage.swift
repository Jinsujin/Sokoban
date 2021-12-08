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
