import SwiftUI

/// Represents a single element cell in the periodic table
struct ElementCell: View {
    let element: ElementData
    let isBookmarked: Bool
    
    private var baseColor: Color {
        ElementColors.colorForElement(element).opacity(0.8)
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 6)
                .fill(baseColor)
                .shadow(color: Color.black.opacity(0.2), radius: 1, x: 0, y: 1)
            
            VStack(spacing: 0) {
                HStack {
                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("\(element.number)")
                        .font(.system(size: 8))
                        .fontWeight(.light)
                }
                .padding(.horizontal, 3)
                .padding(.top, 2)
                
                Text(element.symbol)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                Text(element.name)
                    .font(.system(size: 6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 2)
            }
            .foregroundColor(.white)
        }
        .contextMenu {
            Button(action: {}) {
                Label(isBookmarked ? "Remove Bookmark" : "Add Bookmark", 
                      systemImage: isBookmarked ? "bookmark.slash" : "bookmark")
            }
            
            Button(action: {}) {
                Label("Copy Symbol", systemImage: "doc.on.doc")
            }
        }
    }
}
