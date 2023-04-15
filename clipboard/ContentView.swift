//
//  ContentView.swift
//  clipboard
//
//  Created by Ayomikun Akintade on 09/09/2022.
//


import SwiftUI

class ClipBoardViewModel : ObservableObject {
    @Published var clipData:[ClipboardData] = []
    var did = 0
    
    
    func fetchClipboard() /*async*/ {
        
    }
    
    
    func addData(s: String, type: Int, i: Data){
        if let index = self.clipData.firstIndex(of: ClipboardData(text: s, type: type, image: i)) {
            self.clipData.remove(at: index)
        }
        self.clipData.insert(ClipboardData(text: s, type: type, image: i), at: 0)
        self.did += 1
    }
    
    
}

struct ClipboardData: Equatable, Hashable {
    var text: String
    var type: Int
    var image: Data
}


struct ContentView: View {
    @EnvironmentObject private var vm : ClipBoardViewModel
    @State private var search = ""
    @FocusState var isFocused : Bool
    var body: some View {
        VStack(alignment:.leading, spacing: 1) {
            HStack {
                VStack (alignment:.leading, spacing: 3){
                    Text("Clipboard")
                        .font(.system(size: 15))
                    Text("With ❤️ by Williams")
                        .font(.system(size: 9))
                        .foregroundColor(.green)
                }
                    .padding(8)
                Spacer()
                TextField("search...", text: $search)
                    .font(.system(size: 13.5))
                    .foregroundColor(.white)
                    .disableAutocorrection(true)
                    .focusable()
                    .focused($isFocused)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.accentColor.opacity(0.5), lineWidth: 4).opacity(isFocused ? 1 : 0).scaleEffect(isFocused ? 1 : 1.04))
                    .animation(isFocused ? .easeIn(duration: 0.2) : .easeOut(duration: 0.0), value: isFocused)
                    .onTapGesture {
                        isFocused = true
                    }
                Text("CLEAR")
                    .font(.system(size: 13))
                    .fontWeight(.bold)
                    .foregroundColor(.red)
                    .onTapGesture {
                        vm.clipData.removeAll()
                    }
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .padding(.horizontal)
                    .onTapGesture {
                        NSApplication.shared.terminate(nil)
                    }
            }
            .background(Color("555"))
            ScrollView(.vertical, showsIndicators: false){
                VStack {
                    if vm.clipData.count > 0 {
                        if !search.isEmpty {
                            ForEach(vm.clipData.filter { $0.text.contains(search) }, id: \.text){
                                data in
                                eachCopiedItem(data: data)
                                    .environmentObject(vm)
                            }
                        }
                        else {
                            ForEach(vm.clipData, id: \.self){
                                data in
                                eachCopiedItem(data: data)
                                    .environmentObject(vm)
                            }
                        }
                    }
                    else {
                        HStack {
                            Spacer()
                            Text("Nothing in Clipboard!")
                            Spacer()
                        }
                        
                    }
                }
                .padding()
            }
            .task {
                vm.fetchClipboard()
            }
            
            /*List(vm.clipData, id: \.text){ data in
                HStack {
                    Text("Hello My name is akintade ayomikun williams akintade and I am a")
                        .lineLimit(3)
                        .font(.system(size: 11))
                    Spacer()
                    Image(systemName: "doc.on.doc")
                }
                Divider()
                    .padding([.vertical], 7)
            }
            .task {
                vm.fetchClipboard()
            }*/
            
            
        }
        .frame(width: 350, height: 350)
        .background(.black)
    }
}

struct eachCopiedItem: View {
    @State var data: ClipboardData
    @State var copied = false
    @EnvironmentObject private var vm: ClipBoardViewModel
    var body: some View {
        HStack (alignment:.center){
            Image(systemName: "circle.fill")
                .font(.system(size: 5))
            if data.type == 0 {
                Text(data.text)
                    .lineLimit(3)
                    .font(.system(size: 12))
            }
            else if data.type == 1 {
                if let nsimage = NSImage(data: data.image) {
                    HStack {
                        Image(nsImage: nsimage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: nsimage.size.width > 200 ? 200 : nsimage.size.width, height: nsimage.size.height > 200 ? 200 : nsimage.size.height)
                        Spacer()
                    }
                }
            }
            Spacer()
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .foregroundColor(copied ? .green : .white)
                .font(copied ? .system(size: 13) : .system(size: 11))
                .onTapGesture {
                    NSPasteboard.general.clearContents()
                    if data.type == 0 {
                        NSPasteboard.general.setString(data.text, forType: .string)
                    }
                    else if data.type == 1 {
                        let type = NSPasteboard.PasteboardType.tiff
                        NSPasteboard.general.setData(data.image, forType: type)
                    }
                    withAnimation {
                        copied = true
                        //data.active = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        copied = false
                    }
                    // Read copied string
                    //NSPasteboard.general.string(forType: .string)
                }
            Image(systemName: /*data.active ? "checkmark" :*/ "multiply.circle")
                .foregroundColor(/*data.active ? .green :*/ .white)
                .font(.system(size: 11))
                .onTapGesture {
                    if let index = vm.clipData.firstIndex(of: ClipboardData(text: data.text, type: data.type, image: data.image)) {
                        vm.clipData.remove(at: index)
                    }
                    
                }
        }
        Divider()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
