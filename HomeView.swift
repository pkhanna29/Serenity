import SwiftUI
//import UIKit
struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                // Header
                VStack {
                    Text("Welcome to Serenity")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Image(systemName: "lightbulb.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.bottom, 20)
                }
                
                // Main Content
                VStack(spacing: 20) {
                    Text("Discover resources to improve your well-being")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Text("Explore articles, exercises, and more to support your journey towards personal growth.")
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color(UIColor.systemGray5))
                )
                .padding(.horizontal)
                
                // Custom Button
                NavigationLink(destination: HomeViewPage()) {
                    Text("Get Started")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.top, 10)
                
                // Footer
                Text("Reminder this is NOT for Emergencies, if in need of help, call 911 or 988")
                    .padding(30)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.red)
                    .font(.system(size: 12))
                    .bold()
                Text("© 2024 Serenity")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            .padding()
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // optional
        .edgesIgnoringSafeArea(.all)
    }
}



struct DetailView: View {
    var body: some View {
        VStack {
            Text("Welcome to My App!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            Text("In this application, you will have access to an AI chatbot, surveys, and more!")
                .padding(.bottom, 50)
            
            Text("Simply click on one of the bottom tabs to get started! This app is purely anonymous and none of your results will be shared, providing a safe space to take some time for yourself.")
                .multilineTextAlignment(.center)
                .font(.caption)
                .padding()
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeView()
}
