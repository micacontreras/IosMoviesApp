import Foundation
import Testing
@testable import MoviesApp

// MARK: - Mocks

struct MockAPIService: MovieAPIService {
    var moviesToReturn: [Movie] = []
    var pageCount: Int = 1
    var shouldFail = false

    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieListResponse {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return MovieListResponse(results: moviesToReturn, page: page, totalPages: pageCount)
    }

    func search(query: String) async throws -> [Movie] {
        if shouldFail { throw URLError(.notConnectedToInternet) }
        return moviesToReturn.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
}

class MockFavoritesStore: FavoritesStore {
    var stored: [Movie] = []

    func loadFavorites() -> [Movie] { stored }

    func saveFavorites(_ movies: [Movie]) { stored = movies }
}

// MARK: - Test Data

extension Movie {
    static let sample1 = Movie(
        id: 1,
        title: "Zootopia 2",
        posterPath: "/zoo.jpg",
        overview: "A sequel to Zootopia",
        releaseDate: "2025-11-26",
        voteAverage: 7.5,
        genreIds: [16, 35, 12]
    )

    static let sample2 = Movie(
        id: 2,
        title: "The Dark Knight",
        posterPath: "/dk.jpg",
        overview: "Batman fights the Joker",
        releaseDate: "2008-07-18",
        voteAverage: 9.0,
        genreIds: [28, 80, 18]
    )

    static let sample3 = Movie(
        id: 3,
        title: "Avengers",
        posterPath: "/av.jpg",
        overview: "Heroes assemble",
        releaseDate: "2012-05-04",
        voteAverage: 8.0,
        genreIds: [28, 12, 878]
    )
}

// MARK: - GenreMap Tests

@Suite("GenreMap")
struct GenreMapTests {
    @Test func returnsCorrectNamesForKnownIds() {
        let names = GenreMap.genreNames(for: [28, 35, 18])
        #expect(names == ["Acción", "Comedia", "Drama"])
    }

    @Test func returnsEmptyForNil() {
        let names = GenreMap.genreNames(for: nil)
        #expect(names.isEmpty)
    }

    @Test func skipsUnknownIds() {
        let names = GenreMap.genreNames(for: [28, 99999])
        #expect(names == ["Acción"])
    }

    @Test func returnsEmptyForEmptyArray() {
        let names = GenreMap.genreNames(for: [])
        #expect(names.isEmpty)
    }
}

// MARK: - MovieRepository Tests

@Suite("MovieRepository")
struct MovieRepositoryTests {
    @Test func loadsFavoritesFromStoreOnInit() {
        let store = MockFavoritesStore()
        store.stored = [.sample1]
        let repo = MovieRepository(api: MockAPIService(), favStore: store)
        #expect(repo.favorites.count == 1)
        #expect(repo.favorites.first?.id == 1)
    }

    @Test func toggleFavoriteAddsMovie() {
        let store = MockFavoritesStore()
        let repo = MovieRepository(api: MockAPIService(), favStore: store)
        repo.toggleFavorite(movie: .sample1)
        #expect(repo.favorites.count == 1)
        #expect(repo.isFavorite(.sample1))
        #expect(store.stored.count == 1)
    }

    @Test func toggleFavoriteRemovesMovie() {
        let store = MockFavoritesStore()
        store.stored = [.sample1]
        let repo = MovieRepository(api: MockAPIService(), favStore: store)
        repo.toggleFavorite(movie: .sample1)
        #expect(repo.favorites.isEmpty)
        #expect(!repo.isFavorite(.sample1))
        #expect(store.stored.isEmpty)
    }

    @Test func isFavoriteReturnsFalseForNonFavorite() {
        let repo = MovieRepository(api: MockAPIService(), favStore: MockFavoritesStore())
        #expect(!repo.isFavorite(.sample1))
    }

    @Test func getMoviesReturnsAPIResults() async throws {
        let api = MockAPIService(moviesToReturn: [.sample1, .sample2], pageCount: 1)
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let response = try await repo.getMovies(category: .popular, page: 1)
        #expect(response.results.count == 2)
        #expect(response.page == 1)
    }

    @Test func searchReturnsFilteredResults() async throws {
        let api = MockAPIService(moviesToReturn: [.sample1, .sample2])
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let results = try await repo.search(query: "Zoo")
        #expect(results.count == 1)
        #expect(results.first?.title == "Zootopia 2")
    }
}

// MARK: - MovieListViewModel Tests

@Suite("MovieListViewModel")
struct MovieListViewModelTests {
    @Test @MainActor func loadMoviesFetchesFirstPage() async {
        let api = MockAPIService(moviesToReturn: [.sample1, .sample2], pageCount: 3)
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let vm = MovieListViewModel(repo: repo)

        await vm.loadMovies()

        #expect(vm.movies.count == 2)
        #expect(!vm.isLoading)
        #expect(!vm.loadError)
    }

    @Test @MainActor func loadMoviesSetsErrorOnFailure() async {
        let api = MockAPIService(shouldFail: true)
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let vm = MovieListViewModel(repo: repo)

        await vm.loadMovies()

        #expect(vm.movies.isEmpty)
        #expect(vm.loadError)
    }

    @Test @MainActor func onCategoryChangedReloadsMovies() async {
        let api = MockAPIService(moviesToReturn: [.sample1], pageCount: 1)
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let vm = MovieListViewModel(repo: repo)

        await vm.loadMovies()
        #expect(vm.selectedCategory == .popular)

        vm.onCategoryChanged(.topRated)
        #expect(vm.selectedCategory == .topRated)

        // Wait for the Task inside onCategoryChanged to complete
        try? await Task.sleep(for: .milliseconds(100))
        #expect(vm.movies.count == 1)
    }

    @Test @MainActor func onSearchActiveChangedClearsMovies() async {
        let api = MockAPIService(moviesToReturn: [.sample1, .sample2], pageCount: 1)
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let vm = MovieListViewModel(repo: repo)

        await vm.loadMovies()
        #expect(vm.movies.count == 2)

        vm.onSearchActiveChanged(true)
        #expect(vm.movies.isEmpty)
        #expect(vm.isSearching)
    }

    @Test @MainActor func onSearchActiveChangedRestoresMovies() async {
        let api = MockAPIService(moviesToReturn: [.sample1, .sample2], pageCount: 1)
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let vm = MovieListViewModel(repo: repo)

        await vm.loadMovies()
        vm.onSearchActiveChanged(true)
        vm.onSearchActiveChanged(false)

        #expect(vm.movies.count == 2)
        #expect(!vm.isSearching)
    }

    @Test @MainActor func onQueryChangedIgnoresShortQueries() async {
        let api = MockAPIService(moviesToReturn: [.sample1])
        let repo = MovieRepository(api: api, favStore: MockFavoritesStore())
        let vm = MovieListViewModel(repo: repo)

        vm.onQueryChanged("ab")
        #expect(vm.movies.isEmpty)
    }
}

// MARK: - MovieCategory Tests

@Suite("MovieCategory")
struct MovieCategoryTests {
    @Test func allCasesHaveAPIPath() {
        for category in MovieCategory.allCases {
            #expect(category.apiPath.hasPrefix("/movie/"))
        }
    }

    @Test func allCasesHaveDisplayName() {
        for category in MovieCategory.allCases {
            #expect(!category.displayName.isEmpty)
        }
    }

    @Test func popularHasCorrectPath() {
        #expect(MovieCategory.popular.apiPath == "/movie/popular")
    }

    @Test func topRatedHasCorrectPath() {
        #expect(MovieCategory.topRated.apiPath == "/movie/top_rated")
    }
}
