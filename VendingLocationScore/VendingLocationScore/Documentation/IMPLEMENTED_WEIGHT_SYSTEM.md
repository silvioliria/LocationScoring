# 🎯 **IMPLEMENTED WEIGHT SYSTEM**

## **Overview**
This document outlines the exact weight system that has been implemented in the VendingLocationScore app, following the specifications provided by the user.

## **📊 Total Weight Distribution**
- **Core Metrics (apply to all locations)**: **0.75 total (75%)**
- **Module Block (pick exactly one set)**: **0.25 total (25%)**
- **Total**: **1.0 (100%)**

---

## **🏗️ Core Metrics (0.75 total) - Apply to ALL Locations**

### **Foot Traffic (Daily) - 0.20 (20%)**
- **Key**: `foot_traffic_daily`
- **Description**: Daily foot traffic volume. Higher traffic increases sales potential.
- **Rating Scale**: 1-5 stars
  - 1: < 100
  - 2: 100-200
  - 3: 200-350
  - 4: 350-500
  - 5: > 500

### **Target Demographic Fit - 0.10 (10%)**
- **Key**: `target_demo_fit`
- **Description**: Alignment with target customer demographic profile.
- **Rating Scale**: 1-5 stars
  - 1: No Match
  - 2: Poor Match
  - 3: Fair Match
  - 4: Good Match
  - 5: Excellent Match

### **Nearby Competition - 0.10 (10%)**
- **Key**: `nearby_competition`
- **Description**: Proximity and strength of competing food/beverage options.
- **Rating Scale**: 1-5 stars
  - 1: High competition
  - 2: Moderate-high competition
  - 3: Moderate competition
  - 4: Low competition
  - 5: Zero competition

### **Logistics & Infrastructure (Subtotal: 0.15)**

#### **Visibility & Accessibility - 0.05 (5%)**
- **Key**: `visibility_accessibility`
- **Description**: Visibility and accessibility of potential vending locations.
- **Rating Scale**: 1-5 stars
  - 1: Hidden location
  - 2: Side corridor
  - 3: Secondary traffic flow
  - 4: Clear sightline
  - 5: Prime high-traffic spot

#### **Parking & Transit Access - 0.04 (4%)**
- **Key**: `parking_transit`
- **Description**: Ease of access for service vehicles and logistics.
- **Rating Scale**: 1-5 stars
  - 1: No loading access
  - 2: Difficult access
  - 3: Acceptable access
  - 4: Good access
  - 5: Dedicated loading zone

#### **Security - 0.04 (4%)**
- **Key**: `security`
- **Description**: Security measures and theft prevention capabilities.
- **Rating Scale**: 1-5 stars
  - 1: No CCTV or security
  - 2: Limited security
  - 3: Part-time monitoring
  - 4: CCTV + staff presence
  - 5: Full security system

#### **Adjacent Amenities - 0.02 (2%)**
- **Key**: `adjacent_amenities`
- **Description**: Nearby amenities that drive foot traffic (elevators, mailrooms, ATMs).
- **Rating Scale**: 1-5 stars
  - 1: No amenities
  - 2: 1 traffic booster
  - 3: 2 traffic boosters
  - 4: 3 traffic boosters
  - 5: 4+ traffic boosters

### **Financial Terms & ROI (Subtotal: 0.20)**

#### **Host Commission % - 0.08 (8%)**
- **Key**: `host_commission_pct`
- **Description**: Commission percentage charged by location host.
- **Note**: Commission lives only here to avoid double counting in modules.
- **Rating Scale**: 1-5 stars
  - 1: Above 20%
  - 2: 16-20%
  - 3: 11-15%
  - 4: 6-10%
  - 5: 5% or lower

#### **Payback Period vs Target - 0.06 (6%)**
- **Key**: `payback_vs_target`
- **Description**: How quickly the investment pays for itself compared to target.
- **Rating Scale**: 1-5 stars
  - 1: > 36 months
  - 2: 24-36 months
  - 3: 18-24 months
  - 4: 12-18 months
  - 5: < 12 months

#### **Route Fit / Clustering - 0.04 (4%)**
- **Key**: `route_cluster_fit`
- **Description**: How well this location fits into existing service routes.
- **Rating Scale**: 1-5 stars
  - 1: Requires new route
  - 2: Significant detour
  - 3: Minor detour
  - 4: On existing route
  - 5: Perfect route fit

#### **Install Complexity / One-time Cost - 0.02 (2%)**
- **Key**: `install_complexity`
- **Description**: Complexity and cost of initial installation.
- **Rating Scale**: 1-5 stars
  - 1: Very complex/expensive
  - 2: Complex/expensive
  - 3: Moderate complexity/cost
  - 4: Simple/affordable
  - 5: Very simple/cheap

---

## **🏢 Module Block (0.25 total) - Pick Exactly One Set**

### **Residential (Apartments/Condos/Townhomes) - 0.25 total**

| Metric | Key | Weight | Description |
|--------|-----|---------|-------------|
| Total Units | `res_total_units` | 0.035 (3.5%) | Total number of residential units |
| Occupancy Rate | `res_occupancy_rate` | 0.020 (2.0%) | Current occupancy rate |
| % Residents 18-45 | `res_demo_18_45_pct` | 0.020 (2.0%) | Target age demographic percentage |
| Average Lease Length | `res_avg_lease_months` | 0.010 (1.0%) | Average length of residential leases |
| Amenity Usage Rate | `res_amenity_usage_pct` | 0.020 (2.0%) | How actively residents use amenities |
| 24/7 Common-Area Access | `res_access_24_7` | 0.020 (2.0%) | Whether common areas are accessible 24/7 |
| Install Visibility | `res_install_visibility` | 0.025 (2.5%) | Visibility of vending machine installation |
| Power & Connectivity | `res_power_connectivity` | 0.020 (2.0%) | Availability of power and internet |
| Service/Loading Path | `res_service_path` | 0.020 (2.0%) | Ease of service and loading access |
| Security Measures | `res_security_measures` | 0.020 (2.0%) | Security measures in place |
| On-Site Alternatives | `res_on_site_alternatives` | 0.010 (1.0%) | Competing food/beverage options |
| Walk Time to Store | `res_walk_time_store_min` | 0.020 (2.0%) | Walking time to nearest store |
| HOA/Strata Rules | `res_hoa_rules` | 0.005 (0.5%) | Restrictions by HOA/strata council |
| Resident Events/Year | `res_events_per_year` | 0.005 (0.5%) | Number of resident events annually |

### **Office - 0.25 total**

| Metric | Key | Weight | Description |
|--------|-----|---------|-------------|
| Common Areas Available | `off_common_areas` | 0.060 (6.0%) | Availability of common areas |
| Hours & Access Control | `off_hours_access` | 0.050 (5.0%) | Building access hours and control |
| Tenant Amenities Offered | `off_tenant_amenities` | 0.050 (5.0%) | Amenities available to tenants |
| Proximity to Hub/Transit | `off_proximity_hub_transit` | 0.040 (4.0%) | Proximity to transportation hubs |
| Branding Restrictions | `off_branding_restrictions` | 0.020 (2.0%) | Restrictions on branding/signage |
| Layout Type | `off_layout_type` | 0.030 (3.0%) | Single vs. multi-tenant layout |

### **Hospital / Healthcare - 0.25 total**

| Metric | Key | Weight | Description |
|--------|-----|---------|-------------|
| Health-Safety Compliance | `hos_health_safety` | 0.070 (7.0%) | Compliance with health regulations |
| Distance to Patient Areas | `hos_distance_patient_m` | 0.050 (5.0%) | Distance from vending to patients |
| Designated Vending Zones | `hos_vending_zones` | 0.050 (5.0%) | Availability of designated zones |
| Facilities Mgmt Coordination | `hos_fm_coordination` | 0.040 (4.0%) | Coordination with facilities team |
| Hygiene & Sanitation Extras | `hos_hygiene_extras` | 0.040 (4.0%) | Additional hygiene requirements |

### **School / University - 0.25 total**

| Metric | Key | Weight | Description |
|--------|-----|---------|-------------|
| Placement in Student Hotspots | `sch_placement_hotspots` | 0.080 (8.0%) | Placement in high-traffic areas |
| Schedule Alignment | `sch_schedule_alignment` | 0.050 (5.0%) | Alignment with student schedules |
| Product-Mix Suitability | `sch_product_mix` | 0.040 (4.0%) | Suitability for school environment |
| Admin Approval Status | `sch_admin_approval` | 0.050 (5.0%) | Administrative approval status |
| Safety & Accessibility | `sch_safety_accessibility` | 0.030 (3.0%) | Safety measures and accessibility |

---

## **🧮 Scoring Calculation**

### **Formula**
```
Final Score = Σ(value_normalized × weight)
```

### **Normalization**
- **Option 1**: Normalize to 0-1 (divide by 5) before multiplying by weight
- **Option 2**: Multiply raw 1-5 by weight and divide final sum by 5
- **Current Implementation**: Option 2 (consistent across the app)

### **Decision Thresholds**
- **Greenlight**: ≥ 0.75
- **Watchlist**: 0.60 - 0.74
- **Pass**: < 0.60

---

## **📁 Implementation Files**

### **Primary Implementation**
- `CentralizedMetrics.swift` - Metric definitions and weights
- `GeneralMetrics.swift` - Core metrics calculation logic

### **Key Features**
- ✅ **Exact weight matching** to specifications
- ✅ **Consistent 1-5 rating scale** across all metrics
- ✅ **Proper weight distribution** (0.75 + 0.25 = 1.0)
- ✅ **Location-specific modules** with appropriate weights
- ✅ **Standardized scoring calculation** across the app

---

## **🔧 Technical Notes**

### **Current Status**
- All weights have been implemented exactly as specified
- Build succeeds without errors
- Scoring system is ready for use

### **Next Steps**
- The system is ready for testing with real location data
- All metrics will use the standardized 1-5 rating scale
- Scores will be calculated using the exact weight distribution specified

---

*This weight system ensures consistent, fair, and mathematically sound scoring across all location types while maintaining the business logic priorities specified.*
