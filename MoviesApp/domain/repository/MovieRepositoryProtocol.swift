import Foundation

protocol MovieRepositoryProtocol {
    func getPopular() async throws -> [Movie]
    func search(query: String) async throws -> [Movie]
    func toggleFavorite(movie: Movie)
    func isFavorite(_ movie: Movie) -> Bool
}
