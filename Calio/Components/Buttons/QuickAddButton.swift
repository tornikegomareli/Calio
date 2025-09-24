import SwiftUI

struct QuickAddButton: View {
  let action: () -> Void
  
  var body: some View {
    Button(action: {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
        action()
      }
      HapticManager.impact(.light)
    }) {
      Label("Add Food", systemImage: "plus.circle.fill")
        .font(.system(size: 17, weight: .semibold, design: .rounded))
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
    .buttonStyle(.plain)
  }
}

struct PresetButton: View {
  let preset: Preset
  let action: () -> Void
  
  var body: some View {
    Button(action: {
      HapticManager.impact(.light)
      action()
    }) {
      VStack(alignment: .leading, spacing: 4) {
        Text(preset.name)
          .font(.system(size: 14, weight: .medium, design: .rounded))
          .lineLimit(1)
        
        HStack(spacing: 4) {
          Text("\(preset.calories) kcal")
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundColor(.secondary)
          
          if preset.defaultWeight > 0 {
            Text("• \(Int(preset.defaultWeight))g")
              .font(.system(size: 12, weight: .regular, design: .rounded))
              .foregroundColor(.secondary)
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color(.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    .buttonStyle(.plain)
  }
}

#Preview("Quick Add") {
  QuickAddButton {
    print("Add tapped")
  }
  .padding()
}

#Preview("Preset") {
  PresetButton(
    preset: Preset(
      name: "Chicken Breast",
      calories: 330,
      protein: 40,
      defaultWeight: 200
    )
  ) {
    print("Preset tapped")
  }
  .padding()
}
