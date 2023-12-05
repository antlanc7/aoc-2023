const std = @import("std");
const input: []const u8 = @embedFile("input.txt");
const test_input: []const u8 = @embedFile("test.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var iter_lines = std.mem.tokenizeAny(u8, input, "\r\n");
    var sum: u32 = 0;
    var list = std.ArrayList([]const u8).init(allocator);
    while (iter_lines.next()) |line| {
        try list.append(line);
    }
    const lines = try list.toOwnedSlice();
    for (lines, 0..) |line, i| {
        const colon_index = std.mem.indexOf(u8, line, ": ").? + 1;
        const bar_index = std.mem.indexOf(u8, line, " | ").?;
        var winning_numbers_iter = std.mem.tokenizeScalar(u8, line[colon_index..bar_index], ' ');
        var winning_numbers = std.ArrayList(u32).init(allocator);
        while (winning_numbers_iter.next()) |number_token| {
            const num = try std.fmt.parseUnsigned(u32, number_token, 10);
            try winning_numbers.append(num);
        }
        var matches: u32 = 0;
        var my_numbers_iter = std.mem.tokenizeScalar(u8, line[(bar_index + 3)..], ' ');
        while (my_numbers_iter.next()) |number_token| {
            const num = try std.fmt.parseUnsigned(u32, number_token, 10);
            if (std.mem.indexOfScalar(u32, winning_numbers.items, num) != null) {
                matches += 1;
            }
        }
        const points = if (matches > 0) std.math.pow(u32, 2, matches - 1) else 0;
        std.debug.print("points {}: {}\n", .{ i + 1, points });
        sum += points;
    }
    std.debug.print("sum: {}", .{sum});
}
