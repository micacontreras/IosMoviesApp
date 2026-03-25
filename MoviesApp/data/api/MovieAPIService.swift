import Foundation

protocol MovieAPIService {
    func fetchPopular() async throws -> [Movie]
    func search(query: String) async throws -> [Movie]
}

struct TMDBAPIService: MovieAPIService {
    let api: TMDBAPI

    func fetchPopular() async throws -> [Movie] {
        guard let url = api.makeURL(path: "/movie/popular") else { return [] }
        return try await fetchWithRetry(url: url)
    }

    func search(query: String) async throws -> [Movie] {
        guard let url = api.makeURL(path: "/search/movie", query: [
            URLQueryItem(name: "query", value: query)
        ]) else { return [] }
        return try await fetchWithRetry(url: url)
    }

    private func makeSession() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }

    private func fetchWithRetry(url: URL, maxRetries: Int = 3) async throws -> [Movie] {
        var lastError: Error?
        for attempt in 0...maxRetries {
            if attempt > 0 {
                // Increase delay between retries: 1s, 2s, 3s
                try await Task.sleep(for: .seconds(attempt))
            }
            guard !Task.isCancelled else { throw CancellationError() }
            do {
                // Create a fresh session per attempt to avoid reusing broken QUIC connections
                let session = makeSession()
                var request = URLRequest(url: url)
                request.assumesHTTP3Capable = false
                let (data, _) = try await session.data(for: request)
                return try JSONDecoder().decode(MovieListResponse.self, from: data).results
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
}
