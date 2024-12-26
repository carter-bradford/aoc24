from collections import deque

def read_all_coordinates(filename):
    coordinates = []
    with open(filename, 'r') as f:
        for line in f:
            x, y = map(int, line.strip().split(','))
            coordinates.append((x, y))
    return coordinates

def find_shortest_path(obstacles):
    # Grid dimensions
    GRID_SIZE = 71  # 0 to 70 inclusive
    START = (0, 0)
    END = (70, 70)
    
    # If start or end is blocked, no path exists
    if START in obstacles or END in obstacles:
        return -1
    
    # Possible moves: up, down, left, right
    MOVES = [(0, 1), (0, -1), (1, 0), (-1, 0)]
    
    # BFS queue and visited set
    queue = deque([(START, 0)])  # (position, steps)
    visited = {START}
    
    while queue:
        (x, y), steps = queue.popleft()
        
        # If we reached the end, return steps
        if (x, y) == END:
            return steps
        
        # Try all possible moves
        for dx, dy in MOVES:
            new_x, new_y = x + dx, y + dy
            new_pos = (new_x, new_y)
            
            # Check if move is valid:
            # 1. Within grid boundaries
            # 2. Not visited
            # 3. Not an obstacle
            if (0 <= new_x < GRID_SIZE and 
                0 <= new_y < GRID_SIZE and 
                new_pos not in visited and 
                new_pos not in obstacles):
                
                queue.append((new_pos, steps + 1))
                visited.add(new_pos)
    
    # If we get here, no path exists
    return -1

def main():
    # Read all coordinates
    coordinates = read_all_coordinates('obstacles.txt')
    
    # Create initial obstacle set with first 1024 coordinates
    obstacles = set(coordinates[:1024])
    
    # Test each subsequent coordinate
    for i, coord in enumerate(coordinates[1024:], start=1024):
        # Add new obstacle
        obstacles.add(coord)
        
        # Check if path exists
        if find_shortest_path(obstacles) == -1:
            print(f"Coordinate #{i + 1} ({coord[0]}, {coord[1]}) makes the path impossible")
            break

if __name__ == "__main__":
    main()
