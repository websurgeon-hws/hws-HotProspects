//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import Foundation

public class Prospect: Identifiable, Codable {
    public let id = UUID()
    public var name = "Anonymous"
    public var emailAddress = ""
    public var date = Date()
    fileprivate(set) public var isContacted = false

}

public class Prospects: ObservableObject {
    static let saveKey = "SavedData"
        
    @Published private(set) var people: [Prospect]

    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    
    init() {
        let result = FileManager.default.loadProspects(withName: Self.saveKey)
        switch result {
        case .failure:
            self.people = []
        case let .success(people):
            self.people = people
        }
    }
        
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    
    private func save() {
        _ = FileManager.default.saveProspects(people, withName: Self.saveKey)
    }
}
