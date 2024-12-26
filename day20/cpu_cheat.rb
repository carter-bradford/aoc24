def load_maze(filename)
  maze = []
  wall_positions = []
  start_position = nil
  end_position = nil

  File.readlines(filename).each_with_index do |line, row|
    # Convert each line into an array of characters
    maze_row = line.chomp.chars

    # Process each character in the row
    maze_row.each_with_index do |char, col|
      case char
      when '#'
        wall_positions << [row, col]
      when 'S'
        start_position = [row, col]
      when 'E'
        end_position = [row, col]
      end
    end

    maze << maze_row
  end

  return maze, wall_positions, start_position, end_position
end

# Since there is only one patth before cheating, just start bfrom the end and work backwards
#  to find the non-cheating distnace.
def find_distance(maze, end_p)
  distances = { end_p => 0 }
  current_p = end_p
  #  Keep track of the positions we need to visit
  queue = [end_p]
  while !queue.empty?
    current_p = queue.shift

    # Find possible moves from the current position
    possible_moves = [
      [current_p[0] - 1, current_p[1]], # up
      [current_p[0] + 1, current_p[1]], # down
      [current_p[0], current_p[1] - 1], # left
      [current_p[0], current_p[1] + 1]  # right
    ]

    possible_moves.each do |move|
      if move[0].between?(0, maze.length - 1) && move[1].between?(0, maze[0].length - 1) && maze[move[0]][move[1]] != '#' && distances[move].nil?
        queue << move
        distances[move] = distances[current_p] + 1
      end
    end
  end

  return distances
end

def distance_between_points(p1, p2)
  return (p1[0] - p2[0]).abs + (p1[1] - p2[1]).abs
end

# To cheat, it only makes sense to consider places where walls are next to a current path
def find_cheating_options(maze, wall_positions, distances)
  cheating_savings = {}
  wall_positions.each do |wall|
    adjacent_positions = [
      [wall[0] - 1, wall[1]], # up
      [wall[0] + 1, wall[1]], # down
      [wall[0], wall[1] - 1], # left
      [wall[0], wall[1] + 1]  # right
    ]

    cheating_positions = adjacent_positions.select do |pos|
      pos[0].between?(0, maze.length - 1) &&
      pos[1].between?(0, maze[0].length - 1) &&
      maze[pos[0]][pos[1]] != '#'
    end

    next if cheating_positions.empty?

    min_distance = cheating_positions.map { |pos| distances[pos] }.compact.min

    cheating_positions.each do |pos|
      updated_time_with_cheat = [distances[pos], min_distance + 2].min
      time_savings = distances[pos] - updated_time_with_cheat
      cheating_savings[[wall, pos]] = time_savings if time_savings >= 100
    end
  end
  return cheating_savings
end

def part2_cheating_options(maze, distances)
  cheat_length = 20
  cheat_options = {}
  distances.each do |start_p, distance|

    nearby_points = distances.keys.select { |pos| distance_between_points(start_p, pos) <= cheat_length &&  distances[pos] < distance }
    nearby_points.each do |end_p|
      total_time_saved = distances[start_p] - distances[end_p] - distance_between_points(start_p, end_p)
      cheat_options[[start_p, end_p]] = total_time_saved if total_time_saved >= 100 && (!cheat_options.key?([start_p, end_p]) || total_time_saved < cheat_options[[start_p, end_p]])
    end
  end
  return cheat_options
end

maze, wall_positions, start_p, end_p = load_maze('cpu_maze.txt')
puts "Start position: #{start_p}"
puts "End position: #{end_p}"
distances_no_cheating = find_distance(maze, end_p)
puts "Distance without cheating: #{distances_no_cheating[start_p]}"
cheating_savings = find_cheating_options(maze, wall_positions, distances_no_cheating)
puts "Number of cheating options with savings of 100+: #{cheating_savings.length}"

part2_cheats = part2_cheating_options(maze, distances_no_cheating)
puts "Number of part 2 cheating options with savings of 100+: #{part2_cheats.length}"
