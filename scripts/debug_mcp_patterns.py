#!/usr/bin/env python3
"""
Debug MCP Pattern Matching
Test individual patterns to see what's working and what's not
"""

import re

def test_patterns():
    """Test individual patterns"""
    
    # Test utterances
    test_utterances = [
        "Show me avg calls in Germany",
        "Show me calls in Germany and break it down based on slow ramping and fast ramping AEs",
        "Compare Coverage in AMER ACC for this month and this month last year",
        "Show me average ACV for AMER ACC",
        "Find meetings data for EMEA region",
        "Show me call connections in UKI",
        "Average meetings per AE in AMER",
        "Coverage rates by country",
        "ACV performance in Germany",
        "Meeting statistics for US AEs",
        "Show me ramp status analysis for UKI region"
    ]
    
    # KPI patterns
    kpi_patterns = [
        r'kpi', r'key performance', r'performance analysis', r'metrics',
        r'quarterly results', r'performance indicators', r'avg calls', r'average calls',
        r'calls.*germany', r'calls.*break.*down', r'ramping.*aes', r'ramp.*status',
        r'coverage', r'meetings', r'acv', r'pipeline generation', r'call connections',
        r'meeting statistics', r'performance.*germany', r'performance.*us',
        r'compare.*coverage', r'this month', r'last year', r'break.*down',
        r'slow ramping', r'fast ramping', r'ramp.*analysis'
    ]
    
    print("🔍 Testing KPI Pattern Matching")
    print("=" * 60)
    
    for utterance in test_utterances:
        print(f"\nUtterance: '{utterance}'")
        text_lower = utterance.lower()
        matched_patterns = []
        
        for pattern in kpi_patterns:
            if re.search(pattern, text_lower):
                matched_patterns.append(pattern)
        
        if matched_patterns:
            print(f"✅ Matched patterns: {matched_patterns}")
        else:
            print("❌ No patterns matched")
    
    print("\n" + "=" * 60)
    print("🔍 Testing OU Pattern Matching")
    print("=" * 60)
    
    # OU patterns
    ou_patterns = {
        r'AMER\s+ACC(?:\s+OU)?': 'AMER ACC',
        r'AMER-ACC': 'AMER ACC',
        r'ACC\s+in\s+AMER': 'AMER ACC',
        r'EMEA\s+ENTR(?:AISE)?': 'EMEA ENTR',
        r'EMEA-ENTR': 'EMEA ENTR',
        r'Enterprise\s+EMEA': 'EMEA ENTR',
        r'SMB\s*-\s*AMER\s+SMB': 'SMB - AMER SMB',
        r'SMB\s*-\s*EMEA\s+SMB': 'SMB - EMEA SMB',
        r'UKI': 'UKI',
        r'LATAM': 'LATAM',
        r'ANZ': 'ANZ',
        r'APAC': 'APAC',
        r'AMER': 'AMER'
    }
    
    ou_test_utterances = [
        "Show me KPI analysis for AMER ACC",
        "What's the performance metrics for SMB - AMER SMB in US",
        "Find opportunities in stage 3 or higher for EMEA SMB",
        "Show me calls in Germany and break it down based on slow ramping and fast ramping AEs",
        "Compare Coverage in AMER ACC for this month and this month last year"
    ]
    
    for utterance in ou_test_utterances:
        print(f"\nUtterance: '{utterance}'")
        text_upper = utterance.upper()
        matched_ou = None
        
        for pattern, ou_name in ou_patterns.items():
            if re.search(pattern, text_upper):
                matched_ou = ou_name
                break
        
        if matched_ou:
            print(f"✅ Matched OU: {matched_ou}")
        else:
            print("❌ No OU matched")

if __name__ == "__main__":
    test_patterns()
