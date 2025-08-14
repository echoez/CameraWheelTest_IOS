import SwiftUI
import UIKit

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct CameraWheelView: View {
    @State private var wheelRotation: Double = 0
    @State private var lastAngle: Double = 0
    private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    
    let isoValues = [50, 64, 80, 100, 125, 160, 200, 250, 320, 400, 500, 640, 800, 1000, 1250, 1600, 2000, 2500, 3200, 4000, 5000, 6400]
    
    private var selectedIndex: Int {
        let stepAngle = 360.0 / Double(isoValues.count)
        let normalizedRotation = wheelRotation.truncatingRemainder(dividingBy: 360)
        let adjustedRotation = normalizedRotation < 0 ? normalizedRotation + 360 : normalizedRotation
        let index = Int((adjustedRotation + stepAngle / 2) / stepAngle) % isoValues.count
        return index
    }
    
    var body: some View {
        HStack(spacing: 20) {
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 80, height: 30)
                .cornerRadius(6)
                .overlay(
                    Text("\(isoValues[selectedIndex])")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                )
            
            ZStack {
                // Fixed position indicator at top
                Triangle()
                    .fill(Color.white)
                    .frame(width: 8, height: 6)
                    .position(x: 125, y: 20)
                
                // Rotating wheel content
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [5, 3]))
                        .frame(width: 200, height: 200)
                    
                    ForEach(0..<isoValues.count, id: \.self) { index in
                        let valueAngle = Double(index) * (360.0 / Double(isoValues.count)) - 90
                        let isSelected = index == selectedIndex
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: isSelected ? 6 : 4, height: isSelected ? 6 : 4)
                            .position(
                                x: 100 + cos(valueAngle * .pi / 180) * 100,
                                y: 100 + sin(valueAngle * .pi / 180) * 100
                            )
                        
                        if index % 4 == 0 {
                            Text("\(isoValues[index])")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(valueAngle + 90))
                                .position(
                                    x: 100 + cos(valueAngle * .pi / 180) * 80,
                                    y: 100 + sin(valueAngle * .pi / 180) * 80
                                )
                        }
                    }
                    
                    Text("A")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 16)
                        .background(Color.red)
                        .cornerRadius(4)
                        .position(
                            x: 100 + cos((45 - 90) * .pi / 180) * 85,
                            y: 100 + sin((45 - 90) * .pi / 180) * 85
                        )
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 12, height: 12)
                }
                .rotationEffect(.degrees(wheelRotation))
                .frame(width: 250, height: 250)
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let center = CGPoint(x: 125, y: 125)
                    let adjustedLocation = CGPoint(x: value.location.x - 100, y: value.location.y)
                    let currentAngle = atan2(adjustedLocation.y - center.y, adjustedLocation.x - center.x) * 180 / .pi
                    
                    if lastAngle == 0 {
                        lastAngle = currentAngle
                        return
                    }
                    
                    var angleDelta = currentAngle - lastAngle
                    
                    if angleDelta > 180 {
                        angleDelta -= 360
                    } else if angleDelta < -180 {
                        angleDelta += 360
                    }
                    
                    let previousIndex = selectedIndex
                    wheelRotation += angleDelta
                    lastAngle = currentAngle
                    
                    if selectedIndex != previousIndex {
                        impactFeedback.impactOccurred()
                    }
                }
                .onEnded { _ in
                    lastAngle = 0
                }
        )
        .onAppear {
            impactFeedback.prepare()
        }
    }
}

#Preview {
    CameraWheelView()
        .background(Color.black)
}