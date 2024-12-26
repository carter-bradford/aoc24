const std = @import("std");

const Game = struct {
    a_button: struct {
        x_inc: i64,
        y_inc: i64,
    },
    b_button: struct {
        x_inc: i64,
        y_inc: i64,
    },
    prize: struct {
        x: i64,
        y: i64,
    },
};

pub fn loadGames(filename: []const u8) !std.ArrayList(Game) {
    var file = try std.fs.cwd().openFile(filename, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var games = std.ArrayList(Game).init(std.heap.page_allocator);
    var current_game: Game = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (line.len == 0) continue;

        // Process non-empty line here
        if (std.mem.startsWith(u8, line, "Button A")) {
            current_game = Game{
                .a_button = .{
                    .x_inc = blk: {
                        const x_start = std.mem.indexOf(u8, line, "X+").? + 2;
                        const x_end = std.mem.indexOf(u8, line[x_start..], ",").? + x_start;
                        const x_num = std.fmt.parseInt(i64, line[x_start..x_end], 10) catch 0;
                        break :blk x_num;
                    },
                    .y_inc = blk: {
                        const y_start = std.mem.indexOf(u8, line, "Y+").? + 2;
                        const y_end = line.len;
                        const y_num = std.fmt.parseInt(i64, line[y_start..y_end], 10) catch 0;
                        break :blk y_num;
                    },
                },
                .b_button = undefined,
                .prize = undefined,
            };
        }
        if (std.mem.startsWith(u8, line, "Button B")) {
            current_game.b_button = .{
                .x_inc = blk: {
                    const x_start = std.mem.indexOf(u8, line, "X+").? + 2;
                    const x_end = std.mem.indexOf(u8, line[x_start..], ",").? + x_start;
                    const x_num = std.fmt.parseInt(i64, line[x_start..x_end], 10) catch 0;
                    break :blk x_num;
                },
                .y_inc = blk: {
                    const y_start = std.mem.indexOf(u8, line, "Y+").? + 2;
                    const y_end = line.len;
                    const y_num = std.fmt.parseInt(i64, line[y_start..y_end], 10) catch 0;
                    break :blk y_num;
                },
            };
        }
        if (std.mem.startsWith(u8, line, "Prize")) {
            current_game.prize = .{
                .x = blk: {
                    const x_start = std.mem.indexOf(u8, line, "X=").? + 2;
                    const x_end = std.mem.indexOf(u8, line[x_start..], ",").? + x_start;
                    const x_num = std.fmt.parseInt(i64, line[x_start..x_end], 10) catch 0;
                    break :blk x_num;
                },
                .y = blk: {
                    const y_start = std.mem.indexOf(u8, line, "Y=").? + 2;
                    const y_end = line.len;
                    const y_num = std.fmt.parseInt(i64, line[y_start..y_end], 10) catch 0;
                    break :blk y_num;
                },
            };
            try games.append(current_game);
        }
    }
    return games;
}

pub fn solveGameCost(game: Game, with_offset: bool) i64 {
    const prize_x: i64 = if (with_offset) game.prize.x + 10000000000000 else game.prize.x;
    const prize_y: i64 = if (with_offset) game.prize.y + 10000000000000 else game.prize.y;
    const det = game.a_button.x_inc * game.b_button.y_inc - game.a_button.y_inc * game.b_button.x_inc;
    const det1 = prize_x * game.b_button.y_inc - prize_y * game.b_button.x_inc;
    const det2 = game.a_button.x_inc * prize_y - game.a_button.y_inc * prize_x;
    if (det == 0) {
        // std.debug.print("Determinant is zero, cannot solve\n", .{});
        return 0;
    }
    if (@mod(det1, det) != 0 or @mod(det2, det) != 0) {
        // std.debug.print("No integer solution\n", .{});
        return 0;
    }
    const a_presses = @divTrunc(det1, det);
    const b_presses = @divTrunc(det2, det);
    if (a_presses < 0 or b_presses < 0) return 0;
    const cost = 3 * a_presses + b_presses;
    // std.debug.print("A presses: {}, B presses: {}, Cost: {}\n", .{ a_presses, b_presses, cost });
    return cost;
}

pub fn main() !void {
    const games = try loadGames("the_claw_input.txt");
    var total_cost: i64 = 0;
    var total_cost_with_offset: i64 = 0;
    for (games.items) |game| {
        total_cost += solveGameCost(game, false);
        total_cost_with_offset += solveGameCost(game, true);
    }
    std.debug.print("Total cost: {}\n", .{total_cost});
    std.debug.print("Total cost with offset: {}\n", .{total_cost_with_offset});
}
