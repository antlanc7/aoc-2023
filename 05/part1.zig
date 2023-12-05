const std = @import("std");
const input: []const u8 = @embedFile("input.txt");
const test_input: []const u8 = @embedFile("test.txt");

const Map = struct {
    dest_begin: u32,
    src_begin: u32,
    range: u32,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var min: ?u32 = null;

    var iter_blocks = std.mem.tokenizeSequence(u8, input, "\n\n");
    const seeds_line = iter_blocks.next().?;

    var map_blocks_list = std.ArrayList([]const Map).init(allocator);
    while (iter_blocks.next()) |block| {
        var iter_lines = std.mem.tokenizeAny(u8, block, "\r\n");
        _ = iter_lines.next(); //discard first line (header)
        var maps_list = std.ArrayList(Map).init(allocator);
        while (iter_lines.next()) |line| {
            var iter_nums = std.mem.tokenizeScalar(u8, line, ' ');
            const dest = try std.fmt.parseUnsigned(u32, iter_nums.next().?, 10);
            const src = try std.fmt.parseUnsigned(u32, iter_nums.next().?, 10);
            const range = try std.fmt.parseUnsigned(u32, iter_nums.next().?, 10);
            const map = Map{ .dest_begin = dest, .src_begin = src, .range = range };
            try maps_list.append(map);
        }
        try map_blocks_list.append(try maps_list.toOwnedSlice());
    }
    const map_blocks = try map_blocks_list.toOwnedSlice();

    var seeds_iter = std.mem.tokenizeScalar(u8, seeds_line, ' ');
    _ = seeds_iter.next();

    while (seeds_iter.next()) |seed_token| {
        const seed = try std.fmt.parseUnsigned(u32, seed_token, 10);

        var current = seed;

        for (map_blocks) |map_block| {
            for (map_block) |map| {
                if (current >= map.src_begin and current < map.src_begin + map.range) {
                    current = map.dest_begin + (current - map.src_begin);
                    break;
                }
            }
        }

        std.debug.print("seed {} --> ... --> {}\n", .{ seed, current });
        if (min == null or current < min.?) {
            min = current;
        }
    }
    std.debug.print("min: {}", .{min.?});
}
