import Foundation

protocol MovieRepositoryProtocol {
    func getMovies(category: MovieCategory, page: Int) async throws -> MovieListResponse
    func search(query: String) async throws -> [Movie]
    func toggleFavorite(movie: Movie)
    func isFavorite(_ movie: Movie) -> Bool
}
