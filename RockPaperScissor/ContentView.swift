//
//  ContentView.swift
//  RockPaperScissor
//
//  Created by Dodi Aditya on 12/09/23.
//

import SwiftUI

enum RpsChoices: String, CaseIterable {
    case rock, paper, scissors
}

struct RpsImage: View {
    var icon: String
    var color: Color
    
    private var isRock: Bool {
        icon == "icon-rock"
    }
    
    var body: some View {
        Image(icon)
            .resizable()
            .scaledToFit()
            .frame(width: isRock ? 50 : 60, height: isRock ? 50 : 60)
            .padding(isRock ? 25 : 20)
            .background(.white)
            .clipShape(Circle())
            .padding()
            .background(color)
            .clipShape(Circle())
    }
}

enum FadeRotateFrom {
    case bottom, right
}

struct FadeRotateModifier: ViewModifier {
    var from: FadeRotateFrom
    var withRotation = true
    var isAnimated = false
    
    private var rotation: Angle {
        if withRotation {
            return .degrees(isAnimated ? 0 : (from == .bottom ? -100 : 100))
        }
        return .degrees(0)
    }
    
    private var offset: (x: CGFloat, y: CGFloat) {
        switch from {
        case .bottom:
            return (x: 0, y: isAnimated ? 0 : 30)
        case .right:
            return (x: isAnimated ? 0 : 30, y: 0)
        }
    }
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(rotation)
            .opacity(isAnimated ? 1 : 0)
            .offset(x: offset.x, y: offset.y)
    }
}

struct ScaleAnimationModifier: ViewModifier {
    var delay: Double
    var isAnimated: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimated ? 1 : 0)
            .animation(.spring().delay(delay), value: isAnimated)
    }
}

extension View {
    func fadeRotate(from: FadeRotateFrom, withRotation: Bool = true, isAnimated: Bool) -> some View {
        modifier(FadeRotateModifier(
            from: from,
            withRotation: withRotation,
            isAnimated: isAnimated)
        )
    }
    
    func scaleAnimation(delay: Double = 0, isAnimated: Bool) -> some View {
        modifier(ScaleAnimationModifier(delay: delay, isAnimated: isAnimated))
    }
}

struct ContentView: View {
    @State private var isShowRules = false
    @State private var isShowEndAlert = false
    
    @State private var score = 0
    @State private var matchPlayed = 0
    
    @State private var answerMode = false
    @State private var isPlayerWin = false
    
    @State private var playerValue: RpsChoices = .rock
    @State private var enemyValue: RpsChoices = .paper
    
    @State private var animatedAnswer = false
    @State private var animatedQuestion = false
    
    private var isDraw: Bool {
        playerValue == enemyValue
    }
    
    private var isEnded: Bool {
        matchPlayed >= 10
    }
    
    private var matchRemaining: Int {
        10 - matchPlayed
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color("BgSecondary"), Color("BgPrimary")], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Spacer()
                    
                    VStack {
                        Text("SCORE")
                            .font(.caption)
                            .foregroundColor(Color("DarkBlue"))
                            .fontWeight(.semibold)
                        Text("\(score)")
                            .font(.system(size: 36))
                            .fontWeight(.heavy)
                            .foregroundColor(.black.opacity(0.7))
                    } // VStack
                    .frame(width: 80, height: 80)
                    .background(LinearGradient(colors: [.white, .gray], startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                } // HStack
                .padding(.horizontal, 24)
                .padding(.vertical, 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.white.opacity(0.8), lineWidth: 2)
                )
                
                Spacer()
                
                if answerMode {
                    VStack {
                        HStack(spacing: 50) {
                            VStack(spacing: 20) {
                                RpsImage(
                                    icon: "icon-\(playerValue.rawValue)",
                                    color: answerColor(playerValue)
                                )
                                .fadeRotate(
                                    from: .bottom,
                                    isAnimated: animatedAnswer
                                )
                                
                                Text("YOU PICKED")
                                    .bold()
                                    .fadeRotate(
                                        from: .bottom,
                                        withRotation: false,
                                        isAnimated: animatedAnswer
                                    )
                            } // VStack
                            .animation(.default, value: animatedAnswer)
                            
                            VStack(spacing: 20) {
                                RpsImage(
                                    icon: "icon-\(enemyValue.rawValue)",
                                    color: answerColor(enemyValue)
                                )
                                .fadeRotate(
                                    from: .right,
                                    isAnimated: animatedAnswer
                                )
                                
                                Text("ENEMY PICKED")
                                    .bold()
                                    .fadeRotate(
                                        from: .right,
                                        withRotation: false,
                                        isAnimated: animatedAnswer
                                    )
                            } // VStack
                            .animation(.default.delay(0.5), value: animatedAnswer)
                        } // HStack
                        
                        Group {
                            Text("\(isDraw ? "DRAW" : "YOU \(isPlayerWin ? "WIN" : "LOSE")")")
                                .font(.largeTitle)
                                .bold()
                                .tracking(2)
                                .padding(.top, 40)
                                .padding(.bottom)
                            
                            if (!isEnded) {
                                Text("Match Remaining: \(matchRemaining)")
                            }
                            
                            Button {
                                if isEnded {
                                    isShowEndAlert = true
                                    return
                                }
                                withAnimation {
                                    answerMode = false
                                }
                            } label: {
                                Text(!isEnded ? "NEXT MATCH" : "FINISH")
                                    .bold()
                                    .tracking(2)
                                    .foregroundColor(Color("DarkBlue"))
                                    .font(.title3)
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 16)
                                    .background(RoundedRectangle(cornerRadius: 10).fill(.white))
                            }
                        } // Group
                        .offset(y: animatedAnswer ? 0 : 40)
                        .opacity(animatedAnswer ? 1 : 0)
                        .animation(.spring().delay(1), value: animatedAnswer)
                    } // VStack
                    .transition(.opacity)
                    .onAppear {
                        animatedAnswer = true
                    }
                    .onDisappear {
                        animatedAnswer = false
                    }
                } else {
                    ZStack(alignment: .center) {
                        Image("bg-triangle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 250, height: 250)
                        
                        VStack(spacing: 24) {
                            HStack(spacing: 50) {
                                Button {
                                    onAnswer(.paper)
                                } label: {
                                    RpsImage(
                                        icon: "icon-paper",
                                        color: .blue
                                    )
                                    .scaleAnimation(isAnimated: animatedQuestion)
                                }
                                Button {
                                    onAnswer(.scissors)
                                } label: {
                                    RpsImage(
                                        icon: "icon-scissors",
                                        color: .yellow
                                    )
                                    .scaleAnimation(delay: 0.3, isAnimated: animatedQuestion)
                                }
                            } // HStack
                            
                            HStack {
                                Button {
                                    onAnswer(.rock)
                                } label: {
                                    RpsImage(
                                        icon: "icon-rock",
                                        color: .red
                                    )
                                    .scaleAnimation(delay: 0.6, isAnimated: animatedQuestion)
                                }
                            } // HStack
                        } // VStack
                    } // ZStack
                    .transition(.opacity)
                    .onAppear {
                        animatedQuestion = true
                    }
                    .onDisappear {
                        animatedQuestion = false
                    }
                }
                
                Spacer()
                
                Button {
                    isShowRules = true
                } label: {
                    Text("RULES")
                        .font(.headline)
                        .tracking(4)
                        .foregroundColor(.primary)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.white, lineWidth: 1)
                        )
                }
            } // VStack
            .padding(24)
        } // ZStack
        .sheet(isPresented: $isShowRules) {
            ZStack {
                Color.white
                    .ignoresSafeArea()
                VStack(spacing: 24) {
                    Text("RULES")
                        .font(.title)
                        .tracking(4)
                        .foregroundColor(Color("DarkBlue"))
                        .bold()
                    
                    Image("image-rules")
                        .padding()
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            } // ZStack
            .presentationDetents([.height(600)])
        }
        .alert("Good Game", isPresented: $isShowEndAlert) {
            Button("Restart") {
                restart()
            }
        } message: {
            Text("The game was ended. Your last score is \(score)")
        }
    }
    
    func answerColor(_ value: RpsChoices) -> Color {
        switch value {
        case .paper:
            return .blue
        case .rock:
            return .red
        case .scissors:
            return .yellow
        }
    }
    
    func restart() {
        withAnimation {
            score = 0
            matchPlayed = 0
            
            answerMode = false
            isPlayerWin = false
            
            playerValue = .rock
            enemyValue = .paper
        }
    }
    
    func isWin(_ value: RpsChoices, with: RpsChoices) -> Bool {
        switch value {
        case .rock:
            return with == .scissors
        case .paper:
            return with == .rock
        case .scissors:
            return with == .paper
        }
    }
    
    func onAnswer(_ value: RpsChoices) {
        matchPlayed += 1
        
        playerValue = value
        enemyValue = RpsChoices.allCases.randomElement() ?? RpsChoices.paper
        
        withAnimation {
            answerMode = true
        }
        
        if playerValue != enemyValue {
            isPlayerWin = isWin(value, with: enemyValue)
            
            if isPlayerWin {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        score += 1
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
