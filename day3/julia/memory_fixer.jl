# read memdump.txt into a string -- note that I joined the lines from the input to get things to work correctly
memdump = read("memdump.txt", String)

# Part 1
# Find all instances in memdump that match the regex patter mul\(\d+,\d+\)
pattern1 = r"mul\(\d+,\d+\)"
matches = eachmatch(pattern1, memdump)
sumTotalPart1 = 0
for match in matches
    nums = parse.(Int, split(match.match[5:end-1], ','))
    global sumTotalPart1 += nums[1] * nums[2]
end

# Part 2
sumTotalPart2 = 0

# Find all the matches in memdump that are before a do() or don't()
preamblePattern = r"^(.*?)(do\(\)|don't\(\))"
matches = eachmatch(preamblePattern, memdump)
for match in matches
    pattern = r"mul\(\d+,\d+\)"
    preambleMatches = eachmatch(pattern, match.match)
    for preambleMatch in preambleMatches
        nums = parse.(Int, split(preambleMatch.match[5:end-1], ','))
        global sumTotalPart2 += nums[1] * nums[2]
    end
end

# Find all the matches in memdump that are between do() and don't()
pattern2 = r"do\(\)(.*?)(?:do\(\)(.*?))*don't\(\)"
matches = eachmatch(pattern2, memdump)
for match in matches
    pattern = r"mul\(\d+,\d+\)"
    conditionalMatches = eachmatch(pattern, match.match)
    for conditionalMatch in conditionalMatches
        nums = parse.(Int, split(conditionalMatch.match[5:end-1], ','))
        global sumTotalPart2 += nums[1] * nums[2]
    end
end

println(sumTotalPart1)
println(sumTotalPart2)