import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"
    case english = "en"
    case japanese = "ja"

    var id: String { rawValue }

    /// Keep language names in their own language so the picker remains usable
    /// even when the current interface language is unfamiliar to the user.
    var displayName: String {
        switch self {
        case .simplifiedChinese: "简体中文"
        case .traditionalChinese: "繁體中文"
        case .english: "English"
        case .japanese: "日本語"
        }
    }

    var locale: Locale { Locale(identifier: rawValue) }

    static var current: AppLanguage {
        UserDefaults.standard.string(forKey: "appLanguage")
            .flatMap(AppLanguage.init(rawValue:)) ?? .simplifiedChinese
    }
}

enum L10n {
    enum Key: Hashable {
        case preferences, settings, quit, general, display, about, language
        case menuBarDisplay, displayContent, hideWhenNoMedia, fontWeight
        case scrollingDisplay, maximumCharacters, characterRange, autoScroll
        case scrollingMode, scrollingSpeed, qualityRecognition, showAppleMusicQuality
        case qualityRecognitionHint, openAccessibilitySettings, preview
        case settingsApplyImmediately, noMediaWarning, launchAtLogin
        case mediaPriority, mediaPriorityHint, notInstalled, unknownArtist
        case noReadableMedia, noQualityInfo, highQuality, whyNoQualityInfo
        case qualityInfoTitle, openSystemSettings, appDescription, openRepository
        case artworkAccessibility, loop, pingPong, regular, medium, semibold, bold
        case iconOnly, iconAndTitle, iconAndTitleAndArtist, playing, paused, stopped, unknown
        case lossless, hiResLossless, accessibilityPermissionExplanation
        case noCurrentMediaExplanation, unsupportedSourceExplanation, noPlaybackEvidenceExplanation
        case providerUnavailableExplanation
        case launchAtLoginApproval, enableLaunchAtLoginFailed, disableLaunchAtLoginFailed
    }

    static func text(_ key: Key, language: AppLanguage = .current) -> String {
        (translations[language]?[key] ?? translations[.simplifiedChinese]?[key])!
    }

    private static let translations: [AppLanguage: [Key: String]] = [
        .simplifiedChinese: [
            .preferences: "ImaotoBar 偏好设置", .settings: "设置…", .quit: "退出 ImaotoBar",
            .general: "通用", .display: "显示", .about: "关于", .language: "语言",
            .menuBarDisplay: "菜单栏显示", .displayContent: "显示内容", .hideWhenNoMedia: "未读取到媒体时隐藏图标", .fontWeight: "字体粗细",
            .scrollingDisplay: "滚动显示", .maximumCharacters: "显示字符数限制", .characterRange: "可设置范围：%d–%d 个字符", .autoScroll: "超过显示字符数限制时自动滚动",
            .scrollingMode: "滚动模式", .scrollingSpeed: "滚动速度", .qualityRecognition: "音质识别", .showAppleMusicQuality: "显示 Apple Music 音质",
            .qualityRecognitionHint: "为保证识别稳定性，开启后建议保持 Apple Music 处于前台或最小化状态。", .openAccessibilitySettings: "打开辅助功能设置", .preview: "效果预览",
            .settingsApplyImmediately: "设置会立即应用到菜单栏", .noMediaWarning: "当前未读取到 Music 或 Spotify。请确认播放器正在运行，并允许 ImaotoBar 使用“自动化”权限。",
            .launchAtLogin: "开机自启", .mediaPriority: "媒体识别优先级", .mediaPriorityHint: "拖动调整顺序。多个播放器状态相同时，将优先识别排在上方的平台。", .notInstalled: "未安装",
            .unknownArtist: "未知艺术家", .noReadableMedia: "当前没有可读取的媒体", .noQualityInfo: "未获得音质信息", .highQuality: "高质量", .whyNoQualityInfo: "为什么没有音质信息",
            .qualityInfoTitle: "关于“高质量”", .openSystemSettings: "打开系统设置", .appDescription: "原生、轻量的 macOS 菜单栏媒体信息工具", .openRepository: "在 GitHub 中打开 ImaotoBar 仓库",
            .artworkAccessibility: "%@ 的歌曲封面", .loop: "循环", .pingPong: "来回", .regular: "常规", .medium: "中等", .semibold: "半粗", .bold: "粗体",
            .iconOnly: "仅图标", .iconAndTitle: "图标 + 歌名", .iconAndTitleAndArtist: "图标 + 歌名 + 歌手", .playing: "播放中", .paused: "已暂停", .stopped: "已停止", .unknown: "未知",
            .lossless: "无损", .hiResLossless: "高解析无损",
            .launchAtLoginApproval: "请在“系统设置 → 通用 → 登录项”中允许 ImaotoBar 开机自启。", .enableLaunchAtLoginFailed: "无法开启开机自启：%@", .disableLaunchAtLoginFailed: "无法关闭开机自启：%@",
            .accessibilityPermissionExplanation: "ImaotoBar 需要“辅助功能”权限，才能只读检查 Music 当前播放控件中的音质标识。", .noCurrentMediaExplanation: "当前没有正在播放、可用于识别音质的 Apple Music 曲目。", .unsupportedSourceExplanation: "当前媒体来源暂未提供音质识别。识别仅支持 Apple Music。", .noPlaybackEvidenceExplanation: "Music 当前播放控件没有提供可验证的音质信息。在大部份情况下，这表明目前播放的曲目为普通音质（最高为 AAC 256kbps），也有较小可能性是当前版本的 Music 未向辅助功能公开该信息。", .providerUnavailableExplanation: "暂时无法读取 Music 的播放控件。ImaotoBar 会尝试维持一个最小化的 Music 窗口用于后台识别；若仍失败，可重新打开 Music 后再试。"
        ],
        .traditionalChinese: [
            .preferences: "ImaotoBar 偏好設定", .settings: "設定…", .quit: "結束 ImaotoBar", .general: "一般", .display: "顯示", .about: "關於", .language: "語言", .launchAtLoginApproval: "請在「系統設定 → 一般 → 登入項目」中允許 ImaotoBar 在登入時啟動。", .enableLaunchAtLoginFailed: "無法啟用登入時啟動：%@", .disableLaunchAtLoginFailed: "無法關閉登入時啟動：%@",
            .menuBarDisplay: "選單列顯示", .displayContent: "顯示內容", .hideWhenNoMedia: "未讀取到媒體時隱藏圖示", .fontWeight: "字體粗細", .scrollingDisplay: "捲動顯示", .maximumCharacters: "顯示字元數限制", .characterRange: "可設定範圍：%d–%d 個字元", .autoScroll: "超過顯示字元數限制時自動捲動", .scrollingMode: "捲動模式", .scrollingSpeed: "捲動速度", .qualityRecognition: "音質辨識", .showAppleMusicQuality: "顯示 Apple Music 音質", .qualityRecognitionHint: "為確保辨識穩定性，開啟後建議讓 Apple Music 保持在前景或最小化。", .openAccessibilitySettings: "開啟輔助使用設定", .preview: "效果預覽", .settingsApplyImmediately: "設定會立即套用至選單列", .noMediaWarning: "目前未讀取到 Music 或 Spotify。請確認播放器正在執行，並允許 ImaotoBar 使用「自動化」權限。", .launchAtLogin: "登入時啟動", .mediaPriority: "媒體辨識優先順序", .mediaPriorityHint: "拖移以調整順序。多個播放器狀態相同時，會優先辨識上方的平台。", .notInstalled: "未安裝", .unknownArtist: "未知演出者", .noReadableMedia: "目前沒有可讀取的媒體", .noQualityInfo: "未取得音質資訊", .highQuality: "高品質", .whyNoQualityInfo: "為什麼沒有音質資訊", .qualityInfoTitle: "關於「高品質」", .openSystemSettings: "開啟系統設定", .appDescription: "原生、輕量的 macOS 選單列媒體資訊工具", .openRepository: "在 GitHub 開啟 ImaotoBar 儲存庫", .artworkAccessibility: "%@ 的歌曲封面", .loop: "循環", .pingPong: "來回", .regular: "一般", .medium: "中等", .semibold: "半粗體", .bold: "粗體", .iconOnly: "僅圖示", .iconAndTitle: "圖示 + 歌名", .iconAndTitleAndArtist: "圖示 + 歌名 + 演出者", .playing: "播放中", .paused: "已暫停", .stopped: "已停止", .unknown: "未知", .lossless: "無損", .hiResLossless: "高解析無損", .accessibilityPermissionExplanation: "ImaotoBar 需要「輔助使用」權限，才能以唯讀方式檢查 Music 目前播放控制項中的音質標示。", .noCurrentMediaExplanation: "目前沒有正在播放、可供辨識音質的 Apple Music 曲目。", .unsupportedSourceExplanation: "目前媒體來源不提供音質辨識。辨識僅支援 Apple Music。", .noPlaybackEvidenceExplanation: "Music 目前播放控制項未提供可驗證的音質資訊。多數情況下，這表示目前曲目為一般音質（最高 AAC 256kbps）；也可能是目前版本的 Music 未透過輔助使用功能公開該資訊。", .providerUnavailableExplanation: "暫時無法讀取 Music 的播放控制項。ImaotoBar 會嘗試維持最小化的 Music 視窗以供背景辨識；若仍失敗，請重新開啟 Music 後再試。"
        ],
        .english: [
            .preferences: "ImaotoBar Preferences", .settings: "Settings…", .quit: "Quit ImaotoBar", .general: "General", .display: "Display", .about: "About", .language: "Language", .launchAtLoginApproval: "Allow ImaotoBar to launch at login in System Settings → General → Login Items.", .enableLaunchAtLoginFailed: "Could not enable launch at login: %@", .disableLaunchAtLoginFailed: "Could not disable launch at login: %@",
            .menuBarDisplay: "Menu Bar Display", .displayContent: "Show", .hideWhenNoMedia: "Hide icon when no media is detected", .fontWeight: "Font Weight", .scrollingDisplay: "Scrolling", .maximumCharacters: "Character limit", .characterRange: "Range: %d–%d characters", .autoScroll: "Scroll automatically when the character limit is exceeded", .scrollingMode: "Scrolling mode", .scrollingSpeed: "Scrolling speed", .qualityRecognition: "Audio Quality Detection", .showAppleMusicQuality: "Show Apple Music audio quality", .qualityRecognitionHint: "For reliable detection, keep Apple Music in the foreground or minimized after enabling this option.", .openAccessibilitySettings: "Open Accessibility Settings", .preview: "Preview", .settingsApplyImmediately: "Changes apply to the menu bar immediately", .noMediaWarning: "No media was detected from Music or Spotify. Make sure a player is running and allow ImaotoBar to use Automation.", .launchAtLogin: "Launch at login", .mediaPriority: "Media Detection Priority", .mediaPriorityHint: "Drag to reorder. When multiple players have the same state, the higher platform takes priority.", .notInstalled: "Not installed", .unknownArtist: "Unknown artist", .noReadableMedia: "No readable media", .noQualityInfo: "Audio quality unavailable", .highQuality: "High quality", .whyNoQualityInfo: "Why is audio quality unavailable?", .qualityInfoTitle: "About “High quality”", .openSystemSettings: "Open System Settings", .appDescription: "A native, lightweight macOS menu bar media utility", .openRepository: "Open ImaotoBar repository on GitHub", .artworkAccessibility: "Artwork for %@", .loop: "Loop", .pingPong: "Back and forth", .regular: "Regular", .medium: "Medium", .semibold: "Semibold", .bold: "Bold", .iconOnly: "Icon only", .iconAndTitle: "Icon + title", .iconAndTitleAndArtist: "Icon + title + artist", .playing: "Playing", .paused: "Paused", .stopped: "Stopped", .unknown: "Unknown", .lossless: "Lossless", .hiResLossless: "Hi-Res Lossless", .accessibilityPermissionExplanation: "ImaotoBar needs Accessibility permission to read the audio-quality label in Music’s Now Playing controls.", .noCurrentMediaExplanation: "There is no currently playing Apple Music track whose audio quality can be detected.", .unsupportedSourceExplanation: "The current media source does not provide audio-quality detection. Only Apple Music is supported.", .noPlaybackEvidenceExplanation: "Music’s Now Playing controls do not provide verifiable audio-quality information. Usually this means the track is standard quality (up to AAC 256 kbps), though the current version of Music may not expose it through Accessibility.", .providerUnavailableExplanation: "Music’s Now Playing controls are temporarily unavailable. ImaotoBar will try to keep a minimized Music window for background detection; if this continues, reopen Music and try again."
        ],
        .japanese: [
            .preferences: "ImaotoBar 環境設定", .settings: "設定…", .quit: "ImaotoBar を終了", .general: "一般", .display: "表示", .about: "情報", .language: "言語", .launchAtLoginApproval: "「システム設定 → 一般 → ログイン項目」で ImaotoBar のログイン時起動を許可してください。", .enableLaunchAtLoginFailed: "ログイン時起動を有効にできませんでした：%@", .disableLaunchAtLoginFailed: "ログイン時起動を無効にできませんでした：%@", .menuBarDisplay: "メニューバー表示", .displayContent: "表示内容", .hideWhenNoMedia: "メディアが検出されないときアイコンを隠す", .fontWeight: "フォントの太さ", .scrollingDisplay: "スクロール表示", .maximumCharacters: "文字数の上限", .characterRange: "設定範囲：%d～%d 文字", .autoScroll: "文字数の上限を超えたとき自動でスクロール", .scrollingMode: "スクロール方式", .scrollingSpeed: "スクロール速度", .qualityRecognition: "音質の検出", .showAppleMusicQuality: "Apple Music の音質を表示", .qualityRecognitionHint: "検出を安定させるため、有効後は Apple Music を前面または最小化した状態にしてください。", .openAccessibilitySettings: "アクセシビリティ設定を開く", .preview: "プレビュー", .settingsApplyImmediately: "変更はすぐにメニューバーへ反映されます", .noMediaWarning: "Music または Spotify からメディアを検出できません。プレーヤーが起動していることと、ImaotoBar の「オートメーション」権限を確認してください。", .launchAtLogin: "ログイン時に起動", .mediaPriority: "メディア検出の優先順位", .mediaPriorityHint: "ドラッグして順序を変更します。複数のプレーヤーが同じ状態の場合、上にあるプラットフォームを優先します。", .notInstalled: "未インストール", .unknownArtist: "不明なアーティスト", .noReadableMedia: "読み取れるメディアがありません", .noQualityInfo: "音質情報を取得できません", .highQuality: "高音質", .whyNoQualityInfo: "音質情報がない理由", .qualityInfoTitle: "「高音質」について", .openSystemSettings: "システム設定を開く", .appDescription: "ネイティブで軽量な macOS メニューバー用メディア情報ツール", .openRepository: "GitHub で ImaotoBar リポジトリを開く", .artworkAccessibility: "%@ のアートワーク", .loop: "ループ", .pingPong: "往復", .regular: "標準", .medium: "中", .semibold: "セミボールド", .bold: "太字", .iconOnly: "アイコンのみ", .iconAndTitle: "アイコン + 曲名", .iconAndTitleAndArtist: "アイコン + 曲名 + アーティスト", .playing: "再生中", .paused: "一時停止", .stopped: "停止", .unknown: "不明", .lossless: "ロスレス", .hiResLossless: "ハイレゾロスレス", .accessibilityPermissionExplanation: "ImaotoBar が Music の再生コントロールにある音質ラベルを読み取るには、アクセシビリティのアクセス許可が必要です。", .noCurrentMediaExplanation: "音質を検出できる再生中の Apple Music トラックはありません。", .unsupportedSourceExplanation: "現在のメディアソースは音質の検出に対応していません。対応しているのは Apple Music のみです。", .noPlaybackEvidenceExplanation: "Music の再生コントロールは確認可能な音質情報を提供していません。通常は標準音質（最大 AAC 256 kbps）であることを示しますが、現在の Music がアクセシビリティ経由で情報を公開していない可能性もあります。", .providerUnavailableExplanation: "Music の再生コントロールを一時的に読み取れません。ImaotoBar はバックグラウンド検出のため最小化した Music ウィンドウを維持しようとします。解決しない場合は Music を再起動してください。"
        ]
    ]
}
