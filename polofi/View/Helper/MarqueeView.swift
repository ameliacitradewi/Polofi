//
//  MarqueeView.swift
//  polofi
//
//  Created by Amelia Citra on 15/05/26.
//

import SwiftUI
import UIKit

private enum MarqueeMeasure {
    static func singleLineWidth(for string: String, textStyle: UIFont.TextStyle) -> CGFloat {
        let uiFont = UIFont.preferredFont(forTextStyle: textStyle)
        let size = (string as NSString).size(withAttributes: [.font: uiFont])
        return ceil(size.width)
    }
}

private struct ContainerWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct MarqueeView: View {
    let text: String
    var font: Font = .headline
    /// Harus selaras dengan `font` untuk deteksi overflow (default = `.headline`).
    var measurementTextStyle: UIFont.TextStyle = .headline
    var interItemSpacing: CGFloat = 40
    var pixelsPerSecond: CGFloat = 30

    @Environment(\.sizeCategory) private var sizeCategory

    @State private var containerWidth: CGFloat = 0

    var body: some View {
        let stripWidth = MarqueeMeasure.singleLineWidth(for: text, textStyle: measurementTextStyle)
        let overflows = stripWidth > containerWidth + 0.5 && containerWidth > 0

        ZStack(alignment: .leading) {
            Group {
                if overflows {
                    MarqueeStrip(
                        text: text,
                        font: font,
                        segmentWidth: stripWidth,
                        gap: interItemSpacing,
                        pixelsPerSecond: pixelsPerSecond
                    )
                    .frame(width: containerWidth, alignment: .leading)
                    .clipped()
                } else {
                    Text(text)
                        .font(font)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
            }
            .accessibilityLabel(text)
        }
        .frame(maxWidth: .infinity)
        .background {
            GeometryReader { geo in
                Color.clear.preference(key: ContainerWidthKey.self, value: geo.size.width)
            }
        }
        .onPreferenceChange(ContainerWidthKey.self) { containerWidth = $0 }
        .id("\(text)-\(sizeCategory)")
    }
}

private struct MarqueeStrip: View {
    let text: String
    let font: Font
    let segmentWidth: CGFloat
    let gap: CGFloat
    let pixelsPerSecond: CGFloat

    @State private var animating = false

    private var distance: CGFloat { segmentWidth + gap }
    private var duration: Double { max(Double(distance / pixelsPerSecond), 1.5) }

    var body: some View {
        HStack(spacing: gap) {
            label
            label
        }
        .offset(x: animating ? -distance : 0)
        .task { startAnimation() }
        .onChange(of: distance) {
            animating = false
            DispatchQueue.main.async { startAnimation() }
        }
    }

    private func startAnimation() {
        withAnimation(
            .linear(duration: duration)
                .repeatForever(autoreverses: false)
        ) {
            animating = true
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
    VStack(alignment: .leading) {
        Text("Lofi Chill Playlist")
            .font(.headline)
            .fontWeight(.semibold)
        HStack(spacing: 8) {
            Image(systemName: "backward.fill")
            MarqueeView(text: "Purrple Cat - Crescent Moon Extra Long Title Here")
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
