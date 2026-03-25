import Foundation

protocol MovieAPIService {
    func fetchMovies(category: MovieCategory, page: Int) async throws -> MovieListResponse
    func search(query: String) async throws -> [Movie]
}

struct TMDBAPIService: MovieAPIService {
    let api: TMDBAPI

    func fetchMovies(category: MovieCategory, page: Int = 1) async throws -> MovieListResponse {
        guard let url = api.makeURL(path: category.apiPath, query: [
            URLQueryItem(name: "page", value: String(page))
        ]) else { return MovieListResponse(results: [], page: 0, totalPages: 0) }
        return try await fetchWithRetry(url: url)
    }

    func search(query: String) async throws -> [Movie] {
        guard let url = api.makeURL(path: "/search/movie", query: [
            URLQueryItem(name: "query", value: query)
        ]) else { return [] }
        return try await fetchWithRetry(url: url).results
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }

    private func fetchWithRetry(url: URL, maxRetries: Int = 3) async throws -> MovieListResponse {
        var lastError: Error?
        for attempt in 0...maxRetries {
            if attempt > 0 {
                try await Task.sleep(for: .seconds(attempt))
            }
            guard !Task.isCancelled else { throw CancellationError() }
            do {
                let session = makeSession()
                var request = URLRequest(url: url)
                request.assumesHTTP3Capable = false
                let (data, _) = try await session.data(for: request)
                return try JSONDecoder().decode(MovieListResponse.self, from: data)
            } catch {
                lastError = error
                if Task.isCancelled { throw CancellationError() }
                print("Network attempt \(attempt + 1) failed: \(error.localizedDescription)")
            }
        }
        throw lastError ?? URLError(.unknown)
    }
}

struct MovieListResponse: Codable {
    let results: [Movie]
    let page: Int
    let totalPages: Int

    private enum CodingKeys: String, CodingKey {
        case results, page
        case totalPages = "total_pages"
    }
}
