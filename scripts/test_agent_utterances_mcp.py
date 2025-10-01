#!/usr/bin/env python3
"""
Test Agent Utterances using MCP Path
Tests the complete flow from natural language to MCP routing to Salesforce execution
"""

import requests
import json
import time

# MCP Server endpoint
MCP_BASE_URL = "http://localhost:8787"

def test_mcp_route(utterance):
    """Test MCP routing for an utterance"""
    print(f"\n🔍 Testing: '{utterance}'")
    print("-" * 60)
    
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
            print(f"✅ MCP Route Success")
            print(f"   Tool: {result.get('tool', 'N/A')}")
            print(f"   Args: {json.dumps(result.get('args', {}), indent=2)}")
            
            # If no error, test the analyze endpoint
            if 'error' not in result:
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
                    print(f"   Message: {analyze_result.get('message', 'N/A')}")
                else:
                    print(f"❌ MCP Analyze Failed: {analyze_response.status_code}")
            else:
                print(f"❌ MCP Route Error: {result.get('error', 'Unknown error')}")
                
        else:
            print(f"❌ MCP Route Failed: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"❌ Exception: {str(e)}")

def main():
    """Test various agent utterances"""
    print("🚀 Testing Agent Utterances via MCP Path")
    print("=" * 60)
    
    # Test utterances for different tools
    test_utterances = [
        # KPI Analysis utterances (our fixed functionality)
        "Show me KPI analysis for AMER ACC",
        "What's the performance metrics for SMB - AMER SMB in US",
        "Compare KPI performance between AMER ACC and EMEA ENTR",
        "Show me ramp status analysis for UKI region",
        "What are the quarterly results for AMER ACC this quarter",
        
        # Open Pipe Analysis utterances
        "Show me all products that passed stage 4 within AMER ACC",
        "Find opportunities in stage 3 or higher for EMEA ENTR",
        "Open pipe analysis for UKI with country = US, top 20",
        "Compare last quarter open pipe post stage 4 for AMER ACC",
        
        # Content Search utterances
        "Find recent ACT courses on Data Cloud",
        "Search for Consensus content about Salesforce CRM",
        "Show me ACT articles on AI and machine learning",
        "Find content about Service Cloud implementation",
        
        # SME Search utterances
        "Find SMEs for Data Cloud in AMER ACC",
        "Search for experts on Salesforce CRM in EMEA",
        "Who are the SMEs for Service Cloud in UKI region",
        "Find subject matter experts for Marketing Cloud",
        
        # Future Pipeline utterances
        "Generate future pipeline for AMER ACC next quarter",
        "Show me cross-sell opportunities for EMEA ENTR",
        "What are the top renewal products for UKI",
        "Create pipeline for Data Cloud in SMB - AMER SMB",
        
        # Workflow utterances
        "How do I set up a new sales process",
        "What's the workflow for opportunity management",
        "Show me the procedure for lead qualification",
        
        # Edge cases and error handling
        "Show me something random that doesn't match any tool",
        "KPI analysis without specifying OU",
        "Open pipe analysis for invalid OU",
    ]
    
    # Test each utterance
    for i, utterance in enumerate(test_utterances, 1):
        print(f"\n📝 Test {i}/{len(test_utterances)}")
        test_mcp_route(utterance)
        time.sleep(0.5)  # Small delay between tests
    
    print(f"\n🎯 Testing Complete!")
    print(f"   Total utterances tested: {len(test_utterances)}")
    print(f"   MCP Server: {MCP_BASE_URL}")

if __name__ == "__main__":
    main()
