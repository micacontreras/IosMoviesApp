import Foundation

struct Movie: Identifiable, Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let posterPath: String?
    let overview: String
    let releaseDate: String
    let voteAverage: Double

    var posterURL: URL? {
        guard let p = posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(p)")
    }

    private enum CodingKeys: String, CodingKey {
        case id, title
        case posterPath = "poster_path"
        case overview
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}
