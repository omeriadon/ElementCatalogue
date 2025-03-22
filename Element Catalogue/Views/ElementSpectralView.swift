import SwiftUI

struct ElementSpectralView: View {
    @State private var selectedElement: ElementData? = ElementService.shared.getAllElements().first
    private let elements = ElementService.shared.getAllElements()
    
    var body: some View {
        VStack(spacing: 20) {
            // Element selector
            Picker("Select Element", selection: $selectedElement) {
                ForEach(elements) { element in
                    Text(element.name).tag(element as ElementData?)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: 200)
            .padding(.top)
            
            if let element = selectedElement {
                // Element info card
                elementCard(element)
                
                // Spectral display
                spectralDisplay(element)
                
                Spacer()
            } else {
                Text("Select an element to view its spectral lines")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            }
        }
        .padding()
        .navigationTitle("Spectral View")
        .frame(minWidth: 600, minHeight: 400)
    }
    
    private func elementCard(_ element: ElementData) -> some View {
        VStack(alignment: .center, spacing: 10) {
            Text(element.symbol)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.white)
            
            Text(element.name)
                .font(.title)
                .foregroundColor(.white)
            
            Text("Atomic Number: \(element.number)")
                .font(.headline)
                .foregroundColor(.white.opacity(0.9))
            
            Text("Atomic Mass: \(String(format: "%.3f", element.atomic_mass))")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
        .padding()
        .frame(minWidth: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(ElementColors.colorForElement(element))
                .shadow(radius: 5)
        )
    }
    
    private func spectralDisplay(_ element: ElementData) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Emission Spectrum")
                .font(.headline)
            
            // Simulated spectral lines visualization
            spectralLines(for: element)
                .frame(height: 120)
                .background(Color.black.opacity(0.8))
                .cornerRadius(8)
            
            // Wavelength scale
            HStack(spacing: 0) {
                ForEach(0..<7) { i in
                    Text("\(380 + i * 50)nm")
                        .font(.system(size: 10))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Information about the spectrum
            Text("Notable spectral lines:")
                .font(.subheadline)
                .padding(.top, 5)
            
            spectralInfo(for: element)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.windowBackgroundColor))
                .shadow(radius: 2)
        )
    }
    
    private func spectralLines(for element: ElementData) -> some View {
        // Generate pseudo-random spectral lines based on element properties
        Canvas { context, size in
            // Draw rainbow gradient manually with rects
            let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple]
            let segmentWidth = size.width / CGFloat(colors.count)
            
            for (index, color) in colors.enumerated() {
                let segmentRect = CGRect(
                    x: CGFloat(index) * segmentWidth,
                    y: 40,
                    width: segmentWidth,
                    height: 40
                )
                context.fill(Path(segmentRect), with: .color(color))
            }
            
            // Draw element-specific spectral lines with white color
            let lineCount = min(15, max(5, element.number / 10))
            for i in 0..<lineCount {
                // Use element properties to generate consistent "random" positions
                let seed = Double(element.number * (i + 1))
                let xPos = size.width * (sin(seed) * 0.5 + 0.5)
                
                let path = Path { p in
                    p.move(to: CGPoint(x: xPos, y: 0))
                    p.addLine(to: CGPoint(x: xPos, y: size.height))
                }
                
                // Use thick white lines for all spectral lines
                context.stroke(path, with: .color(.white), lineWidth: 3)
            }
        }
    }
    
    private func spectralInfo(for element: ElementData) -> some View {
        // Simulated spectral data
        let category = element.category
        let wavelengths: [String] = [
            "434.2 nm (blue)",
            "486.3 nm (green-blue)",
            "656.3 nm (red)"
        ]
        
        return VStack(alignment: .leading, spacing: 5) {
            Text("\(element.name) is in the \(category) category.")
                .font(.caption)
            
            ForEach(wavelengths, id: \.self) { wavelength in
                HStack {
                    Circle()
                        .fill(ElementColors.colorForElement(element))
                        .frame(width: 8, height: 8)
                    Text(wavelength)
                        .font(.caption)
                }
            }
            
            Text("Note: This is simulated spectral data for educational purposes.")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.top, 5)
        }
    }
}

// Helper extension for ElementColors to ensure consistency
extension ElementColors {
    static func spectralColor(for wavelength: Double) -> Color {
        // Convert wavelength (380-750nm) to RGB
        if wavelength >= 380 && wavelength <= 440 {
            return Color(red: (440 - wavelength) / 60, green: 0, blue: 1)
        } else if wavelength >= 440 && wavelength <= 490 {
            return Color(red: 0, green: (wavelength - 440) / 50, blue: 1)
        } else if wavelength >= 490 && wavelength <= 510 {
            return Color(red: 0, green: 1, blue: (510 - wavelength) / 20)
        } else if wavelength >= 510 && wavelength <= 580 {
            return Color(red: (wavelength - 510) / 70, green: 1, blue: 0)
        } else if wavelength >= 580 && wavelength <= 645 {
            return Color(red: 1, green: (645 - wavelength) / 65, blue: 0)
        } else if wavelength >= 645 && wavelength <= 750 {
            return Color(red: 1, green: 0, blue: 0)
        } else {
            return Color.gray
        }
    }
}
