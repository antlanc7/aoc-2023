const std = @import("std");
const input: []const u8 = @embedFile("input.txt");
const test_input: []const u8 = @embedFile("test.txt");

const input_to_use = input;

pub fn main() !void {
    var prod: usize = 1;

    var iter_lines = std.mem.tokenizeAny(u8, input_to_use, "\r\n");
    const times_line = iter_lines.next().?;
    const distances_line = iter_lines.next().?;

    var times_iter = std.mem.tokenizeScalar(u8, times_line, ' ');
    var distances_iter = std.mem.tokenizeScalar(u8, distances_line, ' ');

    // discard headers
    _ = times_iter.next();
    _ = distances_iter.next();

    while (times_iter.next()) |time_token| {
        const distance_token = distances_iter.next().?;

        const t = try std.fmt.parseInt(usize, time_token, 10);
        const d = try std.fmt.parseInt(usize, distance_token, 10);

        // the traveled distance is time_hold * (time - time_hold)
        // x:= time_hold
        // t:= time
        // d:= distance
        // have to find values of x in [0,time]/N where the function x*(t-x)>d
        // tx-x^2>d --> x^2-tx+d<0
        // solve the quadratic equation
        // since the function is symmetric around t/2, we can just find the first solution and then evaluate the second as t - x

        const delta: f64 = @floatFromInt(t * t - 4 * d);
        const tF: f64 = @floatFromInt(t);

        const x1F = (tF - std.math.sqrt(delta)) / 2;
        const x2F = tF - x1F;

        var x1: usize = @intFromFloat(@ceil(x1F));
        if (@ceil(x1F) == x1F) {
            x1 += 1;
        }
        var x2: usize = @intFromFloat(@floor(x2F));
        if (@floor(x2F) == x2F) {
            x2 -= 1;
        }

        std.debug.print("x1F {}, x2F {}, x1 {}, x2 {}\n", .{ x1F, x2F, x1, x2 });

        prod *= (x2 + 1) - x1;
    }
    std.debug.print("prod: {}", .{prod});
}
