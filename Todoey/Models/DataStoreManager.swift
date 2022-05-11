import Foundation
import RealmSwift

class DataStoreManager {
    
    public static let shared = DataStoreManager()
    
    private init() {
        do {
            realm = try Realm()
        } catch  {
            fatalError("Error initializating Realm.")
        }
    }
    
    var realm: Realm
    
}
