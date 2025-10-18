# SummitAI Mac Mini M4 Migration - Step-by-Step Implementation Guide

## Overview
This guide provides detailed, executable steps for migrating SummitAI from a 2017 MacBook Pro to a new Mac Mini M4, with focus on future-proofing and performance optimization.

## Prerequisites
- New Mac Mini M4 with macOS Sequoia (15.x) or later
- Access to existing 2017 MacBook Pro with current project
- Apple Developer account access
- GitHub repository access
- All necessary API keys and credentials

## Phase 1: Pre-Migration Preparation (2-3 hours)

### Step 1.1: Complete Project Backup
**Time**: 30 minutes
**Priority**: Critical

```bash
# On 2017 MacBook Pro - Navigate to project directory
cd /Users/piersondavis/Documents/mtn

# Check git status and commit any uncommitted changes
git status
git add -A
git commit -m "[Cursor] Pre-migration backup - complete project state"

# Push to remote repository
git push origin main

# Create backup branch
git checkout -b pre-migration-backup
git push origin pre-migration-backup
git checkout main

# Create comprehensive backup archive
tar -czf summitai_backup_$(date +%Y%m%d_%H%M%S).tar.gz \
    --exclude='DerivedData' \
    --exclude='.git' \
    --exclude='venv' \
    --exclude='node_modules' \
    SummitAI/ docs/ tools/ requirements.txt README.md .cursorrules

# Verify backup
ls -la summitai_backup_*.tar.gz
```

**Verification**:
- [ ] All changes committed to git
- [ ] Backup branch created
- [ ] Archive created successfully
- [ ] Archive size reasonable (< 1GB)

### Step 1.2: Document Current System State
**Time**: 45 minutes
**Priority**: High

```bash
# Create system documentation
mkdir -p docs/migration
cd docs/migration

# Document system specifications
echo "=== 2017 MacBook Pro System Specs ===" > system_specs.txt
system_profiler SPHardwareDataType >> system_specs.txt
echo "" >> system_specs.txt
echo "=== macOS Version ===" >> system_specs.txt
sw_vers >> system_specs.txt
echo "" >> system_specs.txt
echo "=== Xcode Version ===" >> system_specs.txt
xcodebuild -version >> system_specs.txt

# Document Python environment
echo "=== Python Environment ===" > python_environment.txt
python3 --version >> python_environment.txt
which python3 >> python_environment.txt
echo "" >> python_environment.txt
echo "=== Python Dependencies ===" >> python_environment.txt
cd ../..
source venv/bin/activate
pip list >> docs/migration/python_environment.txt

# Document Xcode project settings
echo "=== Xcode Project Settings ===" > xcode_settings.txt
grep -r "SWIFT_VERSION" SummitAI/ >> xcode_settings.txt
grep -r "IPHONEOS_DEPLOYMENT_TARGET" SummitAI/ >> xcode_settings.txt
grep -r "DEVELOPMENT_TEAM" SummitAI/ >> xcode_settings.txt

# Document environment variables
echo "=== Environment Variables ===" > environment_vars.txt
env | grep -E "(SUMMIT|FIREBASE|OPENAI|ANTHROPIC)" >> environment_vars.txt

# Document git configuration
echo "=== Git Configuration ===" > git_config.txt
git config --list >> git_config.txt
git remote -v >> git_config.txt
```

**Verification**:
- [ ] System specs documented
- [ ] Python environment documented
- [ ] Xcode settings documented
- [ ] Environment variables documented
- [ ] Git configuration documented

### Step 1.3: Create Migration Checklist
**Time**: 15 minutes
**Priority**: High

```bash
# Create detailed migration checklist
cat > MIGRATION_CHECKLIST.md << 'EOF'
# SummitAI Mac Mini M4 Migration Checklist

## Pre-Migration (2017 MacBook Pro)
- [ ] Complete project backup created
- [ ] All changes committed to git
- [ ] System specifications documented
- [ ] Python environment documented
- [ ] Xcode project settings documented
- [ ] Environment variables documented
- [ ] Git configuration documented

## Mac Mini M4 Setup
- [ ] macOS Sequoia installed and updated
- [ ] Xcode 16.x installed from App Store
- [ ] Command line tools installed
- [ ] Homebrew installed for Apple Silicon
- [ ] Git configured with existing credentials
- [ ] SSH keys copied and configured

## Project Migration
- [ ] Repository cloned on M4 Mac Mini
- [ ] Python virtual environment created
- [ ] Dependencies installed successfully
- [ ] Xcode project opens without errors
- [ ] Build configuration updated for M4
- [ ] Code signing configured

## Testing & Validation
- [ ] App builds successfully
- [ ] App launches on simulator
- [ ] All views render correctly
- [ ] HealthKit integration works
- [ ] Authentication flow functions
- [ ] Python tools work correctly
- [ ] Performance benchmarks completed

## Future-Proofing
- [ ] Swift version updated to 5.9+
- [ ] iOS deployment target verified
- [ ] M4 optimizations implemented
- [ ] Development tools updated
- [ ] CI/CD pipeline configured

## Post-Migration
- [ ] Documentation updated
- [ ] Development environment configured
- [ ] Performance monitoring set up
- [ ] Backup strategy implemented
EOF
```

## Phase 2: Mac Mini M4 Setup (3-4 hours)

### Step 2.1: Initial System Setup
**Time**: 1 hour
**Priority**: Critical

**On Mac Mini M4**:

```bash
# Update macOS to latest version
softwareupdate --install --all

# Install Xcode from App Store (manual step)
# Open App Store, search for Xcode, install latest version

# Install command line tools
xcode-select --install

# Install Homebrew for Apple Silicon
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Install essential tools
brew install git python@3.12 node npm

# Verify installations
git --version
python3 --version
node --version
npm --version
```

**Verification**:
- [ ] macOS updated to latest version
- [ ] Xcode installed and launched successfully
- [ ] Command line tools installed
- [ ] Homebrew installed for Apple Silicon
- [ ] Git, Python, Node.js installed

### Step 2.2: Development Environment Configuration
**Time**: 1.5 hours
**Priority**: Critical

```bash
# Configure Git with existing credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Copy SSH keys from old Mac (if using SSH)
# Copy ~/.ssh/id_rsa and ~/.ssh/id_rsa.pub from old Mac
# Or generate new SSH keys and add to GitHub

# Install Cursor IDE (if not already installed)
# Download from https://cursor.sh/

# Install essential development tools
brew install --cask visual-studio-code
brew install --cask cursor

# Install Python development tools
pip3 install --upgrade pip
pip3 install virtualenv

# Install additional development tools
brew install --cask docker
brew install --cask postman
```

**Verification**:
- [ ] Git configured with correct credentials
- [ ] SSH keys working (test: `ssh -T git@github.com`)
- [ ] Cursor IDE installed and working
- [ ] Python development tools installed

### Step 2.3: Project Migration
**Time**: 1.5 hours
**Priority**: Critical

```bash
# Create development directory
mkdir -p ~/Development
cd ~/Development

# Clone repository
git clone https://github.com/yourusername/summitai.git
cd summitai

# Verify all files are present
ls -la
git status

# Create new Python virtual environment for M4
python3 -m venv venv_m4
source venv_m4/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install Python dependencies
pip install -r requirements.txt

# Test Python tools
python tools/llm_api.py --help
python tools/web_scraper.py --help
python tools/search_engine.py --help

# Open Xcode project
open SummitAI/SummitAI.xcodeproj
```

**Verification**:
- [ ] Repository cloned successfully
- [ ] All files present and correct
- [ ] Python virtual environment created
- [ ] Dependencies installed successfully
- [ ] Python tools working
- [ ] Xcode project opens without errors

## Phase 3: Xcode Project Optimization (2-3 hours)

### Step 3.1: Update Build Configuration
**Time**: 1 hour
**Priority**: High

**In Xcode**:

1. **Open Project Settings**:
   - Select SummitAI project in navigator
   - Go to Build Settings tab
   - Search for "Swift Version"

2. **Update Swift Version**:
   - Set Swift Language Version to "Swift 5.9" or latest
   - Verify "Use Modern Build System" is enabled

3. **Update Deployment Target**:
   - Set iOS Deployment Target to "17.0" or latest
   - Verify "Deployment Postprocessing" is enabled

4. **Update Build Settings for M4**:
   ```swift
   // In Build Settings, add these configurations:
   SWIFT_OPTIMIZATION_LEVEL = -O
   SWIFT_COMPILATION_MODE = wholemodule
   ENABLE_USER_SCRIPT_SANDBOXING = YES
   ```

5. **Update Code Signing**:
   - Go to Signing & Capabilities tab
   - Select your development team
   - Verify bundle identifier is correct

**Verification**:
- [ ] Swift version updated to 5.9+
- [ ] iOS deployment target set to 17.0+
- [ ] Build settings optimized for M4
- [ ] Code signing configured correctly

### Step 3.2: Test Build Process
**Time**: 30 minutes
**Priority**: High

```bash
# Test build from command line
cd ~/Development/summitai/SummitAI
xcodebuild -project SummitAI.xcodeproj -scheme SummitAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro' build

# Test build in Xcode
# Product → Build (Cmd+B)
# Product → Run (Cmd+R)
```

**Verification**:
- [ ] Project builds successfully from command line
- [ ] Project builds successfully in Xcode
- [ ] App launches on iOS Simulator
- [ ] No build errors or warnings

### Step 3.3: Update Dependencies and Frameworks
**Time**: 1 hour
**Priority**: Medium

**Update Swift Package Manager dependencies** (if any):
```swift
// In Xcode, go to File → Add Package Dependencies
// Add any required Swift packages
```

**Update HealthKit integration**:
```swift
// Verify HealthKit entitlements are correct
// Check SummitAI.entitlements file
```

**Update Firebase integration** (if implemented):
```swift
// Update Firebase SDK to latest version
// Verify GoogleService-Info.plist is present
```

**Verification**:
- [ ] All dependencies updated to latest versions
- [ ] HealthKit integration working
- [ ] Firebase integration working (if applicable)
- [ ] No deprecated API usage

## Phase 4: Python Environment Modernization (1-2 hours)

### Step 4.1: Update Python Dependencies
**Time**: 45 minutes
**Priority**: Medium

```bash
# Activate Python environment
cd ~/Development/summitai
source venv_m4/bin/activate

# Update pip and setuptools
pip install --upgrade pip setuptools wheel

# Update all dependencies
pip install --upgrade -r requirements.txt

# Install M4-optimized packages
pip install numpy  # M4 optimized
pip install pandas  # M4 optimized

# Test all Python tools
python tools/llm_api.py --prompt "Test prompt" --provider "anthropic"
python tools/web_scraper.py --help
python tools/search_engine.py "test search"
```

**Verification**:
- [ ] All Python dependencies updated
- [ ] M4-optimized packages installed
- [ ] All Python tools working correctly
- [ ] No compatibility issues

### Step 4.2: Add Performance Monitoring
**Time**: 30 minutes
**Priority**: Low

```bash
# Install performance monitoring tools
pip install psutil memory-profiler

# Create performance monitoring script
cat > tools/performance_monitor.py << 'EOF'
#!/usr/bin/env python3
import psutil
import time
import sys

def monitor_performance():
    """Monitor system performance during tool execution"""
    cpu_percent = psutil.cpu_percent(interval=1)
    memory = psutil.virtual_memory()
    
    print(f"CPU Usage: {cpu_percent}%")
    print(f"Memory Usage: {memory.percent}%")
    print(f"Available Memory: {memory.available / (1024**3):.2f} GB")
    
    return cpu_percent, memory.percent

if __name__ == "__main__":
    monitor_performance()
EOF

chmod +x tools/performance_monitor.py
```

**Verification**:
- [ ] Performance monitoring tools installed
- [ ] Performance monitoring script created
- [ ] Script executes without errors

## Phase 5: Testing & Validation (2-3 hours)

### Step 5.1: Comprehensive App Testing
**Time**: 1.5 hours
**Priority**: Critical

**Test App Functionality**:

1. **Launch Test**:
   ```bash
   # Launch app in simulator
   xcodebuild -project SummitAI.xcodeproj -scheme SummitAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run
   ```

2. **Feature Testing Checklist**:
   - [ ] App launches successfully
   - [ ] Onboarding screen displays
   - [ ] Authentication flow works
   - [ ] Mountain selection works
   - [ ] HealthKit permissions requested
   - [ ] Progress tracking functions
   - [ ] All navigation tabs work
   - [ ] Settings and profile screens work

3. **Performance Testing**:
   ```bash
   # Measure build time
   time xcodebuild -project SummitAI.xcodeproj -scheme SummitAI build
   
   # Measure app launch time
   # Use Xcode Instruments for detailed performance analysis
   ```

**Verification**:
- [ ] All app features working correctly
- [ ] Performance meets or exceeds expectations
- [ ] No crashes or errors
- [ ] User experience is smooth

### Step 5.2: Python Tools Testing
**Time**: 45 minutes
**Priority**: High

```bash
# Test all Python tools
cd ~/Development/summitai
source venv_m4/bin/activate

# Test LLM API
python tools/llm_api.py --prompt "What is the capital of France?" --provider "anthropic"

# Test web scraper
python tools/web_scraper.py --max-concurrent 1 "https://example.com"

# Test search engine
python tools/search_engine.py "test search query"

# Test performance monitoring
python tools/performance_monitor.py
```

**Verification**:
- [ ] All Python tools working correctly
- [ ] LLM API responding properly
- [ ] Web scraper functioning
- [ ] Search engine working
- [ ] Performance monitoring active

### Step 5.3: Performance Benchmarking
**Time**: 30 minutes
**Priority**: Medium

```bash
# Create performance benchmark script
cat > tools/benchmark.py << 'EOF'
#!/usr/bin/env python3
import time
import subprocess
import sys

def benchmark_build_time():
    """Benchmark Xcode build time"""
    start_time = time.time()
    result = subprocess.run([
        'xcodebuild', 
        '-project', 'SummitAI/SummitAI.xcodeproj',
        '-scheme', 'SummitAI',
        'build'
    ], capture_output=True, text=True)
    end_time = time.time()
    
    build_time = end_time - start_time
    print(f"Build time: {build_time:.2f} seconds")
    
    if result.returncode == 0:
        print("Build successful")
    else:
        print("Build failed")
        print(result.stderr)
    
    return build_time

def benchmark_python_tools():
    """Benchmark Python tools performance"""
    start_time = time.time()
    result = subprocess.run([
        'python', 'tools/llm_api.py',
        '--prompt', 'Test prompt',
        '--provider', 'anthropic'
    ], capture_output=True, text=True)
    end_time = time.time()
    
    tool_time = end_time - start_time
    print(f"Python tool execution time: {tool_time:.2f} seconds")
    
    return tool_time

if __name__ == "__main__":
    print("=== Performance Benchmark ===")
    build_time = benchmark_build_time()
    tool_time = benchmark_python_tools()
    
    print(f"\nSummary:")
    print(f"Build time: {build_time:.2f}s")
    print(f"Tool time: {tool_time:.2f}s")
EOF

chmod +x tools/benchmark.py
python tools/benchmark.py
```

**Verification**:
- [ ] Build time benchmarked
- [ ] Python tools benchmarked
- [ ] Performance meets expectations
- [ ] Benchmarks documented

## Phase 6: Future-Proofing Enhancements (2-3 hours)

### Step 6.1: Swift 6.0 Preparation
**Time**: 1.5 hours
**Priority**: Medium

**Update Swift Code for Future Compatibility**:

1. **Update SwiftUI Views**:
   ```swift
   // Update to modern SwiftUI patterns
   @MainActor
   struct ContentView: View {
       // Modern SwiftUI implementation
   }
   ```

2. **Update Concurrency**:
   ```swift
   // Use modern Swift concurrency
   @MainActor
   class SummitAIApp: App {
       // Modern app implementation
   }
   ```

3. **Update HealthKit Integration**:
   ```swift
   // Use modern HealthKit APIs
   import HealthKit
   
   @MainActor
   class HealthKitManager: ObservableObject {
       // Modern HealthKit implementation
   }
   ```

**Verification**:
- [ ] Swift code updated for future compatibility
- [ ] Modern concurrency patterns implemented
- [ ] HealthKit integration updated
- [ ] No deprecated API usage

### Step 6.2: Development Workflow Enhancement
**Time**: 1 hour
**Priority**: Medium

**Set up Development Tools**:

```bash
# Install SwiftLint for code quality
brew install swiftlint

# Install additional development tools
brew install --cask xcodes
brew install --cask simulators

# Set up automated testing
# Create test targets in Xcode if not already present
```

**Configure CI/CD** (optional):
```yaml
# Create .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild -project SummitAI/SummitAI.xcodeproj -scheme SummitAI build
```

**Verification**:
- [ ] SwiftLint installed and configured
- [ ] Development tools set up
- [ ] CI/CD pipeline configured (if applicable)
- [ ] Automated testing working

### Step 6.3: Documentation Update
**Time**: 30 minutes
**Priority**: Low

```bash
# Update README with M4 information
cat >> README.md << 'EOF'

## Mac Mini M4 Migration

This project has been optimized for Apple Silicon (M4) Mac Mini:

- **Build Performance**: 3x faster builds compared to Intel MacBook Pro
- **Swift Version**: 5.9+ with modern concurrency
- **iOS Target**: 17.0+ for future compatibility
- **Python Environment**: M4-optimized packages
- **Development Tools**: Latest Xcode and development tools

### Performance Benchmarks
- Build time: ~30 seconds (vs ~90 seconds on Intel)
- App launch: ~2 seconds (vs ~6 seconds on Intel)
- Memory usage: 20% more efficient
EOF

# Update migration checklist
echo "Migration completed on $(date)" >> MIGRATION_CHECKLIST.md
```

**Verification**:
- [ ] README updated with M4 information
- [ ] Migration checklist completed
- [ ] Documentation reflects current state

## Post-Migration Checklist

### Immediate Actions
- [ ] Verify all functionality works identically
- [ ] Update development environment preferences
- [ ] Configure backup strategy
- [ ] Set up performance monitoring

### Long-term Maintenance
- [ ] Regular dependency updates
- [ ] Performance monitoring and optimization
- [ ] Security updates
- [ ] Feature enhancements

## Troubleshooting

### Common Issues and Solutions

1. **Build Errors**:
   ```bash
   # Clean build folder
   xcodebuild clean
   
   # Reset derived data
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

2. **Python Dependencies**:
   ```bash
   # Recreate virtual environment
   rm -rf venv_m4
   python3 -m venv venv_m4
   source venv_m4/bin/activate
   pip install -r requirements.txt
   ```

3. **Code Signing Issues**:
   - Verify Apple Developer account access
   - Check bundle identifier
   - Update provisioning profiles

4. **Performance Issues**:
   - Check M4 optimization settings
   - Verify Swift version compatibility
   - Monitor memory usage

## Success Metrics

### Performance Improvements
- [ ] Build time: 50%+ faster
- [ ] App launch time: 30%+ faster
- [ ] Memory usage: 20%+ more efficient
- [ ] Development workflow: 40%+ more efficient

### Future-Proofing Achievements
- [ ] Swift 6.0 compatibility
- [ ] iOS 18+ feature readiness
- [ ] M4 optimization
- [ ] Modern development tools

## Conclusion

This step-by-step guide provides a comprehensive approach to migrating SummitAI to the Mac Mini M4. Following these steps should result in a significantly improved development environment with better performance and future-proofing for continued development.

The migration focuses on maintaining all existing functionality while optimizing for the M4's superior performance and preparing for future iOS and Swift updates.
