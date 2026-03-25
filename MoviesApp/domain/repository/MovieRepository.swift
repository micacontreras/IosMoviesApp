import Foundation

class MovieRepository: ObservableObject, MovieRepositoryProtocol {
    private let api: MovieAPIService
    private let favStore: FavoritesStore
    @Published private(set) var favorites: [Movie] = []  // <-- Published

    init(api: MovieAPIService, favStore: FavoritesStore) {
        self.api = api
        self.favStore = favStore
        self.favorites = favStore.loadFavorites()
    }

    func getPopular() async throws -> [Movie] {
        try await api.fetchPopular()
    }

    func search(query: String) async throws -> [Movie] {
        try await api.search(query: query)
    }

    func toggleFavorite(movie: Movie) {
        if let index = favorites.firstIndex(of: movie) {
            favorites.remove(at: index)
        } else {
            favorites.append(movie)
        }
        favStore.saveFavorites(favorites)
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favorites.contains(movie)
    }
}
