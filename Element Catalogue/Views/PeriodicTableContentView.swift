import SwiftUI

/// The main layout component for the periodic table
struct PeriodicTableContentView: View {
    // Grid layout properties
    let gridSpacing: CGFloat
    let cellSize: CGFloat
    
    // Element data
    let mainElements: [ElementData]  
    let lanthanides: [ElementData]
    let actinides: [ElementData]
    
    // Interactive callbacks
    let isBookmarked: (ElementData) -> Bool
    let onElementTap: (ElementData) -> Void
    
    // Calculate content dimensions
    var contentWidth: CGFloat {
        18 * (cellSize + gridSpacing)
    }
    
    var contentHeight: CGFloat {
        10 * (cellSize + gridSpacing)
    }
    
    var body: some View {
        // Use GeometryReader instead of ZStack for better layout stability
        GeometryReader { geometry in
            Canvas { context, size in
                // Draw a lightweight representation of cells for better performance
                for element in mainElements {
                    let xPos = CGFloat(element.xpos - 1) * (cellSize + gridSpacing)
                    let yPos = CGFloat(element.ypos - 1) * (cellSize + gridSpacing)
                    
                    let rect = CGRect(x: xPos, y: yPos, width: cellSize, height: cellSize)
                    
                    // Draw cell background
                    let color = ElementColors.colorForElement(element).opacity(0.8)
                    context.fill(Path(roundedRect: rect, cornerRadius: 6), with: .color(color))
                    
                    // Draw element symbol - make it bigger
                    let textPoint = CGPoint(x: xPos + cellSize / 2, y: yPos + cellSize / 2)
                    context.draw(
                        Text(element.symbol)
                            .font(.system(size: 20, weight: .bold)) // Increased from 14 to 20
                            .foregroundColor(.white), 
                        at: textPoint
                    )
                }
                
                // Similar drawing for lanthanides and actinides could be implemented
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        // Calculate which element was tapped
                        let location = value.location
                        
                        // Find which main element was tapped
                        for element in mainElements {
                            let xPos = CGFloat(element.xpos - 1) * (cellSize + gridSpacing)
                            let yPos = CGFloat(element.ypos - 1) * (cellSize + gridSpacing)
                            
                            let elementRect = CGRect(x: xPos, y: yPos, width: cellSize, height: cellSize)
                            
                            if elementRect.contains(location) {
                                onElementTap(element)
                                return
                            }
                        }
                        
                        // Similar checks for lanthanides and actinides could be implemented
                    }
            )
        }
        .frame(width: contentWidth, height: contentHeight)
        
        // Additionally keep the original implementation but make it conditional
        // or provide a way to switch between the two rendering approaches
    }
}
