import SwiftUI

struct InfoSectionView<Content: View>: View {
    let title: String
    let content: Content
    let color: Color
    
    init(title: String, color: Color = .accentColor, @ViewBuilder content: () -> Content) {
        self.title = title
        self.color = color
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(color)
                .padding(.bottom, 2)
            
            content
            
            Divider()
                .background(color.opacity(0.3))
        }
    }
}

struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .leading)
            
            Text(value)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 3)
    }
}
