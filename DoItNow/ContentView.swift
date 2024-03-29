//
//  ContentView.swift
//  DoItNow
//
//  Created by KFA8IB on 1.01.2024.
//

import SwiftUI

struct GoalItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var deadline: Date
    var isCompleted: Bool = false
}

class GoalsViewModel: ObservableObject {
    @Published var goals: [GoalItem] = [] {
        didSet {
            saveGoals()
        }
    }
    
    init() {
        loadGoals()
    }
    
    func saveGoals() {
        if let encodedData = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encodedData, forKey: "savedGoals")
        }
    }
    
    func loadGoals() {
        if let savedData = UserDefaults.standard.data(forKey: "savedGoals"),
           let loadedGoals = try? JSONDecoder().decode([GoalItem].self, from: savedData) {
            goals = loadedGoals
        }
    }
    
    func addGoal(title: String, description: String, deadline: Date) {
        let newGoal = GoalItem(title: title, description: description, deadline: deadline)
        goals.append(newGoal)
    }
    
    func removeGoal(at indexSet: IndexSet) {
        goals.remove(atOffsets: indexSet)
    }
    
    func toggleGoalCompletion(goal: GoalItem) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index].isCompleted.toggle()
        }
    }
    
    func moveGoal(from source: IndexSet, to destination: Int) {
        goals.move(fromOffsets: source, toOffset: destination)
    }
}

struct GoalsView: View {
    @StateObject var viewModel = GoalsViewModel()
    @State private var showingAddSheet = false
    @State private var newGoalTitle = ""
    @State private var newGoalDescription = ""
    @State private var newGoalDeadline = Date()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.goals) { goal in
                    VStack(alignment: .leading) {
                        Text(goal.title)
                            .font(.headline)
                        Text(goal.description)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Deadline: \(formattedDate(date: goal.deadline))")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .padding(.leading,15)
                            .padding(.trailing,15)
                            .opacity(0.8)
                            .padding(.bottom, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(Color.red, lineWidth: 1)
                            )
                            .padding(.bottom, 5)
                            .onTapGesture {
                                viewModel.toggleGoalCompletion(goal: goal)
                            }
                    }
                }
                .onDelete(perform: viewModel.removeGoal)
                .onMove(perform: viewModel.moveGoal)
            }
            .navigationTitle("Goals")
            .navigationBarItems(trailing:
                Button(action: { showingAddSheet.toggle() }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingAddSheet) {
                AddGoalView(isPresented: $showingAddSheet, viewModel: viewModel)
            }
        }
    }
    
    func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AddGoalView: View {
    @Binding var isPresented: Bool
    @ObservedObject var viewModel: GoalsViewModel
    @State private var goalTitle = ""
    @State private var goalDescription = ""
    @State private var goalAlarm = ""
    @State private var goalDeadline = Date()
    
    let reminderSounds = ["Sound 1", "Sound 2", "Sound 3"]
    @State private var selectedReminderSound = "Sound 1"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $goalTitle)
                    TextField("Description", text: $goalDescription)
                    TextField("Alarm", text: $goalAlarm)
                    DatePicker("Deadline", selection: $goalDeadline, displayedComponents: .date)
                    
                    Picker("Reminder Sound", selection: $selectedReminderSound) {
                        ForEach(reminderSounds, id: \.self) { sound in
                            Text(sound).tag(sound)
                        }
                    }
                }
                Section {
                    Button("Add Goal") {
                        viewModel.addGoal(title: goalTitle, description: goalDescription, deadline: goalDeadline)
                        isPresented = false
                        
                    }
                }
            }
            .navigationTitle("New Goal")
        }
    }
}

struct ContentView: View {
    var body: some View {
        GoalsView()
    }
}

struct DoItNow: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
