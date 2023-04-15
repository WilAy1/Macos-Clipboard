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
        let popoverWindow = self.popover.contentViewController?.view.window as? NSWindow
        popoverWindow?.parent?.removeChildWindow(popoverWindow!)
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
            if let item = items.first?.string(forType: .string) {
                vm.addData(s: item, type: 0, i: Data())
            }
            
            if let pngData = items.first?.data(forType: .png) {
                vm.addData(s: "is:image", type: 1, i: pngData)
            } else if let tiffData = items.first?.data(forType: .tiff) {
                vm.addData(s: "is:image", type: 1, i: tiffData)
            } else if let fcData = items.first?.data(forType: .fileContents), let image = NSImage(data: fcData) {
                guard let jpgData = jpegDataFrom(image: image) as? Data else { return }
                vm.addData(s: "is:image", type: 1, i: jpgData)
            }
            
            
            /*if let data = items.first?.data(forType: kUTTypeFileURL as NSPasteboard.PasteboardType),
               let str =  String(data: data, encoding: .utf8),
               let url = URL(string: str),
               let image = NSImage(contentsOf: url) {
                print("a")
                //imageView.image = image
            }*/
            //if let imgData = items.first?.data(forType: .URL) {
            //    print("a")
            //    vm.addData(s: "", type: 1, i: imgData)
            //}
            //print("New item in pasteboard: '\(item)'")
            
            
        }
    
}
func jpegDataFrom(image:NSImage) -> Data {
    let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
    let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
    let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
    return jpegData
}
