import AppKit
import Foundation

@main
struct AppIconShapeHarness {
    static func main() {
        let arguments = CommandLine.arguments
        guard arguments.count == 2 else {
            fputs("Usage: AppIconShapeHarness <icon.png>\n", stderr)
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

        print("PASS: app icon has transparent corners and an opaque center")
    }
}
