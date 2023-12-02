const std = @import("std");
const input: []const u8 = @embedFile("input.txt");

pub fn main() !void {
    var iter = std.mem.tokenizeAny(u8, input, "\r\n");
    var sum: u32 = 0;
    while (iter.next()) |line| {
        var iterLine = std.mem.tokenizeSequence(u8, line, ": ");
        _ = iterLine.next();
        const reveals = iterLine.next().?;
        var iter_reveals = std.mem.tokenizeSequence(u8, reveals, "; ");
        var max_red: u32 = 0;
        var max_green: u32 = 0;
        var max_blue: u32 = 0;
        while (iter_reveals.next()) |reveal| {
            var iter_colors = std.mem.tokenizeSequence(u8, reveal, ", ");
            while (iter_colors.next()) |color| {
                var color_parts = std.mem.tokenizeSequence(u8, color, " ");
                const n = try std.fmt.parseInt(u32, color_parts.next().?, 10);
                const color_name = color_parts.next().?;
                if (std.mem.eql(u8, color_name, "red") and n > max_red) {
                    max_red = n;
                } else if (std.mem.eql(u8, color_name, "green") and n > max_green) {
                    max_green = n;
                } else if (std.mem.eql(u8, color_name, "blue") and n > max_blue) {
                    max_blue = n;
                }
            }
        }
        const power = max_blue * max_green * max_red;
        sum += power;
        std.debug.print("{} {} {} {} {}\n", .{ max_red, max_green, max_blue, power, sum });
    }
    std.debug.print("{}\n", .{sum});
}
