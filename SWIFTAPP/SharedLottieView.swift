//
//  SharedLottieView.swift
//  TESTING
//
//  Created by apprenant130 on 18/09/2025.
//

import SwiftUI
import Lottie

/// Reusable Lottie wrapper — keep exactly ONE of these in your project.
struct LottieView: UIViewRepresentable {
    let name: String
    var loopMode: LottieLoopMode = .loop
    var speed: CGFloat = 1.0
    var contentMode: UIView.ContentMode = .scaleAspectFit  // change per usage
    var size: CGSize?

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(animation: LottieAnimation.named(name))
        view.contentMode = contentMode
        view.loopMode = loopMode
        view.animationSpeed = speed
        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {
        // Update when the animation name or settings change
        uiView.animation = LottieAnimation.named(name)
        uiView.loopMode = loopMode
        uiView.animationSpeed = speed
        uiView.contentMode = contentMode
        if !uiView.isAnimationPlaying { uiView.play() }
    }
}
