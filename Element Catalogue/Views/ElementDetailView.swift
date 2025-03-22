import SwiftUI
import SwiftData

struct ElementDetailView: View {
    let element: ElementData
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [BookmarkedElement]
    
    // Add a state variable to track image load attempts
    @State private var imageLoadAttempt = 0
    
    // Add fallback URLs to try in sequence
    private func getImageURLs(for element: ElementData) -> [URL?] {
        let nameForURL = element.name.lowercased().replacingOccurrences(of: " ", with: "-")
        
        // Start with the URL from the JSON if available
        var urls: [URL?] = []
        
        if let image = element.image, !image.url.isEmpty {
            urls.append(URL(string: image.url))
        }
        
        // Add various fallback URLs
        urls.append(URL(string: "https://images-of-elements.com/\(nameForURL).jpg"))
        urls.append(URL(string: "https://images-of-elements.com/\(element.symbol.lowercased()).jpg"))
        urls.append(URL(string: "https://en.wikipedia.org/wiki/\(element.name)#/media/File:\(nameForURL).jpg"))
        
        return urls
    }
    
    private var isBookmarked: Bool {
        bookmarks.contains { $0.elementNumber == element.number }
    }
    
    private var elementColor: Color {
        ElementColors.colorForCategory(element.category)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        ZStack {
                            Circle()
                                .fill(elementColor)
                                .frame(width: 80, height: 80)
                                .shadow(radius: 2)
                            
                            Text(element.symbol)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Text(element.name)
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(elementColor)
                        
                        Text("Atomic Number: \(element.number)")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    // Bookmark button
                    Button(action: toggleBookmark) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.title)
                            .foregroundColor(elementColor)
                    }
                    .buttonStyle(.borderless)
                }
                .padding(.bottom, 8)
                
                // Basic information
                InfoSectionView(title: "Basic Information", color: elementColor) {
                    InfoRowView(label: "Category", value: element.category)
                    InfoRowView(label: "Atomic Mass", value: "\(element.atomic_mass)")
                    InfoRowView(label: "Phase", value: element.phase)
                    if let appearance = element.appearance {
                        InfoRowView(label: "Appearance", value: appearance)
                    }
                    InfoRowView(label: "Block", value: element.block)
                    InfoRowView(label: "Period", value: "\(element.period)")
                    InfoRowView(label: "Group", value: "\(element.group)")
                }
                
                // Physical properties
                InfoSectionView(title: "Physical Properties", color: elementColor) {
                    if let density = element.density {
                        InfoRowView(label: "Density", value: "\(density) g/cm³")
                    }
                    if let melt = element.melt {
                        InfoRowView(label: "Melting Point", value: "\(melt) K")
                    }
                    if let boil = element.boil {
                        InfoRowView(label: "Boiling Point", value: "\(boil) K")
                    }
                    if let molar_heat = element.molar_heat {
                        InfoRowView(label: "Molar Heat", value: "\(molar_heat) J/(mol·K)")
                    }
                }
                
                // Electronic properties
                InfoSectionView(title: "Electronic Properties", color: elementColor) {
                    InfoRowView(label: "Electron Configuration", value: element.electron_configuration)
                    InfoRowView(label: "Semantic Configuration", value: element.electron_configuration_semantic)
                    if let electronegativity = element.electronegativity_pauling {
                        InfoRowView(label: "Electronegativity", value: "\(electronegativity) (Pauling)")
                    }
                    if let electron_affinity = element.electron_affinity {
                        InfoRowView(label: "Electron Affinity", value: "\(electron_affinity) kJ/mol")
                    }
                    InfoRowView(label: "Shells", value: element.shells.map { "\($0)" }.joined(separator: ", "))
                }
                
                // Discovery information
                InfoSectionView(title: "Discovery", color: elementColor) {
                    if let discoveredBy = element.discovered_by {
                        InfoRowView(label: "Discovered By", value: discoveredBy)
                    }
                    if let namedBy = element.named_by {
                        InfoRowView(label: "Named By", value: namedBy)
                    }
                }
                
                // Summary
                InfoSectionView(title: "Summary", color: elementColor) {
                    Text(element.summary)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Image (if available)
                InfoSectionView(title: "Image", color: elementColor) {
                    let imageURLs = getImageURLs(for: element)
                    
                    if imageLoadAttempt < imageURLs.count, let imageUrl = imageURLs[imageLoadAttempt] {
                        AsyncImage(url: imageUrl) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(height: 150)
                                    .onAppear {
                                        // Log URL attempt for debugging
                                        print("Attempting to load image from: \(imageUrl)")
                                    }
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 200)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                                    .onAppear {
                                        print("Successfully loaded image for \(element.name)")
                                    }
                            case .failure:
                                // Try next URL on failure
                                Color.clear
                                    .onAppear {
                                        print("Failed to load image from \(imageUrl), trying next URL")
                                        if imageLoadAttempt < imageURLs.count - 1 {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                imageLoadAttempt += 1
                                            }
                                        }
                                    }
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        // Fallback when all URLs fail
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(elementColor.opacity(0.2))
                                .frame(height: 150)
                            
                            VStack {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                Text("Image unavailable")
                                    .font(.caption)
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    if let image = element.image, !image.attribution.isEmpty {
                        Text(image.attribution)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 4)
                    }
                }
                
                // Additional images section
                if let bohrImage = element.bohr_model_image, !bohrImage.isEmpty {
                    Divider()
                    
                    Text("Bohr Model")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    AsyncImage(url: URL(string: bohrImage)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 150)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 150)
                                .cornerRadius(8)
                        case .failure:
                            Text("Failed to load Bohr model image")
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                
                // Spectral image if available
                if let spectralImg = element.spectral_img, !spectralImg.isEmpty {
                    Divider()
                    
                    Text("Spectral Image")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    AsyncImage(url: URL(string: spectralImg)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 120)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 120)
                                .cornerRadius(8)
                        case .failure:
                            Text("Failed to load spectral image")
                                .foregroundColor(.secondary)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
        }
    }
    
    private func toggleBookmark() {
        if let existingBookmark = bookmarks.first(where: { $0.elementNumber == element.number }) {
            modelContext.delete(existingBookmark)
        } else {
            let newBookmark = BookmarkedElement(elementNumber: element.number)
            modelContext.insert(newBookmark)
        }
    }
}
