//
//  AccessGrad.swift
//  Help2
//
//  Created by Pranav Khanna on 6/16/25.
//
import SwiftUI

struct AccessGrad: View {
    @State private var gratitudeEntries: [String] = []

    var body: some View {
        VStack {
            List(gratitudeEntries, id: \.self) { entry in
                Text(entry)
            }
            .onAppear {
                NetworkManager.shared.fetchGratitudeEntries { entries in
                    DispatchQueue.main.async {
                        self.gratitudeEntries = entries
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // optional
        .edgesIgnoringSafeArea(.all)
    }
    
}

#Preview {
    AccessGrad()
}
