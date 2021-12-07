import Foundation

print(MS.welcome)
print(MS.br)

let model = StageModel()
//print(model.getCurrentTitle())
//let map = model.getCurrentStage().mapToString()
//print(map)
model.startNextStage()

mainLoop(isContinueGame: true, isClear: false)


//MARK: - main
func mainLoop(isContinueGame: Bool, isClear: Bool) {
    if !isContinueGame {
        print(Command.QUIT.message)
        return
    }
    
    if isClear {
        print("축하합니다, 모든 스테이지를 클리어 했습니다!")
        return
    }
    
    print(MS.prompt, terminator: "")

    let input = readLine() ?? ""
    let inputLower = input.lowercased()
    action(by: inputLower, completion: mainLoop)
}



func action(by inputString: String, completion: (Bool, Bool)-> Void) {
    let allCommandString = Command.allCases.map{ String($0.rawValue) }.joined()

    // 입력받은 문자열을 쪼개서 char 로 만든다
    // char 하나씩 실행

    // 예) ddzw
    // ->, ->, z: 커맨드에 속하지 않음(경고메시지출력), z 경고메시지 출력

    let inputArray = Array(inputString)
    var isContinueGame = true
    var isClear = false
    for input in inputArray {
        if !allCommandString.contains(input) {
            print(MS.notAvailableKey(input))
            continue
        }

        // 입력값중에 q가 있는경우(게임종료)
        // for 문 종료
        if Command(rawValue: input) == .QUIT {
            isContinueGame = false
            break
        }
        // 이동 처리
        // 1. 이동이 반영된 지도 보여주기
        // => stageModel 에서 이동을 처리하고, 결과값을 받아오기
        // 이동완료됨 : 지도 반환(이동처리후)
        // 이동불가: 지도 반환(현재지도)
        let moveResult = model.move(to: input)

        // 2. 받아온 결과 print
        if let map = moveResult.map {
            print(map)
        }
        print(moveResult.systemInfo)
        
        
        if model.checkStageClear() {
            model.startNextStage()
        }
        
        if model.checkGameClear() {
            isClear = true
            break
        }
    }
    completion(isContinueGame, isClear)
}

