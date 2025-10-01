#!/usr/bin/env python3
"""
Content Search 100 Utterance Test Script
Tests content search functionality with 100 diverse utterances in 10 batches
"""

import requests
import json
import time
import random

# MCP Server Configuration
MCP_BASE_URL = "http://localhost:8787"
CONTENT_SEARCH_TOOL = "content_search"

# 100 Test Utterances for Content Search
TEST_UTTERANCES = [
    # Basic Content Searches (20)
    "Find data cloud content",
    "Show me sales cloud training materials",
    "Search for marketing cloud resources",
    "Get service cloud documentation",
    "Look for platform content",
    "Find analytics training",
    "Show me automation guides",
    "Search for integration content",
    "Get security best practices",
    "Find mobile development resources",
    "Show me AI and machine learning content",
    "Search for cloud computing materials",
    "Get digital transformation guides",
    "Find customer success stories",
    "Show me implementation guides",
    "Search for troubleshooting content",
    "Get performance optimization guides",
    "Find scalability resources",
    "Show me architecture patterns",
    "Search for best practices content",
    
    # Product-Specific Searches (20)
    "Data Cloud platform training",
    "Sales Cloud CRM courses",
    "Marketing Cloud automation",
    "Service Cloud support tools",
    "Commerce Cloud e-commerce",
    "Experience Cloud portals",
    "MuleSoft integration platform",
    "Tableau analytics dashboard",
    "Slack collaboration tools",
    "Heroku cloud platform",
    "Einstein AI features",
    "Lightning Web Components",
    "Apex development guides",
    "Flow automation builder",
    "Process Builder workflows",
    "Validation rules setup",
    "Custom objects creation",
    "Reports and dashboards",
    "Data loader tools",
    "Sandbox management",
    
    # Role-Based Searches (20)
    "Content for sales representatives",
    "Training for account executives",
    "Resources for solution architects",
    "Guides for system administrators",
    "Materials for developers",
    "Content for project managers",
    "Training for business analysts",
    "Resources for consultants",
    "Guides for technical leads",
    "Materials for product managers",
    "Content for customer success",
    "Training for support teams",
    "Resources for marketing teams",
    "Guides for sales operations",
    "Materials for IT teams",
    "Content for executives",
    "Training for new hires",
    "Resources for experienced users",
    "Guides for power users",
    "Materials for end users",
    
    # Industry-Specific Searches (20)
    "Healthcare industry solutions",
    "Financial services content",
    "Manufacturing automation",
    "Retail commerce solutions",
    "Education platform tools",
    "Government compliance guides",
    "Non-profit organization resources",
    "Real estate management tools",
    "Media and entertainment solutions",
    "Travel and hospitality guides",
    "Energy sector resources",
    "Telecommunications tools",
    "Automotive industry solutions",
    "Aerospace and defense guides",
    "Consumer goods resources",
    "Professional services tools",
    "Technology sector solutions",
    "Consulting industry guides",
    "Legal services resources",
    "Insurance industry tools",
    
    # Advanced Content Searches (20)
    "Advanced data modeling techniques",
    "Complex integration patterns",
    "Enterprise architecture best practices",
    "Security implementation guides",
    "Performance tuning strategies",
    "Scalability planning resources",
    "Disaster recovery procedures",
    "Backup and restore guides",
    "Monitoring and alerting setup",
    "Logging and debugging tools",
    "Testing strategies and frameworks",
    "Code review best practices",
    "Documentation standards",
    "Change management processes",
    "Release management guides",
    "Deployment strategies",
    "Environment management",
    "User training programs",
    "Support escalation procedures",
    "Troubleshooting methodologies"
]

def test_content_search_utterance(utterance, batch_num, utterance_num):
    """Test a single content search utterance"""
    try:
        # Prepare the request
        payload = {
            "tool": CONTENT_SEARCH_TOOL,
            "utterance": utterance,
            "parameters": {
                "topic": extract_topic(utterance),
                "source": "ANY",
                "limitN": 10,
                "includeSemantic": True,
                "includePersonalization": True,
                "includeQuality": True,
                "includeLifecycle": True,
                "includeAnalytics": True
            }
        }
        
        # Make the request
        response = requests.post(
            f"{MCP_BASE_URL}/route",
            json={"text": utterance},
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            
            # Check if tool was detected
            if "tool" in result and result["tool"] == "content_search":
                # Tool was detected successfully
                return {
                    "utterance": utterance,
                    "batch": batch_num,
                    "number": utterance_num,
                    "success": True,
                    "message_length": 0,  # MCP only returns tool detection, not actual content
                    "results_count": 0,
                    "error": None
                }
            else:
                # Tool was not detected
                return {
                    "utterance": utterance,
                    "batch": batch_num,
                    "number": utterance_num,
                    "success": False,
                    "message_length": 0,
                    "results_count": 0,
                    "error": f"Tool not detected: {result.get('error', 'Unknown error')}"
                }
        else:
            return {
                "utterance": utterance,
                "batch": batch_num,
                "number": utterance_num,
                "success": False,
                "message_length": 0,
                "results_count": 0,
                "error": f"HTTP {response.status_code}: {response.text}"
            }
            
    except Exception as e:
        return {
            "utterance": utterance,
            "batch": batch_num,
            "number": utterance_num,
            "success": False,
            "message_length": 0,
            "results_count": 0,
            "error": str(e)
        }

def extract_topic(utterance):
    """Extract topic from utterance for better search"""
    utterance_lower = utterance.lower()
    
    if "data cloud" in utterance_lower:
        return "Data Cloud"
    elif "sales cloud" in utterance_lower:
        return "Sales Cloud"
    elif "marketing cloud" in utterance_lower:
        return "Marketing Cloud"
    elif "service cloud" in utterance_lower:
        return "Service Cloud"
    elif "platform" in utterance_lower:
        return "Platform"
    elif "analytics" in utterance_lower:
        return "Analytics"
    elif "ai" in utterance_lower or "machine learning" in utterance_lower:
        return "AI/ML"
    else:
        return None

def run_batch_test(batch_num, utterances):
    """Run a batch of 10 utterances"""
    print(f"\n=== BATCH {batch_num}: Testing {len(utterances)} utterances ===")
    
    batch_results = []
    for i, utterance in enumerate(utterances, 1):
        print(f"  {i:2d}. Testing: {utterance[:50]}{'...' if len(utterance) > 50 else ''}")
        
        result = test_content_search_utterance(utterance, batch_num, i)
        batch_results.append(result)
        
        # Add small delay to avoid overwhelming the server
        time.sleep(0.5)
        
        # Print result
        status = "✅" if result["success"] else "❌"
        print(f"      {status} Success: {result['success']}, Results: {result['results_count']}, Length: {result['message_length']}")
        if result["error"]:
            print(f"      Error: {result['error']}")
    
    return batch_results

def main():
    """Main test execution"""
    print("=== Content Search 100 Utterance Test ===")
    print(f"Testing {len(TEST_UTTERANCES)} utterances in 10 batches of 10 each")
    print(f"MCP Server: {MCP_BASE_URL}")
    print(f"Tool: {CONTENT_SEARCH_TOOL}")
    
    # Check if MCP server is running
    try:
        response = requests.get(f"{MCP_BASE_URL}/health", timeout=5)
        if response.status_code != 200:
            print("❌ MCP server is not responding properly")
            return
    except Exception as e:
        print(f"❌ Cannot connect to MCP server: {e}")
        return
    
    print("✅ MCP server is running")
    
    # Run tests in 10 batches
    all_results = []
    for batch_num in range(1, 11):
        start_idx = (batch_num - 1) * 10
        end_idx = start_idx + 10
        batch_utterances = TEST_UTTERANCES[start_idx:end_idx]
        
        batch_results = run_batch_test(batch_num, batch_utterances)
        all_results.extend(batch_results)
        
        # Add delay between batches
        if batch_num < 10:
            print(f"  Waiting 2 seconds before next batch...")
            time.sleep(2)
    
    # Generate summary report
    print("\n" + "="*60)
    print("FINAL SUMMARY REPORT")
    print("="*60)
    
    total_tests = len(all_results)
    successful_tests = sum(1 for r in all_results if r["success"])
    failed_tests = total_tests - successful_tests
    
    print(f"Total Tests: {total_tests}")
    print(f"Successful: {successful_tests} ({successful_tests/total_tests*100:.1f}%)")
    print(f"Failed: {failed_tests} ({failed_tests/total_tests*100:.1f}%)")
    
    # Results count analysis
    results_with_content = sum(1 for r in all_results if r["results_count"] > 0)
    print(f"Tests with Results: {results_with_content} ({results_with_content/total_tests*100:.1f}%)")
    
    # Message length analysis
    avg_message_length = sum(r["message_length"] for r in all_results) / total_tests
    print(f"Average Message Length: {avg_message_length:.0f} characters")
    
    # Show failed tests
    if failed_tests > 0:
        print(f"\nFailed Tests ({failed_tests}):")
        for result in all_results:
            if not result["success"]:
                print(f"  - {result['utterance'][:50]}{'...' if len(result['utterance']) > 50 else ''}")
                print(f"    Error: {result['error']}")
    
    # Show successful tests with no results
    no_results_tests = [r for r in all_results if r["success"] and r["results_count"] == 0]
    if no_results_tests:
        print(f"\nSuccessful Tests with No Results ({len(no_results_tests)}):")
        for result in no_results_tests[:10]:  # Show first 10
            print(f"  - {result['utterance'][:50]}{'...' if len(result['utterance']) > 50 else ''}")
        if len(no_results_tests) > 10:
            print(f"  ... and {len(no_results_tests) - 10} more")
    
    print("\n=== Test Complete ===")

if __name__ == "__main__":
    main()
