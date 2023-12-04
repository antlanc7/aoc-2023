const std = @import("std");
const test_input: []const u8 = @embedFile("test1.txt");
const input: []const u8 = @embedFile("input.txt");

fn isDigit(char: u8) bool {
    return switch (char) {
        '0'...'9' => true,
        else => false,
    };
}

const WholeNumber = struct {
    start: usize,
    end: usize,
    value: u32,
};

fn findWholeNumber(buf: []const u8, index: usize) ?WholeNumber {
    if (!isDigit(buf[index])) {
        return null;
    }
    var start = index;
    var end = index;

    while (start > 0 and isDigit(buf[start - 1])) {
        start -= 1;
    }

    while (end < (buf.len - 1) and isDigit(buf[end + 1])) {
        end += 1;
    }

    const to_parse = buf[start .. end + 1];

    return .{
        .start = start,
        .end = end,
        .value = std.fmt.parseUnsigned(u32, to_parse, 10) catch {
            std.debug.print("found invalid number {s} at {} {}-{}\n", .{ to_parse, index, start, end });
            @panic("aborting");
        },
    };
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    var iter_lines = std.mem.tokenizeAny(u8, input, "\r\n");
    var list = std.ArrayList([]const u8).init(allocator);
    while (iter_lines.next()) |line| {
        try list.append(line);
    }
    const lines = try list.toOwnedSlice();
    var sum: u32 = 0;

    for (lines, 0..) |line, i| {
        var starting_index_of_gear: ?usize = null;
        while (std.mem.indexOfScalarPos(u8, line, starting_index_of_gear orelse 0, '*')) |index_of_gear| {
            starting_index_of_gear = index_of_gear + 1;
            var num_list = std.ArrayList(WholeNumber).init(allocator);
            defer num_list.deinit();
            for ((index_of_gear - 1)..(index_of_gear + 2)) |x| {
                for (lines[(i - 1)..(i + 2)]) |l| {
                    if (findWholeNumber(l, x)) |foundNumber| {
                        if (findEqual: {
                            for (num_list.items) |n| {
                                if (std.meta.eql(n, foundNumber)) {
                                    break :findEqual true;
                                }
                            }
                            break :findEqual false;
                        }) {
                            std.debug.print("found duplicate number {} at {}-{}\n", .{ foundNumber.value, foundNumber.start, foundNumber.end });
                            continue;
                        }
                        std.debug.print("found number {} at {}-{}\n", .{ foundNumber.value, foundNumber.start, foundNumber.end });
                        try num_list.append(foundNumber);
                    }
                }
            }
            if (num_list.items.len == 2) {
                std.debug.print("found valid gear with numbers {} and {} at {}-{}\n", .{ num_list.items[0].value, num_list.items[1].value, i, index_of_gear });
                sum += num_list.items[0].value * num_list.items[1].value;
            } else {
                std.debug.print("found invalid gear with {} numbers at {}-{}\n", .{ num_list.items.len, i, index_of_gear });
            }
        }
    }
    std.debug.print("sum: {}\n", .{sum});
}
