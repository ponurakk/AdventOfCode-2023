const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;
const AutoHashMap = std.AutoHashMap;

const MapValue = struct { i32, usize };

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("data.txt", .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var content = try file.reader().readAllAlloc(allocator, stat.size);
    var iterator = mem.tokenize(u8, content, "\n");

    var part1Sum: i32 = 0;
    var part2Sum: i32 = 0;

    var totalLen: usize = 0;
    while (iterator.next()) |_| totalLen += 1;
    iterator.reset();

    var played = ArrayList(i32).init(allocator);

    // Populate array given that every card is at least once
    for (0..totalLen) |_| {
        try played.append(1);
    }

    var i: usize = 0;
    while (iterator.next()) |line| {
        var card = mem.splitSequence(u8, line, ": ");
        _ = card.next();
        var numbers = mem.splitSequence(u8, card.next().?, " | ");

        var winningNumbers = ArrayList(i32).init(allocator);
        var myNumbers = ArrayList(i32).init(allocator);
        var foundNumbers = ArrayList(i32).init(allocator);

        winningNumbers.deinit();
        myNumbers.deinit();
        foundNumbers.deinit();

        try addNumsToArray(numbers.next().?, &winningNumbers);
        try addNumsToArray(numbers.next().?, &myNumbers);

        var index: i32 = 0;

        for (myNumbers.items) |value| {
            var isInArray = mem.containsAtLeast(i32, winningNumbers.items, 1, &[_]i32{value});
            if (isInArray == true) try foundNumbers.append(value);
        }

        if (foundNumbers.items.len > 0) {
            index += std.math.pow(i32, 2, @as(i32, @intCast(foundNumbers.items.len - 1)));
        }

        for (0..foundNumbers.items.len) |w| {
            played.items[i + w + 1] += played.items[i];
        }

        part1Sum += index;
        i += 1;
    }

    for (played.items) |value| part2Sum += value;

    std.debug.print("Part1: {}\n", .{part1Sum});
    std.debug.print("Part2: {}\n", .{part2Sum});

    played.deinit();
}

fn addNumsToArray(numbers: []const u8, array: *ArrayList(i32)) !void {
    var numberIter = std.mem.splitSequence(u8, numbers, " ");
    while (numberIter.next()) |numberStr| {
        if (!mem.eql(u8, numberStr, "")) {
            var number = try std.fmt.parseInt(i32, numberStr, 10);
            try array.append(number);
        }
    }
}
