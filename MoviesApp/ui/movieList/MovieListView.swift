import SwiftUI

struct MovieListView: View {
    @StateObject private var vm: MovieListViewModel

    init(vm: MovieListViewModel) {
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        NavigationStack {
            MovieListContent(vm: vm)
                .navigationTitle("Películas")
                .searchable(text: $vm.query, prompt: "Buscar películas...")
                .task { await vm.loadMovies() }
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
        VStack(spacing: 0) {
            if !isSearching {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(MovieCategory.allCases) { category in
                            Button {
                                vm.onCategoryChanged(category)
                            } label: {
                                Text(category.displayName)
                                    .font(.subheadline)
                                    .fontWeight(vm.selectedCategory == category ? .bold : .regular)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(vm.selectedCategory == category ? Color.accentColor : Color.gray.opacity(0.2))
                                    .foregroundColor(vm.selectedCategory == category ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
            }

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
                    .onAppear {
                        Task { await vm.loadNextPageIfNeeded(currentMovie: movie) }
                    }
                }

                if vm.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .refreshable {
                await vm.loadMovies()
            }
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
                            Task { await vm.loadMovies() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
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
