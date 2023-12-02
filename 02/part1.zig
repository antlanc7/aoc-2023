const std = @import("std");
const input: []const u8 = @embedFile("input.txt");

pub fn main() !void {
    var iter = std.mem.tokenizeAny(u8, input, "\r\n");
    var sum: u32 = 0;
    while (iter.next()) |line| {
        var iterLine = std.mem.tokenizeSequence(u8, line, ": ");
        const part1 = iterLine.next().?;
        const reveals = iterLine.next().?;
        var iter_reveals = std.mem.tokenizeSequence(u8, reveals, "; ");
        const id = try std.fmt.parseInt(u32, part1[5..], 10);
        var valid = true;
        reveals_loop: while (iter_reveals.next()) |reveal| {
            var iter_colors = std.mem.tokenizeSequence(u8, reveal, ", ");
            while (iter_colors.next()) |color| {
                var color_parts = std.mem.tokenizeSequence(u8, color, " ");
                const n = try std.fmt.parseInt(u32, color_parts.next().?, 10);
                const color_name = color_parts.next().?;
                std.debug.print("{s} {}\n", .{ color_name, n });
                if ((std.mem.eql(u8, color_name, "red") and n > 12) or
                    (std.mem.eql(u8, color_name, "green") and n > 13) or
                    (std.mem.eql(u8, color_name, "blue") and n > 14))
                {
                    valid = false;
                    break :reveals_loop;
                }
            }
        }

        if (valid) sum += id;
        std.debug.print("{} {} {}\n", .{ valid, id, sum });
    }
    std.debug.print("{}\n", .{sum});
}
