 # ☀️ WeatherL - iOS Weather Application

Modern iOS weather application built with SwiftUI, featuring real-time weather data, favorites management, and intelligent analytics.

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue.svg)

## 📱 Features

- ✅ **Real-time Weather Data** - Current conditions using Tomorrow.io API
- ✅ **7-Day Forecast** - Weekly weather predictions with detailed information
- ✅ **Hourly Forecast** - 24-hour weather breakdown
- ✅ **Favorites Management** - Save and quickly access your favorite cities
- ✅ **Analytics Dashboard**
  - Temperature trends visualization with Swift Charts
  - Weekly statistics (average, max, min)
  - Multi-city comparisons
  - Intelligent weather recommendations
- ✅ **Air Quality Index** - Real-time air quality monitoring
- ✅ **Location Services** - Automatic weather for current GPS location
- ✅ **Unit Toggle** - Switch between Celsius and Fahrenheit
- ✅ **Smooth Animations** - Professional UI/UX with fluid transitions

## 🛠️ Technologies

- **SwiftUI** - Modern declarative UI framework
- **Swift Charts** - Native data visualization
- **Async/Await** - Modern concurrency model
- **MVVM Architecture** - Clean, maintainable code organization
- **Tomorrow.io API** - Professional weather data provider
- **CoreLocation** - GPS integration for location-based weather

## 📋 Requirements

- iOS 17.0 or later
- Xcode 15.0 or later
- Swift 5.9 or later
- Tomorrow.io API Key (free tier available)

## 🚀 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/lalolop123/weatherL1.git
cd weatherL1
```

2. **Set up API Key:**
   - Rename `Services/Config.example.swift` to `Services/Config.swift`
   - Get your free API key from [Tomorrow.io](https://www.tomorrow.io/)
   - Replace `TU_API_KEY_AQUI` with your actual API key in `Config.swift`




## 🏗️ Project Structure
```
Weather L/
├── Models/              # Data models (Weather, Statistics, Forecasts)
├── ViewModels/          # Business logic layer
│   ├── WeatherViewModel.swift
│   └── StatisticsViewModel.swift
├── Views/              # SwiftUI views
│   ├── ContentView.swift
│   ├── StatisticsView.swift
│   ├── FavoritesView.swift
│   └── Components/     # Reusable UI components
├── Services/           # External services
│   ├── WeatherService.swift
│   ├── GeocodeService.swift
│   └── LocationManager.swift
└── Helpers/            # Utility functions and extensions
```

## 📊 Key Features Breakdown

### Weather Dashboard
- Dynamic background based on weather conditions
- Expandable weather detail cards
- Real-time updates with pull-to-refresh
- Temperature, humidity, wind speed, UV index

### Analytics View
- Interactive temperature charts
- Weekly weather statistics
- City comparison tool
- Smart recommendations (clothing, activities, health)

### Favorites System
- Quick access to saved cities
- Swipe to delete functionality
- Persistent storage using UserDefaults

## 🎓 Educational Purpose

This project was developed as part of the Software Development Engineering program at **Universidad Tecmilenio** (6th Semester), demonstrating:

- iOS native app development with SwiftUI
- RESTful API integration
- Data visualization techniques
- Clean architecture principles (MVVM)
- Asynchronous programming
- Location services implementation

## 👨‍💻 Developer

**Eduardo Lopez** (Lalo)  
Software Development Engineering Student  
Universidad Tecmilenio

## 📄 License

This project is for educational purposes.

## 🙏 Acknowledgments

- Weather data provided by [Tomorrow.io](https://www.tomorrow.io/)
- Icons by SF Symbols
- Charts powered by Swift Charts framework

