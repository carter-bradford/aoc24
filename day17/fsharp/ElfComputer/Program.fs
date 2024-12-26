
type CpuState = {
    mutable A: int64
    B: int64
    C: int64
    instructionPointer: int
    outputCollecor: int64 list
}

let processInstruction (op: int) (operand: int) (state: CpuState) (program: int list) : CpuState =
    let comboOperand = 
        match operand with
        | x when x >= 0 && x <= 3 -> x |> int64
        | 4 -> state.A
        | 5 -> state.B
        | 6 -> state.C
        | _ -> failwith "Invalid operand"

    match op with
    | 0 -> { state with A = state.A / (1L <<< int comboOperand); instructionPointer = state.instructionPointer + 2 }
    | 1 -> { state with B = state.B ^^^ int64 operand; instructionPointer = state.instructionPointer + 2 }
    | 2 -> { state with B = comboOperand % 8L; instructionPointer = state.instructionPointer + 2 }
    | 3 -> { state with instructionPointer = if state.A = 0L then state.instructionPointer + 2 else operand } 
    | 4 -> { state with B = state.B ^^^ state.C; instructionPointer = state.instructionPointer + 2 }
    | 5 -> { state with instructionPointer = state.instructionPointer + 2; outputCollecor = state.outputCollecor @ [comboOperand % 8L] }
    | 6 -> { state with B = state.A / (1L <<< int comboOperand); instructionPointer = state.instructionPointer + 2 }
    | 7 -> { state with C = state.A / (1L <<< int comboOperand); instructionPointer = state.instructionPointer + 2 }
    | _ -> state

let program = [2;4;1;1;7;5;1;5;4;5;0;3;5;5;3;0]
//let cpuState = { A = 30344604L; B = 0L; C = 0L; instructionPointer = 0; outputCollecor = [] }
let cpuState = { A = 164540892147389L; B = 0L; C = 0L; instructionPointer = 0; outputCollecor = [] }

let rec loop state =
    if state.instructionPointer >= program.Length then 
        state
    else
        let op = program.[state.instructionPointer]
        let operand = program.[state.instructionPointer + 1]
        let newState = processInstruction op operand state program
        loop newState

let finalState = loop cpuState
printfn "%s" (finalState.outputCollecor |> List.map string |> String.concat ",")

let mutable current = 0L
let candidates: int64 list = []

let rec findCandidate i j =
    if i < 0 then printfn "%d" current
    else
        let candidate = current + (1L <<< (i * 3)) * int64 j
        printfn "Candidate in octal: %o" candidate
        cpuState.A <- candidate
        let endState = loop cpuState
        //printfn "%s" (endState.outputCollecor |> List.map string |> String.concat ",")
        if List.length endState.outputCollecor > i && List.skip i endState.outputCollecor = List.skip i (program |> List.map int64) then
            current <- candidate
            printfn "Found candidate: %d" candidate
            findCandidate (i - 1) 0
        else
            if j < System.Int32.MaxValue then
                // printfn "j+1 %d" (j+1)
                findCandidate i (j + 1)

findCandidate (program.Length - 1) 0
printfn "Final candidate: %d" current
