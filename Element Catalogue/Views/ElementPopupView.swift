import SwiftUI
import SwiftData
import SceneKit

struct ElementPopupView: View {
    let element: ElementData
    let onClose: () -> Void
    let onToggleBookmark: () -> Void
    let isBookmarked: Bool
    
    // Track image loading attempts
    @State private var imageLoadAttempt = 0
    
    // Get image URLs for the element
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
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    onClose()
                }
            
            // Main content container
            VStack(spacing: 0) {
                // Header with action buttons
                HStack {
                    Button(action: onToggleBookmark) {
                        Label(
                            isBookmarked ? "Remove Bookmark" : "Add Bookmark",
                            systemImage: isBookmarked ? "bookmark.fill" : "bookmark"
                        )
                        .foregroundColor(ElementColors.colorForElement(element))
                    }
                    .buttonStyle(.plain)
                    .padding()
                    
                    Spacer()
                    
                    Button(action: onClose) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    .padding()
                }
                
                // Content in a scrollview for flexibility
                ScrollView {
                    VStack(spacing: 25) {
                        // Element header with circular symbol
                        elementHeader()
                            .padding(.horizontal)
                        
                        // Element details sections
                        Group {
                            // Basic Information
                            InfoSectionView(title: "Basic Information", color: ElementColors.colorForElement(element)) {
                                InfoRowView(label: "Category", value: element.category.capitalized)
                                InfoRowView(label: "Atomic Mass", value: "\(element.atomic_mass)")
                                InfoRowView(label: "Phase", value: element.phase)
                                if ((element.appearance?.isEmpty) == false) {
                                    InfoRowView(label: "Appearance", value: element.appearance!)
                                }
                                InfoRowView(label: "Block", value: element.block)
                                InfoRowView(label: "Period", value: "\(element.period)")
                                InfoRowView(label: "Group", value: "\(element.group)")
                            }
                            
                            // Physical Properties
                            InfoSectionView(title: "Physical Properties", color: ElementColors.colorForElement(element)) {
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
                            
                            // Electronic Properties
                            InfoSectionView(title: "Electronic Properties", color: ElementColors.colorForElement(element)) {
                                InfoRowView(label: "Electron Configuration", value: element.electron_configuration)
                                // Fix conditional binding by checking if electronegativity_pauling is not nil
                                if element.electronegativity_pauling != nil {
                                    InfoRowView(label: "Electronegativity", value: "\(element.electronegativity_pauling!) (Pauling)")
                                }
                                if let firstEnergy = element.ionization_energies.first {
                                    InfoRowView(label: "Ionization Energy", value: "\(firstEnergy) kJ/mol")
                                }
                                InfoRowView(label: "Shells", value: element.shells.map { "\($0)" }.joined(separator: ", "))
                            }
                            
                            // Discovery Information
                            if ((element.discovered_by?.isEmpty) == false || (element.named_by?.isEmpty) == false) {
                                InfoSectionView(title: "Discovery", color: ElementColors.colorForElement(element)) {
                                    if ((element.discovered_by?.isEmpty) == false) {
                                        InfoRowView(label: "Discovered By", value: element.discovered_by!)
                                    }
                                    if ((element.named_by?.isEmpty) == false) {
                                        InfoRowView(label: "Named By", value: element.named_by!)
                                    }
                                }
                            }
                            
                            // Summary
                            if ((element.summary.isEmpty) == false) {
                                InfoSectionView(title: "Summary", color: ElementColors.colorForElement(element)) {
                                    Text(element.summary)
                                        .font(.body)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                            
                            // Emission Spectrum
                            InfoSectionView(title: "Emission Spectrum", color: ElementColors.colorForElement(element)) {
                                ElementSpectralComponent(element: element)
                                    .frame(height: 100)
                                    .padding(.vertical, 5)
                            }
                            
                            // Element Images
                            InfoSectionView(title: "Images", color: ElementColors.colorForElement(element)) {
                                elementImages()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 20)
                }
            }
            .frame(maxWidth: 600, maxHeight: 700)
            .background(Color(.windowBackgroundColor).opacity(0.98))
            .cornerRadius(12)
            .shadow(radius: 15)
        }
        .transition(.opacity)
        .zIndex(10)
    }
    
    // MARK: - Component Builders
    
    private func elementHeader() -> some View {
        HStack(alignment: .top, spacing: 20) {
            // Element symbol in a circle with element color
            ZStack {
                Circle()
                    .fill(ElementColors.colorForElement(element))
                    .frame(width: 100, height: 100)
                    .shadow(radius: 3)
                
                VStack(spacing: 0) {
                    Text(element.symbol)
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(element.number)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            
            // Element name and basic details - left align all content
            VStack(alignment: .leading, spacing: 8) {
                Text(element.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(ElementColors.colorForElement(element))
                
                Text("Atomic Number: \(element.number)")
                    .font(.headline)
                
                Text("Atomic Mass: \(String(format: "%.3f", element.atomic_mass))")
                    .font(.subheadline)
                
                Spacer()
                
                
                if (element.source.isEmpty) == false {
                    
                    Link("View Source", destination: URL(string: element.source)!)
                        .font(.caption)
                        .tint(ElementColors.colorForElement(element))
                    
                }

            }
            .padding(.top, 8)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity, alignment: .leading) // Left align the entire header
    }
    
    private func elementImages() -> some View {
        VStack(alignment: .leading, spacing: 15) {
            let imageURLs = getImageURLs(for: element)
            
            if imageLoadAttempt < imageURLs.count, let imageUrl = imageURLs[imageLoadAttempt] {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    case .failure:
                        // Try next URL on failure
                        Color.clear
                            .onAppear {
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
            } else {
                Text("No images available")
                    .foregroundColor(.secondary)
                    .frame(height: 100)
            }
            
            // Bohr model image if available - themed divider
            if let bohrModel = element.bohr_model_image, !bohrModel.isEmpty {
                // Themed divider that matches element color
                Divider()
                    .background(ElementColors.colorForElement(element).opacity(0.5))
                    .padding(.vertical, 8)
                
                Text("Bohr Model")
                    .font(.headline)
                    .foregroundColor(ElementColors.colorForElement(element))
                
                AsyncImage(url: URL(string: bohrModel)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 120)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 160)
                            .cornerRadius(8)
                            .shadow(radius: 2)
                    case .failure:
                        Text("Failed to load Bohr model")
                            .foregroundColor(.secondary)
                            .frame(height: 80)
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
}

// Reusable spectral visualization component - simplified
struct ElementSpectralComponent: View {
    let element: ElementData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            // Spectral lines visualization
            spectralLines()
                .frame(height: 60)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            
            // Simple wavelength indicator
            HStack(spacing: 0) {
                ForEach(0..<7) { i in
                    Text("\(380 + i * 50)nm")
                        .font(.system(size: 8))
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func spectralLines() -> some View {
        Canvas { context, size in
            // Draw a continuous spectrum background using simple color blocks
            let colors = [
                Color.red, Color.orange, Color.yellow, Color.green, 
                Color.blue, Color.indigo, Color.purple
            ]
            
            // Draw the continuous spectrum as color blocks
            let rectHeight: CGFloat = 30
            let rectY = (size.height - rectHeight) / 2
            let segmentWidth = size.width / CGFloat(colors.count)
            
            for (index, color) in colors.enumerated() {
                let rect = CGRect(
                    x: CGFloat(index) * segmentWidth,
                    y: rectY,
                    width: segmentWidth,
                    height: rectHeight
                )
                context.fill(Path(rect), with: .color(color))
            }
            
            // Draw element-specific spectral lines with consistent white color
            let lineCount = min(8, max(3, element.number / 15))
            for i in 0..<lineCount {
                // Use element properties to generate positions
                let seed = Double(element.number * (i + 1))
                let xPos = size.width * (sin(seed * 0.1) * 0.5 + 0.5)
                
                let linePath = Path { p in
                    p.move(to: CGPoint(x: xPos, y: 0))
                    p.addLine(to: CGPoint(x: xPos, y: size.height))
                }
                
                // Use thick white lines for all elements
                context.stroke(linePath, with: .color(.white), lineWidth: 3)
            }
        }
    }
}
