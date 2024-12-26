import * as fs from "fs";

function generatePermutations(operators: string[], length: number): string[][] {
    if (length === 1) return operators.map(op => [op]);
    const perms: string[][] = [];
    const smallerPerms = generatePermutations(operators, length - 1);
    for (const perm of smallerPerms) {
        for (const op of operators) {
            perms.push([...perm, op]);
        }
    }
    return perms;
}

function applyOperations(operands : number[], operators: string[]) : number {
    return operators.reduce((acc, operator, index) => {
        if (operator === "||") {
            return Number(acc.toString() + operands[index + 1].toString());
        } else
        if (operator === "+") {
            return acc + operands[index + 1];
        } else {
            return acc * operands[index + 1];
        }
    }, operands[0]);
}

// Read the file
const fileContent = fs.readFileSync("the_calculations.txt", "utf-8");

// Initialize the lists
const equationResults: number[] = [];
const operands: number[][] = [];

// Process the data
fileContent.split("\n").forEach((line) => {
    if (line.trim()) { // Ensure line is not empty
        const [left, right] = line.split(":");
        equationResults.push(Number(left.trim()));
        const rightOperands = right.trim().split(" ").map(Number);
        operands.push(rightOperands);
    }
});

let equationsSolved = 0;
let sumOfValues = 0;
for(let i = 0; i < operands.length; i++) {
    let result = equationResults[i];
    let operand = operands[i];
    console.log(`Result: ${result}`);
    const operators = ["+", "*"];
    const permutations = generatePermutations(operators, operand.length - 1);

    for (const perm of permutations) {
        let calcResult = applyOperations(operand, perm);
        if(calcResult === result) {
            console.log(`Found: ${operand.join(" ")} = ${result} -- ${perm.join(" ")}`);
            equationsSolved++;
            sumOfValues += result;
            break;
        }
    }
}

let equationsSolvedPart2 = 0;
let sumOfValuesPart2 = 0;
for(let i = 0; i < operands.length; i++) {
    let result = equationResults[i];
    let operand = operands[i];
    console.log(`Result: ${result}`);
    const operators = ["+", "*", "||"];
    const permutations = generatePermutations(operators, operand.length - 1);

    for (const perm of permutations) {
        let calcResult = applyOperations(operand, perm);
        if(calcResult === result) {
            console.log(`Found: ${operand.join(" ")} = ${result} -- ${perm.join(" ")}`);
            equationsSolvedPart2++;
            sumOfValuesPart2 += result;
            break;
        }
    }
}

console.log(`Solved ${equationsSolved} equations`);
console.log(`Sum of values: ${sumOfValues}`);
console.log(`Solved ${equationsSolvedPart2} equations`);
console.log(`Sum of values: ${sumOfValuesPart2}`);
// Output the lists to verify
//console.log("Equation Results:", equationResults);
//console.log("Operands:", operands);