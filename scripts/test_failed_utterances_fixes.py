#!/usr/bin/env python3
"""
Test the 8 Failed Utterances with Updated Patterns
Verify that the fixes work for the previously failed utterances
"""

import requests
import json
import time

def test_failed_utterances():
    """Test the 8 previously failed utterances"""
    
    # The 8 failed utterances from the analysis
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
    
    print("🔧 Testing 8 Previously Failed Utterances with Updated Patterns")
    print("=" * 80)
    
    results = []
    
    for i, utterance in enumerate(failed_utterances, 1):
        try:
            print(f"\n🔍 Test {i}: \"{utterance}\"")
            
            # Send request to MCP server
            response = requests.post(
                'http://localhost:8787/route',
                json={'text': utterance},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if 'error' in data:
                    print(f"❌ STILL FAILED")
                    print(f"   Error: {data['error']}")
                    results.append({
                        'utterance': utterance,
                        'status': 'failed',
                        'error': data['error']
                    })
                else:
                    print(f"✅ NOW WORKING")
                    print(f"   Tool: {data.get('tool', 'Unknown')}")
                    if 'args' in data:
                        print(f"   Args: {data['args']}")
                    results.append({
                        'utterance': utterance,
                        'status': 'success',
                        'tool': data.get('tool'),
                        'args': data.get('args', {})
                    })
            else:
                print(f"❌ HTTP ERROR: {response.status_code}")
                results.append({
                    'utterance': utterance,
                    'status': 'failed',
                    'error': f'HTTP {response.status_code}'
                })
                
        except Exception as e:
            print(f"❌ EXCEPTION: {str(e)}")
            results.append({
                'utterance': utterance,
                'status': 'failed',
                'error': str(e)
            })
        
        # Small delay between requests
        time.sleep(0.2)
    
    # Summary
    successful = sum(1 for r in results if r['status'] == 'success')
    failed = len(results) - successful
    success_rate = (successful / len(results)) * 100
    
    print("\n" + "=" * 80)
    print("🎯 FIXES TEST RESULTS")
    print("=" * 80)
    print(f"Total utterances tested: {len(results)}")
    print(f"Now working: {successful}")
    print(f"Still failed: {failed}")
    print(f"Success rate: {success_rate:.1f}%")
    
    if successful > 0:
        print(f"\n✅ SUCCESSFUL FIXES:")
        for result in results:
            if result['status'] == 'success':
                print(f"   - \"{result['utterance'][:50]}...\" → {result['tool']}")
    
    if failed > 0:
        print(f"\n❌ STILL FAILING:")
        for result in results:
            if result['status'] == 'failed':
                print(f"   - \"{result['utterance'][:50]}...\" → {result['error']}")
    
    # Save results
    with open('failed_utterances_fix_results.json', 'w') as f:
        json.dump({
            'summary': {
                'total': len(results),
                'successful': successful,
                'failed': failed,
                'success_rate': success_rate
            },
            'results': results
        }, f, indent=2)
    
    print(f"\n💾 Results saved to: failed_utterances_fix_results.json")
    
    return results

if __name__ == "__main__":
    # Check if MCP server is running
    try:
        response = requests.get('http://localhost:8787/health', timeout=5)
        if response.status_code != 200:
            print("❌ MCP server is not responding properly")
            exit(1)
    except Exception as e:
        print(f"❌ Cannot connect to MCP server: {e}")
        print("Please ensure the MCP server is running on localhost:8787")
        exit(1)
    
    print("✅ MCP server is running")
    
    # Test the failed utterances
    test_failed_utterances()
