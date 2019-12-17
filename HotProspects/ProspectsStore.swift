//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import Foundation

public enum ProspectsStoreSaveError: Error {
    case noProspectsFound
    case storeLocationNotFound
    case unhandled(error: Error)
}

public enum ProspectsStoreLoadError: Error {
    case storeLocationNotFound
    case noProspectsFound
    case unhandled(error: Error)
}

public protocol ProspectsStore {
    func saveProspects(
        _ prospects: [Prospect],
        withName name: String
    ) -> Result<URL, ProspectsStoreSaveError>
    
    func loadProspects(
        withName name: String
    ) -> Result<[Prospect], ProspectsStoreLoadError>
}
