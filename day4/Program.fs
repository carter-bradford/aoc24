open System.IO

// REad the data from wordsearch.txt file such that each row is a string in an array
let lines = File.ReadAllLines("wordsearch.txt")

let rowOccurences (searchLines : string array) : int = 
    searchLines |> Array.fold (fun acc line -> 
        let words = ["XMAS"; "SAMX"]
        words |> List.fold (fun acc word ->
            let mutable count = 0
            let regex = System.Text.RegularExpressions.Regex(word)
            count <- regex.Matches(line).Count
            acc + count
        ) acc
    ) 0 

printfn "Total Row occurrences: %d" (rowOccurences lines)

// Convert lines into a matrix where each chacter is a separate element in the matrix and transpose the matrix
let transposedMatrix = 
    lines 
    |> Array.map (fun x -> x.ToCharArray()) 
    |> Array.transpose 
    |> Array.map (fun chars -> new string(chars))

printfn "Total Column occurrences: %d" (rowOccurences transposedMatrix)

// Read the data from the wordsearch.txt file into a matrix where each row is a line from the file and each character is an element in the row.
let characterMatrix = File.ReadAllLines("wordsearch.txt") |> Array.map (fun x -> x.ToCharArray())

let getDiagonals (matrix: char[][]) (length: int) =
    let rows = matrix.Length
    let cols = matrix.[0].Length

    let getDiagonal (startRow: int) (startCol: int) (rowInc: int) (colInc: int) =
        let rec loop (row: int) (col: int) (acc: char list) =
            if row >= 0 && row < rows && col >= 0 && col < cols && List.length acc < length then
                loop (row + rowInc) (col + colInc) (matrix.[row].[col] :: acc)
            else
                acc |> List.rev |> List.toArray
        loop startRow startCol []

    let diagonals = 
        [ for row in 0 .. rows - 1 do
            for col in 0 .. cols - 1 do
                if row + length <= rows && col + length <= cols then
                    yield getDiagonal row col 1 1
                if row + length <= rows && col - length >= -1 then
                    yield getDiagonal row col 1 -1 ]

    diagonals |> List.filter (fun diag -> diag.Length = length)

let diagonals = getDiagonals characterMatrix 4
let diagonalStrings = diagonals |> List.map (fun diag -> new string(diag))

let diagonalOccurences (diagonalStrings : string list) : int = 
    let words = ["XMAS"; "SAMX"]
    diagonalStrings |> List.fold (fun acc diag -> 
        words |> List.fold (fun acc word -> 
            if diag.Contains(word) then acc + 1 else acc
        ) acc
    ) 0

printfn "Total Diagonal occurrences: %d" (diagonalOccurences diagonalStrings)

printfn "Total XMAS occurrences: %d" ((rowOccurences lines) + (rowOccurences transposedMatrix) + (diagonalOccurences diagonalStrings))

// Part 2
// Break characterMatrix into all the 3x3 matrices
let get3x3Matrices (matrix: char[][]) =
    let rows = matrix.Length
    let cols = matrix.[0].Length

    let get3x3Matrix (startRow: int) (startCol: int) =
        let rec loop (row: int) (col: int) (acc: char list list) =
            if row >= 0 && row < rows && col >= 0 && col < cols && List.length acc < 3 then
                loop (row + 1) col (Array.toList matrix.[row].[col..col+2] :: acc)
            else
                acc |> List.rev |> List.map (fun x -> x |> List.toArray) |> List.toArray
        loop startRow startCol []

    [ for row in 0 .. rows - 1 do
        for col in 0 .. cols - 1 do
            if row + 2 < rows && col + 2 < cols then
                yield get3x3Matrix row col ]

// For each 3x3 matrix, determine if it the meets the X-MAS requirements
let matrixBlocks = 
    get3x3Matrices characterMatrix
    |> List.toArray
    |> Array.filter (fun (matrix: char[][]) -> 
        matrix.[1].[1] = 'A' &&
        ((matrix.[0].[0] = 'M' && matrix.[2].[2] = 'S') || (matrix.[0].[0] = 'S' && matrix.[2].[2] = 'M')) &&
        ((matrix.[0].[2] = 'M' && matrix.[2].[0] = 'S') || (matrix.[0].[2] = 'S' && matrix.[2].[0] = 'M')))

printfn "X-MAS Mathcing Blocks: %A" (matrixBlocks).Length


