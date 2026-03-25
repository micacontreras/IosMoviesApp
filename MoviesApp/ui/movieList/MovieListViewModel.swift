import SwiftUI

@MainActor
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var loadError = false

    let repo: MovieRepositoryProtocol
    private var popularMovies: [Movie] = []
    private var searchTask: Task<Void, Never>?

    init(repo: MovieRepositoryProtocol) {
        self.repo = repo
    }

    func loadPopular() async {
        loadError = false
        isLoading = true
        defer { isLoading = false }
        do {
            popularMovies = try await repo.getPopular()
            if !isSearching {
                movies = popularMovies
            }
        } catch {
            print("Error: \(error)")
            loadError = true
        }
    }

    func onSearchActiveChanged(_ active: Bool) {
        isSearching = active
        if !active {
            searchTask?.cancel()
            query = ""
            movies = popularMovies
            hasSearched = false
        } else {
            movies = []
            hasSearched = false
        }
    }

    func onQueryChanged(_ newQuery: String) {
        searchTask?.cancel()
        hasSearched = false

        if newQuery.isEmpty || newQuery.count < 3 {
            movies = []
            return
        }

        isLoading = true
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            do {
                let results = try await repo.search(query: newQuery)
                guard !Task.isCancelled else { return }
                movies = results
                hasSearched = true
            } catch {
                if !Task.isCancelled {
                    print("Search error: \(error)")
                    hasSearched = true
                }
            }
            isLoading = false
        }
    }
}
