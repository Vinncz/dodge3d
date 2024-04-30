//
//  HapticFeedback.swift
//  dodge3d
//
//  Created by Jonathan Aaron Wibawa on 30/04/24.
//

import SwiftUI
import UIKit

struct HapticFeedback: UIViewRepresentable {
    let feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle

    func makeUIView(context: Context) -> UIView {
        return UIView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        let feedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
        feedbackGenerator.prepare()
        feedbackGenerator.impactOccurred()
    }
}
