//
//  ContentView.swift
//  Element Catalogue
//
//  Created by Adon Omeri on 22/3/2025.
//

import SwiftUI
import SwiftData
import AppKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var bookmarks: [BookmarkedElement]
    @State private var showingClearBookmarksAlert = false
    @State private var selectedTab: Tab = .list
    @State private var isExpanded = false
    @State private var currentWindow: NSWindow?
    
    enum Tab {
        case list, periodicTable
    }
    
    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                ElementsListView()
                    .tabItem {
                        Label("Elements", systemImage: "list.bullet")
                    }
                    .tag(Tab.list)
                
                PeriodicTableView()
                    .tabItem {
                        Label("Periodic Table", systemImage: "square.grid.3x3")
                    }
                    .tag(Tab.periodicTable)
            }
            .onChange(of: selectedTab) { oldValue, newValue in
                // Auto-resize window when tab changes - only for the current window
                resizeWindowForTab(newValue)
            }
        }
        .frame(minWidth: 425, maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
        .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
        .background(
            WindowAccessor { window in
                // Store reference to the window
                self.currentWindow = window
                window.isOpaque = false
                window.backgroundColor = NSColor.clear
                
                // Configure as floating window
                window.level = .floating
                window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
                window.isMovableByWindowBackground = true
            }
        )
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: .clearAllBookmarks,
                object: nil,
                queue: .main
            ) { _ in
                showingClearBookmarksAlert = true
            }
        }
        .alert("Clear All Bookmarks", isPresented: $showingClearBookmarksAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear All", role: .destructive) {
                clearAllBookmarks()
            }
        } message: {
            Text("Are you sure you want to remove all bookmarked elements?")
        }
        .onReceive(NotificationCenter.default.publisher(for: .clearAllBookmarks)) { _ in
            // Handle clear all bookmarks
            clearAllBookmarks()
        }
    }
    
    private func resizeWindowForTab(_ tab: Tab) {
        guard let window = currentWindow else { return }
        
        let origin = window.frame.origin
        var size: CGSize
        
        switch tab {
        case .list:
            size = CGSize(width: 480, height: 600)
            isExpanded = false
        case .periodicTable:
            // Larger size to accommodate the period/group annotations
            size = CGSize(width: 1000, height: 600) 
            isExpanded = true
        }
        
        // Use smooth animation when changing tabs
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().setFrame(NSRect(origin: origin, size: size), display: true)
        }
    }
    
    private func toggleWindowSize() {
        guard let window = currentWindow else { return }
        
        if isExpanded {
            // Return to original size
            window.setFrame(NSRect(
                origin: window.frame.origin,
                size: CGSize(width: 480, height: 600)
            ), display: true, animate: true)
        } else {
            // Expand to new specified size
            window.setFrame(NSRect(
                origin: window.frame.origin,
                size: CGSize(width: 960, height: 565) // Updated to match periodic table view
            ), display: true, animate: true)
        }
        isExpanded.toggle()
    }
    
    private func clearAllBookmarks() {
        for bookmark in bookmarks {
            modelContext.delete(bookmark)
        }
        try? modelContext.save()
    }
}

// Helper view to access the NSWindow
struct WindowAccessor: NSViewRepresentable {
    var callback: (NSWindow) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.callback(window)
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}

#Preview {
    ContentView()
}
