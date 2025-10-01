#!/usr/bin/env python3
"""
Debug Pattern Matching for Failed Utterances
Test individual patterns to see why they're not matching
"""

import re

def test_patterns():
    """Test individual patterns against failed utterances"""
    
    # Failed utterances
    failed_utterances = [
        "Show me meeting trends: current vs previous quarter in EMEA ENTR",
        "Compare call connection improvement in UKI this quarter vs last quarter", 
        "What's the meeting performance by management tier in UKI?",
        "Look for retail industry solutions in APAC",
        "Find management training content for EMEA ENTR leaders",
        "Get leadership development content in APAC",
        "Find strategic planning resources for LATAM management",
        "Search for leadership coaches in UKI"
    ]
    
    # KPI patterns
    kpi_patterns = [
        r'trends', r'meeting trends', r'performance trends', r'improvement',
        r'call connection improvement', r'management tier', r'management level',
        r'performance by management', r'management performance'
    ]
    
    # Content search patterns
    content_patterns = [
        r'retail industry', r'retail.*solutions', r'management training', r'leadership development',
        r'strategic planning', r'planning resources', r'industry solutions', r'management content'
    ]
    
    # SME search patterns
    sme_patterns = [
        r'leadership coaches', r'coaches', r'product expert', r'product specialist', r'technical expert'
    ]
    
    print("🔍 Debugging Pattern Matching for Failed Utterances")
    print("=" * 80)
    
    for utterance in failed_utterances:
        print(f"\n📝 Utterance: \"{utterance}\"")
        utterance_lower = utterance.lower()
        
        # Test KPI patterns
        kpi_matches = []
        for pattern in kpi_patterns:
            if re.search(pattern, utterance_lower):
                kpi_matches.append(pattern)
        
        # Test Content patterns
        content_matches = []
        for pattern in content_patterns:
            if re.search(pattern, utterance_lower):
                content_matches.append(pattern)
        
        # Test SME patterns
        sme_matches = []
        for pattern in sme_patterns:
            if re.search(pattern, utterance_lower):
                sme_matches.append(pattern)
        
        print(f"   KPI matches: {kpi_matches}")
        print(f"   Content matches: {content_matches}")
        print(f"   SME matches: {sme_matches}")
        
        if not kpi_matches and not content_matches and not sme_matches:
            print("   ❌ NO MATCHES FOUND")
        else:
            print("   ✅ MATCHES FOUND")

def test_specific_patterns():
    """Test specific patterns that should match"""
    
    print("\n" + "=" * 80)
    print("🎯 Testing Specific Patterns")
    print("=" * 80)
    
    test_cases = [
        ("Show me meeting trends: current vs previous quarter in EMEA ENTR", "trends"),
        ("Compare call connection improvement in UKI this quarter vs last quarter", "improvement"),
        ("What's the meeting performance by management tier in UKI?", "management tier"),
        ("Look for retail industry solutions in APAC", "retail industry"),
        ("Find management training content for EMEA ENTR leaders", "management training"),
        ("Get leadership development content in APAC", "leadership development"),
        ("Find strategic planning resources for LATAM management", "strategic planning"),
        ("Search for leadership coaches in UKI", "leadership coaches")
    ]
    
    for utterance, expected_pattern in test_cases:
        utterance_lower = utterance.lower()
        match = re.search(expected_pattern, utterance_lower)
        print(f"\"{utterance}\"")
        print(f"   Pattern: {expected_pattern}")
        print(f"   Match: {'✅ YES' if match else '❌ NO'}")
        if match:
            print(f"   Matched text: '{match.group()}'")
        print()

if __name__ == "__main__":
    test_patterns()
    test_specific_patterns()
