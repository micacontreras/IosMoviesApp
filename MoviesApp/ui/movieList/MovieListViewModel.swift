import SwiftUI

@MainActor
class MovieListViewModel: ObservableObject {
    @Published var movies: [Movie] = []
    @Published var query: String = ""
    @Published var isLoading = false
    @Published var isSearching = false
    @Published var hasSearched = false
    @Published var loadError = false
    @Published var selectedCategory: MovieCategory = .popular
    @Published var isLoadingMore = false

    let repo: MovieRepositoryProtocol
    private var cachedMovies: [Movie] = []
    private var searchTask: Task<Void, Never>?
    private var currentPage = 0
    private var totalPages = 1

    init(repo: MovieRepositoryProtocol) {
        self.repo = repo
    }

    func loadMovies() async {
        currentPage = 0
        totalPages = 1
        cachedMovies = []
        await loadNextPage()
    }

    func loadNextPageIfNeeded(currentMovie: Movie) async {
        guard !isSearching,
              !isLoadingMore,
              currentPage < totalPages,
              let index = movies.firstIndex(of: currentMovie),
              index >= movies.count - 3 else { return }
        await loadNextPage()
    }

    private func loadNextPage() async {
        let isFirstPage = currentPage == 0
        if isFirstPage {
            loadError = false
            isLoading = true
        }
        isLoadingMore = true
        defer {
            if isFirstPage { isLoading = false }
            isLoadingMore = false
        }

        do {
            let response = try await repo.getMovies(category: selectedCategory, page: currentPage + 1)
            currentPage = response.page
            totalPages = response.totalPages
            let newMovies = response.results.filter { movie in
                !cachedMovies.contains { $0.id == movie.id }
            }
            cachedMovies.append(contentsOf: newMovies)
            if !isSearching {
                movies = cachedMovies
            }
        } catch {
            print("Error: \(error)")
            if isFirstPage { loadError = true }
        }
    }

    func onCategoryChanged(_ category: MovieCategory) {
        selectedCategory = category
        Task { await loadMovies() }
    }

    func onSearchActiveChanged(_ active: Bool) {
        isSearching = active
        if !active {
            searchTask?.cancel()
            query = ""
            movies = cachedMovies
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
