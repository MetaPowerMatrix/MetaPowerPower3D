/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A list of video cards.
*/

import SwiftUI

/// A view the presents a horizontally scrollable list of video cards.
struct RoomListView: View {
    @Environment(\.gameInfo) private var game
    @Environment(\.openWindow) private var openWindow

    typealias SelectionAction = (PortalRoomInfo) -> Void

    private let title: String?
    private let rooms: [PortalRoomInfo]

    private let cardStyle: VideoCardStyle
    private let cardSpacing: Double

    private let selectionAction: SelectionAction?
    
    init(title: String? = nil, rooms: [PortalRoomInfo], cardStyle: VideoCardStyle, cardSpacing: Double, selectionAction: SelectionAction? = nil) {
        self.title = title
        self.rooms = rooms
        self.cardStyle = cardStyle
        self.cardSpacing = cardSpacing
        self.selectionAction = selectionAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            titleView
                .padding(.leading, margins)
                .padding(.bottom, 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: cardSpacing) {
                    ForEach(rooms, id: \.room_id) { room in
                        RoomCardView(room: room, style: cardStyle)
                            .onTapGesture {
                                game.roomInfo = room
                                game.gameState.gameLevel = 0
                                game.gameState.totalScenes = 2
                                game.gameState.scene = room.cover
                                openWindow(id: "game_scene")
                            }
                    }
                }
                .buttonStyle(buttonStyle)
                // In tvOS, add vertical padding to accommodate card resizing.
                .padding([.top, .bottom], 0)
                .padding([.leading, .trailing], margins)
            }
        }
    }
    
    @ViewBuilder
    var titleView: some View {
        if let title {
            Text(title)
            #if os(visionOS)
                .font(cardStyle == .full ? .largeTitle : .title)
            #elseif os(tvOS)
                .font(cardStyle == .full ? .largeTitle.weight(.semibold) : .title2)
            #else
                .font(cardStyle == .full ? .title2.bold() : .title3.bold())
            #endif
            
        }
    }
    
    var buttonStyle: some PrimitiveButtonStyle {
        #if os(tvOS)
        .card
        #else
        .plain
        #endif
    }
    
    var margins: Double {
        30
    }
}
