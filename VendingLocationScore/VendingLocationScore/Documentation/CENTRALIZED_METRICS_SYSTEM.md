# Centralized Metrics System Architecture

## Overview

This document describes the new centralized, object-oriented metrics system that has been added to the VendingLocationScore application. This system provides a more maintainable, type-safe, and extensible approach to managing metrics across different location types.

## Key Benefits

1. **Centralized Management**: All metric definitions are managed in one place
2. **Type Safety**: Strong typing with enums and protocols
3. **Extensibility**: Easy to add new metrics and location types
4. **Consistency**: Uniform metric structure across all location types
5. **Maintainability**: Single source of truth for metric logic
6. **SwiftData Compatibility**: Properly designed for persistence

## Architecture Components

### 1. MetricCategory Enum
Defines the core categories that apply across all location types:
- `footTraffic` - Daily foot traffic volume
- `demographics` - Target audience alignment
- `competition` - Competitive landscape
- `accessibility` - Parking and transit access
- `security` - Security measures
- `amenities` - Adjacent facilities
- `operations` - Hours and operational aspects
- `financial` - Commission and financial terms
- `layout` - Building layout characteristics
- `restrictions` - Operational restrictions

### 2. MetricDefinition Class
The core model for defining metrics:
- **Properties**: title, description, category, weight, validation rules
- **Location Applicability**: Which location types can use this metric
- **Rating Configuration**: Min/max ratings and descriptions
- **SwiftData Compatible**: Uses raw values for persistence

### 3. MetricInstance Class
Represents actual metric data for a specific location:
- **Rating**: The actual score (1-5)
- **Notes**: User-provided notes
- **Metadata**: Timestamps, computed values

### 4. LocationMetrics Class
Manages all metrics for a specific location:
- **Metric Collection**: Groups metrics by category
- **Score Calculation**: Overall and category-specific scoring
- **Completion Tracking**: Progress monitoring

### 5. MetricRegistry Singleton
Central registry for all metric definitions:
- **Registration**: Adds new metric definitions
- **Retrieval**: Gets metrics by location type and category
- **Default Setup**: Pre-configured with all existing metrics

### 6. MetricService
Service layer for metric operations:
- **CRUD Operations**: Create, read, update, delete metrics
- **Migration**: Converts legacy metrics to new system
- **Scoring**: Calculates various score types

## Current Implementation Status

### ✅ Completed
- Core architecture and models
- SwiftData compatibility fixes
- Metric registry with all existing metrics
- Service layer implementation
- Modern SwiftUI views (CentralizedMetricsView)

### 🔄 Integration Required
- Connect new system to existing views
- Migrate existing data
- Update navigation to use new views

### 📱 UI Components Available
- `CentralizedMetricsView` - Main metrics display
- `OverallScoreWidget` - Score visualization
- `CategorySection` - Grouped metric display
- `MetricRowCard` - Individual metric rows
- `CentralizedMetricDetailView` - Metric editing

## Migration Strategy

### Phase 1: Parallel Implementation
- Keep existing system running
- Add new centralized system alongside
- Test with new locations

### Phase 2: Data Migration
- Use `MetricService.migrateLegacyMetrics()` to convert existing data
- Validate migration results
- Maintain data integrity

### Phase 3: UI Integration
- Replace existing metric views with new centralized views
- Update navigation and routing
- Ensure backward compatibility

### Phase 4: Cleanup
- Remove legacy metric models
- Clean up unused code
- Update documentation

## Usage Examples

### Creating a New Metric
```swift
let newMetric = MetricDefinition(
    key: "custom_metric",
    title: "Custom Metric",
    description: "Description of the metric",
    category: .amenities,
    weight: 0.15,
    isRequired: false,
    applicableLocations: [.office, .hospital],
    ratingDescriptions: [
        1: "Poor",
        2: "Fair",
        3: "Good",
        4: "Very Good",
        5: "Excellent"
    ]
)

MetricRegistry.shared.registerMetric(newMetric)
```

### Using the Metric Service
```swift
let metricService = MetricService.shared

// Get metrics for a location
let metricsByCategory = try metricService.getMetricsByCategory(
    for: location, 
    context: context
)

// Update a metric
try metricService.updateMetric(
    for: location,
    metricKey: "general_foot_traffic",
    rating: 4,
    notes: "High traffic during lunch hours",
    context: context
)

// Calculate scores
let overallScore = try metricService.calculateOverallScore(
    for: location, 
    context: context
)
```

## Integration with Existing Code

### Current Views That Can Be Enhanced
- `GeneralMetricsView` - Replace with `CentralizedMetricsView`
- `OfficeMetricsView` - Use centralized system
- `HospitalMetricsView` - Use centralized system
- `SchoolMetricsView` - Use centralized system
- `ResidentialMetricsView` - Use centralized system

### Benefits for Each View
- **Consistent UI**: All views use the same design patterns
- **Unified Logic**: Same scoring and validation across all types
- **Easier Maintenance**: Changes apply to all location types
- **Better UX**: Consistent interaction patterns

## Future Enhancements

### 1. Dynamic Metric Configuration
- Load metric definitions from remote sources
- User-customizable metric weights
- A/B testing for different metric configurations

### 2. Advanced Analytics
- Trend analysis over time
- Comparative scoring between locations
- Predictive scoring based on historical data

### 3. Integration Features
- Export metrics to external systems
- API endpoints for metric data
- Web dashboard integration

## Technical Notes

### SwiftData Considerations
- Uses raw string values for enum persistence
- Computed properties provide type-safe access
- Proper Codable implementation for data migration

### Performance Optimizations
- Lazy loading of metric instances
- Efficient category-based grouping
- Minimal memory footprint for large datasets

### Error Handling
- Comprehensive error types
- Graceful fallbacks for missing data
- User-friendly error messages

## Conclusion

The centralized metrics system provides a solid foundation for the future growth of the VendingLocationScore application. It maintains all existing functionality while adding significant improvements in maintainability, consistency, and extensibility.

The system is designed to be integrated gradually, ensuring that no existing functionality is disrupted during the transition. Once fully integrated, it will provide a much more robust and maintainable foundation for managing location metrics.
