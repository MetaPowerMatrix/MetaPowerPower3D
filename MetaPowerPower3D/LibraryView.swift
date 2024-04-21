import SwiftUI

struct LibraryView: View {
    @Environment(\.gameInfo) private var game
    @StateObject private var gameTownModel = GameTownModel()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: verticalPadding) {
                // Displays a horizontally scrolling list of Featured videos.
                RoomListView(title: "热门密室",
                              rooms: gameTownModel.rooms,
                              cardStyle: .full,
                             cardSpacing: horizontalSpacing
                ).withGame(game)
                
            }
            .onAppear {
                gameTownModel.fetchMishiRooms()
            }
            .padding([.top, .bottom], verticalPadding)
            
        }
    }

    // MARK: - Platform-specific metrics.
    
    /// The vertical padding between views.
    var verticalPadding: Double {
        30
    }
    
    var outerPadding: Double {
        30
    }
    
    var horizontalSpacing: Double {
        30
    }
    
    var logoHeight: Double {
        34
    }
}

#Preview {
    LibraryView()
}
