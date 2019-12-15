//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import Foundation

class Prospect: Identifiable, Codable {
    let id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    fileprivate(set) var isContacted = false

}

class Prospects: ObservableObject {
    @Published var people: [Prospect]

    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
    }
    
    init() {
        self.people = []
    }
}
