import AppKit

@MainActor
enum MenuBarTemplateImageRenderer {
    static func textImage(
        text: String,
        font: NSFont,
        height: CGFloat,
        minimumWidth: CGFloat = 0
    ) -> NSImage {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.black
        ]
        let measuredSize = (text as NSString).size(withAttributes: attributes)
        let imageSize = NSSize(
            width: max(1, minimumWidth, ceil(measuredSize.width)),
            height: height
        )
        let image = NSImage(size: imageSize, flipped: true) { _ in
            let origin = NSPoint(
                x: 0,
                y: floor((height - measuredSize.height) / 2)
            )
            (text as NSString).draw(at: origin, withAttributes: attributes)
            return true
        }
        image.isTemplate = true
        return image
    }

    static func qualityBadgeImage(
        tier: AudioQualityTier,
        size: NSSize
    ) -> NSImage {
        let image = NSImage(size: size, flipped: true) { bounds in
            let path = NSBezierPath(
                roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
                xRadius: 3,
                yRadius: 3
            )
            NSColor.black.withAlphaComponent(0.82).setStroke()
            path.lineWidth = 1
            path.stroke()

            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 7.5, weight: .semibold),
                .foregroundColor: NSColor.black,
                .paragraphStyle: paragraph,
                .kern: 0.2
            ]
            (tier.badgeText as NSString).draw(
                in: CGRect(x: 1, y: 2.2, width: bounds.width - 2, height: 10),
                withAttributes: attributes
            )
            return true
        }
        image.isTemplate = true
        return image
    }
}
