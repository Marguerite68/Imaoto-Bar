import AppKit
import Foundation

@main
struct AppIconShapeHarness {
    static func main() {
        let arguments = CommandLine.arguments
        guard arguments.count == 2 || arguments.count == 4 else {
            fputs("Usage: AppIconShapeHarness <icon.png> [<expected.png> <actual.png>]\n", stderr)
            exit(64)
        }

        guard let image = NSImage(contentsOf: URL(fileURLWithPath: arguments[1])),
              let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            fputs("FAIL: unable to load app icon PNG\n", stderr)
            exit(1)
        }

        let cornerCoordinates = [
            (x: 0, y: 0),
            (x: bitmap.pixelsWide - 1, y: 0),
            (x: 0, y: bitmap.pixelsHigh - 1),
            (x: bitmap.pixelsWide - 1, y: bitmap.pixelsHigh - 1)
        ]

        guard cornerCoordinates.allSatisfy({ coordinate in
            (bitmap.colorAt(x: coordinate.x, y: coordinate.y)?.alphaComponent ?? 1) < 0.01
        }) else {
            fputs("FAIL: app icon corners must be transparent so macOS renders a rounded icon\n", stderr)
            exit(1)
        }

        let centerAlpha = bitmap.colorAt(x: bitmap.pixelsWide / 2, y: bitmap.pixelsHigh / 2)?.alphaComponent ?? 0
        guard centerAlpha > 0.99 else {
            fputs("FAIL: app icon center must remain opaque\n", stderr)
            exit(1)
        }

        if arguments.count == 4 {
            guard let expected = bitmapImage(at: arguments[2]),
                  let actual = bitmapImage(at: arguments[3]),
                  expected.pixelsWide == actual.pixelsWide,
                  expected.pixelsHigh == actual.pixelsHigh else {
                fputs("FAIL: packaged icon representation dimensions are invalid\n", stderr)
                exit(1)
            }

            var totalDifference: CGFloat = 0
            for y in 0..<expected.pixelsHigh {
                for x in 0..<expected.pixelsWide {
                    let expectedColor = expected.colorAt(x: x, y: y) ?? .clear
                    let actualColor = actual.colorAt(x: x, y: y) ?? .clear
                    totalDifference += abs(expectedColor.redComponent - actualColor.redComponent)
                    totalDifference += abs(expectedColor.greenComponent - actualColor.greenComponent)
                    totalDifference += abs(expectedColor.blueComponent - actualColor.blueComponent)
                    totalDifference += abs(expectedColor.alphaComponent - actualColor.alphaComponent)
                }
            }

            let meanDifference = totalDifference / CGFloat(expected.pixelsWide * expected.pixelsHigh * 4)
            guard meanDifference < 0.01 else {
                fputs("FAIL: packaged 48px icon does not match the generated 48px representation\n", stderr)
                exit(1)
            }
        }

        print("PASS: app icon has transparent corners and an opaque center")
    }

    private static func bitmapImage(at path: String) -> NSBitmapImageRep? {
        guard let image = NSImage(contentsOf: URL(fileURLWithPath: path)),
              let tiffData = image.tiffRepresentation else { return nil }
        return NSBitmapImageRep(data: tiffData)
    }
}
