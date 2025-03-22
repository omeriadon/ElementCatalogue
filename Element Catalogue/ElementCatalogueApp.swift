//
//  Element_CatalogueApp.swift
//  Element Catalogue
//
//  Created by Adon Omeri on 22/3/2025.
//

import SwiftUI
import SwiftData
import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillUpdate(_ notification: Notification) {
        DispatchQueue.main.async {
            if let menu = NSApplication.shared.mainMenu {
                for title in ["File", "Window", "View", "Help"] {
                    if let item = menu.items.first(where: { $0.title == title }) {
                        menu.removeItem(item)
                    }
                }
            }
        }
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create main menu items programmatically
        setupMainMenu()
    }
    
    private func setupMainMenu() {
        // Get the main menu
        guard let mainMenu = NSApplication.shared.mainMenu else { return }
        
        // Remove standard menu items that we don't want
        for title in ["File", "Window", "View", "Help"] {
            if let item = mainMenu.items.first(where: { $0.title == title }) {
                mainMenu.removeItem(item)
            }
        }
        
        // Create Tools menu
        let toolsMenu = NSMenu(title: "Tools")
        let clearBookmarksItem = NSMenuItem(
            title: "Clear All Bookmarks", 
            action: #selector(clearAllBookmarks), 
            keyEquivalent: "d"
        )
        clearBookmarksItem.keyEquivalentModifierMask = [.command, .shift]
        
        // Add a red trash icon to the menu item
        let trashIcon = NSImage(systemSymbolName: "trash", accessibilityDescription: "Clear Bookmarks")
        clearBookmarksItem.image = trashIcon
        
        toolsMenu.addItem(clearBookmarksItem)
        
        let toolsMenuItem = NSMenuItem(title: "Tools", action: nil, keyEquivalent: "")
        toolsMenuItem.submenu = toolsMenu
        mainMenu.insertItem(toolsMenuItem, at: 2)
    }
    
    @objc func clearAllBookmarks() {
        // Post notification to clear bookmarks
        NotificationCenter.default.post(name: .clearAllBookmarks, object: nil)
    }
    
    // Helper function to configure a window as floating
    func configureWindowAsFloating(_ window: NSWindow) {
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
    }
}

// Update notification names extension
extension Notification.Name {
    static let clearAllBookmarks = Notification.Name("clearAllBookmarks")
}

@main
struct Element_CatalogueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    static var shared: Element_CatalogueApp!
    @Environment(\.openWindow) private var openWindow
    
    init() {
        Element_CatalogueApp.shared = self
    }
    
    // Configure SwiftData for persistence
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([BookmarkedElement.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("Successfully created SwiftData container")
            return container
        } catch {
            print("Failed to create SwiftData container: \(error)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup("Element Catalogue", id: "main") {
            ContentView()
                .background(.ultraThinMaterial)
                .preferredColorScheme(.dark)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    // Make window floating when it appears
                    DispatchQueue.main.async {
                        NSApp.windows.forEach { window in
                            appDelegate.configureWindowAsFloating(window)
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar) 
        .defaultSize(width: 800, height: 600)
        
        // Add menu bar commands
        .commands {
            // New Window command in top-level menu
            CommandMenu("File") {
                Button("New Window") {
                    openWindow(id: "main")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            // Replace other window groups
            CommandGroup(replacing: .windowSize) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .windowArrangement) { }
        }
    }
}
