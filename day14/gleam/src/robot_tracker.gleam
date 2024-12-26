import gleam/int
import gleam/io
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/result
import gleam/string
import simplifile

pub type Robot {
  Robot(x: Int, y: Int, dx: Int, dy: Int)
}

pub fn read_input_file(filename: String) -> Result(String, simplifile.FileError) {
  simplifile.read(filename)
}

pub fn parse_line(line: String) -> Result(Robot, String) {
  let p_reg_exp_result =
    regexp.compile("p=(-?\\d+),(-?\\d+)\\s", regexp.Options(False, False))
  let v_reg_exp_result =
    regexp.compile("v=(-?\\d+),(-?\\d+)$", regexp.Options(False, False))

  case p_reg_exp_result, v_reg_exp_result {
    Ok(p_reg_exp), Ok(v_reg_exp) -> {
      let p_match =
        regexp.scan(p_reg_exp, line)
        |> list.take(1)
        |> list.first

      let v_match =
        regexp.scan(v_reg_exp, line)
        |> list.take(1)
        |> list.first

      case p_match, v_match {
        Ok(p), Ok(v) -> {
          let x =
            list.first(p.submatches)
            |> result.unwrap(Some("0"))
            |> option.unwrap("0")
            |> int.parse
            |> result.unwrap(0)
          let y =
            list.last(p.submatches)
            |> result.unwrap(Some("0"))
            |> option.unwrap("0")
            |> int.parse
            |> result.unwrap(0)
          let dx =
            list.first(v.submatches)
            |> result.unwrap(Some("0"))
            |> option.unwrap("0")
            |> int.parse
            |> result.unwrap(0)
          let dy =
            list.last(v.submatches)
            |> result.unwrap(Some("0"))
            |> option.unwrap("0")
            |> int.parse
            |> result.unwrap(0)

          Ok(Robot(x, y, dx, dy))
        }
        _, _ -> Error("Failed to parse p or v")
      }
    }
    _, _ -> Error("Failed to parse line")
  }
}

// Note that I stopped at reading the file here -- that was painful enough to figure out without much help from AI / Interwebs
// Will come back later to solve the problem using Gleam
pub fn main() {
  io.println("Hello from robot_tracker!")
  let input =
    read_input_file(
      "/Users/carterbradford/tech-stuff/aoc-2024/day14/robot_movements.txt",
    )
  case input {
    Ok(contents) -> {
      let lines = string.split(contents, "\n")
      list.each(lines, fn(line) { parse_line(line) })
      let robots = list.map(lines, fn(line) { parse_line(line) })
      list.each(robots, fn(robot_result) {
        case robot_result {
          Ok(robot) ->
            io.println(
              "Position: ("
              <> string.inspect(robot.x)
              <> ","
              <> string.inspect(robot.y)
              <> ") - Velocity: ("
              <> string.inspect(robot.dx)
              <> ","
              <> string.inspect(robot.dy)
              <> ")",
            )
          Error(_err) -> io.println("Error processing robot")
        }
      })
    }
    Error(_err) -> {
      io.println("Failed reading the file")
    }
  }
}
