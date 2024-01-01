//
//  ContentView.swift
//  DoItNow
//
//  Created by KFA8IB on 1.01.2024.
//

import SwiftUI

struct GoalItem: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var deadline: Date
    var isCompleted: Bool = false
}

class GoalsViewModel: ObservableObject {
    @Published var goals: [GoalItem] = []
    
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
                            .padding(.top, 5)
                            .padding(.bottom, 10)
                            .opacity(0.8)
                            .padding(.bottom, 5)
                            .overlay(
                                RoundedRectangle(cornerRadius: 2)
                                    .stroke(Color.gray, lineWidth: 0.5)
                            )
                            .padding(.bottom, 5)
                            .onTapGesture {
                                viewModel.toggleGoalCompletion(goal: goal)
                            }
                    }
                }
                .onDelete(perform: viewModel.removeGoal)
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
    @State private var goalDeadline = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal Details")) {
                    TextField("Title", text: $goalTitle)
                    TextField("Description", text: $goalDescription)
                    DatePicker("Deadline", selection: $goalDeadline, displayedComponents: .date)
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


#Preview {
    ContentView()
}
