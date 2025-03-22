import SwiftUI
import SwiftData

/// Main container view for the periodic table functionality
struct PeriodicTableView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [BookmarkedElement]
    @State private var selectedElement: ElementData? = nil
    @State private var useSimpleRenderer = true
    @State private var isFloating = false
    @State private var floatingWindow: NSWindow?
    
    // Grid constants
    private let gridSpacing: CGFloat = 2
    private let cellSize: CGFloat = 50
    
    // Pre-filter elements for better performance
    private let elements = ElementService.shared.getAllElements()
    
    private var mainElements: [ElementData] {
        elements.filter { $0.ypos <= 7 && $0.xpos <= 18 }
    }
    
    private var lanthanides: [ElementData] {
        elements.filter { $0.category == "lanthanide" }
    }
    
    private var actinides: [ElementData] {
        elements.filter { $0.category == "actinide" }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Period numbers on left side
                HStack(alignment: .top, spacing: 0) {
                    // Group numbers along top
                    VStack(spacing: 0) {
                        // Top row with group numbers
                        HStack(spacing: 0) {
                            // Empty corner cell
                            Text("")
                                .frame(width: 30, height: 30)
                            
                            // Group numbers
                            ForEach(1...18, id: \.self) { group in
                                Text("\(group)")
                                    .font(.system(size: 10))
                                    .frame(width: cellSize, height: 30)
                            }
                        }
                        
                        HStack(spacing: 0) {
                            // Period numbers along left side - fix vertical alignment
                            VStack(spacing: 0) {
                                ForEach(1...7, id: \.self) { period in
                                    Text("\(period)")
                                        .font(.system(size: 10))
                                        .frame(width: 30, height: cellSize)
                                        .offset(y: -cellSize/2) // Align correctly with cells
                                }
                                // Extra rows for lanthanides/actinides
                                Text("")
                                    .frame(width: 30, height: cellSize)
                                Text("")
                                    .frame(width: 30, height: cellSize)
                            }
                            
                            // Main periodic table grid
                            if useSimpleRenderer {
                                // Simple grid layout using GeometryReader
                                GeometryReader { geometry in
                                    ZStack {
                                        // Layout each element directly 
                                        ForEach(mainElements) { element in
                                            elementButton(for: element)
                                        }
                                        
                                        // Lanthanides and actinides
                                        ForEach(lanthanides) { element in
                                            elementButton(for: element, offset: CGPoint(
                                                x: CGFloat(element.number - 57) * cellSize + 2 * cellSize,
                                                y: 8 * cellSize
                                            ))
                                        }
                                        
                                        ForEach(actinides) { element in
                                            elementButton(for: element, offset: CGPoint(
                                                x: CGFloat(element.number - 89) * cellSize + 2 * cellSize,
                                                y: 9 * cellSize
                                            ))
                                        }
                                    }
                                }
                                .frame(width: 18 * cellSize, height: 10 * cellSize)
                            } else {
                                PeriodicTableContentView(
                                    gridSpacing: gridSpacing, 
                                    cellSize: cellSize, 
                                    mainElements: mainElements, 
                                    lanthanides: lanthanides, 
                                    actinides: actinides,
                                    isBookmarked: isBookmarked,
                                    onElementTap: { element in
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedElement = element
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .blur(radius: selectedElement != nil ? 6 : 0)
            
            if selectedElement != nil {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // Element popup with consistent animations
            if let element = selectedElement {
                ElementPopupView(
                    element: element,
                    onClose: { 
                        withAnimation(.easeOut(duration: 0.15)) {
                            selectedElement = nil
                        }
                    },
                    onToggleBookmark: { toggleBookmark(element) },
                    isBookmarked: isBookmarked(element)
                )
                .transition(.opacity)
            }
        }
        .navigationTitle("Periodic Table")
        .frame(minWidth: 900, minHeight: 500)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                // Bookmarks clear button
                Button(action: {
                    let alert = NSAlert()
                    alert.messageText = "Clear All Bookmarks"
                    alert.informativeText = "Are you sure you want to remove all bookmarked elements?"
                    alert.addButton(withTitle: "Cancel")
                    alert.addButton(withTitle: "Clear All")
                    if alert.runModal() == .alertSecondButtonReturn {
                        clearAllBookmarks()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .opacity(bookmarks.isEmpty ? 0.3 : 1.0)
                }
                .disabled(bookmarks.isEmpty)
                .help("Clear All Bookmarks")
            }
            
            // Remove floating window button - it's unnecessary now that all windows float
        }
        .onKeyPress(.escape) {
            if selectedElement != nil {
                withAnimation(.easeOut(duration: 0.15)) {
                    selectedElement = nil
                }
                return .handled
            } else if isFloating {
                closeFloatingWindow()
                return .handled
            }
            return .ignored
        }
        // Clean up window when view disappears
        .onDisappear {
            closeFloatingWindow()
        }
    }
    
    private func elementButton(for element: ElementData, offset: CGPoint? = nil) -> some View {
        let xPos = offset?.x ?? CGFloat(element.xpos - 1) * cellSize
        let yPos = offset?.y ?? CGFloat(element.ypos - 1) * cellSize
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedElement = element
            }
        }) {
            VStack(spacing: 0) {
                // Atomic number on top
                Text("\(element.number)")
                    .font(.system(size: 8))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 1)
                    .padding(.trailing, 2)
                
                // Element symbol - make bigger
                Text(element.symbol)
                    .font(.system(size: 20, weight: .bold)) // Increased from 14 to 20
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Remove element name at bottom
            }
            .foregroundColor(.white)
            .frame(width: cellSize - 4, height: cellSize - 4)
            .background(ElementColors.colorForElement(element))
            .cornerRadius(4)
            .overlay(
                Group {
                    if isBookmarked(element) {
                        Image(systemName: "bookmark.fill")
                            .font(.system(size: 8))
                            .foregroundColor(.white)
                            .offset(x: -13, y: -13)
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .position(x: xPos + cellSize/2, y: yPos + cellSize/2)
    }
    
    // MARK: - Floating Window
    
    private func openFloatingWindow() {
        // Create a detached window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 960, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        // Create a ContentView specifically for the floating window
        let contentView = PeriodicTableView()
            .environment(\.modelContext, modelContext)
        
        // Set the window content
        window.contentViewController = NSHostingController(rootView: contentView)
        
        // Configure and show the window
        window.title = "Periodic Table (Floating)"
        window.setFrameAutosaveName("PeriodicTableWindow")
        window.center()
        
        // Configure as floating window
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        
        window.makeKeyAndOrderFront(nil)
        
        // Store the window reference and update state
        self.floatingWindow = window
        self.isFloating = true
        
        // Implement window close notification listener
        NotificationCenter.default.addObserver(
            forName: NSWindow.willCloseNotification,
            object: window,
            queue: nil
        ) { _ in
            self.isFloating = false
            self.floatingWindow = nil
        }
    }
    
    private func closeFloatingWindow() {
        floatingWindow?.close()
        floatingWindow = nil
        isFloating = false
    }
    
    // MARK: - Bookmark Management
    
    private func isBookmarked(_ element: ElementData) -> Bool {
        bookmarks.contains { $0.elementNumber == element.number }
    }
    
    private func toggleBookmark(_ element: ElementData) {
        if let existingBookmark = bookmarks.first(where: { $0.elementNumber == element.number }) {
            modelContext.delete(existingBookmark)
        } else {
            let newBookmark = BookmarkedElement(elementNumber: element.number)
            modelContext.insert(newBookmark)
        }
        try? modelContext.save()
    }
    
    private func clearAllBookmarks() {
        for bookmark in bookmarks {
            modelContext.delete(bookmark)
        }
        try? modelContext.save()
    }
}
