const std = @import("std");
const input: []const u8 = @embedFile("input.txt");
const numbers = .{ "zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

pub fn main() !void {
    var iter = std.mem.tokenizeAny(u8, input, "\r\n");
    var sum: u32 = 0;
    const allocator = std.heap.page_allocator;
    while (iter.next()) |line| {
        var replaced_line = try allocator.dupe(u8, line);
        inline for (numbers, 0..) |n, i| {
            const newLine = try std.mem.replaceOwned(u8, allocator, replaced_line, n, &.{ n[0], i + '0', n[n.len - 1] });
            allocator.free(replaced_line);
            replaced_line = newLine;
        }
        std.debug.print("{s} {s} ", .{ line, replaced_line });
        var calibration_value: u8 = 0;
        var last_digit: u8 = 0;
        for (replaced_line) |char| {
            if (char >= '0' and char <= '9') {
                if (calibration_value == 0) {
                    calibration_value += (char - '0') * 10;
                }
                last_digit = char;
            }
        }
        calibration_value += last_digit - '0';
        sum += calibration_value;
        std.debug.print("{} {}\n", .{ calibration_value, sum });
        allocator.free(replaced_line);
    }
    std.debug.print("{}", .{sum});
}
