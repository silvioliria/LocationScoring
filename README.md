# PerkPoint Location Score

A comprehensive iOS application for evaluating and scoring vending machine locations based on various metrics and criteria.

## Overview

PerkPoint Location Score is designed to help businesses and entrepreneurs assess the potential profitability and viability of vending machine locations. The app provides a systematic approach to evaluating locations using multiple criteria including financial metrics, general metrics, and location-specific factors.

## Features

### Core Functionality
- **Location Management**: Create, edit, and manage vending machine locations
- **Comprehensive Scoring**: Multi-factor evaluation system with weighted scoring
- **Metric Categories**:
  - Financial Metrics (revenue, costs, profit margins)
  - General Metrics (foot traffic, accessibility, competition)
  - Location-Specific Metrics (hospitals, schools, offices, residential areas)
- **Scorecard System**: Visual representation of location scores and rankings
- **User Authentication**: Secure login and user profile management

### Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **CloudKit Integration**: Cloud-based data storage and synchronization
- **Modular Design**: Reusable components and services

## Project Structure

```
VendingLocationScore/
├── Models/                 # Data models and business logic
│   ├── NewArchitecture/   # Centralized metrics system
│   ├── Financials.swift   # Financial calculations
│   └── Scorecard.swift    # Scoring algorithms
├── Views/                  # SwiftUI views and components
│   ├── Components/        # Reusable UI components
│   ├── ModuleTypes/       # Location-specific views
│   └── Shared/           # Common UI elements
├── Services/              # Business logic and data services
│   ├── AuthenticationService.swift
│   ├── CloudKitService.swift
│   └── MetricService.swift
└── Config/                # App configuration
```

## Getting Started

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- macOS 14.0 or later (for development)
- Apple Developer Account (for deployment)

### Installation
1. Clone the repository
   ```bash
   git clone [your-repository-url]
   cd PerkPointLocationScore
   ```

2. Open the project in Xcode
   ```bash
   open VendingLocationScore.xcodeproj
   ```

3. Build and run the project
   - Select your target device or simulator
   - Press Cmd+R to build and run

## Usage

### Creating a New Location
1. Navigate to the Dashboard
2. Tap "Create New Location"
3. Fill in location details and metrics
4. Review the calculated score
5. Save the location

### Evaluating Locations
1. Select a location from the list
2. Review all metrics and scores
3. Use the scorecard view for visual analysis
4. Compare multiple locations side-by-side

### Managing Metrics
- Customize metric weights based on business priorities
- Add location-specific criteria
- Adjust scoring algorithms as needed

## Development

### Code Style
- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Implement MVVM architecture consistently
- Write unit tests for business logic

### Adding New Features
1. Create models in the appropriate Models directory
2. Implement services for business logic
3. Design SwiftUI views following the existing pattern
4. Update the navigation and routing

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation in the Docs/ folder

## Roadmap

- [ ] Enhanced analytics and reporting
- [ ] Integration with mapping services
- [ ] Multi-user collaboration features
- [ ] Advanced scoring algorithms
- [ ] Export and sharing capabilities
- [ ] Performance optimizations

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Platform**: iOS  
**Language**: Swift
