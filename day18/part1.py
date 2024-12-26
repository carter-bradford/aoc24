from collections import deque

def read_obstacles(filename, limit=1024):
    obstacles = set()
    with open(filename, 'r') as f:
        for i, line in enumerate(f):
            if i >= limit:
                break
            x, y = map(int, line.strip().split(','))
            obstacles.add((x, y))
    return obstacles

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
    # Read obstacles
    obstacles = read_obstacles('obstacles.txt')
    
    # Find shortest path
    steps = find_shortest_path(obstacles)
    
    if steps == -1:
        print("No path exists!")
    else:
        print(f"Shortest path takes {steps} steps")

if __name__ == "__main__":
    main()
