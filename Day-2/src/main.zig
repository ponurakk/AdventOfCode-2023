const std = @import("std");
const mem = std.mem;
const ArrayList = std.ArrayList;

const Color = struct {
    red: usize,
    green: usize,
    blue: usize,
};

pub fn main() !void {
    const cubeColor = Color{
        .red = 12,
        .green = 13,
        .blue = 14,
    };

    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile("data.txt", .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var content = try file.reader().readAllAlloc(allocator, stat.size);
    var iterator = mem.tokenize(u8, content, "\n");

    var part1Sum: usize = 0;
    var part2Sum: usize = 0;

    while (iterator.next()) |line| {
        var isPosible = true;

        var game = std.mem.splitSequence(u8, line, ": ");
        var gameNumber = try std.fmt.parseInt(usize, game.next().?[5..], 10);
        var rounds = std.mem.splitSequence(u8, game.next().?, "; ");

        var mostCubes: Color = Color{
            .red = 0,
            .green = 0,
            .blue = 0,
        };

        while (rounds.next()) |currentRound| {
            var cubes = std.mem.splitSequence(u8, currentRound, ", ");
            while (cubes.next()) |cube| {
                var cubeValue = std.mem.splitSequence(u8, cube, " ");
                var count = try std.fmt.parseInt(usize, cubeValue.next().?, 10);
                var color = cubeValue.next().?;

                if (mem.eql(u8, color, "red") and count > cubeColor.red) isPosible = false;
                if (mem.eql(u8, color, "green") and count > cubeColor.green) isPosible = false;
                if (mem.eql(u8, color, "blue") and count > cubeColor.blue) isPosible = false;

                if (mem.eql(u8, color, "red") and mostCubes.red < count) {
                    mostCubes.red = count;
                }
                if (mem.eql(u8, color, "green") and mostCubes.green < count) {
                    mostCubes.green = count;
                }
                if (mem.eql(u8, color, "blue") and mostCubes.blue < count) {
                    mostCubes.blue = count;
                }
            }
        }

        if (isPosible == true) {
            part1Sum += gameNumber;
        }

        part2Sum += mostCubes.red * mostCubes.green * mostCubes.blue;
    }

    std.debug.print("Part1: {}\n", .{part1Sum});
    std.debug.print("Part2: {}\n", .{part2Sum});
}
