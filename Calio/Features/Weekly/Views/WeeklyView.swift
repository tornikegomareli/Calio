import SwiftUI
import SwiftData

struct WeeklyView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var weeklyLogs: [DailyLog] = []
    @State private var currentGoal: Goal?
    @State private var selectedDate = Date()
    @State private var weekOffset = 0
    
    private var currentWeekDates: [Date] {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? Date()
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)
        }
    }
    
    private var weeklyAverage: Int {
        guard !weeklyLogs.isEmpty else { return 0 }
        let totalCalories = weeklyLogs.reduce(0) { $0 + $1.totalCalories }
        return totalCalories / weeklyLogs.count
    }
    
    private var daysOnTarget: Int {
        guard let goal = currentGoal else { return 0 }
        return weeklyLogs.filter { $0.totalCalories >= Int(Double(goal.calories) * 0.9) && 
                                  $0.totalCalories <= Int(Double(goal.calories) * 1.1) }.count
    }
    
    private var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = Date()
        
        while true {
            let dayLog = weeklyLogs.first { 
                calendar.isDate($0.date, inSameDayAs: checkDate) 
            }
            
            if let log = dayLog, log.totalCalories > 0 {
                streak += 1
                guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
                checkDate = previousDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    weekNavigationView
                    
                    statsSection
                    
                    weekGridView
                    
                    weeklyChartView
                }
                .padding()
            }
            .navigationTitle("Weekly")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
            .onAppear {
                loadWeeklyData()
            }
            .onChange(of: weekOffset) { _, _ in
                updateSelectedWeek()
                loadWeeklyData()
            }
        }
    }
    
    private var weekNavigationView: some View {
        HStack {
            Button(action: { weekOffset -= 1 }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                Text(weekRangeText)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                
                if weekOffset == 0 {
                    Text("Current Week")
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: { weekOffset += 1 }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(weekOffset >= 0 ? .secondary : .primary)
            }
            .disabled(weekOffset >= 0)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var weekRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startDate = currentWeekDates.first ?? Date()
        let endDate = currentWeekDates.last ?? Date()
        
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Average",
                    value: "\(weeklyAverage)",
                    unit: "kcal/day",
                    color: .blue
                )
                
                StatCard(
                    title: "On Target",
                    value: "\(daysOnTarget)",
                    unit: "days",
                    color: .green
                )
                
                StatCard(
                    title: "Streak",
                    value: "\(currentStreak)",
                    unit: "days",
                    color: .orange
                )
            }
            
            if let goal = currentGoal {
                WeeklyProgressBar(
                    current: weeklyAverage,
                    goal: goal.calories
                )
            }
        }
    }
    
    private var weekGridView: some View {
        VStack(spacing: 12) {
            ForEach(currentWeekDates, id: \.self) { date in
                DayRow(
                    date: date,
                    log: weeklyLogs.first { Calendar.current.isDate($0.date, inSameDayAs: date) },
                    goal: currentGoal
                )
            }
        }
    }
    
    private var weeklyChartView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Daily Intake")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            
            WeeklyChart(
                logs: weeklyLogs,
                dates: currentWeekDates,
                goal: currentGoal
            )
            .frame(height: 200)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
    
    private func loadWeeklyData() {
        let goalRequest = FetchDescriptor<Goal>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        currentGoal = try? modelContext.fetch(goalRequest).first
        
        let calendar = Calendar.current
        let startOfWeek = currentWeekDates.first ?? Date()
        let endOfWeek = currentWeekDates.last ?? Date()
        
        let request = FetchDescriptor<DailyLog>(
            predicate: #Predicate { log in
                log.date >= startOfWeek && log.date <= endOfWeek
            },
            sortBy: [SortDescriptor(\.date)]
        )
        
        weeklyLogs = (try? modelContext.fetch(request)) ?? []
    }
    
    private func updateSelectedWeek() {
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: Date()) {
            selectedDate = newDate
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(unit)
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct WeeklyProgressBar: View {
    let current: Int
    let goal: Int
    
    private var progress: Double {
        goal > 0 ? Double(current) / Double(goal) : 0
    }
    
    private var progressColor: Color {
        if progress >= 0.9 && progress <= 1.1 {
            return .green
        } else if progress > 1.1 {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Weekly Average vs Goal")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(progressColor)
                        .frame(width: geometry.size.width * min(1.2, progress))
                        .animation(.easeInOut(duration: 0.3), value: progress)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.primary.opacity(0.3))
                        .frame(width: 2)
                        .offset(x: geometry.size.width - 2)
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct DayRow: View {
    let date: Date
    let log: DailyLog?
    let goal: Goal?
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    private var progress: Double {
        guard let goal = goal, goal.calories > 0 else { return 0 }
        return Double(log?.totalCalories ?? 0) / Double(goal.calories)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(spacing: 4) {
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                
                Text(dateFormatter.string(from: date))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(isToday ? .accentColor : .primary)
            }
            .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(log?.totalCalories ?? 0) kcal")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    
                    Spacer()
                    
                    if let goal = goal, log != nil {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(.systemGray5))
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * min(1.2, progress))
                    }
                }
                .frame(height: 6)
            }
            
            if isToday {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(isToday ? Color(.tertiarySystemBackground) : Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private var progressColor: Color {
        if progress >= 0.9 && progress <= 1.1 {
            return .green
        } else if progress > 1.1 {
            return .orange
        } else if progress > 0 {
            return .blue
        } else {
            return .gray
        }
    }
}

struct WeeklyChart: View {
    let logs: [DailyLog]
    let dates: [Date]
    let goal: Goal?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let goal = goal {
                    Path { path in
                        let y = geometry.size.height * (1 - CGFloat(goal.calories) / CGFloat(maxValue))
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .foregroundColor(.green.opacity(0.5))
                }
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(dates, id: \.self) { date in
                        let log = logs.first { Calendar.current.isDate($0.date, inSameDayAs: date) }
                        let calories = log?.totalCalories ?? 0
                        let height = geometry.size.height * CGFloat(calories) / CGFloat(maxValue)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(for: calories))
                            .frame(height: max(4, height))
                    }
                }
            }
        }
        .padding(.top)
    }
    
    private var maxValue: Int {
        let maxLog = logs.map(\.totalCalories).max() ?? 0
        let goalValue = goal?.calories ?? 0
        return max(maxLog, goalValue, 100) + 200
    }
    
    private func barColor(for calories: Int) -> Color {
        guard let goal = goal else { return .blue }
        let progress = Double(calories) / Double(goal.calories)
        
        if progress >= 0.9 && progress <= 1.1 {
            return .green
        } else if progress > 1.1 {
            return .orange
        } else if progress > 0 {
            return .blue
        } else {
            return .gray.opacity(0.3)
        }
    }
}

#Preview {
    WeeklyView()
        .modelContainer(for: [Goal.self, DailyLog.self, FoodEntry.self, Preset.self])
}