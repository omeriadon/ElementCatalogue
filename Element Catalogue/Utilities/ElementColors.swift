import SwiftUI

struct ElementColors {
    static func colorForCategory(_ category: String) -> Color {
        switch category.lowercased() {
        case "alkali metal":
            return Color.red
        case "alkaline earth metal":
            return Color.orange
        case "transition metal":
            return Color.yellow
        case "post-transition metal":
            return Color.green
        case "metalloid":
            return Color.blue
        case "diatomic nonmetal":
            return Color.purple
        case "polyatomic nonmetal":
            return Color.pink
        case "noble gas":
            return Color.gray
        case "lanthanide":
            return Color.teal
        case "actinide":
            return Color.indigo
        default:
            return Color.black
        }
    }
    
    static func colorForElement(_ element: ElementData) -> Color {
        return colorForCategory(element.category)
    }
}
