const std = @import("std");
const input: []const u8 = @embedFile("input.txt");

pub fn main() !void {
    var iter = std.mem.tokenizeAny(u8, input, "\r\n");
    var sum: u32 = 0;
    while (iter.next()) |line| {
        var calibration_value: u8 = 0;
        var last_digit: u8 = 0;
        for (line) |char| {
            if (char >= '0' and char <= '9') {
                if (calibration_value == 0) {
                    calibration_value += (char - '0') * 10;
                }
                last_digit = char;
            }
        }
        calibration_value += last_digit - '0';
        sum += calibration_value;
    }
    std.debug.print("{}", .{sum});
}
