import Foundation


let model = StageModel(stageNumber: 2)
printWelcome()
mainLoop(isContinueGame: true)


//MARK: - main
func mainLoop(isContinueGame: Bool) {
    if !isContinueGame {
        print(Command.QUIT.message)
        return
    }
    print(MS.prompt, terminator: "")

    let input = readLine() ?? ""
    let inputLower = input.lowercased()
    action(by: inputLower, completion: mainLoop)
}

func printWelcome() {
    let map = model.getCurrentStage().mapToString()
    print(model.getStageTitle())
    print(map)
}


func action(by inputString: String, completion: (Bool)-> Void) {
    let inputArray = Array(inputString)
    var isContinueGame = true
    
    for input in inputArray {
        guard let command = Command(rawValue: input) else {
            print(MS.notAvailableKey(input))
            continue
        }
        
        if command == .QUIT {
            isContinueGame = false
            break
        }
        oneKeyAction(command)
    }
    completion(isContinueGame)
}


func oneKeyAction(_ command: Command) {
    let moveResult = model.move(to: command)
    if let map = moveResult.map {
        print(map)
    }
    print(moveResult.systemInfo)
}
