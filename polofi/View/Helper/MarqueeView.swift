//
//  MarqueeView.swift
//  polofi
//
//  Created by Amelia Citra on 15/05/26.
//

import SwiftUI

private struct MeasuredStripWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// Single-line title: stays centered when it fits; horizontal marquee when wider than available space (Spotify-style seamless loop).
struct MarqueeView: View {
    let text: String
    var font: Font = .headline
    var interItemSpacing: CGFloat = 40
    /// Scroll speed roughly in points per second.
    var pixelsPerSecond: CGFloat = 30

    @State private var measuredStripWidth: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let overflows = measuredStripWidth > w + 0.5 && w > 0 && measuredStripWidth > 0

            Group {
                if overflows {
                    MarqueeStrip(
                        text: text,
                        font: font,
                        segmentWidth: measuredStripWidth,
                        gap: interItemSpacing,
                        pixelsPerSecond: pixelsPerSecond
                    )
                    .frame(width: w, height: h, alignment: .leading)
                    .clipped()
                } else {
                    Text(text)
                        .font(font)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(width: w, height: h, alignment: .center)
                }
            }
            .accessibilityLabel(text)
        }
        .overlay(alignment: .topLeading) {
            Text(text)
                .font(font)
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
                .background {
                    GeometryReader { g in
                        Color.clear.preference(key: MeasuredStripWidthKey.self, value: g.size.width)
                    }
                }
                .accessibilityHidden(true)
                .hidden()
        }
        .onPreferenceChange(MeasuredStripWidthKey.self) { measuredStripWidth = $0 }
        .id(text)
    }
}

private struct MarqueeStrip: View {
    let text: String
    let font: Font
    let segmentWidth: CGFloat
    let gap: CGFloat
    let pixelsPerSecond: CGFloat

    @State private var offset: CGFloat = 0

    var body: some View {
        HStack(spacing: gap) {
            label
            label
        }
        .offset(x: offset)
        .onAppear {
            let distance = segmentWidth + gap
            let duration = max(Double(distance / pixelsPerSecond), 1.5)
            offset = 0
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                offset = -distance
            }
        }
    }

    private var label: some View {
        Text(text)
            .font(font)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
    }
}

#Preview("Overflow") {
    MarqueeView(text: "Bluewave - A Better Future Bluewave12345678901234567890")
        .frame(width: 180)
        .padding()
}

#Preview("Fits") {
    MarqueeView(text: "Short title")
        .frame(width: 220)
        .padding()
}
