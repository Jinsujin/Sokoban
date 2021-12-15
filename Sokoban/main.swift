import Foundation

print(MS.welcome)

let model = StageController()
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
    let inputArray = Array(inputString)
    var isContinueGame = true
    var isClear = false
    
    for input in inputArray {
        guard let command = Command(rawValue: input) else {
            print(MS.notAvailableKey(input))
            continue
        }
        if command == .QUIT {
            isContinueGame = false
            break
        }

        if oneKeyAction(command) {
            isClear = true
            break
        }
    }
    completion(isContinueGame, isClear)
}

func oneKeyAction(_ command: Command) -> Bool {
    let moveResult = model.move(to: command)
    if let map = moveResult.map {
        print(map)
    }
    print(moveResult.systemInfo)
    
    if model.checkStageClear() && !model.checkGameClear() {
        model.printStartStage()
    }
    
    if model.checkGameClear() {
        return true
    }
    
    return false
}
