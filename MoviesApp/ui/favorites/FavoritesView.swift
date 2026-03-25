import SwiftUI

enum FavoriteSortOption: String, CaseIterable {
    case dateAdded = "Fecha agregada"
    case name = "Nombre"
    case rating = "Valoración"
}

struct FavoritesView: View {
    @ObservedObject var repo: MovieRepository
    @State private var sortOption: FavoriteSortOption = .dateAdded

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    private var sortedFavorites: [Movie] {
        switch sortOption {
        case .dateAdded:
            return repo.favorites
        case .name:
            return repo.favorites.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .rating:
            return repo.favorites.sorted { $0.voteAverage > $1.voteAverage }
        }
    }

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
                        ForEach(sortedFavorites) { movie in
                            NavigationLink(value: movie) {
                                movieCard(movie)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Favoritas")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(FavoriteSortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .navigationDestination(for: Movie.self) { movie in
                MovieDetailView(vm: MovieDetailViewModel(movie: movie, repo: repo))
            }
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
