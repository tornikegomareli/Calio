import SwiftUI

struct RingView: View {
  let progress: Double
  let lineWidth: CGFloat
  let color: Color
  let backgroundColor: Color
  
  init(
    progress: Double,
    lineWidth: CGFloat = 20,
    color: Color = .accentColor,
    backgroundColor: Color = .gray.opacity(0.2)
  ) {
    self.progress = min(1.0, max(0.0, progress))
    self.lineWidth = lineWidth
    self.color = color
    self.backgroundColor = backgroundColor
  }
  
  var body: some View {
    ZStack {
      Circle()
        .stroke(backgroundColor, lineWidth: lineWidth)
      
      Circle()
        .trim(from: 0, to: progress)
        .stroke(
          progressColor,
          style: StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round
          )
        )
        .rotationEffect(.degrees(-90))
        .animation(.easeInOut(duration: 0.3), value: progress)
    }
  }
  
  private var progressColor: Color {
    if progress >= 1.0 {
      return .orange
    } else if progress >= 0.8 {
      return color
    } else {
      return color.opacity(0.9)
    }
  }
}

struct MultiRingView: View {
  let caloriesProgress: Double
  let proteinProgress: Double?
  let carbsProgress: Double?
  let fatProgress: Double?
  
  var body: some View {
    ZStack {
      // Outermost ring - Calories (green)
      RingView(
        progress: caloriesProgress,
        lineWidth: 16,
        color: .green
      )
      
      // Second ring - Protein (red) 
      // Padding = calories lineWidth + spacing
      if let proteinProgress = proteinProgress {
        RingView(
          progress: proteinProgress,
          lineWidth: 12,
          color: .red
        )
        .padding(20) // 16 (calories width) + 4 (spacing)
      }
      
      // Third ring - Carbs (blue)
      // Padding = calories + protein + spacing
      if let carbsProgress = carbsProgress {
        RingView(
          progress: carbsProgress,
          lineWidth: 12,
          color: .blue
        )
        .padding(36) // 16 + 4 + 12 + 4
      }
      
      // Innermost ring - Fat (yellow)
      // Padding = calories + protein + carbs + spacing
      if let fatProgress = fatProgress {
        RingView(
          progress: fatProgress,
          lineWidth: 12,
          color: .yellow
        )
        .padding(52) // 16 + 4 + 12 + 4 + 12 + 4
      }
    }
  }
}

#Preview("Single Ring") {
  RingView(progress: 0.65)
    .frame(width: 200, height: 200)
    .padding()
}

#Preview("Multi Ring") {
  MultiRingView(
    caloriesProgress: 0.75,
    proteinProgress: 0.6,
    carbsProgress: 0.8,
    fatProgress: 0.5
  )
  .frame(width: 250, height: 250)
  .padding()
}
