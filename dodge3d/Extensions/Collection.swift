import Foundation

extension Collection {
    
    public func doesNotContain ( where predicate: (Element) throws -> Bool ) rethrows -> Bool {
        return try !contains(where: predicate)
    }
    
}
