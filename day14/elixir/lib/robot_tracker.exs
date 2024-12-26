defmodule RobotTracker do
  defmodule Robot do
    defstruct x: 0, y: 0, dx: 0, dy: 0
  end

  def read_input_file(filename) do
    filename
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [_, pos] = Regex.run(~r/p=(.*?)\s/, line)
      [_, vel] = Regex.run(~r/v=(.*?)$/, line)
      [x, y] = String.split(pos, ",") |> Enum.map(&String.to_integer/1)
      [dx, dy] = String.split(vel, ",") |> Enum.map(&String.to_integer/1)
      %Robot{x: x, y: y, dx: dx, dy: dy}
    end)
  end

  def calculate_position(robot, num_seconds, grid_size_x, grid_size_y) do
    %{
      x_inc: robot.x + robot.dx * num_seconds,
      y_inc: robot.y + robot.dy * num_seconds,
      final_x: rem(rem(robot.x + robot.dx * num_seconds, grid_size_x) + grid_size_x, grid_size_x),
      final_y: rem(rem(robot.y + robot.dy * num_seconds, grid_size_y) + grid_size_y, grid_size_y)
    }
  end

  def process_robot_movement(filename, grid_size_x, grid_size_y, num_seconds, min_safety_factor) do
    # IO.puts("Processing robot movement with grid size #{grid_size_x}x#{grid_size_y} for #{num_seconds} seconds...")

    robots = read_input_file(filename)
    # Create a MapSet to store final robot positions and store it in process dictionary
    Process.put(:final_positions, MapSet.new())

    Enum.each(robots, fn robot ->
      # IO.inspect(robot)
      result = calculate_position(robot, num_seconds, grid_size_x, grid_size_y)
      # Add final position to MapSet
      Process.put(:final_positions, MapSet.put(Process.get(:final_positions), {result.final_x, result.final_y}))

      mid_x = div(grid_size_x, 2)
      mid_y = div(grid_size_y, 2)
      quadrant = cond do
        result.final_x == mid_x || result.final_y == mid_y -> :middle
        result.final_x < mid_x && result.final_y > mid_y -> :northwest
        result.final_x > mid_x && result.final_y > mid_y -> :northeast
        result.final_x < mid_x && result.final_y < mid_y -> :southwest
        result.final_x > mid_x && result.final_y < mid_y -> :southeast
      end
      if quadrant != :middle do
        Process.put(quadrant, (Process.get(quadrant) || 0) + 1)
      end
      # IO.puts("Robot moved to (#{result.final_x}, #{result.final_y})")
    end)

    # IO.puts("\nQuadrant counts:")
    # IO.puts("Northwest: #{Process.get(:northwest) || 0}")
    # IO.puts("Northeast: #{Process.get(:northeast) || 0}")
    # IO.puts("Southwest: #{Process.get(:southwest) || 0}")
    # IO.puts("Southeast: #{Process.get(:southeast) || 0}")
    counts = [
      Process.get(:northwest) || 0,
      Process.get(:northeast) || 0,
      Process.get(:southwest) || 0,
      Process.get(:southeast) || 0
    ]
    result = Enum.reduce(counts, 1, &(&1 * &2))
    # Print grid visualization
    if min_safety_factor > 0 and result < min_safety_factor do
      IO.puts("\nGrid visualization:")
      for y <- (grid_size_y - 1)..0 do
        row = for x <- 0..(grid_size_x - 1) do
          if MapSet.member?(Process.get(:final_positions), {x, y}), do: "X", else: "."
        end
        IO.puts(Enum.join(row))
      end
    end

    IO.puts("\nProduct of quadrant counts: #{result}")

    # Clear Process dictionary entries
    Process.delete(:final_positions)
    Process.delete(:northwest)
    Process.delete(:northeast)
    Process.delete(:southwest)
    Process.delete(:southeast)

    result
  end

  # Optional: Main function to run the script directly
  def main(_args \\ []) do
    filename = "/Users/carterbradford/tech-stuff/aoc-2024/day14/robot_movements.txt"
    safety_factor = process_robot_movement(filename, 101, 103, 100, 0)
    IO.puts("Safety factor: #{safety_factor}")
    #filename = "/Users/carterbradford/tech-stuff/aoc-2024/day14/robot_example.txt"
    #safety_factor = process_robot_movement(filename, 11, 7, 100)
    min_safety_factor = process_robot_movement(filename, 101, 103, 1, 0)

    Enum.reduce(2..19999, min_safety_factor, fn num_seconds, current_min ->
      IO.puts("Processing for #{num_seconds} seconds...")
      safety_factor = process_robot_movement(filename, 101, 103, num_seconds, current_min)
      min(safety_factor, current_min)
    end)
  end
end

# If you want to run this as a script, uncomment the following line:
RobotTracker.main()
