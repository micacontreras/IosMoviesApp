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

                if vm.movie.voteAverage > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", vm.movie.voteAverage))
                            .font(.headline)
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

