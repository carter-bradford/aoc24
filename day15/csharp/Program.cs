
static char[,] ReadWarehouseMap(string fileName)
{
    string[] lines = File.ReadAllLines(fileName);
    char[,] warehouseMap = new char[lines.Length, lines[0].Length];

    for (int i = 0; i < lines.Length; i++)
    {
        for (int j = 0; j < lines[i].Length; j++)
        {
            warehouseMap[i, j] = lines[i][j];
        }
    }

    return warehouseMap;
}

static char[] ReadRobotInstructions(string fileName)
{
    string line = File.ReadAllText(fileName);
    return line.ToCharArray();
}

static void PrintWarehouseMap(MapState currentState)
{
    for (int i = 0; i < currentState.WarehouseMap.GetLength(0); i++)
    {
        for (int j = 0; j < currentState.WarehouseMap.GetLength(1); j++)
        {
            if ( i == currentState.RobotY && j == currentState.RobotX)
            {
                //Console.Write('@');
                Console.Write(currentState.WarehouseMap[i, j]);
            }
            else
            {
                Console.Write(currentState.WarehouseMap[i, j]);
            }
        }
        Console.WriteLine();
    }
}

static (int, int) UpdatePosition(char direction, int robotX, int robotY)
{
    //Console.WriteLine(direction);
    var newPosition = direction switch
    {
        '^' => (robotX, robotY - 1),
        'v' => (robotX, robotY + 1),
        '>' => (robotX + 1, robotY),
        '<' => (robotX - 1, robotY),
        _ => (robotX, robotY) // Default case
    };
    return newPosition;
}

static Dictionary<(int,int), bool> CanMoveDoubleBox(char[,] warehouseMap, int x, int y, char direction, 
    Dictionary<(int,int), bool> canMoveMap)
{
    // X Y is the left side of the box
    var rightHandX = x + 1;
    var yDelta = y + (direction == '^' ? -1 : 1);

    if (warehouseMap[yDelta, x] == '#' || warehouseMap[yDelta, rightHandX] == '#')
    {
        if (!canMoveMap.ContainsKey((x, y)))
        {
            canMoveMap.Add((x, y), false);
        }
        return canMoveMap;
    }

    if (warehouseMap[yDelta, x] == '.' && warehouseMap[yDelta, rightHandX] == '.')
    {
        if (!canMoveMap.ContainsKey((x, y)))
        {
            canMoveMap.Add((x, y), true);
        }
        return canMoveMap;
    }
    else
    {
        if (!canMoveMap.ContainsKey((x, y)))
        {
            canMoveMap.Add((x, y), true);
        }

        var nextLeft = warehouseMap[yDelta, x];
        var nextRight = warehouseMap[yDelta, rightHandX];
        if (nextLeft == '[')
        {
            canMoveMap = CanMoveDoubleBox(warehouseMap, x, yDelta, direction, canMoveMap);
        }

        if (nextLeft == ']')
        {
            canMoveMap = CanMoveDoubleBox(warehouseMap, x-1, yDelta, direction, canMoveMap);
        }

        if (nextRight == '[')
        {
            canMoveMap = CanMoveDoubleBox(warehouseMap, rightHandX, yDelta, direction, canMoveMap);
        }

        return canMoveMap;
    }
}

static MapState ProcessCommandR(char direction, int x, int y, MapState mapState)
{
    var (attemptedX, attemptedY) = UpdatePosition(direction, x, y);

    var currentChar = mapState.WarehouseMap[attemptedY, attemptedX];
    if (currentChar == '#')
    {
        return mapState;
    }
    else if (currentChar == '.') 
    {
        if (mapState.WarehouseMap[y, x] == 'O' || ((mapState.WarehouseMap[y, x] == '[' || mapState.WarehouseMap[y, x] == ']') && (direction is '<' or '>')))
        {
            mapState.WarehouseMap[attemptedY, attemptedX] = mapState.WarehouseMap[y, x];
            mapState.WarehouseMap[y, x] = '.';
            return new MapState
            {
                WarehouseMap = mapState.WarehouseMap, 
                RobotX = mapState.RobotX, 
                RobotY = mapState.RobotY
            };
        }
        else
        {
            return new MapState
            {
                WarehouseMap = mapState.WarehouseMap,
                RobotX = attemptedX,
                RobotY = attemptedY
            };
        }
    }
    else if (currentChar == 'O' || ((currentChar is  '[' or ']') && (direction is '<' or '>')))
    {
        var newMapState = ProcessCommandR(direction, attemptedX, attemptedY, mapState);
        if (newMapState.WarehouseMap[attemptedY, attemptedX] == '.')
        {
            if(x == newMapState.RobotX && y == newMapState.RobotY)
            {
                return new MapState
                {
                    WarehouseMap = newMapState.WarehouseMap,
                    RobotX = attemptedX,
                    RobotY = attemptedY
                };
            }
            else
            {
                newMapState.WarehouseMap[attemptedY, attemptedX] = newMapState.WarehouseMap[y, x];
                newMapState.WarehouseMap[y, x] = '.';
                return new MapState
                {
                    WarehouseMap = newMapState.WarehouseMap,
                    RobotX = newMapState.RobotX,
                    RobotY = newMapState.RobotY
                };
            }
        } 
        return newMapState;
    }
    else if (currentChar is '[' or ']')
    {
        // The more complex case because we are moving up/down and the boxes can spread
        // Treat the boxes as a unit with the left side the "position" of the box
        var boxXCoordinate = currentChar == '[' ? attemptedX : attemptedX - 1;
        var canMoveBoxMap = CanMoveDoubleBox(mapState.WarehouseMap, 
            boxXCoordinate, attemptedY, direction, new());
        if (canMoveBoxMap.Values.All(v => v))
        {
            if(direction == '^')
            {
                var sortedKeys = canMoveBoxMap.Keys.OrderBy(k => k.Item2).ToList();
                foreach (var key in sortedKeys)
                {
                    mapState.WarehouseMap[key.Item2 - 1, key.Item1] = '[';
                    mapState.WarehouseMap[key.Item2 - 1, key.Item1 + 1] = ']';
                    mapState.WarehouseMap[key.Item2, key.Item1] = '.';
                    mapState.WarehouseMap[key.Item2, key.Item1 + 1] = '.';
                }
                return new MapState
                {
                    WarehouseMap = mapState.WarehouseMap,
                    RobotX = attemptedX,
                    RobotY = attemptedY
                };
            }
            else
            {
                var sortedKeys = canMoveBoxMap.Keys.OrderByDescending(k => k.Item2).ToList();
                foreach (var key in sortedKeys)
                {
                    mapState.WarehouseMap[key.Item2 + 1, key.Item1] = '[';
                    mapState.WarehouseMap[key.Item2 + 1, key.Item1 + 1] = ']';
                    mapState.WarehouseMap[key.Item2, key.Item1] = '.';
                    mapState.WarehouseMap[key.Item2, key.Item1 + 1] = '.';
                }
                return new MapState
                {
                    WarehouseMap = mapState.WarehouseMap,
                    RobotX = attemptedX,
                    RobotY = attemptedY
                };
            }
        }
        
        return mapState;
    }
    else
    {
        return mapState;
    }
}

static long CalculateGpsSum(char[,] warehouseMap)
{
    long gpsSum = 0;
    for (int i = 0; i < warehouseMap.GetLength(0); i++)
    {
        for (int j = 0; j < warehouseMap.GetLength(1); j++)
        {
            if (warehouseMap[i, j] == 'O' || warehouseMap[i, j] == '[')
            {
                gpsSum += 100 * i + j;
            }
        }
    }
    return gpsSum;
}

static long ProcessRobotMovements(char[,] warehouseMap, char[] robotCommands, int robotX, int robotY)
{
    var currentMapState = new MapState {
        WarehouseMap = warehouseMap,
        RobotX = robotX,
        RobotY = robotY
    };
    
    foreach(char command in robotCommands)
    {

        if (command == '^' || command == 'v' || command == '<' || command == '>')
        {
            currentMapState = ProcessCommandR(command, currentMapState.RobotX, 
                currentMapState.RobotY, currentMapState);
            //PrintWarehouseMap(currentMapState);
            //Console.WriteLine();
        }
    }
    
    PrintWarehouseMap(currentMapState);
    
    
    return CalculateGpsSum(currentMapState.WarehouseMap);
}

// Part 2
static char[,] DoubleWarehouse(char[,] warehouseMap)
{
    int originalHeight = warehouseMap.GetLength(0);
    int originalWidth = warehouseMap.GetLength(1);
    char[,] doubledWarehouseMap = new char[originalHeight, originalWidth * 2];

    for (int i = 0; i < originalHeight; i++)
    {
        for (int j = 0; j < originalWidth; j++)
        {
            if(warehouseMap[i,j] == '@')
            {
                doubledWarehouseMap[i,j * 2] = '@';
                doubledWarehouseMap[i,j * 2 +1] = '.';
            }
            else if (warehouseMap[i, j] != 'O')
            {
                doubledWarehouseMap[i, j * 2] = warehouseMap[i, j];
                doubledWarehouseMap[i, j * 2 + 1] = warehouseMap[i, j];
            }
            else
            {
                doubledWarehouseMap[i, j * 2] = '[';
                doubledWarehouseMap[i, j * 2 + 1] = ']';
            }
        }
    }

    return doubledWarehouseMap;
}

var warehouseMap = ReadWarehouseMap("/Users/carterbradford/tech-stuff/aoc-2024/day15/csharp/warehouse_map.txt");
var robotInstructions = ReadRobotInstructions("/Users/carterbradford/tech-stuff/aoc-2024/day15/csharp/robot_commands.txt");
var doubledWarehouseMap = DoubleWarehouse(warehouseMap);
var robotX = 24;
var robotY = 24;
// Update the map to reflect that the robot's starting position is a free space
warehouseMap[robotY, robotX] = '.';
var result = ProcessRobotMovements(warehouseMap, robotInstructions, robotX, robotY);
Console.WriteLine("Result: " + result);
// Correct Answer for Part 1:  1451928


doubledWarehouseMap[robotY, robotX * 2] = '.';
PrintWarehouseMap(new MapState {
    WarehouseMap = doubledWarehouseMap, 
    RobotX = robotX * 2, 
    RobotY = robotY});
var result2 = ProcessRobotMovements(doubledWarehouseMap, robotInstructions, robotX * 2, robotY);
Console.WriteLine("Result 2: " + result2);
//PrintWarehouseMap(doubledWarehouseMap);


record MapState
{
    public char[,] WarehouseMap { get; set; }
    public int RobotX { get; set; }
    public int RobotY { get; set; }
}

