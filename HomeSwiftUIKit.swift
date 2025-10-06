//
//  HomeSwiftUIKit.swift
//  Help2
//
//  Created by Pranav Khanna on 6/16/25.
//

import SwiftUI

struct HomeSwiftUIView: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Home Page")
                .font(.title)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

#Preview {
    HomeSwiftUIView()
}
