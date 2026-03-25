import Foundation

enum MovieCategory: String, CaseIterable, Identifiable {
    case popular
    case topRated
    case upcoming
    case nowPlaying

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .popular:    return "Populares"
        case .topRated:   return "Mejor valoradas"
        case .upcoming:   return "Próximamente"
        case .nowPlaying: return "En cartelera"
        }
    }

    var apiPath: String {
        switch self {
        case .popular:    return "/movie/popular"
        case .topRated:   return "/movie/top_rated"
        case .upcoming:   return "/movie/upcoming"
        case .nowPlaying: return "/movie/now_playing"
        }
    }
}
