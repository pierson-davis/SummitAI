#!/bin/bash

# SummitAI Security Test Runner
# This script automates security testing for the SummitAI app

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_NAME="SummitAI"
SCHEME="SummitAI"
DESTINATION="platform=iOS Simulator,name=iPhone 14"
TEST_RESULTS_DIR="security_test_results"
REPORT_DIR="security_reports"

# Create directories
mkdir -p "$TEST_RESULTS_DIR"
mkdir -p "$REPORT_DIR"

echo -e "${BLUE}🔒 SummitAI Security Test Runner${NC}"
echo "=================================="

# Function to print status
print_status() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

# Function to print success
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Function to print warning
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to run command and capture output
run_command() {
    local cmd="$1"
    local output_file="$2"
    local description="$3"
    
    print_status "Running: $description"
    
    if eval "$cmd" > "$output_file" 2>&1; then
        print_success "$description completed successfully"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
print_status "Checking prerequisites..."

if ! command_exists xcodebuild; then
    print_error "xcodebuild not found. Please install Xcode."
    exit 1
fi

if ! command_exists swiftlint; then
    print_warning "SwiftLint not found. Installing via Homebrew..."
    if command_exists brew; then
        brew install swiftlint
    else
        print_error "Homebrew not found. Please install SwiftLint manually."
        exit 1
    fi
fi

if ! command_exists sonar-scanner; then
    print_warning "SonarQube Scanner not found. Installing via Homebrew..."
    if command_exists brew; then
        brew install sonar-scanner
    else
        print_warning "SonarQube Scanner not available. Skipping SonarQube analysis."
    fi
fi

print_success "Prerequisites check completed"

# 1. SwiftLint Security Analysis
print_status "Starting SwiftLint Security Analysis..."

if command_exists swiftlint; then
    run_command "swiftlint lint --config .swiftlint-security.yml --reporter json" \
        "$TEST_RESULTS_DIR/swiftlint_security.json" \
        "SwiftLint Security Analysis"
    
    run_command "swiftlint lint --config .swiftlint-security.yml --reporter html" \
        "$REPORT_DIR/swiftlint_security_report.html" \
        "SwiftLint Security Report Generation"
else
    print_warning "SwiftLint not available. Skipping SwiftLint analysis."
fi

# 2. Security Unit Tests
print_status "Running Security Unit Tests..."

run_command "xcodebuild test \
    -scheme $SCHEME \
    -destination '$DESTINATION' \
    -only-testing:${PROJECT_NAME}Tests/SecurityTests \
    -resultBundlePath $TEST_RESULTS_DIR/security_unit_tests.xcresult" \
    "$TEST_RESULTS_DIR/security_unit_tests.log" \
    "Security Unit Tests"

# 3. Security Integration Tests
print_status "Running Security Integration Tests..."

run_command "xcodebuild test \
    -scheme $SCHEME \
    -destination '$DESTINATION' \
    -only-testing:${PROJECT_NAME}Tests/SecurityIntegrationTests \
    -resultBundlePath $TEST_RESULTS_DIR/security_integration_tests.xcresult" \
    "$TEST_RESULTS_DIR/security_integration_tests.log" \
    "Security Integration Tests"

# 4. Penetration Tests
print_status "Running Penetration Tests..."

run_command "xcodebuild test \
    -scheme $SCHEME \
    -destination '$DESTINATION' \
    -only-testing:${PROJECT_NAME}Tests/PenetrationTestSuite \
    -resultBundlePath $TEST_RESULTS_DIR/penetration_tests.xcresult" \
    "$TEST_RESULTS_DIR/penetration_tests.log" \
    "Penetration Tests"

# 5. OWASP Dependency Check
print_status "Running OWASP Dependency Check..."

if command_exists dependency-check; then
    run_command "dependency-check \
        --project '$PROJECT_NAME' \
        --scan . \
        --format JSON \
        --out $TEST_RESULTS_DIR/dependency_check_report.json" \
        "$TEST_RESULTS_DIR/dependency_check.log" \
        "OWASP Dependency Check"
    
    run_command "dependency-check \
        --project '$PROJECT_NAME' \
        --scan . \
        --format HTML \
        --out $REPORT_DIR/dependency_check_report.html" \
        "$TEST_RESULTS_DIR/dependency_check_html.log" \
        "OWASP Dependency Check HTML Report"
else
    print_warning "OWASP Dependency Check not available. Skipping dependency analysis."
fi

# 6. SonarQube Analysis
print_status "Running SonarQube Analysis..."

if command_exists sonar-scanner; then
    # Create sonar-project.properties if it doesn't exist
    if [ ! -f "sonar-project.properties" ]; then
        cat > sonar-project.properties << EOF
sonar.projectKey=summitai
sonar.projectName=SummitAI
sonar.projectVersion=1.0
sonar.sources=SummitAI
sonar.tests=SummitAITests
sonar.swift.swiftlint.reportPaths=$TEST_RESULTS_DIR/swiftlint_security.json
sonar.coverage.reportPaths=$TEST_RESULTS_DIR/coverage.xml
sonar.cfamily.build-wrapper-output=bw-output
EOF
    fi
    
    run_command "sonar-scanner \
        -Dsonar.host.url=\${SONAR_HOST_URL:-http://localhost:9000} \
        -Dsonar.login=\${SONAR_TOKEN:-}" \
        "$TEST_RESULTS_DIR/sonar_analysis.log" \
        "SonarQube Analysis"
else
    print_warning "SonarQube Scanner not available. Skipping SonarQube analysis."
fi

# 7. Security Test Summary
print_status "Generating Security Test Summary..."

cat > "$REPORT_DIR/security_test_summary.md" << EOF
# SummitAI Security Test Summary

**Generated:** $(date)
**Test Runner Version:** 1.0
**Project:** $PROJECT_NAME

## Test Results Overview

### SwiftLint Security Analysis
- **Status:** $(if [ -f "$TEST_RESULTS_DIR/swiftlint_security.json" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
- **Report:** [swiftlint_security_report.html](swiftlint_security_report.html)

### Security Unit Tests
- **Status:** $(if [ -f "$TEST_RESULTS_DIR/security_unit_tests.xcresult" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
- **Log:** [security_unit_tests.log](security_unit_tests.log)

### Security Integration Tests
- **Status:** $(if [ -f "$TEST_RESULTS_DIR/security_integration_tests.xcresult" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
- **Log:** [security_integration_tests.log](security_integration_tests.log)

### Penetration Tests
- **Status:** $(if [ -f "$TEST_RESULTS_DIR/penetration_tests.xcresult" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
- **Log:** [penetration_tests.log](penetration_tests.log)

### OWASP Dependency Check
- **Status:** $(if [ -f "$TEST_RESULTS_DIR/dependency_check_report.json" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
- **Report:** [dependency_check_report.html](dependency_check_report.html)

### SonarQube Analysis
- **Status:** $(if [ -f "$TEST_RESULTS_DIR/sonar_analysis.log" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
- **Log:** [sonar_analysis.log](sonar_analysis.log)

## Security Metrics

### Test Coverage
- **Unit Tests:** $(grep -c "test" "$TEST_RESULTS_DIR/security_unit_tests.log" 2>/dev/null || echo "N/A")
- **Integration Tests:** $(grep -c "test" "$TEST_RESULTS_DIR/security_integration_tests.log" 2>/dev/null || echo "N/A")
- **Penetration Tests:** $(grep -c "test" "$TEST_RESULTS_DIR/penetration_tests.log" 2>/dev/null || echo "N/A")

### Security Issues
- **Critical:** $(grep -c "CRITICAL" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
- **High:** $(grep -c "HIGH" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
- **Medium:** $(grep -c "MEDIUM" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
- **Low:** $(grep -c "LOW" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")

## Recommendations

1. **Review all security issues** identified in the reports
2. **Address critical and high severity** issues immediately
3. **Implement security fixes** based on test results
4. **Update security tests** as needed
5. **Schedule regular security testing** (weekly/monthly)

## Next Steps

1. Review security test results
2. Prioritize security issues by severity
3. Implement security fixes
4. Re-run security tests
5. Update security documentation

---
*This report was generated automatically by the SummitAI Security Test Runner*
EOF

print_success "Security Test Summary generated"

# 8. Generate HTML Report
print_status "Generating HTML Report..."

cat > "$REPORT_DIR/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SummitAI Security Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2c3e50; color: white; padding: 20px; border-radius: 5px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .success { background: #d4edda; border-color: #c3e6cb; }
        .warning { background: #fff3cd; border-color: #ffeaa7; }
        .error { background: #f8d7da; border-color: #f5c6cb; }
        .metric { display: inline-block; margin: 10px; padding: 10px; background: #f8f9fa; border-radius: 3px; }
        .footer { margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 5px; text-align: center; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔒 SummitAI Security Test Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <div class="section">
        <h2>Test Results Overview</h2>
        <div class="metric">
            <strong>SwiftLint Security</strong><br>
            $(if [ -f "$TEST_RESULTS_DIR/swiftlint_security.json" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
        </div>
        <div class="metric">
            <strong>Unit Tests</strong><br>
            $(if [ -f "$TEST_RESULTS_DIR/security_unit_tests.xcresult" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
        </div>
        <div class="metric">
            <strong>Integration Tests</strong><br>
            $(if [ -f "$TEST_RESULTS_DIR/security_integration_tests.xcresult" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
        </div>
        <div class="metric">
            <strong>Penetration Tests</strong><br>
            $(if [ -f "$TEST_RESULTS_DIR/penetration_tests.xcresult" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
        </div>
        <div class="metric">
            <strong>Dependency Check</strong><br>
            $(if [ -f "$TEST_RESULTS_DIR/dependency_check_report.json" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
        </div>
        <div class="metric">
            <strong>SonarQube</strong><br>
            $(if [ -f "$TEST_RESULTS_DIR/sonar_analysis.log" ]; then echo "✅ Completed"; else echo "❌ Failed"; fi)
        </div>
    </div>
    
    <div class="section">
        <h2>Security Metrics</h2>
        <div class="metric">
            <strong>Critical Issues</strong><br>
            $(grep -c "CRITICAL" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
        </div>
        <div class="metric">
            <strong>High Issues</strong><br>
            $(grep -c "HIGH" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
        </div>
        <div class="metric">
            <strong>Medium Issues</strong><br>
            $(grep -c "MEDIUM" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
        </div>
        <div class="metric">
            <strong>Low Issues</strong><br>
            $(grep -c "LOW" "$TEST_RESULTS_DIR"/*.json 2>/dev/null || echo "0")
        </div>
    </div>
    
    <div class="section">
        <h2>Reports</h2>
        <ul>
            <li><a href="security_test_summary.md">Security Test Summary</a></li>
            <li><a href="swiftlint_security_report.html">SwiftLint Security Report</a></li>
            <li><a href="dependency_check_report.html">OWASP Dependency Check Report</a></li>
        </ul>
    </div>
    
    <div class="footer">
        <p>Generated by SummitAI Security Test Runner v1.0</p>
    </div>
</body>
</html>
EOF

print_success "HTML Report generated"

# 9. Final Summary
echo ""
echo -e "${BLUE}🔒 Security Test Summary${NC}"
echo "========================"
echo -e "Test Results Directory: ${YELLOW}$TEST_RESULTS_DIR${NC}"
echo -e "Report Directory: ${YELLOW}$REPORT_DIR${NC}"
echo -e "HTML Report: ${YELLOW}$REPORT_DIR/index.html${NC}"
echo ""

# Count test results
total_tests=0
passed_tests=0

if [ -f "$TEST_RESULTS_DIR/security_unit_tests.xcresult" ]; then
    total_tests=$((total_tests + 1))
    passed_tests=$((passed_tests + 1))
fi

if [ -f "$TEST_RESULTS_DIR/security_integration_tests.xcresult" ]; then
    total_tests=$((total_tests + 1))
    passed_tests=$((passed_tests + 1))
fi

if [ -f "$TEST_RESULTS_DIR/penetration_tests.xcresult" ]; then
    total_tests=$((total_tests + 1))
    passed_tests=$((passed_tests + 1))
fi

echo -e "Tests Completed: ${GREEN}$passed_tests/$total_tests${NC}"

if [ $passed_tests -eq $total_tests ]; then
    print_success "All security tests completed successfully!"
    exit 0
else
    print_warning "Some security tests failed. Please review the results."
    exit 1
fi
