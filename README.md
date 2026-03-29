# MoviesApp

Aplicacion iOS para explorar peliculas populares, buscar titulos y guardar favoritos. Construida con **SwiftUI** y la API de [The Movie Database (TMDB)](https://www.themoviedb.org/).

## Screenshots

| Peliculas | Detalle | Favoritas | Busqueda |
|-----------|---------|-----------|----------|
| <img src="https://github.com/user-attachments/assets/58627829-a146-436a-8325-6b9a046a7780" width="250"/> | <img src="https://github.com/user-attachments/assets/d6db6aea-433d-4b5d-8efd-e6f075fcebeb" width="250"/> | <img src="https://github.com/user-attachments/assets/253da78f-b304-4607-adc8-bf8d23701ebc" width="250"/> | <img src="https://github.com/user-attachments/assets/93fac017-b1db-4de3-889b-0e4ea0025ef9" width="250"/> |

## Funcionalidades

- **Listado de peliculas populares** con poster, rating y scroll infinito (paginacion automatica)
- **Categorias** — Populares, Mejor valoradas, Proximamente y En cartelera
- **Pull-to-refresh** para recargar la categoria actual
- **Busqueda en tiempo real** con debounce (300ms) y minimo 3 caracteres
- **Detalle de pelicula** con poster, estrellas visuales, fecha de estreno, generos y sinopsis
- **Favoritas** en grid de 2 columnas con eliminacion directa, navegacion al detalle y ordenamiento (fecha, nombre, rating)
- **Persistencia local** de favoritos usando UserDefaults (sin llamadas extra a la API)
- **Cache de imagenes** con NSCache para carga eficiente de posters
- **Manejo de errores de red** con reintentos automaticos y boton de reintentar
- **Unit tests** con 20 tests cubriendo Repository, ViewModel, GenreMap y MovieCategory

## Arquitectura

El proyecto sigue el patron **MVVM + Repository**:

```
MoviesApp/
├── data/
│   ├── api/
│   │   └── MovieAPIService.swift        # Servicio HTTP con retry logic
│   ├── models/
│   │   ├── MovieDto.swift               # Modelo Movie (Codable, Hashable)
│   │   ├── MovieCategory.swift          # Enum de categorias con paths de API
│   │   ├── GenreMap.swift               # Mapeo de generos a nombres en español
│   │   └── TMDBAPI.swift                # Configuracion de endpoints TMDB
│   └── storage/
│       └── FavoritesStore.swift         # Persistencia en UserDefaults
├── domain/
│   └── repository/
│       ├── MovieRepository.swift        # Repositorio central (ObservableObject)
│       └── MovieRepositoryProtocol.swift
└── ui/
    ├── movieList/
    │   ├── MovieListView.swift          # Lista principal + searchable
    │   └── MovieListViewModel.swift     # Logica de busqueda y carga
    ├── detail/
    │   ├── MovieDetailView.swift        # Vista de detalle con toolbar
    │   └── MovieDetailViewModel.swift
    ├── favorites/
    │   └── FavoritesView.swift          # Grid de favoritas
    ├── MovieRowView.swift               # Celda del listado
    └── PosterImageView.swift            # Carga de imagenes con cache
```

### Flujo de datos

```
View → ViewModel → Repository → APIService / FavoritesStore
                       ↓
                 @Published (reactivo via Combine/SwiftUI)
```

- Los **ViewModels** son `@MainActor` y usan `@Published` para actualizar las vistas
- El **Repository** es `ObservableObject` compartido entre tabs
- Las **Favoritas** se observan directamente desde el Repository (single source of truth)

## Stack tecnologico

| Componente | Tecnologia |
|------------|------------|
| UI | SwiftUI |
| Arquitectura | MVVM + Repository |
| Networking | URLSession + async/await |
| Persistencia | UserDefaults + JSONEncoder |
| Cache de imagenes | NSCache |
| Testing | Swift Testing framework |
| API | TMDB API v3 |
| Minimo iOS | 17.0 |

## Requisitos

- Xcode 15+
- iOS 17.0+
- API Key de [TMDB](https://www.themoviedb.org/settings/api) (ya incluida en `Secrets.swift`)

## Como ejecutar

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/micacontreras/IosMoviesApp.git
   ```
2. Abrir `MoviesApp.xcodeproj` en Xcode
3. Seleccionar un simulador o dispositivo fisico
4. Ejecutar con `Cmd + R`

## Aprendizajes

Este proyecto fue creado como ejercicio de aprendizaje de desarrollo iOS, cubriendo:

- Navegacion con `NavigationStack` y `navigationDestination`
- Estado reactivo con `@StateObject`, `@ObservedObject` y `@Published`
- Networking asincrono con `async/await` y manejo de errores
- Busqueda con `.searchable` y `@Environment(\.isSearching)`
- Layouts con `LazyVGrid` y `ScrollView`
- Paginacion infinita con deteccion de scroll
- Persistencia local con `UserDefaults`
- Cache de imagenes custom reemplazando `AsyncImage`
- Unit testing con Swift Testing framework y mocks

## Licencia

Este proyecto es de uso educativo.
