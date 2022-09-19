//
//  clipboardApp.swift
//  clipboard
//
//  Created by Ayomikun Akintade on 09/09/2022.
//

import SwiftUI

@main
struct clipboardApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    //@StateObject var vm = ClipBoardViewModel()
    var body: some Scene {
        Settings {
            AnyView(EmptyView())
        }
        /*WindowGroup {
            ContentView()
                .environmentObject(vm)
        }*/
    }
}

extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    
    private var statusItems: NSStatusItem!
    private var popover: NSPopover!
    var timer: Timer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0
    var vm = ClipBoardViewModel()
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {

        statusItems = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let statusButtton = statusItems.button {
            statusButtton.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard")
            statusButtton.action = #selector(clipboardClicked)
        }
        
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 350, height: 350)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView().environmentObject(vm))
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
                    if self.lastChangeCount != self.pasteboard.changeCount {
                        self.lastChangeCount = self.pasteboard.changeCount
                        NotificationCenter.default.post(name: .NSPasteboardDidChange, object: self.pasteboard)
                    }
                }
        NotificationCenter.default.addObserver(self, selector: #selector(onPasteboardChanged), name: .NSPasteboardDidChange, object: nil)
        
    }
    
    @objc func clipboardClicked() {
        
        //update data Task {}
        
        
        if let button = statusItems.button {
            if popover.isShown {
                self.popover.performClose(nil)
            } else {
                self.popover.show(relativeTo: button.visibleRect, of: button, preferredEdge: NSRectEdge.minY)
            }
            
        }
        
    }
    
    @objc
        func onPasteboardChanged(_ notification: Notification) {
            guard let pb = notification.object as? NSPasteboard else { return }
            guard let items = pb.pasteboardItems else { return }
            guard let item = items.first?.string(forType: .string) else { return }
            
            //guard let imgData = pb.data(forType: type) else { return }
            
            vm.addData(s: item, type: 0)
            //print("New item in pasteboard: '\(item)'")
            
            
        }
    
}
