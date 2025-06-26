import Foundation
import SwiftUI

struct AttributedStringParser {
    static func parse(_ input: String) -> AttributedString {
        var attributed = AttributedString(input)

        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return attributed
        }

        let nsrange = NSRange(input.startIndex..., in: input)
        let matches = detector.matches(in: input, options: [], range: nsrange)

        for match in matches {
            guard let url = match.url,
                  let rangeInString = Range(match.range, in: input),
                  let rangeInAttributed = Range(match.range, in: attributed) else {
                continue
            }

            var linkText = AttributedString(String(input[rangeInString]))
            linkText.link = url
            linkText.foregroundColor = .blue
            linkText.underlineStyle = .single

            attributed.replaceSubrange(rangeInAttributed, with: linkText)
        }

        return attributed
    }
}
