#!/usr/bin/env python3
"""
Test Improved MCP Patterns with Specific Examples
Tests the user's specific examples and other problematic utterances
"""

import requests
import json
import time

# MCP Server endpoint
MCP_BASE_URL = "http://localhost:8787"

def test_mcp_route(utterance, test_number):
    """Test MCP routing for an utterance"""
    print(f"\n🔍 Test {test_number}: '{utterance}'")
    print("-" * 80)
    
    try:
        # Route the utterance through MCP
        response = requests.post(
            f"{MCP_BASE_URL}/route",
            json={"text": utterance},
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            if 'error' in result:
                print(f"❌ MCP Route Error: {result['error']}")
                return False
            else:
                print(f"✅ MCP Route Success")
                print(f"   Tool: {result.get('tool', 'N/A')}")
                print(f"   Args: {json.dumps(result.get('args', {}), indent=2)}")
                
                # Test the analyze endpoint
                analyze_response = requests.post(
                    f"{MCP_BASE_URL}/analyze",
                    json=result,
                    headers={"Content-Type": "application/json"},
                    timeout=10
                )
                
                if analyze_response.status_code == 200:
                    analyze_result = analyze_response.json()
                    print(f"✅ MCP Analyze Success")
                    print(f"   Status: {analyze_result.get('status', 'N/A')}")
                    return True
                else:
                    print(f"❌ MCP Analyze Failed: {analyze_response.status_code}")
                    return False
        else:
            print(f"❌ MCP Route Failed: {response.status_code}")
            print(f"   Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Exception: {str(e)}")
        return False

def main():
    """Test improved utterances including user's specific examples"""
    print("🚀 Testing Improved MCP Patterns with Specific Examples")
    print("=" * 80)
    
    # Test utterances including the user's specific examples
    test_utterances = [
        # User's specific examples
        "Show me avg calls in Germany",
        "Show me calls in Germany and break it down based on slow ramping and fast ramping AEs",
        "Compare Coverage in AMER ACC for this month and this month last year",
        
        # Previously failing KPI utterances
        "Show me average ACV for AMER ACC",
        "Find meetings data for EMEA region",
        "What's the pipeline generation for APAC",
        "Show me call connections in UKI",
        "Average meetings per AE in AMER",
        "Coverage rates by country",
        "ACV performance in Germany",
        "Meeting statistics for US AEs",
        "Show me ramp status analysis for UKI region",
        
        # Previously failing OU detection
        "What's the performance metrics for SMB - AMER SMB in US",
        "Find opportunities in stage 3 or higher for EMEA SMB",
        "Create pipeline for Data Cloud in SMB - AMER SMB",
        "Generate renewal pipeline for EMEA SMB",
        
        # Content search improvements
        "Show me ACT articles on AI and machine learning",
        "Find content about Service Cloud implementation",
        
        # SME search improvements
        "Search for experts on Salesforce CRM in EMEA",
        
        # Future pipeline improvements
        "What are the top renewal products for UKI",
        "Filter to Data Cloud and Sales Cloud only",
        
        # Additional test cases
        "Show me KPI analysis for AMER ACC",
        "Show me all products that passed stage 4 within AMER ACC",
        "Find recent ACT courses on Data Cloud",
        "Find SMEs for Data Cloud in AMER ACC",
        "Generate future pipeline for AMER ACC next quarter",
        "How do I set up a new sales process"
    ]
    
    # Test each utterance
    success_count = 0
    error_count = 0
    
    for i, utterance in enumerate(test_utterances, 1):
        result = test_mcp_route(utterance, i)
        if result:
            success_count += 1
        else:
            error_count += 1
        time.sleep(0.2)  # Small delay between tests
    
    print(f"\n🎯 Testing Complete!")
    print(f"   Total utterances tested: {len(test_utterances)}")
    print(f"   Successful: {success_count}")
    print(f"   Errors: {error_count}")
    print(f"   Success Rate: {(success_count/len(test_utterances)*100):.1f}%")
    print(f"   MCP Server: {MCP_BASE_URL}")

if __name__ == "__main__":
    main()
