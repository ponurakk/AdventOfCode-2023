const std = @import("std");
const ascii = @import("std").ascii;
const unicode = @import("std").unicode;

pub fn main() !void {
    // const stdout_file = std.io.getStdOut().writer();
    // var bw = std.io.bufferedWriter(stdout_file);
    // const stdout = bw.writer();
    // try stdout.print("Run `zig build test` to run the tests.\n", .{});
    // try bw.flush(); // don't forget to flush!

    try handle_file();
}

fn handle_file() !void {
    var file = std.fs.cwd().openFile("data.txt", .{ .mode = .read_only }) catch |err| {
        std.debug.print("Error: {}\n", .{err});
        return;
    };
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    var buf: [1024]u8 = undefined;

    var total: i32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var first_num: ?u8 = null;
        var last_num: ?u8 = null;
        for (line) |char| {
            if (!ascii.isDigit(char)) continue;

            if (first_num == null) {
                first_num = char;
                last_num = char;
            } else {
                last_num = char;
            }
        }

        var num1 = try charToInt(first_num orelse 0);
        var num2 = try charToInt(last_num orelse 0);

        const result = try std.fmt.bufPrint(&buf, "{}{}", .{ num1, num2 });

        const res = try std.fmt.parseInt(i32, result, 10);
        total += res;
    }
    std.debug.print("{d}\n", .{total});
}

fn charToInt(number: i32) !i32 {
    var f1: u21 = @intCast(number);
    var num_utf: [1]u8 = undefined;
    _ = try unicode.utf8Encode(f1, &num_utf);
    const num = try std.fmt.parseInt(i32, &num_utf, 10);
    return num;
}
