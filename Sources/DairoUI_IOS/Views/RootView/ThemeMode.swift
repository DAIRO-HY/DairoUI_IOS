//
//  ThemeMode.swift
//  DairoUI_IOS
//

import SwiftUI

/// App 的主题模式，保存在 UserDefaults 中（键为 `ThemeMode.storageKey`）。
///
///     @AppStorage(ThemeMode.storageKey) var theme = ThemeMode.system.rawValue
public enum ThemeMode: Int, CaseIterable, Sendable {

    /// 跟随系统
    case system = 0

    /// 浅色
    case light = 1

    /// 深色
    case dark = 2

    /// 主题模式在 UserDefaults 中的设置名
    public static let storageKey = "THEME"

    /// 对应的 SwiftUI 配色方案，跟随系统时为 nil
    public var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
