import sys
from collections import defaultdict
import heapq
sys.setrecursionlimit(10000)

def read_map():
    grid = []
    with open('map.txt', 'r') as file:
        for line in file:
            # Strip newline and convert string to list of chars
            grid.append(list(line.strip()))
    return grid

def move_forward(x, y, direction):
    if direction == 'N':
        return x, y - 1
    elif direction == 'E':
        return x + 1, y
    elif direction == 'S':
        return x, y + 1
    elif direction == 'W':
        return x - 1, y

def rotate_left(direction):
    if direction == 'N':
        return 'W'
    elif direction == 'E':
        return 'N'
    elif direction == 'S':
        return 'E'
    elif direction == 'W':
        return 'S'

def rotate_right(direction):
    if direction == 'N':
        return 'E'
    elif direction == 'E':
        return 'S'
    elif direction == 'S':
        return 'W'
    elif direction == 'W':
        return 'N'

def find_goal():
    for y in range(len(the_map)):
        for x in range(len(the_map[0])):
            if the_map[y][x] == 'E':
                return x, y
    return None, None

def is_valid_move(the_map, visited, x, y):
    return 0 < x < len(the_map[0]) and 0 < y < len(the_map) and the_map[y][x] != '#' and not visited[y][x]

def calculate_shortest_path(start, goal, graph):
    # Dijkstra's algorithm
    distances = defaultdict(lambda: float('inf'))
    start_state = (start[0], start[1], initial_direction)
    distances[start_state] = 0
    pq = [(0, start_state)]
    
    while pq:
        dist, current = heapq.heappop(pq)
        
        if (current[0], current[1]) == goal:
            return dist
            
        if dist > distances[current]:
            continue
            
        for cost, neighbor in graph[current]:
            new_dist = dist + cost
            if new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                heapq.heappush(pq, (new_dist, neighbor))
                
    return float('inf')

def find_nodes_in_shortest_path_collection(start, goal, graph):
    distances = defaultdict(lambda: float('inf'))
    paths = defaultdict(list)  # Store paths for each state
    start_state = (start[0], start[1], initial_direction)
    distances[start_state] = 0
    paths[start_state] = [[start_state]]
    pq = [(0, start_state)]
    shortest_paths = []
    min_dist = float('inf')
    
    while pq:
        dist, current = heapq.heappop(pq)
        
        if (current[0], current[1]) == goal:
            if dist < min_dist:
                min_dist = dist
                shortest_paths = paths[current]
            elif dist == min_dist:
                shortest_paths.extend(paths[current])
            continue
            
        if dist > distances[current]:
            continue
            
        for cost, neighbor in graph[current]:
            new_dist = dist + cost
            if new_dist < distances[neighbor]:
                distances[neighbor] = new_dist
                paths[neighbor] = [path + [neighbor] for path in paths[current]]
                heapq.heappush(pq, (new_dist, neighbor))
            elif new_dist == distances[neighbor]:
                paths[neighbor].extend([path + [neighbor] for path in paths[current]])
    
    # Count unique nodes in shortest paths
    unique_nodes = set()
    for path in shortest_paths:
        for x, y, _ in path:
            unique_nodes.add((x, y))
    
    return len(unique_nodes)

def findShortestPathLength(the_map, start, goal):
    
    rows, cols = len(the_map), len(the_map[0])
    graph = defaultdict(list)
    
    # Build graph for each position and direction
    for y in range(rows):
        for x in range(cols):
            if the_map[y][x] == '#':
                continue
            
            # For each position, consider all four directions
            for direction in ['N', 'E', 'S', 'W']:
                current = (x, y, direction)
                
                # Check moves in all directions
                for next_dir in ['N', 'E', 'S', 'W']:
                    next_x, next_y = move_forward(x, y, next_dir)
                    
                    if 0 <= next_x < cols and 0 <= next_y < rows and the_map[next_y][next_x] != '#':
                        # Cost is 1 if continuing in same direction, 1001 if turning
                        cost = 1 if next_dir == direction else 1001
                        graph[current].append((cost, (next_x, next_y, next_dir)))

    # Dijkstra's algorithm
    shortest_path = calculate_shortest_path(start, goal, graph)
    nodes_in_all_shortest_paths = find_nodes_in_shortest_path_collection(start, goal, graph)
    print(nodes_in_all_shortest_paths)
    return shortest_path

the_map = read_map()
start_x = 1
start_y = 139
(goal_x, goal_y) = find_goal()
initial_direction = 'E'
shotest_path = findShortestPathLength(the_map, (start_x, start_y), (goal_x, goal_y))
print(shotest_path)
