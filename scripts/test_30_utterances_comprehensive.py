#!/usr/bin/env python3
"""
Comprehensive Test of 30 Agent Utterances
Tests various patterns including the specific examples provided
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
    """Test 30 comprehensive agent utterances"""
    print("🚀 Testing 30 Comprehensive Agent Utterances via MCP Path")
    print("=" * 80)
    
    # 30 test utterances including the specific examples provided
    test_utterances = [
        # Specific examples from user
        "Show me avg calls in Germany",
        "Show me calls in Germany and break it down based on slow ramping and fast ramping AEs",
        "Compare Coverage in AMER ACC for this month and this month last year",
        
        # KPI Analysis utterances
        "Show me KPI analysis for AMER ACC",
        "What's the performance metrics for SMB - AMER SMB in US",
        "Compare KPI performance between AMER ACC and EMEA ENTR",
        "Show me ramp status analysis for UKI region",
        "What are the quarterly results for AMER ACC this quarter",
        "Show me average ACV for AMER ACC",
        "Find meetings data for EMEA region",
        "What's the pipeline generation for APAC",
        "Show me call connections in UKI",
        "Average meetings per AE in AMER",
        "Coverage rates by country",
        "ACV performance in Germany",
        "Meeting statistics for US AEs",
        
        # Open Pipe Analysis utterances
        "Show me all products that passed stage 4 within AMER ACC",
        "Find opportunities in stage 3 or higher for EMEA ENTR",
        "Open pipe analysis for UKI with country = US, top 20",
        "Compare last quarter open pipe post stage 4 for AMER ACC",
        "Show me open pipe for AMER ACC where amount > 1M and stage in (3,4,5)",
        "Filter to Data Cloud and Sales Cloud only",
        "Open pipe passed stage 4 in AMER ACC, country = US, top 20",
        "Find opportunities in stage 3 or higher for EMEA SMB",
        
        # Content Search utterances
        "Find recent ACT courses on Data Cloud",
        "Search for Consensus content about Salesforce CRM",
        "Show me ACT articles on AI and machine learning",
        "Find content about Service Cloud implementation",
        "Search for ACT courses on Marketing Cloud",
        "Find Consensus demos about Einstein AI",
        
        # SME Search utterances
        "Find SMEs for Data Cloud in AMER ACC",
        "Search for experts on Salesforce CRM in EMEA",
        "Who are the SMEs for Service Cloud in UKI region",
        "Find subject matter experts for Marketing Cloud",
        "Search for SMEs on Einstein AI in APAC",
        "Find experts for Commerce Cloud in LATAM",
        
        # Future Pipeline utterances
        "Generate future pipeline for AMER ACC next quarter",
        "Show me cross-sell opportunities for EMEA ENTR",
        "What are the top renewal products for UKI",
        "Create pipeline for Data Cloud in SMB - AMER SMB",
        "Show me upsell opportunities for AMER ACC",
        "Generate renewal pipeline for EMEA SMB",
        
        # Workflow utterances
        "How do I set up a new sales process",
        "What's the workflow for opportunity management",
        "Show me the procedure for lead qualification",
        "How to configure Einstein AI for sales",
        "What's the process for data migration",
        "Show me the workflow for user onboarding",
        
        # Edge cases and error handling
        "Show me something random that doesn't match any tool",
        "KPI analysis without specifying OU",
        "Open pipe analysis for invalid OU",
        "Find content without specifying topic",
        "Search for experts without region or expertise",
        "Generate pipeline without OU specification"
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
