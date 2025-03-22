import SwiftUI
import SwiftData

struct ElementsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [BookmarkedElement]
    @State private var searchText = ""
    @State private var selectedElement: ElementData? = nil
    @State private var showingClearBookmarksAlert = false
    @FocusState private var isSearchFocused: Bool
    
    // Filter states
    @State private var selectedSortOption: SortOption = .atomicNumber
    @State private var selectedCategoryFilter: String? = nil
    @State private var selectedPhaseFilter: String? = nil
    @State private var selectedBlockFilter: String? = nil
    @State private var selectedPeriodFilter: Int? = nil
    @State private var selectedGroupFilter: Int? = nil
    
    private var elements: [ElementData] {
        let searchResults = ElementService.shared.searchElements(query: searchText)
        
        // Apply all filters
        let filteredResults = searchResults.filter { element in
            // Only include if passes ALL filters that are set
            (selectedCategoryFilter == nil || element.category == selectedCategoryFilter) &&
            (selectedPhaseFilter == nil || element.phase == selectedPhaseFilter) &&
            (selectedBlockFilter == nil || element.block == selectedBlockFilter) &&
            (selectedPeriodFilter == nil || element.period == selectedPeriodFilter) &&
            (selectedGroupFilter == nil || element.group == selectedGroupFilter)
        }
        
        // Apply sorting
        return selectedSortOption.sortElements(filteredResults)
    }
    
    // Extraction functions for filter options
    private var uniqueCategories: [String] {
        Array(Set(ElementService.shared.getAllElements().map { $0.category })).sorted()
    }
    
    private var uniquePhases: [String] {
        Array(Set(ElementService.shared.getAllElements().map { $0.phase })).sorted()
    }
    
    private var uniqueBlocks: [String] {
        Array(Set(ElementService.shared.getAllElements().map { $0.block })).sorted()
    }
    
    private var uniquePeriods: [Int] {
        Array(Set(ElementService.shared.getAllElements().map { $0.period })).sorted()
    }
    
    private var uniqueGroups: [Int] {
        Array(Set(ElementService.shared.getAllElements().map { $0.group })).sorted()
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                        .font(.system(size: 15))
                    
                    TextField("Search elements", text: $searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 15))
                        .padding(.vertical, 6)
                        .focused($isSearchFocused)
                        .onChange(of: searchText) { oldValue, newValue in
                            if oldValue != newValue {
                                selectedElement = nil
                            }
                        }
                        .onSubmit {
                            if elements.count == 1 {
                                selectedElement = elements.first
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(10)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(12)
                
                // Sort and filter options bar
                HStack {
                    // Sort menu
                    Menu {
                        ForEach(SortOption.sections, id: \.0) { section, options in
                            Section(header: Text(section)) {
                                ForEach(options) { option in
                                    Button(action: {
                                        selectedSortOption = option
                                    }) {
                                        HStack {
                                            Text(option.rawValue)
                                            if selectedSortOption == option {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Sort: \(selectedSortOption.rawValue)", systemImage: "arrow.up.arrow.down")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    
                    // Filter menu
                    Menu {
                        Section(header: Text("General")) {
                            Button(action: {
                                resetAllFilters()
                            }) {
                                Label("Reset All Filters", systemImage: "arrow.counterclockwise")
                            }
                        }
                        
                        Section(header: Text("Categories")) {
                            ForEach(uniqueCategories, id: \.self) { category in
                                Button(action: {
                                    selectedCategoryFilter = category
                                }) {
                                    HStack {
                                        Text(category)
                                        if selectedCategoryFilter == category {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Phase")) {
                            ForEach(uniquePhases, id: \.self) { phase in
                                Button(action: {
                                    selectedPhaseFilter = phase
                                }) {
                                    HStack {
                                        Text(phase)
                                        if selectedPhaseFilter == phase {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Block")) {
                            ForEach(uniqueBlocks, id: \.self) { block in
                                Button(action: {
                                    selectedBlockFilter = block
                                }) {
                                    HStack {
                                        Text("Block \(block)")
                                        if selectedBlockFilter == block {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Period")) {
                            ForEach(uniquePeriods, id: \.self) { period in
                                Button(action: {
                                    selectedPeriodFilter = period
                                }) {
                                    HStack {
                                        Text("Period \(period)")
                                        if selectedPeriodFilter == period {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Group")) {
                            ForEach(uniqueGroups, id: \.self) { group in
                                Button(action: {
                                    selectedGroupFilter = group
                                }) {
                                    HStack {
                                        Text("Group \(group)")
                                        if selectedGroupFilter == group {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    
                    // Reset button
                    Button(action: resetAllFilters) {
                        Label("Reset", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .disabled(selectedSortOption == .atomicNumber && selectedCategoryFilter == nil &&
                             selectedPhaseFilter == nil && selectedBlockFilter == nil &&
                             selectedPeriodFilter == nil && selectedGroupFilter == nil)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
                
                // Filter badges - keep these for clarity
                if selectedCategoryFilter != nil || selectedPhaseFilter != nil || 
                   selectedBlockFilter != nil || selectedPeriodFilter != nil || 
                   selectedGroupFilter != nil || selectedSortOption != .atomicNumber {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            if selectedCategoryFilter != nil || selectedPhaseFilter != nil || 
                               selectedBlockFilter != nil || selectedPeriodFilter != nil || 
                               selectedGroupFilter != nil || selectedSortOption != .atomicNumber {
                                Button(action: resetAllFilters) {
                                    Label("Reset All", systemImage: "arrow.counterclockwise")
                                        .font(.caption)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                        .background(Color.red.opacity(0.2))
                                        .cornerRadius(20)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if let category = selectedCategoryFilter {
                                FilterBadge(text: category, icon: "atom") {
                                    selectedCategoryFilter = nil
                                }
                            }
                            
                            if let phase = selectedPhaseFilter {
                                FilterBadge(text: phase, icon: "thermometer") {
                                    selectedPhaseFilter = nil
                                }
                            }
                            
                            if let block = selectedBlockFilter {
                                FilterBadge(text: "Block \(block)", icon: "cube") {
                                    selectedBlockFilter = nil
                                }
                            }
                            
                            if let period = selectedPeriodFilter {
                                FilterBadge(text: "Period \(period)", icon: "arrow.left.and.right") {
                                    selectedPeriodFilter = nil
                                }
                            }
                            
                            if let group = selectedGroupFilter {
                                FilterBadge(text: "Group \(group)", icon: "arrow.up.and.down") {
                                    selectedGroupFilter = nil
                                }
                            }
                            
                            if selectedSortOption != .atomicNumber {
                                FilterBadge(text: "Sort: \(selectedSortOption.rawValue)", icon: "arrow.up.arrow.down") {
                                    selectedSortOption = .atomicNumber
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)
                    }
                }
                
                // Elements list
                List {
                    // Bookmarked elements section
                    if !bookmarks.isEmpty {
                        Section("Bookmarked Elements") {
                            ForEach(bookmarks, id: \.elementNumber) { bookmark in
                                if let element = ElementService.shared.getElement(byNumber: bookmark.elementNumber) {
                                    ElementRowView(element: element, onToggleBookmark: {
                                        toggleBookmark(element)
                                    })
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            selectedElement = element
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // All elements section
                    Section("All Elements (\(elements.count))") {
                        ForEach(elements) { element in
                            ElementRowView(element: element, onToggleBookmark: {
                                toggleBookmark(element)
                            })
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    selectedElement = element
                                }
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
            }
            .blur(radius: selectedElement != nil ? 10 : 0)
            
            // Use the same ElementPopupView as the periodic table view
            if let element = selectedElement {
                ElementPopupView(
                    element: element,
                    onClose: { 
                        withAnimation(.easeOut(duration: 0.15)) {
                            selectedElement = nil
                            isSearchFocused = true 
                        }
                    },
                    onToggleBookmark: { toggleBookmark(element) },
                    isBookmarked: isBookmarked(element)
                )
            }
        }
        .navigationTitle("Elements")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showingClearBookmarksAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .opacity(bookmarks.isEmpty ? 0.3 : 1.0)
                }
                .disabled(bookmarks.isEmpty)
                .help("Clear All Bookmarks")
            }
            
            // If detail view is showing, add back button
            if selectedElement != nil {
                ToolbarItem(placement: .automatic) {
                    Button(action: {
                        withAnimation {
                            self.selectedElement = nil
                            self.isSearchFocused = true
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                    }
                }
            }
        }
        .onKeyPress(.escape) {
            if selectedElement != nil {
                withAnimation(.easeOut(duration: 0.15)) {
                    selectedElement = nil
                    isSearchFocused = true
                }
                return .handled
            }
            return .ignored
        }
        .alert("Clear All Bookmarks", isPresented: $showingClearBookmarksAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                clearAllBookmarks()
            }
        } message: {
            Text("Are you sure you want to remove all bookmarked elements?")
        }
    }
    
    private func resetAllFilters() {
        selectedCategoryFilter = nil
        selectedPhaseFilter = nil
        selectedBlockFilter = nil
        selectedPeriodFilter = nil
        selectedGroupFilter = nil
        selectedSortOption = .atomicNumber
    }
    
    private func isBookmarked(_ element: ElementData) -> Bool {
        bookmarks.contains { $0.elementNumber == element.number }
    }
    
    private func clearAllBookmarks() {
        for bookmark in bookmarks {
            modelContext.delete(bookmark)
        }
        try? modelContext.save()
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
}

// Filter badge component
struct FilterBadge: View {
    let text: String
    let icon: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            
            Text(text)
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(20)
    }
}
