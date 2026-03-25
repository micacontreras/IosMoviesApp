import SwiftUI

struct MovieListView: View {
    @StateObject private var vm: MovieListViewModel
    @Environment(\.isSearching) private var isSearching

    init(vm: MovieListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            MovieListContent(vm: vm)
                .navigationTitle("Películas")
                .searchable(text: $vm.query, prompt: "Buscar películas...")
                .task { await vm.loadPopular() }
                .navigationDestination(for: Movie.self) { movie in
                    MovieDetailView(vm: MovieDetailViewModel(movie: movie, repo: vm.repo))
                }
        }
    }
}

private struct MovieListContent: View {
    @ObservedObject var vm: MovieListViewModel
    @Environment(\.isSearching) private var isSearching

    var body: some View {
        List {
            if vm.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .listRowSeparator(.hidden)
            }

            ForEach(vm.movies) { movie in
                NavigationLink(value: movie) {
                    MovieRowView(movie: movie)
                }
            }
        }
        .listStyle(.plain)
        .overlay {
            if !vm.isLoading && vm.movies.isEmpty && vm.hasSearched {
                ContentUnavailableView.search(text: vm.query)
            } else if vm.loadError && !vm.isLoading && vm.movies.isEmpty {
                ContentUnavailableView {
                    Label("Error de conexión", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("No se pudo conectar al servidor. Verificá tu conexión a internet.")
                } actions: {
                    Button("Reintentar") {
                        Task { await vm.loadPopular() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .onChange(of: isSearching) { _, active in
            vm.onSearchActiveChanged(active)
        }
        .onChange(of: vm.query) { _, newValue in
            vm.onQueryChanged(newValue)
        }
    }
}

#Preview {
    
}
