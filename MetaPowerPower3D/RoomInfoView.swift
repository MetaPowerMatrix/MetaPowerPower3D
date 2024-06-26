import SwiftUI

struct RoomInfoView: View {
    let room: PortalRoomInfo
    var body: some View {
        VStack(alignment: .leading) {
            Text(room.title)
                .font(.title2)
                .padding(.bottom, 4)
            Text(room.description)
                .font(.headline)
                .padding(.bottom, 12)
        }
    }
}

/// A view that displays a horizontal list of the video's year, rating, and duration.
struct InfoLineView: View {
    let year: String
    let rating: String
    let duration: String
    var body: some View {
        HStack {
            Text("\(year) | \(rating) | \(duration)")
                .font(.subheadline.weight(.medium))
        }
    }
}

/// A view that displays a comma-separated list of genres for a video.
struct GenreView: View {
    let genres: [String]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(genres, id: \.self) {
                Text($0)
                    .fixedSize()
                #if os(visionOS)
                    .font(.caption2.weight(.bold))
                #else
                    .font(.caption)
                #endif
                    .padding([.leading, .trailing], 4)
                    .padding([.top, .bottom], 4)
                    .background(RoundedRectangle(cornerRadius: 5).stroke())
                    .foregroundStyle(.secondary)
            }
            // Push the list to the leading edge.
            Spacer()
        }
    }
}

/// A view that displays a name of a role, followed by one or more people who hold the position.
struct RoleView: View {
    let role: String
    let people: [String]
    var body: some View {
        VStack(alignment: .leading) {
            Text(role)
            Text(people.formatted())
                .foregroundStyle(.secondary)
        }
    }
}
