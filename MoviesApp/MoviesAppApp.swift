import SwiftUI

@main
struct MoviesAppApp: App {
    @StateObject private var repo: MovieRepository

    init() {
        let apiService = TMDBAPIService(api: TMDBAPI(apiKey: Secrets.tmdbAPIKey))
        let favStore = UserDefaultsFavoritesStore()
        _repo = StateObject(wrappedValue: MovieRepository(api: apiService, favStore: favStore))
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                MovieListView(vm: MovieListViewModel(repo: repo))
                    .tabItem {
                        Label("Películas", systemImage: "film")
                    }

                FavoritesView(repo: repo)
                    .tabItem {
                        Label("Favoritas", systemImage: "heart")
                    }
            }
        }
    }
}
