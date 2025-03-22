import SwiftUI
import SwiftData

struct ElementRowView: View {
    let element: ElementData
    @Query private var bookmarks: [BookmarkedElement]
    var onToggleBookmark: () -> Void
    
    private var isBookmarked: Bool {
        bookmarks.contains { $0.elementNumber == element.number }
    }
    
    var body: some View {
        HStack {
            // Element symbol with background
            ZStack {
                Circle()
                    .fill(ElementColors.colorForElement(element))
                    .frame(width: 40, height: 40)
                    .shadow(radius: 1)
                
                Text(element.symbol)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Element details
            VStack(alignment: .leading, spacing: 3) {
                Text(element.name)
                    .font(.headline)
                
                Text("\(element.number) • \(element.category)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 4)
            
            Spacer()
            
            // Bookmark button
            Button(action: onToggleBookmark) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isBookmarked ? 
                                    ElementColors.colorForElement(element) : 
                                    .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
}

// Preview provider for SwiftUI canvas
#Preview {
    ElementRowView(
        element: ElementData(
            name: "Hydrogen", 
            appearance: "Gas",
            atomic_mass: 1.008,
            boil: 20.271,
            category: "diatomic nonmetal",
            density: 0.08988,
            discovered_by: "Henry Cavendish",
            melt: 13.99,
            molar_heat: 28.836,
            named_by: "Antoine Lavoisier",
            number: 1,
            period: 1,
            group: 1,
            phase: "Gas",
            source: "https://en.wikipedia.org/wiki/Hydrogen",
            bohr_model_image: "",
            bohr_model_3d: "",
            spectral_img: "",
            summary: "Hydrogen is the lightest element.",
            symbol: "H",
            xpos: 1,
            ypos: 1,
            wxpos: 1,
            wypos: 1,
            shells: [1],
            electron_configuration: "1s1",
            electron_configuration_semantic: "1s1",
            electron_affinity: 72.769,
            electronegativity_pauling: 2.2,
            ionization_energies: [1312],
            cpk_hex: "ffffff",
            image: nil,
            block: "s"
        ),
        onToggleBookmark: {}
    )
    .frame(width: 300)
}
