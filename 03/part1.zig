const std = @import("std");
const test_input: []const u8 = @embedFile("test1.txt");
const input: []const u8 = @embedFile("input.txt");

fn isDigit(char: u8) bool {
    return switch (char) {
        '0'...'9' => true,
        else => false,
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
        var tokenizer = std.mem.tokenizeScalar(u8, line, '.');
        while (tokenizer.next()) |token| {
            const token_start = tokenizer.index - token.len;
            switch (token[0]) {
                '0'...'9' => {
                    const len_of_num: usize = end_of_num_search: {
                        for (token, 0..) |digit, index| {
                            if (!isDigit(digit)) {
                                break :end_of_num_search index;
                            }
                        }
                        break :end_of_num_search token.len;
                    };
                    const token_end = token_start + len_of_num;
                    tokenizer.index -= token.len - len_of_num;
                    const to_parse = token[0..len_of_num];
                    const num = std.fmt.parseUnsigned(u32, to_parse, 10) catch {
                        std.debug.print("found invalid number {s} at {} {}-{}\n", .{ to_parse, i, token_start, token_end });
                        @panic("aborting");
                    };
                    std.debug.print("found number {} at {} {}-{}\n", .{ num, i, token_start, token_end });
                    if ((token_start > 0 and line[token_start - 1] != '.') or (token_end < line.len and line[token_end] != '.') or search_other_lines: {
                        const capped_token_start = if (token_start == 0) token_start else token_start - 1;
                        const capped_token_end = if (token_end == line.len) token_end else token_end + 1;
                        if (i > 0) {
                            for (lines[i - 1][capped_token_start..capped_token_end]) |char| {
                                if (!isDigit(char) and char != '.') {
                                    break :search_other_lines true;
                                }
                            }
                        }
                        if (i < lines.len - 1) {
                            for (lines[i + 1][capped_token_start..capped_token_end]) |char| {
                                if (!isDigit(char) and char != '.') {
                                    break :search_other_lines true;
                                }
                            }
                        }
                        break :search_other_lines false;
                    }) {
                        sum += num;
                        std.debug.print("found number to sum, new sum {}\n", .{sum});
                    }
                },
                else => {
                    const symbol = token[0];
                    tokenizer.index -= token.len - 1;
                    std.debug.print("found symbol {c} at {} {}-{}\n", .{ symbol, i, token_start, tokenizer.index });
                },
            }
        }
    }
    std.debug.print("sum: {}\n", .{sum});
}
