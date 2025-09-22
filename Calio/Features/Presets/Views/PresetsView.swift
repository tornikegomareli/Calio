import SwiftUI
import SwiftData

struct PresetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\Preset.order), SortDescriptor(\Preset.useCount, order: .reverse)]) 
    private var presets: [Preset]
    
    @State private var showAddPreset = false
    @State private var editingPreset: Preset?
    @State private var searchText = ""
    
    private var filteredPresets: [Preset] {
        if searchText.isEmpty {
            return presets
        }
        return presets.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if filteredPresets.isEmpty {
                    emptyStateView
                } else {
                    ForEach(filteredPresets) { preset in
                        PresetRowView(preset: preset)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deletePreset(preset)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    editingPreset = preset
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.orange)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onMove(perform: movePresets)
                }
            }
            .listStyle(.plain)
            .searchable(text: $searchText, prompt: "Search presets")
            .navigationTitle("Presets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPreset = true
                    } label: {
                        Image(systemName: "plus")
                            .fontWeight(.semibold)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            .sheet(isPresented: $showAddPreset) {
                AddPresetView()
                    .presentationDetents([.medium])
            }
            .sheet(item: $editingPreset) { preset in
                EditPresetView(preset: preset)
                    .presentationDetents([.medium])
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Presets Yet")
                .font(.system(size: 20, weight: .semibold, design: .rounded))
            
            Text("Add your favorite foods for quick logging")
                .font(.system(size: 14, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showAddPreset = true
            } label: {
                Label("Add First Preset", systemImage: "plus.circle.fill")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .listRowBackground(Color.clear)
    }
    
    private func deletePreset(_ preset: Preset) {
        withAnimation {
            modelContext.delete(preset)
            try? modelContext.save()
            HapticManager.notification(.success)
        }
    }
    
    private func movePresets(from source: IndexSet, to destination: Int) {
        var reorderedPresets = filteredPresets
        reorderedPresets.move(fromOffsets: source, toOffset: destination)
        
        for (index, preset) in reorderedPresets.enumerated() {
            preset.order = index
        }
        
        try? modelContext.save()
    }
}

struct PresetRowView: View {
    let preset: Preset
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(preset.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    Label("\(preset.calories) kcal", systemImage: "flame.fill")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if preset.defaultWeight > 0 {
                        Text("\(Int(preset.defaultWeight))g")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    if preset.protein > 0 {
                        MacroLabel(label: "P", value: preset.protein, color: .red)
                    }
                    if preset.carbs > 0 {
                        MacroLabel(label: "C", value: preset.carbs, color: .blue)
                    }
                    if preset.fat > 0 {
                        MacroLabel(label: "F", value: preset.fat, color: .yellow)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                if preset.useCount > 0 {
                    Text("\(preset.useCount)×")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                if let lastUsed = preset.lastUsedAt {
                    Text(lastUsed.formatted(.relative(presentation: .numeric)))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundColor(Color(.tertiaryLabel))
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct MacroLabel: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(color)
            
            Text("\(Int(value))g")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

struct AddPresetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    @State private var weight = 100.0
    
    private var canSave: Bool {
        !name.isEmpty && Int(calories) ?? 0 > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                    
                    HStack {
                        Label("Weight", systemImage: "scalemass")
                        Spacer()
                        Text("\(Int(weight))g")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $weight, in: 0...500, step: 5)
                }
                
                Section("Nutrition per \(Int(weight))g") {
                    HStack {
                        Label("Calories", systemImage: "flame")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Protein", systemImage: "p.square")
                            .foregroundColor(.red)
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Carbs", systemImage: "c.square")
                            .foregroundColor(.blue)
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Fat", systemImage: "f.square")
                            .foregroundColor(.yellow)
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Add Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreset()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func savePreset() {
        let preset = Preset(
            name: name,
            calories: Int(calories) ?? 0,
            protein: Double(protein) ?? 0,
            carbs: Double(carbs) ?? 0,
            fat: Double(fat) ?? 0,
            defaultWeight: weight
        )
        
        modelContext.insert(preset)
        try? modelContext.save()
        HapticManager.notification(.success)
        dismiss()
    }
}

struct EditPresetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let preset: Preset
    @State private var name: String
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var weight: Double
    
    init(preset: Preset) {
        self.preset = preset
        self._name = State(initialValue: preset.name)
        self._calories = State(initialValue: "\(preset.calories)")
        self._protein = State(initialValue: "\(Int(preset.protein))")
        self._carbs = State(initialValue: "\(Int(preset.carbs))")
        self._fat = State(initialValue: "\(Int(preset.fat))")
        self._weight = State(initialValue: preset.defaultWeight)
    }
    
    private var canSave: Bool {
        !name.isEmpty && Int(calories) ?? 0 > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                    
                    HStack {
                        Label("Weight", systemImage: "scalemass")
                        Spacer()
                        Text("\(Int(weight))g")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $weight, in: 0...500, step: 5)
                }
                
                Section("Nutrition per \(Int(weight))g") {
                    HStack {
                        Label("Calories", systemImage: "flame")
                        Spacer()
                        TextField("0", text: $calories)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("kcal")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Protein", systemImage: "p.square")
                            .foregroundColor(.red)
                        Spacer()
                        TextField("0", text: $protein)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Carbs", systemImage: "c.square")
                            .foregroundColor(.blue)
                        Spacer()
                        TextField("0", text: $carbs)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Fat", systemImage: "f.square")
                            .foregroundColor(.yellow)
                        Spacer()
                        TextField("0", text: $fat)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("g")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Edit Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        updatePreset()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func updatePreset() {
        preset.name = name
        preset.calories = Int(calories) ?? 0
        preset.protein = Double(protein) ?? 0
        preset.carbs = Double(carbs) ?? 0
        preset.fat = Double(fat) ?? 0
        preset.defaultWeight = weight
        
        try? modelContext.save()
        HapticManager.notification(.success)
        dismiss()
    }
}

#Preview {
    PresetsView()
        .modelContainer(for: [Preset.self])
}