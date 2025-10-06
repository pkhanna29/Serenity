import SwiftUI

struct HomeViewPage: View {
    var body: some View {
         NavigationStack {
             ScrollView {
                 VStack(alignment: .leading, spacing: 24) {
                     
                     // App Title and Cloud Icon
                     HStack {
                         Text("Home")
                             .font(.largeTitle)
                             .fontWeight(.bold)
                         Spacer()
                         Image(systemName: "cloud.fill")
                             .foregroundColor(.teal)
                     }
                     .padding(.top)
                     
                     // Greeting + Log Button
                     VStack(alignment: .leading, spacing: 12) {
                         Text("How are you feeling today?")
                             .font(.title2)
                             .fontWeight(.medium)

                         NavigationLink(destination: EmotionLogView()) {
                             Text("Log")
                                 .fontWeight(.semibold)
                                 .frame(maxWidth: .infinity)
                                 .padding()
                                 .background(Color.orange)
                                 .foregroundColor(.white)
                                 .cornerRadius(12)
                         }
                               }
                    
                    // Daily Journal Card
                  //  NavigationLink(destination: JournalView()) {
                        HStack {
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.green)
                            Text("Daily Journal")
                                .font(.headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.2))
                        .cornerRadius(12)
                   // }
                    
                    // Tools Section
                    Text("Your Tools")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                      NavigationLink(destination: GratitudeView()) {
                            ToolButton(title: "Gratitude", icon: "book")
                       }
                        
                       NavigationLink(destination: AIView()) {
                            ToolButton(title: "AI Chat", icon: "message")
                        }
                        
                        NavigationLink(destination: HabitTracker()) {
                            ToolButton(title: "Habit Tracker", icon: "checklist")
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            .background(Color(.systemGray5))
        }
    }
}

struct ToolButton: View {
    var title: String
    var icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            Text(title)
                .font(.footnote)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(12)
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            HomeViewPage()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            GratitudeView()
                .tabItem {
                    Image(systemName: "heart.circle")
                    Text("Gratitude")
                }
            
            AIView()
                .tabItem {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("AI")
                }
        }
    }
}


#Preview {
    HomeViewPage()
}
