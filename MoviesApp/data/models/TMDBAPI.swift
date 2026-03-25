import Foundation

struct TMDBAPI {
    let apiKey: String
    let baseURL = "https://api.themoviedb.org/3"

    func makeURL(path: String, query: [URLQueryItem] = []) -> URL? {
        var components = URLComponents(string: baseURL + path)
        var items = query
        items.append(URLQueryItem(name: "api_key", value: apiKey))
        components?.queryItems = items
        return components?.url
    }
}
