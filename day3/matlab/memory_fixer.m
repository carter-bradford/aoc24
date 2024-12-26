filePath = '/Users/carterbradford/tech-stuff/aoc-2024/day3/julia/memdump.txt';
fileData = fileread(filePath);

pattern1 = 'mul\(\d+,\d+\)';
matches = regexp(fileData, pattern1, 'match');

sumTotalPart1 = 0;
for i = 1:length(matches)
    nums = sscanf(matches{i}, 'mul(%d,%d)');
    sumTotalPart1 = sumTotalPart1 + nums(1) * nums(2);
end
disp(sumTotalPart1);