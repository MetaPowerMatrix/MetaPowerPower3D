/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A view that represents a video in the library.
*/
import SwiftUI

/// Constants that represent the supported styles for video cards.
enum VideoCardStyle {
    
    /// A full video card style.
    ///
    /// This style presents a poster image on top and information about the video
    /// below, including video description and genres.
    case full

    /// A style for cards in the Up Next list.
    ///
    /// This style presents a medium-sized poster image on top and a title string below.
    case upNext
    
    /// A compact video card style.
    ///
    /// This style presents a compact-sized poster image on top and a title string below.
    case compact
    
    var cornerRadius: Double {
        switch self {
        case .full:
            #if os(tvOS)
            12.0
            #else
            20.0
            #endif
            
        case .upNext: 12.0
        case .compact: 10.0
        }
    }

}

/// A view that represents a video in the library.
///
/// A user can select a video card to view the video details.
struct RoomCardView: View {
    
    let room: PortalRoomInfo
    let style: VideoCardStyle
    let cornerRadius = 20.0
    
    /// Creates a video card view with a video and an optional style.
    ///
    /// The default style is `.full`.
    init(room: PortalRoomInfo, style: VideoCardStyle = .full) {
        self.room = room
        self.style = style
    }
    
    var image: some View {
        AsyncImage(url: URL(string: room.cover))
            .aspectRatio(contentMode: .fill)
            .eraseToAnyView()
//            .border(Color.black, width: 1)
//            .scaledToFill()
    }

    var body: some View {
        switch style {
        case .compact:
            posterCard
                .frame(width: 200)
        case .upNext:
            posterCard
                .frame(width: 360)
        case .full:
            VStack {
                image
                VStack(alignment: .leading) {
                    Text(room.title)
                        .font(.title)
                    Text(room.description).lineLimit(4)
                }
                .padding(20)
            }
            .background(.thinMaterial)
            .frame(width: 395)
            .shadow(radius: 5)
            .hoverEffect()
            .cornerRadius(style.cornerRadius)
        }
    }
    
    @ViewBuilder
    var posterCard: some View {
        VStack {
            image
                .cornerRadius(style.cornerRadius)
            Text(room.title)
                .font(.title3)
                .lineLimit(1)
        }
        .hoverEffect()
    }
}
