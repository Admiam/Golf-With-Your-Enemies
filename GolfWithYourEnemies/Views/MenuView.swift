//
//  MenuView.swift
//  GolfWithYourEnemies
//
//  Created by Adam Míka on 27.07.2025.
//

import SwiftUI
import SpriteKit

struct MenuView: View {
    @State private var showGame = false

    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()

            VStack(spacing: 32) {
                Text("Golf With Your Enemies")
                    .font(.largeTitle .bold())

                Button("Start Game") { showGame = true }
                    .buttonStyle(.borderedProminent)
            }
        }
        .fullScreenCover(isPresented: $showGame) { GameScreen() }
    }
}

struct GameScreen: View {
    /// fresh scene every time we open the sheet
    private var scene: SKScene {
        let s = GameScene()
        s.size = UIScreen.main.bounds.size
        s.scaleMode = .aspectFill
        return s
    }

    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .onTapGesture {}
    }
}

#Preview {
    MenuView()
}
