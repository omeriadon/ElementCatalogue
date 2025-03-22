import Foundation
import SwiftData

@Model
class BookmarkedElement {
    var elementNumber: Int
    var dateBookmarked: Date
    
    init(elementNumber: Int) {
        self.elementNumber = elementNumber
        self.dateBookmarked = Date()
    }
}
