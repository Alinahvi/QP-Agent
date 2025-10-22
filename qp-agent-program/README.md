# SearchProgramsV4 - Agentforce Action

[![Version](https://img.shields.io/badge/version-4.0.0-blue)](https://github.com/Alinahvi/searchprograms-v4)
[![Status](https://img.shields.io/badge/status-production--ready-green)](https://github.com/Alinahvi/searchprograms-v4)
[![Tests](https://img.shields.io/badge/tests-8%2F8%20passing-success)](https://github.com/Alinahvi/searchprograms-v4)
[![Salesforce](https://img.shields.io/badge/salesforce-v61.0-blue)](https://developer.salesforce.com)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

**AI-powered program discovery for Salesforce enablement teams**

---

## 📋 Overview

SearchProgramsV4 is an Agentforce action that enables AI agents to discover and analyze Salesforce enablement programs across Global and Regional catalogs.

### Key Features

- ✅ **Smart Parameter Extraction**: Automatically parses "programs under 2 hours" → sets `maxHoursRequired=2.0`
- ✅ **Synonym Expansion**: Expands "soft skills" → communication, negotiation, storytelling
- ✅ **Business Priority Fuzzy Matching**: Finds "ACV/AOV" when searching "ACV growth"
- ✅ **Country-to-Region Mapping**: Maps "France" → "EMEA" automatically
- ✅ **Usage Analytics**: Tracks enrollment, popularity, and scheduling trends
- ✅ **100% Test Pass Rate**: Improved from 60% in v3.0

---

## 🚀 Quick Start

### Prerequisites

- Salesforce org with Agentforce enabled
- Salesforce CLI v2.0+
- System Administrator access

### Installation

```bash
# 1. Clone repository
git clone https://github.com/Alinahvi/searchprograms-v4.git
cd searchprograms-v4

# 2. Authenticate with Salesforce
sf org login web --set-default --alias myorg

# 3. Deploy Apex classes
sf project deploy start --source-dir force-app/main/default/classes --target-org myorg

# 4. Run tests
sf apex run --file scripts/apex/test_improved_search.apex --target-org myorg
```

---

## 📊 Test Results

**All 8 tests passing ✅**

| Test # | Description | Status |
|--------|-------------|--------|
| 1 | Duration filtering (≤3 hours) | ✅ PASS |
| 2 | Synonym expansion | ✅ PASS |
| 3 | Beginner level programs | ✅ PASS |
| 4 | ACV growth business priority | ✅ PASS |
| 5 | France programs (country mapping) | ✅ PASS |
| 6 | Most popular programs | ✅ PASS |
| 7 | Manufacturing industry | ✅ PASS |
| 8 | Big Deal Motion programs | ✅ PASS |

**Performance**: 100% pass rate, 17 SOQL queries, 1.4s avg execution time

See [TEST_RESULTS.md](TEST_RESULTS.md) for detailed analysis.

---

## 📦 Package Contents

```
searchprograms-v4/
├── README.md                          # This file
├── CHANGELOG.md                       # Version history
├── IMPROVEMENTS_SUMMARY.md            # v4.0 improvements
├── TEST_RESULTS.md                    # Test analysis
├── LICENSE                            # MIT License
├── .gitignore                         # Git ignore rules
│
├── force-app/main/default/classes/    # Apex classes
│   ├── ANAgentProgramSearchHandlerV4.cls
│   ├── ANAgentProgramSearchHandlerV4.cls-meta.xml
│   ├── ANAgentProgramSearchServiceV4.cls
│   └── ANAgentProgramSearchServiceV4.cls-meta.xml
│
└── scripts/apex/                      # Test scripts
    └── test_improved_search.apex
```

---

## 🎯 Usage Examples

### Example 1: Basic Search

```apex
ANAgentProgramSearchHandlerV4.ProgramSearchRequest req = new ANAgentProgramSearchHandlerV4.ProgramSearchRequest();
req.searchTerm = 'Agentforce';
req.programType = 'BOTH';

List<ANAgentProgramSearchHandlerV4.ProgramSearchResponse> response = 
    ANAgentProgramSearchHandlerV4.searchPrograms(new List<ANAgentProgramSearchHandlerV4.ProgramSearchRequest>{req});
```

### Example 2: Duration Filter

```apex
// Find programs under 2 hours
req.searchTerm = 'programs';
req.programType = 'BOTH';
req.maxHoursRequired = 2.0;
```

### Example 3: Popular Programs

```apex
// Find most popular by enrollment
req.searchTerm = 'programs';
req.sortBy = 'USAGE_COUNT';
req.sortOrder = 'DESC';
req.includeUsageMetrics = true;
```

---

## ⚙️ Configuration

### Create Agent Action

1. **Setup** → **Einstein** → **Agent Actions** → **New**
2. Configure:
   - Action Type: Apex
   - Apex Class: `ANAgentProgramSearchHandlerV4`
   - Method: `searchPrograms`
   - Label: `SearchProgramsV4`
3. **Save & Activate**

### Attach to Agent

1. **Setup** → **Agentforce Agents** → Select agent
2. **Actions** → **Add Action** → `SearchProgramsV4`
3. **Save**

---

## 📚 Documentation

- [IMPROVEMENTS_SUMMARY.md](IMPROVEMENTS_SUMMARY.md) - What's new in v4.0
- [TEST_RESULTS.md](TEST_RESULTS.md) - Comprehensive test analysis
- [CHANGELOG.md](CHANGELOG.md) - Version history

---

## 🔧 Parameters

### Required

| Parameter | Type | Description |
|-----------|------|-------------|
| `searchTerm` | String | Program name, skill, or product |
| `programType` | String | GLOBAL, REGIONAL, or BOTH |

### Optional (15 filters)

- `enablementType` - PRODUCT, ROLE, SKILL, INDUSTRY
- `targetLevel` - BEGINNER, INTERMEDIATE, ADVANCED
- `targetRole` - AE, BDR, SE, CSM, etc.
- `globalRegion` - AMER, EMEA, APAC, LATAM
- `businessPriority` - Strategic priority keyword
- `maxHoursRequired` - Maximum duration
- And 9 more...

---

## 📈 Performance

- **SOQL Queries**: 17 per search (17% of limit)
- **CPU Time**: ~1.4s average (14% of limit)
- **Success Rate**: 100% (vs 60% in v3.0)

---

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create feature branch
3. Run all tests
4. Submit pull request

---

## 📝 License

MIT License - see [LICENSE](LICENSE) file

---

## 🆘 Support

- 📖 [Salesforce Agentforce Docs](https://developer.salesforce.com/docs/agentforce)
- 💬 [Trailblazer Community](https://trailblazer.salesforce.com)
- 🐛 [Report Issues](https://github.com/Alinahvi/searchprograms-v4/issues)

---

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

---

**Version**: 4.0.0 | **Status**: ✅ Production Ready | **Tests**: 8/8 Passing

**Built with ❤️ for Salesforce Enablement Teams**

