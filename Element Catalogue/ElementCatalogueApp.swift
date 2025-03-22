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
        // Make sure Settings menu is available
        let settingsMenu = NSMenu(title: "Settings")
        
        // Add New Window menu item
        let newWindowItem = NSMenuItem(
            title: "New Window",
            action: #selector(createNewWindow),
            keyEquivalent: "n"
        )
        newWindowItem.keyEquivalentModifierMask = .command
        settingsMenu.addItem(newWindowItem)
        
        // Add separator
        settingsMenu.addItem(NSMenuItem.separator())
        
        // Add clear bookmarks item (existing)
        let clearBookmarksItem = NSMenuItem(
            title: "Clear All Bookmarks", 
            action: #selector(clearAllBookmarks), 
            keyEquivalent: "d"
        )
        clearBookmarksItem.keyEquivalentModifierMask = [.command, .shift]
        
        // Add a red trash icon to the menu item
        let trashIcon = NSImage(systemSymbolName: "trash", accessibilityDescription: "Clear Bookmarks")
        clearBookmarksItem.image = trashIcon
        
        settingsMenu.addItem(clearBookmarksItem)
        
        // Add the Settings menu
        if let mainMenu = NSApplication.shared.mainMenu {
            let settingsMenuItem = NSMenuItem(title: "Settings", action: nil, keyEquivalent: "")
            settingsMenuItem.submenu = settingsMenu
            mainMenu.insertItem(settingsMenuItem, at: 1)
        }
        
        // Make app windows floating by default
        if let window = NSApplication.shared.windows.first {
            configureWindowAsFloating(window)
        }
    }
    
    @MainActor
    @objc func createNewWindow() {
        // Create a new window without relying on UIKit-specific APIs
        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        // Create the SwiftUI content view
        let contentView = ContentView()
            .environment(\.modelContext, Element_CatalogueApp.shared.sharedModelContainer.mainContext)
        
        // Set the window content
        newWindow.contentViewController = NSHostingController(rootView: contentView
            .background(.ultraThinMaterial)
            .preferredColorScheme(.dark)
        )
        
        // Configure the window
        newWindow.title = "Element Catalogue"
        newWindow.center()
        configureWindowAsFloating(newWindow)
        newWindow.makeKeyAndOrderFront(nil)
    }
    
    @objc func clearAllBookmarks() {
        // Post notification to clear bookmarks
        NotificationCenter.default.post(name: .clearAllBookmarks, object: nil)
    }
    
    // Helper function to configure a window as floating
    private func configureWindowAsFloating(_ window: NSWindow) {
        window.level = .floating // Make the window float above others
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary] // Visible on all spaces
        window.isMovableByWindowBackground = true // Allow dragging from any point
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
        WindowGroup {
            ContentView()
                .background(.ultraThinMaterial)
                .preferredColorScheme(.dark)
                .modelContainer(sharedModelContainer)
        }
        .windowStyle(.hiddenTitleBar) // Clean look without title bar
        .defaultSize(width: 800, height: 600) // Fixed size window
        
        // Adding commands to modify window behavior
        .commands {
            CommandGroup(replacing: .windowSize) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .windowArrangement) { }
        }
    }
}
