//
//  FontLoader.swift
//  DazedAmuzed
//

import CoreText
import Foundation

enum FontLoader {
    /// Registers the bundled custom fonts (not declared via Info.plist/UIAppFonts
    /// since this project uses Xcode's synthesized Info.plist).
    static func registerCustomFonts() {
        let names = [
            "BricolageGrotesque-Medium",
            "BricolageGrotesque-ExtraBold",
            "BricolageGrotesque-ExtraBoldCondensed",
            "Inter-Medium",
            "Inter-Bold"
        ]
        for name in names {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                print("⚠️ Font not found in bundle: \(name)")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error),
               let error = error?.takeRetainedValue() {
                print("⚠️ Failed to register font \(name): \(error)")
            }
        }
    }
}
