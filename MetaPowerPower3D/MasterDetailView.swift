//
//  MasterDetailView.swift
//  MetaPowerPower3D
//
//  Created by 石勇 on 2024/4/20.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct MasterDetailView: View {
    @State var showSidebar: NavigationSplitViewVisibility = .doubleColumn
    @StateObject private var gameTownModel = GameTownModel()
    @State var selectedRoom: PortalRoomInfo?
    
    var body: some View {
        NavigationSplitView(columnVisibility: $showSidebar) {
            List {
                ForEach(gameTownModel.rooms, id: \.room_id) { room in
                    Button {
                        selectedRoom = room
                    } label: {
                        Text(room.title)
                    }
                }
            }
            .navigationTitle("热门密室")
            .onAppear {
                gameTownModel.fetchMishiRooms()
            }
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        if showSidebar == .doubleColumn {
                            showSidebar = .detailOnly
                        } else {
                            showSidebar = .doubleColumn
                        }
                    }) {
                        Text(showSidebar == .doubleColumn ? "Hide" : "Show")
                    }
                }
            }
            
        } detail: {
            if let selectedRoom {
                GameSceneView().withGame(PortalRoom())
            }
        }
    }
}

#Preview {
    MasterDetailView()
}
