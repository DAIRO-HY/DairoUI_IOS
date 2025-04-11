//
//  ContentView.swift
//  DairoDFS
//
//  Created by zhoulq on 2025/04/09.
//  pushtest

import SwiftUI

@MainActor
class ContentViewModel123 : ObservableObject{
    @Published var state = 0
    func start(){
        Task {
            while true{
                await Task.sleep(1_000_000_000)
                await MainActor.run {
                    self.state += 1
                }
            }
        }
    }
}


public struct ContentView123: View {
    
    @ObservedObject var vm = ContentViewModel123()
    
    public init(){
    }
    
    public var body: some View {
        NavigationView {
            Text("Hello World!\(self.vm.state)")
            //            PhotoGridView()
        }.onAppear{
            self.vm.start()
        }
    }
}


#Preview {
    ContentView123()
}
