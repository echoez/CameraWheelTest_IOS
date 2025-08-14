//
//  ContentView.swift
//  CameraWheelTest
//
//  Created by Michael Cadet on 8/13/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                CameraWheelView()
                    .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    ContentView()
}
