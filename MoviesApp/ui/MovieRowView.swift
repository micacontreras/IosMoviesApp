import SwiftUI

struct MovieRowView: View {
    let movie: Movie

    var body: some View {
        Text(movie.title)
    }
}
