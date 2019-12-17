//
//  Copyright © 2019 Peter Barclay. All rights reserved.
//

import Foundation

public struct FileManagerProspectsStore: ProspectsStore {
    private let fileManager: FileManager
    
    public init(fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
    }
    
    public func saveProspects(_ people: [Prospect], withName name: String) -> Result<URL, ProspectsStoreSaveError> {
        guard let dir = getDocumentsDirectory() else {
             return .failure(.storeLocationNotFound)
        }

        do {
            let data = try JSONEncoder().encode(people)
            let url = dir.appendingPathComponent(name)
            try data.write(
                to: url,
                options: [
                    .atomicWrite,
                    .completeFileProtection
                ])

            return .success(url)
        } catch {
            return .failure(.unhandled(error: error))
        }
    }


    public func loadProspects(withName name: String) -> Result<[Prospect], ProspectsStoreLoadError> {
        guard let dir = getDocumentsDirectory() else {
             return .failure(.storeLocationNotFound)
        }


        do {
            let url = dir.appendingPathComponent(name)
            let data = try Data(contentsOf: url)

            let people = try JSONDecoder().decode([Prospect].self,
                                                  from: data)

            return .success(people)
        } catch {
            return .failure(.unhandled(error: error))
        }
    }
    
    private func getDocumentsDirectory() -> URL? {
        let urls = fileManager.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        return urls.first
    }
}

extension FileManager: ProspectsStore {
    
    public func saveProspects(_ prospects: [Prospect], withName name: String) -> Result<URL, ProspectsStoreSaveError> {
        return FileManagerProspectsStore(fileManager: self)
            .saveProspects(prospects, withName: name)
    }

    public func loadProspects(withName name: String) -> Result<[Prospect], ProspectsStoreLoadError> {
        return FileManagerProspectsStore(fileManager: self)
            .loadProspects(withName: name)
    }
}
