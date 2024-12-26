#include <iostream>
#include <fstream>
#include <regex>
#include <string>
#include <sstream>

std::string readMemdump() {
    std::ifstream file("/Users/carterbradford/tech-stuff/aoc-2024/day3/julia/memdump.txt");
    std::stringstream buffer;
    buffer << file.rdbuf();
    return buffer.str();
}

long processMultiplicationInstructions(std::string memdump) {
    
    std::regex pattern("mul\\((\\d+),(\\d+)\\)");
    std::sregex_iterator iter(memdump.begin(), memdump.end(), pattern);
    std::sregex_iterator end;
    long total = 0;
    for (; iter != end; ++iter) {
        std::smatch match = *iter;    
        int num1 = std::stoi(match[1]);
        int num2 = std::stoi(match[2]);
        total += num1 * num2;
    }
    return total;
}

int main() {
    std::cout << "Reading Memdump file" << std::endl;
    std::string memdump = readMemdump();
    long result = processMultiplicationInstructions(memdump);
    std::cout << "Result: " << result << std::endl;
    return 0;
}
