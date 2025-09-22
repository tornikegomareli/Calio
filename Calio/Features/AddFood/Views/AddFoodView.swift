import SwiftUI
import SwiftData

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var viewModel: AddFoodViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, calories, protein, carbs, fat
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    segmentPicker
                    
                    if viewModel.isQuickAdd {
                        quickAddSection
                    } else {
                        detailedAddSection
                    }
                    
                    actionButtons
                }
                .padding()
            }
            .navigationTitle("Add Food")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.save { dismiss() }
                    }
                    .fontWeight(.semibold)
                    .disabled(!viewModel.canSave)
                }
            }
            .onAppear {
                viewModel.configure(with: modelContext)
                focusedField = viewModel.isQuickAdd ? .calories : .name
            }
        }
    }
    
    private var segmentPicker: some View {
        Picker("Mode", selection: $viewModel.isQuickAdd) {
            Text("Quick Add").tag(true)
            Text("Detailed").tag(false)
        }
        .pickerStyle(.segmented)
        .onChange(of: viewModel.isQuickAdd) { _, newValue in
            focusedField = newValue ? .calories : .name
        }
    }
    
    private var quickAddSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Calories", systemImage: "flame.fill")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                TextField("0", text: $viewModel.calories)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .calories)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            Text("Optional Macros")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                MacroInputField(
                    label: "Protein",
                    value: $viewModel.protein,
                    color: .red,
                    focused: $focusedField,
                    field: .protein
                )
                
                MacroInputField(
                    label: "Carbs",
                    value: $viewModel.carbs,
                    color: .blue,
                    focused: $focusedField,
                    field: .carbs
                )
                
                MacroInputField(
                    label: "Fat",
                    value: $viewModel.fat,
                    color: .yellow,
                    focused: $focusedField,
                    field: .fat
                )
            }
        }
    }
    
    private var detailedAddSection: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Food Name", systemImage: "text.cursor")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                TextField("e.g., Chicken Breast", text: $viewModel.foodName)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .focused($focusedField, equals: .name)
                    .textFieldStyle(.plain)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Weight", systemImage: "scalemass.fill")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.weight))g")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                }
                
                Slider(value: $viewModel.weight, in: 0...400, step: 5) {
                    EmptyView()
                } onEditingChanged: { editing in
                    if !editing {
                        HapticManager.selection()
                    }
                }
                .tint(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Label("Nutrition (per \(Int(viewModel.weight))g)", systemImage: "chart.bar.fill")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    NutritionInputField(
                        label: "Calories",
                        value: $viewModel.calories,
                        suffix: "kcal",
                        color: .green
                    )
                    
                    NutritionInputField(
                        label: "Protein",
                        value: $viewModel.protein,
                        suffix: "g",
                        color: .red
                    )
                }
                
                HStack(spacing: 12) {
                    NutritionInputField(
                        label: "Carbs",
                        value: $viewModel.carbs,
                        suffix: "g",
                        color: .blue
                    )
                    
                    NutritionInputField(
                        label: "Fat",
                        value: $viewModel.fat,
                        suffix: "g",
                        color: .yellow
                    )
                }
            }
            
            Toggle(isOn: $viewModel.saveAsPreset) {
                Label("Save as Preset", systemImage: "star.fill")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .tint(.accentColor)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {
                viewModel.saveAndAddAnother()
            }) {
                Label("Save & Add Another", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemBackground))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canSave)
        }
    }
}

struct MacroInputField: View {
    let label: String
    @Binding var value: String
    let color: Color
    var focused: FocusState<AddFoodView.Field?>.Binding
    let field: AddFoodView.Field
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(color)
            
            HStack {
                TextField("0", text: $value)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .keyboardType(.decimalPad)
                    .focused(focused, equals: field)
                
                Text("g")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

struct NutritionInputField: View {
    let label: String
    @Binding var value: String
    let suffix: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            HStack {
                TextField("0", text: $value)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .keyboardType(.numberPad)
                
                Text(suffix)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

#Preview {
    AddFoodView(viewModel: AddFoodViewModel(todayLog: nil))
        .modelContainer(for: [DailyLog.self, FoodEntry.self, Preset.self])
}