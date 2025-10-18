# SummitAI M4 Migration - Quick Reference Guide

## 🚀 Quick Start Checklist

### Pre-Migration (2017 MacBook Pro)
```bash
# 1. Backup everything
cd /Users/piersondavis/Documents/mtn
git add -A && git commit -m "[Cursor] Pre-migration backup"
git push origin main

# 2. Create system documentation
mkdir -p docs/migration
system_profiler SPHardwareDataType > docs/migration/system_specs.txt
xcodebuild -version > docs/migration/xcode_version.txt
```

### Mac Mini M4 Setup
```bash
# 1. Install Homebrew for Apple Silicon
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install essential tools
brew install git python@3.12 node npm

# 3. Clone repository
cd ~/Development
git clone https://github.com/yourusername/summitai.git
cd summitai

# 4. Create Python environment
python3 -m venv venv_m4
source venv_m4/bin/activate
pip install -r requirements.txt
```

### Xcode Project Updates
1. **Open Project**: `open SummitAI/SummitAI.xcodeproj`
2. **Update Swift**: Build Settings → Swift Language Version → 5.9+
3. **Update Target**: iOS Deployment Target → 17.0+
4. **Code Signing**: Signing & Capabilities → Select Team
5. **Build**: Product → Build (Cmd+B)

## 🔧 Essential Commands

### Build & Test
```bash
# Build from command line
xcodebuild -project SummitAI/SummitAI.xcodeproj -scheme SummitAI build

# Run on simulator
xcodebuild -project SummitAI/SummitAI.xcodeproj -scheme SummitAI -destination 'platform=iOS Simulator,name=iPhone 15 Pro' run

# Test Python tools
python tools/llm_api.py --help
python tools/web_scraper.py --help
python tools/search_engine.py --help
```

### Performance Testing
```bash
# Benchmark build time
time xcodebuild -project SummitAI/SummitAI.xcodeproj -scheme SummitAI build

# Monitor performance
python tools/performance_monitor.py
```

## 📋 Critical Settings

### Xcode Build Settings
- **Swift Version**: 5.9+
- **iOS Deployment Target**: 17.0+
- **Swift Optimization Level**: -O
- **Swift Compilation Mode**: wholemodule
- **Enable User Script Sandboxing**: YES

### Python Environment
- **Python Version**: 3.12+
- **Virtual Environment**: venv_m4
- **Dependencies**: Updated for M4 optimization
- **M4 Packages**: numpy, pandas (M4 optimized)

## 🚨 Common Issues & Solutions

### Build Errors
```bash
# Clean build
xcodebuild clean
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Python Issues
```bash
# Recreate environment
rm -rf venv_m4
python3 -m venv venv_m4
source venv_m4/bin/activate
pip install -r requirements.txt
```

### Code Signing
- Check Apple Developer account access
- Verify bundle identifier
- Update provisioning profiles

## 📊 Expected Performance Improvements

| Metric | Intel MacBook Pro | M4 Mac Mini | Improvement |
|--------|------------------|-------------|-------------|
| Build Time | ~90 seconds | ~30 seconds | 3x faster |
| App Launch | ~6 seconds | ~2 seconds | 3x faster |
| Memory Usage | Baseline | 20% less | 20% more efficient |
| Development | Baseline | 40% faster | 40% more efficient |

## 🔄 Migration Timeline

### Day 1: Setup (6-8 hours)
- **Morning**: Backup and documentation
- **Afternoon**: M4 setup and basic configuration

### Day 2: Migration (6-8 hours)
- **Morning**: Project migration and testing
- **Afternoon**: Optimization and future-proofing

### Day 3: Validation (4-6 hours)
- **Morning**: Comprehensive testing
- **Afternoon**: Final enhancements

## 📁 File Structure After Migration

```
~/Development/summitai/
├── SummitAI/                    # Xcode project
│   ├── SummitAI.xcodeproj
│   └── SummitAI/
├── docs/                        # Documentation
│   ├── migration/               # Migration docs
│   ├── plans/                   # Project plans
│   └── implementation/          # Implementation guides
├── tools/                       # Python tools
│   ├── llm_api.py
│   ├── web_scraper.py
│   ├── search_engine.py
│   └── performance_monitor.py
├── venv_m4/                     # M4 Python environment
├── requirements.txt
├── README.md
└── MIGRATION_CHECKLIST.md
```

## 🎯 Success Criteria

### Immediate Success
- [ ] App builds successfully
- [ ] App launches on simulator
- [ ] All features work identically
- [ ] Python tools function correctly
- [ ] Performance improved significantly

### Future-Proofing Success
- [ ] Swift 6.0 compatibility
- [ ] iOS 18+ feature readiness
- [ ] M4 optimization active
- [ ] Modern development tools
- [ ] CI/CD pipeline configured

## 📞 Support Resources

### Documentation
- [SummitAI M4 Migration Plan](SummitAI_MAC_MINI_M4_MIGRATION_PLAN.md)
- [Step-by-Step Implementation](SummitAI_MAC_MINI_M4_STEP_BY_STEP.md)
- [System Specifications](migration/system_specs.txt)

### Tools
- [Performance Monitor](tools/performance_monitor.py)
- [Benchmark Script](tools/benchmark.py)
- [Migration Checklist](MIGRATION_CHECKLIST.md)

## 🔍 Verification Commands

```bash
# Verify system
sw_vers
xcodebuild -version
python3 --version

# Verify project
git status
ls -la SummitAI/
xcodebuild -project SummitAI/SummitAI.xcodeproj -list

# Verify Python
source venv_m4/bin/activate
pip list
python tools/llm_api.py --help

# Verify performance
time xcodebuild -project SummitAI/SummitAI.xcodeproj -scheme SummitAI build
```

## 🎉 Post-Migration Celebration

Once migration is complete:
1. **Test all features** thoroughly
2. **Document performance improvements**
3. **Update team** on new capabilities
4. **Plan next development phase**
5. **Enjoy the speed boost!** 🚀

---

*This quick reference guide provides essential commands and checklists for the SummitAI M4 migration. For detailed instructions, refer to the comprehensive migration plan and step-by-step implementation guide.*
