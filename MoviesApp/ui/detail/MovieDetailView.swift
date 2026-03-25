import SwiftUI

struct MovieDetailView: View {
    @StateObject var vm: MovieDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                if let posterPath = vm.movie.posterPath {
                    AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                }

                Text(vm.movie.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if !vm.movie.releaseDate.isEmpty {
                    Text(vm.movie.releaseDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if vm.movie.voteAverage > 0 {
                    HStack(spacing: 4) {
                        let starRating = vm.movie.voteAverage / 2.0
                        ForEach(1...5, id: \.self) { index in
                            let fill = starRating - Double(index - 1)
                            Image(systemName: fill >= 1.0 ? "star.fill" : fill >= 0.5 ? "star.leadinghalf.filled" : "star")
                                .foregroundColor(.yellow)
                                .font(.body)
                        }
                        Text(String(format: "%.1f", vm.movie.voteAverage))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                let genres = GenreMap.genreNames(for: vm.movie.genreIds)
                if !genres.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(genres, id: \.self) { name in
                                Text(name)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.horizontal)
                    }
                }

                Text(vm.movie.overview)
                    .font(.body)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.toggleFavorite()
                } label: {
                    Image(systemName: vm.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

