import Foundation

print(MS.welcome)

let model = StageModel()
model.printStartStage()

mainLoop(isContinueGame: true, isClear: false)


// MARK: - main
func mainLoop(isContinueGame: Bool, isClear: Bool) {
    if !isContinueGame {
        print(Command.QUIT.message)
        return
    }
    
    if isClear {
        print(MS.clearGame)
        return
    }
    
    print(MS.prompt, terminator: "")

    let input = readLine() ?? ""
    let inputLower = input.lowercased()
    action(by: inputLower, completion: mainLoop)
}



func action(by inputString: String, completion: (Bool, Bool)-> Void) {
    let allCommandString = Command.allCases.map{ String($0.rawValue) }.joined()
    let inputArray = Array(inputString)
    var isContinueGame = true
    var isClear = false
    
    for input in inputArray {
        if !allCommandString.contains(input) {
            print(MS.notAvailableKey(input))
            continue
        }

        if Command(rawValue: input) == .QUIT {
            isContinueGame = false
            break
        }

        let moveResult = model.move(to: input)
        if let map = moveResult.map {
            print(map)
        }
        print(moveResult.systemInfo)
        
        if model.checkStageClear() {
            model.printStartStage()
        }
        
        if model.checkGameClear() {
            isClear = true
            break
        }
    }
    completion(isContinueGame, isClear)
}

