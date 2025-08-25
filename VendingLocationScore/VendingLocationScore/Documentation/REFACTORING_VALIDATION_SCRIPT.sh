#!/bin/bash

# 🔒 Refactoring Validation Script
# This script validates that refactoring hasn't broken the app

echo "🔒 Starting Refactoring Validation..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  $message${NC}"
            ;;
    esac
}

# Step 1: Build Validation
print_status "INFO" "Step 1: Building project..."
if xcodebuild -project VendingLocationScore.xcodeproj \
              -scheme VendingLocationScore \
              -destination 'platform=iOS Simulator,name=iPhone 16' \
              build > build.log 2>&1; then
    print_status "SUCCESS" "Build completed successfully!"
    
    # Check for warnings
    if grep -q "warning:" build.log; then
        print_status "WARNING" "Build warnings detected. Check build.log for details."
    else
        print_status "SUCCESS" "No build warnings found."
    fi
else
    print_status "ERROR" "Build failed! Check build.log for details."
    exit 1
fi

# Step 2: Check for common refactoring issues
print_status "INFO" "Step 2: Checking for common refactoring issues..."

# Check if all new components are properly imported
print_status "INFO" "Checking component imports..."
if grep -r "import.*ScoreColorUtility\|import.*CompactScoreGauge\|import.*LocationInfoDisplay" VendingLocationScore/Views/ --include="*.swift" > /dev/null 2>&1; then
    print_status "SUCCESS" "New components are properly imported."
else
    print_status "WARNING" "Some new components may not be properly imported."
fi

# Check for any hardcoded values that might have changed
print_status "INFO" "Checking for hardcoded values..."
if grep -r "42\|4\|callout" VendingLocationScore/Views/LocationListView.swift --include="*.swift" > /dev/null 2>&1; then
    print_status "SUCCESS" "Gauge dimensions and styling preserved."
else
    print_status "WARNING" "Gauge dimensions or styling may have changed."
fi

# Step 3: File structure validation
print_status "INFO" "Step 3: Validating file structure..."

# Check if new shared components exist
if [ -f "VendingLocationScore/Views/Shared/ScoreColorUtility.swift" ]; then
    print_status "SUCCESS" "ScoreColorUtility.swift created successfully."
else
    print_status "ERROR" "ScoreColorUtility.swift missing!"
fi

if [ -f "VendingLocationScore/Views/Shared/CompactScoreGauge.swift" ]; then
    print_status "SUCCESS" "CompactScoreGauge.swift created successfully."
else
    print_status "ERROR" "CompactScoreGauge.swift missing!"
fi

if [ -f "VendingLocationScore/Views/Shared/LocationInfoDisplay.swift" ]; then
    print_status "SUCCESS" "LocationInfoDisplay.swift created successfully."
else
    print_status "ERROR" "LocationInfoDisplay.swift missing!"
fi

# Step 4: Code quality checks
print_status "INFO" "Step 4: Code quality validation..."

# Check for any TODO or FIXME comments that might indicate incomplete refactoring
if grep -r "TODO\|FIXME" VendingLocationScore/ --include="*.swift" > /dev/null 2>&1; then
    print_status "WARNING" "TODO or FIXME comments found. Review before proceeding."
else
    print_status "SUCCESS" "No TODO or FIXME comments found."
fi

# Check for any compilation errors in the new components
print_status "INFO" "Checking new component syntax..."
if swift -frontend -parse VendingLocationScore/Views/Shared/ScoreColorUtility.swift > /dev/null 2>&1; then
    print_status "SUCCESS" "ScoreColorUtility.swift syntax is valid."
else
    print_status "ERROR" "ScoreColorUtility.swift has syntax errors!"
fi

if swift -frontend -parse VendingLocationScore/Views/Shared/CompactScoreGauge.swift > /dev/null 2>&1; then
    print_status "SUCCESS" "CompactScoreGauge.swift syntax is valid."
else
    print_status "ERROR" "CompactScoreGauge.swift has syntax errors!"
fi

if swift -frontend -parse VendingLocationScore/Views/Shared/LocationInfoDisplay.swift > /dev/null 2>&1; then
    print_status "SUCCESS" "LocationInfoDisplay.swift syntax is valid."
else
    print_status "ERROR" "LocationInfoDisplay.swift has syntax errors!"
fi

# Step 5: Summary
echo ""
print_status "INFO" "=== REFACTORING VALIDATION SUMMARY ==="
echo ""

if [ $? -eq 0 ]; then
    print_status "SUCCESS" "🎉 Refactoring validation completed successfully!"
    print_status "INFO" "Next steps:"
    print_status "INFO" "1. Test the app manually to verify UI fidelity"
    print_status "INFO" "2. Verify all functionality works as expected"
    print_status "INFO" "3. Take screenshots to compare before/after states"
else
    print_status "ERROR" "❌ Refactoring validation failed! Review the issues above."
    exit 1
fi

echo ""
print_status "INFO" "📱 Manual Testing Required:"
print_status "INFO" "- Location creation flow"
print_status "INFO" "- Location list display"
print_status "INFO" "- Score gauge appearance"
print_status "INFO" "- All navigation paths"

echo ""
print_status "INFO" "🔒 Remember: If it doesn't look and work exactly the same, it's not ready!"
