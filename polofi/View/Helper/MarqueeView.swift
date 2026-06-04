//
//  MarqueeView.swift
//  polofi
//
//  Created by Amelia Citra on 15/05/26.
//

import SwiftUI
import UIKit

// MARK: - Measurement

private enum MarqueeMeasure {
    static func singleLineWidth(for string: String, textStyle: UIFont.TextStyle) -> CGFloat {
        let baseFont = UIFont.preferredFont(forTextStyle: textStyle)
        let font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: baseFont)
        let size = (string as NSString).size(withAttributes: [.font: font])
        return ceil(size.width)
    }
}

// MARK: - MarqueeView

struct MarqueeView: View {
    let text: String
    var font: Font = .headline
    var measurementTextStyle: UIFont.TextStyle = .headline
    var interItemSpacing: CGFloat = 40
    var pixelsPerSecond: CGFloat = 30

    @Environment(\.sizeCategory) private var sizeCategory

    @State private var containerWidth: CGFloat = 0

    private var stripWidth: CGFloat {
        MarqueeMeasure.singleLineWidth(for: text, textStyle: measurementTextStyle)
    }

    private var shouldScroll: Bool {
        containerWidth > 0 && stripWidth > containerWidth + 1
    }

    var body: some View {
        Group {
            if shouldScroll {
                MarqueeScrollContent(
                    text: text,
                    font: font,
                    gap: interItemSpacing,
                    pixelsPerSecond: pixelsPerSecond,
                    segmentWidth: stripWidth
                )
                .frame(width: containerWidth, alignment: .leading)
                .clipped()
            } else {
                Text(text)
                    .font(font)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .animation(.none, value: shouldScroll)
        .frame(maxWidth: .infinity)
        .background {
            Color.clear
                .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { width in
                    if width > 0, abs(width - containerWidth) > 0.5 {
                        containerWidth = width
                    }
                }
        }
        .accessibilityLabel(text)
        .id("\(text)-\(sizeCategory)")
    }
}

// MARK: - Scrolling strip

private struct MarqueeScrollContent: View {
    let text: String
    let font: Font
    let gap: CGFloat
    let pixelsPerSecond: CGFloat
    let segmentWidth: CGFloat

    private var distance: CGFloat { segmentWidth + gap }
    private var duration: Double { max(Double(distance / pixelsPerSecond), 1.5) }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let progress = elapsed.remainder(dividingBy: duration) / duration
            let offset = -CGFloat(progress) * distance

            HStack(spacing: gap) {
                label
                label
            }
            .offset(x: offset)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .clipped()
    }

    private var label: some View {
        Text(text)
            .font(font)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Overflow") {
    VStack(alignment: .leading) {
        Text("Lofi Chill Playlist")
            .font(.headline)
            .fontWeight(.semibold)
        HStack(spacing: 8) {
            Image(systemName: "backward.fill")
            MarqueeView(text: "Bluewave - A Better Future Bluewave12345678901234567890")
            Image(systemName: "forward.fill")
        }
    }
    .padding()
    .frame(width: 320)
}

#Preview("Fits") {
    VStack(alignment: .leading) {
        Text("Lofi Chill Playlist")
            .font(.headline)
            .fontWeight(.semibold)
        HStack(spacing: 8) {
            Image(systemName: "backward.fill")
            MarqueeView(text: "Short title")
            Image(systemName: "forward.fill")
        }
    }
    .padding()
    .frame(width: 320)
}
