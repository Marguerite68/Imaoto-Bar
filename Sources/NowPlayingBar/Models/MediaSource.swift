import Foundation

enum MediaSource: String, CaseIterable, Identifiable, Sendable {
    case appleMusic
    case spotify

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .appleMusic: "Apple Music"
        case .spotify: "Spotify"
        }
    }

    var bundleIdentifier: String {
        switch self {
        case .appleMusic: "com.apple.Music"
        case .spotify: "com.spotify.client"
        }
    }

    var fallbackSymbolName: String {
        switch self {
        case .appleMusic: "music.note"
        case .spotify: "waveform"
        }
    }

    static func normalizedPriority(from rawValues: [String]?) -> [MediaSource] {
        var seen = Set<MediaSource>()
        var priority = (rawValues ?? []).compactMap(MediaSource.init(rawValue:)).filter {
            seen.insert($0).inserted
        }

        for source in allCases where seen.insert(source).inserted {
            priority.append(source)
        }
        return priority
    }
}
