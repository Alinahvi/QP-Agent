#!/usr/bin/env python3
"""
Test utterances with MCP server
"""

import requests
import json

def test_utterance(utterance, server_url="http://localhost:8787"):
    """Test a single utterance with MCP server"""
    try:
        # Test route endpoint
        route_response = requests.post(
            f"{server_url}/route",
            json={"text": utterance},
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        if route_response.status_code == 200:
            route_data = route_response.json()
            if 'error' in route_data:
                return {
                    'utterance': utterance,
                    'route_success': False,
                    'route_error': route_data['error'],
                    'tool': None,
                    'args': None
                }
            else:
                return {
                    'utterance': utterance,
                    'route_success': True,
                    'route_error': None,
                    'tool': route_data.get('tool'),
                    'args': route_data.get('args', {})
                }
        else:
            return {
                'utterance': utterance,
                'route_success': False,
                'route_error': f"HTTP {route_response.status_code}",
                'tool': None,
                'args': None
            }
    except Exception as e:
        return {
            'utterance': utterance,
            'route_success': False,
            'route_error': str(e),
            'tool': None,
            'args': None
        }

def main():
    """Test all utterances"""
    test_utterances = [
        "Show me avg calls in Germany",
        "Show me calls in Germany and break it down based on slow ramping and fast ramping AEs",
        "Compare Coverage in AMER ACC for this month and this month last year",
        "Coverage rates by country",
        "Show me ACT articles on AI and machine learning",
        "Find content about Service Cloud implementation",
        "Search for experts on Salesforce CRM in EMEA",
        "What are the top renewal products for UKI",
        "Filter to Data Cloud and Sales Cloud only"
    ]
    
    print("🚀 MCP Server Utterance Testing")
    print("=" * 80)
    
    success_count = 0
    total_count = len(test_utterances)
    
    for i, utterance in enumerate(test_utterances, 1):
        print(f"\n🔍 Test {i}: '{utterance}'")
        print("-" * 60)
        
        result = test_utterance(utterance)
        
        if result['route_success']:
            print("✅ ROUTE SUCCESS")
            print(f"   Tool: {result['tool']}")
            print(f"   Args: {json.dumps(result['args'], indent=2)}")
            success_count += 1
        else:
            print("❌ ROUTE FAILED")
            print(f"   Error: {result['route_error']}")
    
    print(f"\n🎯 Results Summary")
    print("=" * 80)
    print(f"Total utterances tested: {total_count}")
    print(f"Successful: {success_count}")
    print(f"Failed: {total_count - success_count}")
    print(f"Success Rate: {(success_count/total_count)*100:.1f}%")

if __name__ == "__main__":
    main()
