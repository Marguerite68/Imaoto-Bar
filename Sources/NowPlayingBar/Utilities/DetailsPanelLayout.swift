import AppKit

enum DetailsPanelLayout {
    static let maximumWidth: CGFloat = 390
    static let metadataArtworkSpacing: CGFloat = 16
    static var idleMessage: String { L10n.text(.noReadableMedia) }
    static var idleContentSize: NSSize {
        let messageSize = (idleMessage as NSString).size(
            withAttributes: [.font: NSFont.systemFont(ofSize: 13)]
        )
        return NSSize(
            width: ceil(messageSize.width + 40),
            height: ceil(messageSize.height + 36)
        )
    }
    private static let minimumTextWidth: CGFloat = 130

    static func contentSize(
        for mediaInfo: MediaInfo?,
        recognitionEnabled: Bool
    ) -> NSSize {
        guard mediaInfo != nil else { return idleContentSize }

        return NSSize(
            width: width(for: mediaInfo, recognitionEnabled: recognitionEnabled),
            height: height(recognitionEnabled: recognitionEnabled)
        )
    }

    static func width(
        for mediaInfo: MediaInfo?,
        recognitionEnabled: Bool
    ) -> CGFloat {
        guard mediaInfo != nil else { return idleContentSize.width }

        let padding = padding(recognitionEnabled: recognitionEnabled)
        let artworkWidth = artworkSize(recognitionEnabled: recognitionEnabled)
        let maximumTextWidth = maximumWidth
            - padding * 2
            - artworkWidth
            - metadataArtworkSpacing
        let preferredTextWidth = min(
            max(metadataWidth(for: mediaInfo, recognitionEnabled: recognitionEnabled), minimumTextWidth),
            maximumTextWidth
        )

        return ceil(
            padding * 2
                + preferredTextWidth
                + metadataArtworkSpacing
                + artworkWidth
        )
    }

    static func height(recognitionEnabled: Bool) -> CGFloat {
        recognitionEnabled ? 140 : 116
    }

    static func artworkSize(recognitionEnabled: Bool) -> CGFloat {
        recognitionEnabled ? 112 : 84
    }

    static func padding(recognitionEnabled: Bool) -> CGFloat {
        recognitionEnabled ? 14 : 16
    }

    private static func metadataWidth(
        for mediaInfo: MediaInfo?,
        recognitionEnabled: Bool
    ) -> CGFloat {
        guard let mediaInfo else { return minimumTextWidth }

        let titleFont = NSFont.systemFont(ofSize: 13, weight: .semibold)
        let bodyFont = NSFont.systemFont(ofSize: 13)
        let captionFont = NSFont.systemFont(ofSize: 11)
        let metadata = [
            (mediaInfo.title, titleFont),
            (mediaInfo.artist ?? L10n.text(.unknownArtist), bodyFont),
            (mediaInfo.album ?? "", captionFont),
            ("\(mediaInfo.application.rawValue) · \(mediaInfo.playbackState.displayName)", captionFont),
            (recognitionEnabled ? L10n.text(.noQualityInfo) : "", captionFont)
        ]

        return metadata.map { text, font in
            ceil((text as NSString).size(withAttributes: [.font: font]).width)
        }
        .max() ?? minimumTextWidth
    }
}
