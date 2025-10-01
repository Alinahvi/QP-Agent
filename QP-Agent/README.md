# QP Agent - Salesforce AI Agent Implementation

## Overview
This repository contains the core Apex code for the QP (Query Processing) Agent system, a Salesforce AI agent implementation that provides intelligent data analysis, pipeline management, and knowledge retrieval capabilities.

## Purpose
- **Version Control**: Maintain proper versioning of agent-related Apex code
- **Backup & Recovery**: Provide rollback capabilities when deployments break
- **Development Workflow**: Support collaborative development with proper branching strategy
- **Documentation**: Centralized documentation for agent functionality

## Repository Structure
```
QP-Agent/
├── src/
│   ├── classes/           # Apex classes
│   ├── triggers/          # Apex triggers
│   ├── flows/             # Salesforce flows
│   └── objects/           # Custom objects and fields
├── docs/                  # Documentation and guides
├── scripts/               # Deployment and utility scripts
├── tests/                 # Test data and scenarios
└── releases/              # Versioned releases
```

## Core Agent Components

### 1. KPI Analysis System
- **ANAgentKPIAnalysisHandler** - Main entry point for KPI analysis
- **ANAgentKPIAnalysisService** - Core business logic for KPI processing
- **ANAgentKPIAnalysisV2/V3/V4** - Versioned implementations

### 2. Pipeline Analysis
- **ANAgentOpenPipeAnalysisService** - Open pipeline analysis
- **ANAgentFuturePipelineAnalysisService** - Future pipeline forecasting
- **ANAgentPipelineSearchService** - Pipeline search capabilities

### 3. Knowledge Management
- **ANAgentKnowledgeHandler** - Knowledge article retrieval
- **ANAgentKnowledgeService** - Core knowledge processing logic

### 4. Utility Services
- **ANAgentEmailService** - Email functionality
- **ANAgentCSVService** - CSV generation and handling
- **ANAgentDateUtils** - Date manipulation utilities

## Versioning Strategy

### Branch Structure
- `main` - Production-ready code
- `develop` - Development branch
- `feature/*` - Feature development branches
- `hotfix/*` - Emergency fixes
- `release/*` - Release preparation

### Release Tags
- `v1.0.0` - Major releases
- `v1.1.0` - Minor releases  
- `v1.1.1` - Patch releases

## Getting Started

### Prerequisites
- Salesforce DX CLI
- Access to Salesforce org
- GitHub access

### Setup
1. Clone the repository
2. Set up Salesforce org connection
3. Deploy using SFDX commands
4. Run tests to verify functionality

## Deployment

### Quick Deploy
```bash
sfdx force:source:deploy -p src/classes/
```

### Full Deploy
```bash
sfdx force:source:deploy -p src/
```

## Testing
All classes include comprehensive test coverage. Run tests before deployment:
```bash
sfdx force:apex:test:run -n ANAgentKPIAnalysisHandlerTest
```

## Contributing
1. Create feature branch from `develop`
2. Make changes and add tests
3. Submit pull request
4. Code review and merge

## Support
For issues or questions:
1. Check existing documentation
2. Review test cases
3. Create GitHub issue with details

---

**Maintainer**: Ali Nahvi (Alinahvi)  
**Last Updated**: August 2025  
**Version**: 1.0.0
