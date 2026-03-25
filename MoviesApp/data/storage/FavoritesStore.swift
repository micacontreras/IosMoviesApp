import Foundation

protocol FavoritesStore {
    func loadFavorites() -> [Movie]
    func saveFavorites(_ movies: [Movie])
}

class UserDefaultsFavoritesStore: FavoritesStore {
    private let key = "favorite_movies"

    func loadFavorites() -> [Movie] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Movie].self, from: data)) ?? []
    }

    func saveFavorites(_ movies: [Movie]) {
        if let data = try? JSONEncoder().encode(movies) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
