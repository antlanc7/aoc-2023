const std = @import("std");
const input: []const u8 = @embedFile("input.txt");
const test_input: []const u8 = @embedFile("test.txt");

const LineWithCopies = struct {
    buf: []const u8,
    copies: u32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var iter_lines = std.mem.tokenizeAny(u8, input, "\r\n");
    var sum: u32 = 0;
    var list = std.ArrayList(LineWithCopies).init(allocator);
    while (iter_lines.next()) |line| {
        try list.append(LineWithCopies{
            .buf = line,
            .copies = 1,
        });
    }
    const lines = try list.toOwnedSlice();
    for (lines, 0..) |lineWithCopies, i| {
        const line = lineWithCopies.buf;
        const copies = lineWithCopies.copies;
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
        std.debug.print("matches line {} with {} copies: {}\n", .{ i + 1, copies, matches });
        for (0..matches) |index| {
            lines[i + index + 1].copies += copies;
        }
        sum += copies;
    }
    std.debug.print("sum: {}", .{sum});
}
