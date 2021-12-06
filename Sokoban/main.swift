import Foundation


/**
 step 2. 플레이어 이동 구현

 요구사항
 처음 시작하면 스테이지 2의 지도를 출력한다.
 간단한 프롬프트 (예: SOKOBAN> )를 표시해 준다.
 하나 이상의 문자를 입력받은 경우 순서대로 처리해서 단계별 상태를 출력한다.
 벽이나 공등 다른 물체에 부딪히면 해당 명령을 수행할 수 없습니다 라는 메시지를 출력하고 플레이어를 움직이지 않는다.
 
 - w: 위쪽
 - a: 왼쪽
 - s: 아래쪽
 - d: 오른쪽
 - q: 프로그램 종료
 */



let model = StageModel(stageNumber: 2)
let map = model.getCurrentStage().mapToString()
print(map)

mainLoop(isContinueGame: true)




//MARK: - 명령 입력 관련
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



func action(by inputString: String, completion: (Bool)-> Void) {
    let allCommandString = Command.allCases.map{ String($0.rawValue) }.joined()

    // 입력받은 문자열을 쪼개서 char 로 만든다
    // char 하나씩 실행

    // 예) ddzw
    // ->, ->, z: 커맨드에 속하지 않음(경고메시지출력), z 경고메시지 출력

    let inputArray = Array(inputString)
    var isContinueGame = true
    for input in inputArray {
        if !allCommandString.contains(input) {
//            print("(경고!) \(input.uppercased()) 키는 가능한 입력이 아닙니다. 처리를 건너뜁니다.")
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
    }
    completion(isContinueGame)
}

