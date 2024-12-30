
import SwiftUI
import UserNotifications
import PDFKit
import UniformTypeIdentifiers

//MARK: - Notifications

func scheduleMonthlyNotification() {
    let center = UNUserNotificationCenter.current()

    // Define the content of the notification
    let content = UNMutableNotificationContent()
    content.title = "Reminder"
    content.body = "Anything new to add?"
    content.sound = .default

    // Define the trigger date (1st of every month at 9 AM)
    var dateComponents = DateComponents()
    dateComponents.day = 1
    dateComponents.hour = 9
    dateComponents.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    // Create the request
    let request = UNNotificationRequest(identifier: "MonthlyReminder", content: content, trigger: trigger)

    // Schedule the notification
    center.add(request) { error in
        if let error = error {
            print("Error scheduling notification: \(error.localizedDescription)")
        } else {
            print("Monthly notification scheduled.")
        }
    }
}


// MARK: - Models

struct AcademicEntry: Hashable, Codable {
    var type: AcademicType
    var grades: Set<Int>
    var className: String?
    var scoreOrGrade: String?
}

enum AcademicType: String, Codable {
    case sat, act, ap, dc, other
}

struct VolunteerEntry: Hashable, Codable {
    var activity: String
    var hours: Int
    var contactPerson: String
    var contactInfo: String
    var date: Date
}

struct AchievementEntry: Hashable, Codable {
    var name: String
    var grades: Set<Int>
    var type: AchievementType
}

enum AchievementType: String, Codable {
    case achievement, award
}

struct ExtracurricularEntry: Hashable, Codable {
    var activity: String
    var grades: Set<Int>
    var type: ExtracurricularType
    var specialRole: String?
}

enum ExtracurricularType: String, Codable {
    case sport, club, other
}

struct OtherEntry: Hashable, Codable {
    var name: String
    var category: String
    var grades: Set<Int>
}

// MARK: - UserDefaults Keys

struct UserDefaultsKeys {
    static let academicEntries = "academicEntries"
    static let volunteerEntries = "volunteerEntries"
    static let achievementEntries = "achievementEntries"
    static let extracurricularEntries = "extracurricularEntries"
    static let otherEntries = "otherEntries"
}

struct ContentView: View {
    @State private var academicEntries: [AcademicEntry] = UserDefaults.standard.codable([AcademicEntry].self, forKey: UserDefaultsKeys.academicEntries) ?? []
    @State private var volunteerEntries: [VolunteerEntry] = UserDefaults.standard.codable([VolunteerEntry].self, forKey: UserDefaultsKeys.volunteerEntries) ?? []
    @State private var achievementEntries: [AchievementEntry] = UserDefaults.standard.codable([AchievementEntry].self, forKey: UserDefaultsKeys.achievementEntries) ?? []
    @State private var extracurricularEntries: [ExtracurricularEntry] = UserDefaults.standard.codable([ExtracurricularEntry].self, forKey: UserDefaultsKeys.extracurricularEntries) ?? []
    @State private var otherEntries: [OtherEntry] = UserDefaults.standard.codable([OtherEntry].self, forKey: UserDefaultsKeys.otherEntries) ?? []

    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 15) { // Decrease spacing between buttons
                    CategoryButton(title: "Academic", destination: AcademicFormView(academicEntries: $academicEntries, onSave: saveAcademicEntries), backgroundColor: Color.blue)
                    CategoryButton(title: "Volunteer", destination: VolunteerFormView(volunteerEntries: $volunteerEntries, onSave: saveVolunteerEntries), backgroundColor: Color.blue)
                    CategoryButton(title: "Achievements/Awards", destination: AchievementFormView(achievementEntries: $achievementEntries, onSave: saveAchievementEntries), backgroundColor: Color.blue)
                    CategoryButton(title: "Extracurriculars", destination: ExtracurricularFormView(extracurricularEntries: $extracurricularEntries, onSave: saveExtracurricularEntries), backgroundColor: Color.blue)
                    CategoryButton(title: "Other", destination: OtherFormView(otherEntries: $otherEntries, onSave: saveOtherEntries), backgroundColor: Color.blue)
                    CategoryButton(title: "View All", destination: ViewEntriesView(academicEntries: $academicEntries, volunteerEntries: $volunteerEntries, achievementEntries: $achievementEntries, extracurricularEntries: $extracurricularEntries, otherEntries: $otherEntries, onSave: saveAllEntries), backgroundColor: Color.green) // Green color for "View All"
                }
                .padding(.horizontal) // Add padding only on the horizontal edges
                .padding(.top, 140) // Adjust padding to ensure buttons are not cut off
                .navigationBarTitleDisplayMode(.inline)
                .onDisappear(perform: saveData)

                // Fixed position text at the top
                VStack {
                    Text("ATracker")
                        .font(.system(size: 70, weight: .bold)) // Increase font size
                        .foregroundColor(.primary)
                        .padding(.top, 80) // Adjust this value to move the title as needed
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .top) // Aligns the text at the top
                .zIndex(1) // Ensure it stays on top of other views

                // Overlay small copyright text
                VStack {
                    Spacer()
                    HStack {
                        Text("© C. Mann, 2024")
                            .font(.footnote) // Smaller font size
                            .foregroundColor(.secondary)
                            .padding(.leading, 250) // Add padding from the left edge
                            .padding(.bottom, 25) // Add padding from the bottom edge
                        Spacer()
                    }
                }
                .edgesIgnoringSafeArea(.bottom) // Ensure the text is visible in the bottom safe area
            }
        }
    }

    private func saveAcademicEntries(_ entries: [AcademicEntry]) { academicEntries = entries; saveData() }
    private func saveVolunteerEntries(_ entries: [VolunteerEntry]) { volunteerEntries = entries; saveData() }
    private func saveAchievementEntries(_ entries: [AchievementEntry]) { achievementEntries = entries; saveData() }
    private func saveExtracurricularEntries(_ entries: [ExtracurricularEntry]) { extracurricularEntries = entries; saveData() }
    private func saveOtherEntries(_ entries: [OtherEntry]) { otherEntries = entries; saveData() }
    private func saveAllEntries() { saveData() }

    private func saveData() {
        do {
            try UserDefaults.standard.setCodable(academicEntries, forKey: UserDefaultsKeys.academicEntries)
            try UserDefaults.standard.setCodable(volunteerEntries, forKey: UserDefaultsKeys.volunteerEntries)
            try UserDefaults.standard.setCodable(achievementEntries, forKey: UserDefaultsKeys.achievementEntries)
            try UserDefaults.standard.setCodable(extracurricularEntries, forKey: UserDefaultsKeys.extracurricularEntries)
            try UserDefaults.standard.setCodable(otherEntries, forKey: UserDefaultsKeys.otherEntries)
        } catch {
            print("Failed to save data: \(error)")
        }
    }
}




struct CategoryButton<Destination: View>: View {
    let title: String
    let destination: Destination
    let backgroundColor: Color

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.system(size: 20, weight: .bold)) // Larger font size
                .frame(maxWidth: .infinity) // Make the button take up the full width
                .padding() // Add padding inside the button
                .background(backgroundColor) // Background color
                .foregroundColor(.white) // Text color
                .cornerRadius(10) // Rounded corners
                .shadow(radius: 5) // Add shadow for a more prominent appearance
        }
    }
}

// MARK: - Custom Multi-Select Component

struct MultiSelectPicker: View {
    @Binding var selectedGrades: Set<Int>
    let allGrades = Array(9...12)

    var body: some View {
        VStack {
            Text("Select Grade(s)")
                .font(.headline)

            List(allGrades, id: \.self) { grade in
                Toggle(isOn: Binding(
                    get: { selectedGrades.contains(grade) },
                    set: { isSelected in
                        if isSelected {
                            selectedGrades.insert(grade)
                        } else {
                            selectedGrades.remove(grade)
                        }
                    }
                )) {
                    Text("\(grade)")
                }
            }
        }
    }
}

import SwiftUI

struct AcademicFormView: View {
    @Binding var academicEntries: [AcademicEntry]
    var onSave: ([AcademicEntry]) -> Void

    @State private var selectedType: AcademicType = .ap
    @State private var className: String = ""
    @State private var scoreOrGrade: String = ""
    @State private var selectedGrades: Set<Int> = []
    @State private var showSuccessMessage = false
    @State private var successMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            Picker("Type", selection: $selectedType) {
                Text("SAT").tag(AcademicType.sat)
                Text("ACT").tag(AcademicType.act)
                Text("AP").tag(AcademicType.ap)
                Text("DC").tag(AcademicType.dc)
                Text("Other").tag(AcademicType.other)
            }
            .pickerStyle(.segmented)

            if selectedType == .ap || selectedType == .dc {
                TextField("Class Name", text: $className)
                TextField("Score/Grade", text: $scoreOrGrade)
            } else if selectedType == .sat {
                TextField("Score (0-1600)", text: $scoreOrGrade)
            } else if selectedType == .act {
                TextField("Score (0-36)", text: $scoreOrGrade)
            } else if selectedType == .other {
                TextField("Category", text: $className)
                TextField("Name", text: $scoreOrGrade)
            }

            MultiSelectPicker(selectedGrades: $selectedGrades)

            Button("Save") {
                guard !scoreOrGrade.isEmpty, (selectedType != .ap && selectedType != .dc) || !className.isEmpty, !selectedGrades.isEmpty else {
                    // Optionally show an alert or error message
                    return
                }
                let newEntry = AcademicEntry(type: selectedType, grades: selectedGrades, className: className.isEmpty ? nil : className, scoreOrGrade: scoreOrGrade)
                academicEntries.append(newEntry)
                onSave(academicEntries)
                successMessage = "Academic Entry saved!"
                showSuccessMessage = true
                clearForm()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss() // Go back to the home view
                }
            }

            if showSuccessMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .animation(.easeIn, value: showSuccessMessage)
            }
        }
        .navigationTitle("Academic Form")
    }

    private func clearForm() {
        className = ""
        scoreOrGrade = ""
        selectedType = .ap
        selectedGrades = []
    }
}

struct VolunteerFormView: View {
    @Binding var volunteerEntries: [VolunteerEntry]
    var onSave: ([VolunteerEntry]) -> Void

    @State private var activity: String = ""
    @State private var hoursInput: String = ""
    @State private var contactPerson: String = ""
    @State private var contactInfo: String = ""
    @State private var date: Date = Date()
    @State private var showSuccessMessage = false
    @State private var successMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            TextField("Activity", text: $activity)
            TextField("Hours", text: $hoursInput)
                .keyboardType(.numberPad)
                .onAppear {
                    // Clear the input field when the form appears
                    hoursInput = ""
                }
            TextField("Contact Person", text: $contactPerson)
            TextField("Contact Info", text: $contactInfo)
            DatePicker("Date", selection: $date, displayedComponents: .date)

            Button("Save") {
                guard !activity.isEmpty, let hours = Int(hoursInput), hours > 0, !contactPerson.isEmpty, !contactInfo.isEmpty else {
                    // Show an alert or error message
                    return
                }
                let newEntry = VolunteerEntry(activity: activity, hours: hours, contactPerson: contactPerson, contactInfo: contactInfo, date: date)
                volunteerEntries.append(newEntry)
                onSave(volunteerEntries)
                successMessage = "Volunteer Entry saved!"
                showSuccessMessage = true
                clearForm()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss() // Go back to the home view
                }
            }

            if showSuccessMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .animation(.easeIn, value: showSuccessMessage)
            }
        }
        .navigationTitle("Volunteer Form")
    }

    private func clearForm() {
        activity = ""
        hoursInput = ""
        contactPerson = ""
        contactInfo = ""
        date = Date()
    }
}

struct AchievementFormView: View {
    @Binding var achievementEntries: [AchievementEntry]
    var onSave: ([AchievementEntry]) -> Void

    @State private var name: String = ""
    @State private var selectedType: AchievementType = .achievement
    @State private var selectedGrades: Set<Int> = []
    @State private var showSuccessMessage = false
    @State private var successMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            TextField("Name", text: $name)

            Picker("Type", selection: $selectedType) {
                Text("Achievement").tag(AchievementType.achievement)
                Text("Award").tag(AchievementType.award)
            }
            .pickerStyle(.segmented)

            MultiSelectPicker(selectedGrades: $selectedGrades)

            Button("Save") {
                guard !name.isEmpty, !selectedGrades.isEmpty else {
                    // Show an alert or error message
                    return
                }
                let newEntry = AchievementEntry(name: name, grades: selectedGrades, type: selectedType)
                achievementEntries.append(newEntry)
                onSave(achievementEntries)
                successMessage = "Achievement Entry saved!"
                showSuccessMessage = true
                clearForm()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss() // Go back to the home view
                }
            }

            if showSuccessMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .animation(.easeIn, value: showSuccessMessage)
            }
        }
        .navigationTitle("Achievement Form")
    }

    private func clearForm() {
        name = ""
        selectedType = .achievement
        selectedGrades = []
    }
}

struct ExtracurricularFormView: View {
    @Binding var extracurricularEntries: [ExtracurricularEntry]
    var onSave: ([ExtracurricularEntry]) -> Void

    @State private var activity: String = ""
    @State private var selectedType: ExtracurricularType = .sport
    @State private var selectedGrades: Set<Int> = []
    @State private var specialRole: String?
    @State private var showSuccessMessage = false
    @State private var successMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            TextField("Activity", text: $activity)

            Picker("Type", selection: $selectedType) {
                Text("Sport").tag(ExtracurricularType.sport)
                Text("Club").tag(ExtracurricularType.club)
                Text("Other").tag(ExtracurricularType.other)
            }
            .pickerStyle(.segmented)

            MultiSelectPicker(selectedGrades: $selectedGrades)

            if selectedType == .other {
                TextField("Special Role", text: Binding(
                    get: { specialRole ?? "" },
                    set: { specialRole = $0.isEmpty ? nil : $0 }
                ))
            }

            Button("Save") {
                guard !activity.isEmpty, !selectedGrades.isEmpty else {
                    // Show an alert or error message
                    return
                }
                let newEntry = ExtracurricularEntry(activity: activity, grades: selectedGrades, type: selectedType, specialRole: specialRole)
                extracurricularEntries.append(newEntry)
                onSave(extracurricularEntries)
                successMessage = "Extracurricular Entry saved!"
                showSuccessMessage = true
                clearForm()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss() // Go back to the home view
                }
            }

            if showSuccessMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .animation(.easeIn, value: showSuccessMessage)
            }
        }
        .navigationTitle("Extracurricular Form")
    }

    private func clearForm() {
        activity = ""
        selectedType = .sport
        selectedGrades = []
        specialRole = nil
    }
}


struct OtherFormView: View {
    @Binding var otherEntries: [OtherEntry]
    var onSave: ([OtherEntry]) -> Void

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedGrades: Set<Int> = []
    @State private var showSuccessMessage = false
    @State private var successMessage: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Description", text: $description)

            MultiSelectPicker(selectedGrades: $selectedGrades)

            Button("Save") {
                guard !name.isEmpty, !description.isEmpty, !selectedGrades.isEmpty else {
                    // Show an alert or error message
                    return
                }
                let newEntry = OtherEntry(name: name, category: description, grades: selectedGrades)
                otherEntries.append(newEntry)
                onSave(otherEntries)
                successMessage = "Other Entry saved!"
                showSuccessMessage = true
                clearForm()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    presentationMode.wrappedValue.dismiss() // Go back to the home view
                }
            }

            if showSuccessMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .transition(.opacity)
                    .animation(.easeIn, value: showSuccessMessage)
            }
        }
        .navigationTitle("Other Form")
    }

    private func clearForm() {
        name = ""
        description = ""
        selectedGrades = []
    }
}

// MARK: - View Entries View

extension DateFormatter {
    static let customDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy" // Customize the format here
        return formatter
    }()
}

struct ViewEntriesView: View {
    @Binding var academicEntries: [AcademicEntry]
    @Binding var volunteerEntries: [VolunteerEntry]
    @Binding var achievementEntries: [AchievementEntry]
    @Binding var extracurricularEntries: [ExtracurricularEntry]
    @Binding var otherEntries: [OtherEntry]
    var onSave: () -> Void

    private var totalVolunteerHours: Int {
        volunteerEntries.reduce(0) { $0 + $1.hours }
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Academic")) {
                    ForEach(academicEntries, id: \.self) { entry in
                        VStack(alignment: .leading) {
                            Text("Type: \(entry.type.rawValue.uppercased())") // Convert to uppercase
                            Text("Grades: \(entry.grades.sorted().map { String($0) }.joined(separator: ", "))")
                            if entry.type == .ap || entry.type == .dc {
                                if let className = entry.className {
                                    Text("Class Name: \(className)")
                                }
                            }
                            if let scoreOrGrade = entry.scoreOrGrade {
                                Text("Score/Grade: \(scoreOrGrade)")
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = academicEntries.firstIndex(of: entry) {
                                    academicEntries.remove(at: index)
                                    onSave()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Section(header: Text("Volunteer (\(totalVolunteerHours) hours)")) { // Update header to include total hours
                    ForEach(volunteerEntries, id: \.self) { entry in
                        VStack(alignment: .leading) {
                            Text("Activity: \(entry.activity)")
                            Text("Hours: \(entry.hours)")
                            Text("Contact Person: \(entry.contactPerson)")
                            Text("Contact Info: \(entry.contactInfo)")
                            Text("Date: \(entry.date, formatter: DateFormatter.customDateFormatter)")
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = volunteerEntries.firstIndex(of: entry) {
                                    volunteerEntries.remove(at: index)
                                    onSave()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Section(header: Text("Achievements/Awards")) {
                    ForEach(achievementEntries, id: \.self) { entry in
                        VStack(alignment: .leading) {
                            Text("Name: \(entry.name)")
                            Text("Type: \(entry.type.rawValue.capitalized)") // Capitalize first letter
                            Text("Grades: \(entry.grades.sorted().map { String($0) }.joined(separator: ", "))")
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = achievementEntries.firstIndex(of: entry) {
                                    achievementEntries.remove(at: index)
                                    onSave()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Section(header: Text("Extracurriculars")) {
                    ForEach(extracurricularEntries, id: \.self) { entry in
                        VStack(alignment: .leading) {
                            Text("Activity: \(entry.activity)")
                            Text("Type: \(entry.type.rawValue.capitalized)") // Capitalize first letter
                            Text("Grades: \(entry.grades.sorted().map { String($0) }.joined(separator: ", "))")
                            if let specialRole = entry.specialRole {
                                Text("Special Role: \(specialRole)")
                            }
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = extracurricularEntries.firstIndex(of: entry) {
                                    extracurricularEntries.remove(at: index)
                                    onSave()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }

                Section(header: Text("Other")) {
                    ForEach(otherEntries, id: \.self) { entry in
                        VStack(alignment: .leading) {
                            Text("Name: \(entry.name)")
                            Text("Category: \(entry.category)")
                            Text("Grades: \(entry.grades.sorted().map { String($0) }.joined(separator: ", "))")
                        }
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = otherEntries.firstIndex(of: entry) {
                                    otherEntries.remove(at: index)
                                    onSave()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
            .navigationTitle("View All Entries")
            .listStyle(GroupedListStyle())
        }
    }
}


// MARK: - UserDefaults Extension

extension UserDefaults {
    func setCodable<T: Codable>(_ value: T, forKey key: String) throws {
        let data = try JSONEncoder().encode(value)
        set(data, forKey: key)
    }

    func codable<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
