//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import UserNotifications
import CodeScanner
import SwiftUI

struct ProspectsView: View {
    @EnvironmentObject var prospects: Prospects
    @State private var isShowingScanner = false
    @State private var isShowingSort = false

    enum FilterType {
        case none, contacted, uncontacted
    }
    
    enum SortOrder: String {
        case name = "Name"
        case recent = "Most Recent"
        
        var title: String {
            return self.rawValue
        }
    }

    let filter: FilterType
    @Binding var sortOrder: SortOrder

    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return try! prospects.people.sorted(by: self.peopleSorter)
        case .contacted:
            return try! prospects.people.filter { $0.isContacted }.sorted(by: self.peopleSorter)
        case .uncontacted:
            return try! prospects.people.filter { !$0.isContacted }.sorted(by: self.peopleSorter)
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if self.filter == FilterType.none && prospect.isContacted {
                            Image(systemName: "person.crop.circle.badge.checkmark")
                        }
                    }
                    .contextMenu {
                        Button(prospect.isContacted ? "Mark Uncontacted" : "Mark Contacted" ) {
                            self.prospects.toggle(prospect)
                        }
                        if !prospect.isContacted {
                            Button("Remind Me") {
                                self.addNotification(for: prospect)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle(title)
            .navigationBarItems(trailing:
                HStack {
                    Button(action: {
                        self.isShowingSort = true
                    }) {
                        Image(systemName: "arrow.up.arrow.down.square")
                        Text("Sort")
                    }
                    
                    Spacer(minLength: 20)
                    
                    Button(action: {
                        self.isShowingScanner = true
                    }) {
                        Image(systemName: "qrcode.viewfinder")
                        Text("Scan")
                    }
                }
            )
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: self.randomeExampleData, completion: self.handleScan)
            }
            .actionSheet(isPresented: $isShowingSort) {
                ActionSheet(title: Text("Select Order"), buttons: [
                    .default(Text(SortOrder.name.title)) {
                        self.sortBy(SortOrder.name)
                    },
                    .default(Text(SortOrder.recent.title)) {
                        self.sortBy(SortOrder.recent)
                    }
                ])
            }
        }
    }
    
    var randomeExampleData: String {
        let names: [String] = [
            "Paul Hudson\npaul@hackingwithswift.com",
            "Pete Barclay\npeter@peter-barclay.com",
            "Joe Bloggs\njoe.bloggs@example.com"
        ]
        return names.randomElement() ?? "Some Person\nsome.persone@example.com"
    }
    
    func sortBy(_ order: SortOrder) {
        sortOrder = order
    }
    
    var peopleSorter: (_ a: Prospect, _ b: Prospect) throws -> Bool {
        return {
            switch self.sortOrder {
            case .name:
                return $0.name < $1.name
            case .recent:
                return $0.date > $1.date
            }
        }
    }
    
    func handleScan(result: Result<String, CodeScannerView.ScanError>) {
        self.isShowingScanner = false
       
        switch result {
        case .success(let code):
            let details = code.components(separatedBy: "\n")
            guard details.count == 2 else { return }

            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]

            self.prospects.add(person)
        case .failure(let error):
            print("Scanning failed: \(error)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            #if targetEnvironment(simulator)
               let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            #else
               var dateComponents = DateComponents()
                         dateComponents.hour = 9
                         let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            #endif

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none, sortOrder: .constant(.recent))
    }
}
