const std = @import("std");
const mem = std.mem;
const ascii = std.ascii;
const ArrayList = std.ArrayList;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("data.txt", .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var content = try file.reader().readAllAlloc(allocator, stat.size);
    var iterator = mem.tokenize(u8, content, "\n");

    var lines = ArrayList([]const u8).init(allocator);

    while (iterator.next()) |line| {
        try lines.append(line);
    }

    var input = try lines.toOwnedSlice();
    defer allocator.free(input);

    try getNumbers(input);
}

pub fn getNumbers(input: [][]const u8) !void {
    var part1: usize = 0;

    for (input) |line| {
        var firstDigit: usize = 0;
        var lastDigit: usize = 0;

        getDigit(line, &firstDigit);
        getDigit(line, &lastDigit);

        part1 += firstDigit * 10 + lastDigit;
    }

    std.debug.print("Part 1: {}\n", .{part1});

    var part2: usize = 0;
    const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

    for (input) |line| {
        var firstDigit: usize = 0;
        var index: usize = 0;

        for (line) |char| {
            if (ascii.isDigit(char)) {
                firstDigit = char - '0';
                break;
            }
            index += 1;
        }

        for (numbers, 0..) |value, i| {
            if (mem.indexOf(u8, line, value)) |pos| {
                if (pos < index) {
                    index = pos;
                    firstDigit = i + 1;
                }
            }
        }

        var lastDigit: usize = 0;
        var currentIndex: usize = 0;
        var indexLast: usize = 0;
        for (line) |char| {
            if (ascii.isDigit(char)) {
                lastDigit = char - '0';
                indexLast = currentIndex;
            }
            currentIndex += 1;
        }

        for (numbers, 0..) |value, i| {
            if (mem.lastIndexOf(u8, line, value)) |pos| {
                if (pos > indexLast) {
                    indexLast = pos;
                    lastDigit = i + 1;
                }
            }
        }

        part2 += firstDigit * 10 + lastDigit;
    }

    std.debug.print("Part 2: {}\n", .{part2});
}

fn getDigit(line: []const u8, digit: *usize) void {
    for (line) |char| {
        if (ascii.isDigit(char)) {
            digit.* = char - '0';
            break;
        }
    }
}
