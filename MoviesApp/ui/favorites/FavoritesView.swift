import SwiftUI

struct FavoritesView: View {
    @ObservedObject var repo: MovieRepository

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                if repo.favorites.isEmpty {
                    ContentUnavailableView(
                        "Sin favoritas",
                        systemImage: "heart.slash",
                        description: Text("Las películas que marques como favoritas aparecerán aquí.")
                    )
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(repo.favorites) { movie in
                            movieCard(movie)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favoritas")
        }
    }

    private func movieCard(_ movie: Movie) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                PosterImageView(url: movie.posterURL)
                    .aspectRatio(2/3, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    withAnimation {
                        repo.toggleFavorite(movie: movie)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .black.opacity(0.6))
                        .padding(6)
                }
            }

            Text(movie.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2, reservesSpace: true)

            Text(movie.overview)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3, reservesSpace: true)
        }
    }
}
