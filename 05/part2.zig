const std = @import("std");
const input: []const u8 = @embedFile("input.txt");
const test_input: []const u8 = @embedFile("test.txt");

const Map = struct {
    dest_begin: usize,
    src_begin: usize,
    range: usize,
};

const SeedRange = struct {
    seed_start: usize,
    seed_range: usize,
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var iter_blocks = std.mem.tokenizeSequence(u8, input, "\n\n");
    const seeds_line = iter_blocks.next().?;

    var map_blocks_list = std.ArrayList([]const Map).init(allocator);
    while (iter_blocks.next()) |block| {
        var iter_lines = std.mem.tokenizeAny(u8, block, "\r\n");
        _ = iter_lines.next(); //discard first line (header)
        var maps_list = std.ArrayList(Map).init(allocator);
        while (iter_lines.next()) |line| {
            var iter_nums = std.mem.tokenizeScalar(u8, line, ' ');
            const dest = try std.fmt.parseUnsigned(usize, iter_nums.next().?, 10);
            const src = try std.fmt.parseUnsigned(usize, iter_nums.next().?, 10);
            const range = try std.fmt.parseUnsigned(usize, iter_nums.next().?, 10);
            const map = Map{ .dest_begin = dest, .src_begin = src, .range = range };
            try maps_list.append(map);
        }
        try map_blocks_list.append(try maps_list.toOwnedSlice());
    }
    const map_blocks = try map_blocks_list.toOwnedSlice();

    var seeds_iter = std.mem.tokenizeScalar(u8, seeds_line, ' ');
    _ = seeds_iter.next();

    var seeds_list = std.ArrayList(SeedRange).init(allocator);

    while (seeds_iter.next()) |seed_token| {
        const seed_start = try std.fmt.parseUnsigned(usize, seed_token, 10);
        const seed_range = try std.fmt.parseUnsigned(usize, seeds_iter.next().?, 10);

        try seeds_list.append(.{
            .seed_start = seed_start,
            .seed_range = seed_range,
        });
    }

    // reverse mapping search from 0 to max possible unsigned int to find minimum acceptable value
    // naive solution is too slow to be calculated
    for (0..std.math.maxInt(usize)) |min| {
        var current = min;
        var reverseIterateBlocks = std.mem.reverseIterator(map_blocks);
        while (reverseIterateBlocks.next()) |map_block| {
            for (map_block) |map| {
                if (current >= map.dest_begin and current < map.dest_begin + map.range) {
                    current = map.src_begin + (current - map.dest_begin);
                    break;
                }
            }
        }
        for (seeds_list.items) |seed| {
            if (current >= seed.seed_start and current < seed.seed_start + seed.seed_range) {
                std.debug.print("min: {}", .{min});
                return;
            }
        }
    }
}
