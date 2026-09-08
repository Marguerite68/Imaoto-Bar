import AppKit
import Foundation

@main
struct GenerateAppIcon {
    static func main() throws {
        let arguments = CommandLine.arguments
        guard arguments.count == 3 else {
            fputs("Usage: GenerateAppIcon <artwork.png> <app-icon.png>\n", stderr)
            exit(64)
        }

        guard let artwork = NSImage(contentsOf: URL(fileURLWithPath: arguments[1])) else {
            fputs("Unable to open app icon artwork.\n", stderr)
            exit(1)
        }

        let canvasSide = 1024
        guard let bitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: canvasSide,
            pixelsHigh: canvasSide,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bitmapFormat: [],
            bytesPerRow: 0,
            bitsPerPixel: 0
        ), let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
            fputs("Unable to create app icon bitmap.\n", stderr)
            exit(1)
        }

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context

        let canvas = NSRect(x: 0, y: 0, width: canvasSide, height: canvasSide)
        NSBezierPath(roundedRect: canvas, xRadius: 224, yRadius: 224).addClip()
        NSColor.white.setFill()
        NSBezierPath(rect: canvas).fill()

        // Crop to the artwork bounds, then aspect-fill the rounded icon canvas.
        let visibleArtwork = NSRect(x: 88, y: 125, width: 1078, height: 992)
        artwork.draw(
            in: NSRect(x: -44, y: 0, width: 1112, height: canvasSide),
            from: visibleArtwork,
            operation: .sourceOver,
            fraction: 1,
            respectFlipped: true,
            hints: nil
        )

        NSGraphicsContext.restoreGraphicsState()

        guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
            fputs("Unable to encode app icon PNG.\n", stderr)
            exit(1)
        }
        try pngData.write(to: URL(fileURLWithPath: arguments[2]), options: .atomic)
    }
}
