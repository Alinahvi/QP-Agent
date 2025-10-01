#!/usr/bin/env python3
"""
Agent API Test Script for Content Search UAT
Tests 50 utterances and captures actual agent responses
"""

import requests
import json
import time
from datetime import datetime

# API Configuration
API_BASE_URL = "http://localhost:9999"  # Updated port
API_ENDPOINT = "/api/agent/analyze"

# Test utterances for Content Search
TEST_UTTERANCES = [
    "Show me ACT courses related to Data Cloud",
    "List Sales Cloud ACT courses created between Jan 1 and Mar 31",
    "Find Sales Cloud ACT courses with completion rate > 60%",
    "For those courses, show enrollments",
    "Show a Consensus demo on Data Cloud",
    "Find Consensus demo videos for Data Cloud created in the last quarter",
    "List ACT curricula for Sales Cloud with completion rate > 75% and show links",
    "Show ACT assets tagged Data Cloud created this year",
    "From ACT, show top 5 Sales Cloud courses by enrollment",
    "Show Consensus demos for Sales Cloud with a public preview link",
    "Find ACT courses for Marketing Cloud with completion rate > 70%",
    "Show Consensus demos for Service Cloud created in Q1 2024",
    "List ACT assets for Data Cloud with enrollment > 1000",
    "Show top 3 Consensus demos for Marketing Cloud by view count",
    "Find ACT curricula for Service Cloud with completion rate > 80%",
    "Show Consensus demos for Data Cloud with duration > 15 minutes",
    "List ACT courses for Sales Cloud created between Feb 1 and Apr 30",
    "Show Consensus demos for Service Cloud with public preview",
    "Find ACT assets for Marketing Cloud tagged with 'advanced'",
    "Show Consensus demos for Data Cloud with view count > 5000",
    "List ACT courses for Service Cloud with completion rate > 65%",
    "Show Consensus demos for Marketing Cloud created this year",
    "Find ACT curricula for Data Cloud with enrollment > 2000",
    "Show top 5 Consensus demos for Sales Cloud by engagement",
    "List ACT assets for Service Cloud with completion rate > 75%",
    "Show Consensus demos for Data Cloud with duration < 20 minutes",
    "Find ACT courses for Marketing Cloud created in the last 6 months",
    "Show Consensus demos for Service Cloud with view count > 3000",
    "List ACT curricula for Sales Cloud with completion rate > 85%",
    "Show Consensus demos for Data Cloud with public preview and high engagement",
    "Find ACT assets for Service Cloud tagged with 'integration'",
    "Show Consensus demos for Marketing Cloud with duration > 10 minutes",
    "List ACT courses for Data Cloud with enrollment > 1500",
    "Show Consensus demos for Sales Cloud created between Jan 1 and Mar 31",
    "Find ACT curricula for Marketing Cloud with completion rate > 78%",
    "Show Consensus demos for Service Cloud with view count > 4000",
    "List ACT assets for Data Cloud with completion rate > 80%",
    "Show Consensus demos for Marketing Cloud with public preview",
    "Find ACT courses for Service Cloud created in Q2 2024",
    "Show Consensus demos for Data Cloud with duration > 25 minutes",
    "List ACT curricula for Sales Cloud with enrollment > 3000",
    "Show Consensus demos for Service Cloud with view count > 6000",
    "Find ACT assets for Marketing Cloud with completion rate > 72%",
    "Show Consensus demos for Data Cloud with public preview and duration < 15 minutes",
    "List ACT courses for Service Cloud with completion rate > 68%",
    "Show Consensus demos for Marketing Cloud created in the last quarter",
    "Find ACT curricula for Data Cloud with enrollment > 2500",
    "Show Consensus demos for Sales Cloud with view count > 8000",
    "List ACT assets for Service Cloud with completion rate > 77%",
    "Show Consensus demos for Data Cloud with public preview and high view count"
]

def test_agent_api():
    """Test the agent API with all 50 utterances"""
    results = []
    
    print(f"🧪 Starting Agent API UAT Testing")
    print(f"📊 Total Utterances: {len(TEST_UTTERANCES)}")
    print(f"🌐 API Endpoint: {API_BASE_URL}{API_ENDPOINT}")
    print("=" * 60)
    
    for i, utterance in enumerate(TEST_UTTERANCES, 1):
        print(f"\n🧪 Test {i}/50: {utterance[:50]}...")
        
        try:
            # Prepare request payload
            payload = {
                "utterance": utterance,
                "source": "ACT" if "ACT" in utterance else "Consensus" if "Consensus" in utterance else "Mixed",
                "timestamp": datetime.now().isoformat()
            }
            
            # Make API request
            response = requests.post(
                f"{API_BASE_URL}{API_ENDPOINT}",
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code == 200:
                agent_response = response.json().get("response", "No response received")
                result = "PASS"
                notes = "API call successful"
            else:
                agent_response = f"API Error: {response.status_code} - {response.text}"
                result = "FAIL"
                notes = f"HTTP {response.status_code}"
                
        except requests.exceptions.Timeout:
            agent_response = "API Timeout: Request took longer than 30 seconds"
            result = "FAIL"
            notes = "Timeout"
        except requests.exceptions.ConnectionError:
            agent_response = "API Connection Error: Could not connect to agent API"
            result = "FAIL"
            notes = "Connection Error"
        except Exception as e:
            agent_response = f"Unexpected Error: {str(e)}"
            result = "FAIL"
            notes = "Unexpected Error"
        
        # Store result
        result_data = {
            "utterance_number": i,
            "utterance": utterance,
            "source_requested": "ACT" if "ACT" in utterance else "Consensus" if "Consensus" in utterance else "Mixed",
            "method_used": "API",
            "agent_response": agent_response,
            "result": result,
            "notes": notes,
            "timestamp": datetime.now().isoformat()
        }
        
        results.append(result_data)
        
        print(f"   Result: {result}")
        print(f"   Response Length: {len(agent_response)} characters")
        
        # Small delay to avoid overwhelming the API
        time.sleep(0.5)
    
    return results

def save_results(results):
    """Save results to CSV and JSON files"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    # Save as JSON
    json_filename = f"content_search_uat_results_{timestamp}.json"
    with open(json_filename, 'w') as f:
        json.dump(results, f, indent=2)
    
    # Save as CSV
    csv_filename = f"content_search_uat_results_{timestamp}.csv"
    with open(csv_filename, 'w') as f:
        f.write("Utterance #,Utterance,Source Requested,Method Used,Agent Response,Result,Notes,Timestamp\n")
        for result in results:
            f.write(f"{result['utterance_number']},\"{result['utterance']}\",{result['source_requested']},{result['method_used']},\"{result['agent_response']}\",{result['result']},{result['notes']},{result['timestamp']}\n")
    
    print(f"\n📁 Results saved to:")
    print(f"   JSON: {json_filename}")
    print(f"   CSV: {csv_filename}")
    
    return json_filename, csv_filename

def print_summary(results):
    """Print test summary"""
    total_tests = len(results)
    passed_tests = len([r for r in results if r['result'] == 'PASS'])
    failed_tests = total_tests - passed_tests
    
    print("\n" + "=" * 60)
    print("📊 UAT TESTING SUMMARY")
    print("=" * 60)
    print(f"Total Tests: {total_tests}")
    print(f"Passed: {passed_tests} ({passed_tests/total_tests*100:.1f}%)")
    print(f"Failed: {failed_tests} ({failed_tests/total_tests*100:.1f}%)")
    
    if failed_tests > 0:
        print(f"\n❌ Failed Tests:")
        for result in results:
            if result['result'] == 'FAIL':
                print(f"   Test {result['utterance_number']}: {result['notes']}")
    
    print(f"\n✅ UAT Testing Complete!")

if __name__ == "__main__":
    print("🚀 Starting Content Search UAT Testing with Agent API")
    print("=" * 60)
    
    # Run tests
    results = test_agent_api()
    
    # Save results
    json_file, csv_file = save_results(results)
    
    # Print summary
    print_summary(results)
    
    print(f"\n🎉 All 50 utterances tested and results saved!")
    print(f"📋 Check {csv_file} for detailed results table")
