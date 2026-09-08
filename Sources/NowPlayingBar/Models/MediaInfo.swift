import Foundation

enum MediaApplication: String, Sendable {
    case appleMusic = "Apple Music"
    case spotify = "Spotify"
    case safari = "Safari"
    case other = "Other"
    case unknown = "Unknown"
}

enum PlaybackState: String, Sendable {
    case playing
    case paused
    case stopped
    case unknown

    var displayName: String {
        switch self {
        case .playing: L10n.text(.playing)
        case .paused: L10n.text(.paused)
        case .stopped: L10n.text(.stopped)
        case .unknown: L10n.text(.unknown)
        }
    }
}

struct MediaInfo: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let artist: String?
    let album: String?
    let artworkURL: URL?
    let application: MediaApplication
    let playbackState: PlaybackState

    init(
        id: String,
        title: String,
        artist: String?,
        album: String?,
        artworkURL: URL? = nil,
        application: MediaApplication,
        playbackState: PlaybackState
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkURL = artworkURL
        self.application = application
        self.playbackState = playbackState
    }

    var menuBarText: String {
        guard let artist, !artist.isEmpty else { return title }
        return "\(title) · \(artist)"
    }

    func replacingPlaybackState(with state: PlaybackState) -> MediaInfo {
        MediaInfo(
            id: id,
            title: title,
            artist: artist,
            album: album,
            artworkURL: artworkURL,
            application: application,
            playbackState: state
        )
    }
}
