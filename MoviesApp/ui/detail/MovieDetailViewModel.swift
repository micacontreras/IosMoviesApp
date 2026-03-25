import SwiftUI

@MainActor
class MovieDetailViewModel: ObservableObject {
    @Published var movie: Movie
    let repo: MovieRepositoryProtocol

    init(movie: Movie, repo: MovieRepositoryProtocol) {
        self.movie = movie
        self.repo = repo
    }

    var isFavorite: Bool {
        repo.isFavorite(movie)
    }

    func toggleFavorite() {
        repo.toggleFavorite(movie: movie)
        objectWillChange.send()
    }
}
