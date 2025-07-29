//
//  MenuView.swift
//  GolfWithYourEnemies
//
//  Created by Adam Míka on 27.07.2025.
//

import SwiftUI
import SpriteKit

struct MenuView: View {
    @State private var selected: Course?
    @State private var showGame = false

    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            VStack(spacing: 24) {
                ForEach(allCourses, id: \.name) { item in
                    Button(item.name) {
                        print("Tapped button for course:", item.name)
                        selected = item.course
                        showGame = true
                    }
                    .foregroundColor(.white)
                    .padding(16)
                    .background(content: { RoundedRectangle(cornerRadius: 8) })
                }
            }
            .fullScreenCover(isPresented: $showGame) {
                if let course = selected {
                    GameScreen(course: course)
                }
            }
            .onChange(of: showGame) { newValue in }
        }
    }
}

//struct GameScreen: View {
//    let course: Course
//    @State private var scene: GameScene?
//    
//    var body: some View {
//        ZStack {
//            if let s = scene {
//                SpriteView(scene: s,
//                           debugOptions: [
//                                        .showsFPS,
//                                        .showsNodeCount,
//                                        .showsPhysics,
//                                        .showsFields
//                                      ])
//                .ignoresSafeArea()
//            } else {
//                Color.black.ignoresSafeArea()   // placeholder background
//            }
//        }
//        .onAppear {
//            print("GameScreen appeared for course:", course)
//            scene = GameScene(course: course, size: course.size)
//        }
//    }
//}

struct GameScreen: View {
    let course: Course

    init(course: Course) {
        self.course = course
        print("▶️ GameScreen.init for course:", course)
    }

    private var scene: SKScene {
        print("▶️ creating scene for course:", course)
        let s = GameScene(course: course, size: course.size)
        s.scaleMode = .aspectFill
        return s
    }

    var body: some View {
        SpriteView(scene: scene,
                   debugOptions: [.showsFPS, .showsNodeCount])
            .ignoresSafeArea()
    }
}



#Preview {
    MenuView()
}
