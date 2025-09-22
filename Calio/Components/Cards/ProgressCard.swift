import SwiftUI

struct ProgressCard: View {
    let title: String
    let current: Int
    let goal: Int
    let color: Color
    
    private var progress: Double {
        goal > 0 ? Double(current) / Double(goal) : 0
    }
    
    private var remaining: Int {
        max(0, goal - current)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(remaining) left")
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Text("\(current)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("/ \(goal)")
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                CircularProgressView(progress: progress, color: color, size: 32)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * min(1.0, progress), height: 6)
                        .animation(.easeInOut(duration: 0.3), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct CircularProgressView: View {
    let progress: Double
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 3)
                .frame(width: size, height: size)
            
            Circle()
                .trim(from: 0, to: min(1.0, progress))
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.3), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ProgressCard(
            title: "Calories",
            current: 1580,
            goal: 2200,
            color: .green
        )
        
        ProgressCard(
            title: "Protein",
            current: 85,
            goal: 150,
            color: .red
        )
    }
    .padding()
}