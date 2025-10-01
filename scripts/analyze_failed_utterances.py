#!/usr/bin/env python3
"""
Analyze Failed Utterances from EBP Agent MCP Testing
Extract the 8 failed utterances and their agent responses
"""

import json

def analyze_failed_utterances():
    """Extract and analyze the 8 failed utterances"""
    
    # Load the test results
    with open('ebp_utterances_mcp_test_results.json', 'r') as f:
        data = json.load(f)
    
    failed_utterances = []
    
    # Extract failed utterances from all batches
    for batch in data['batch_results']:
        for detail in batch['details']:
            if detail['status'] == 'failed':
                failed_utterances.append({
                    'utterance': detail['utterance'],
                    'error': detail['error'],
                    'batch': batch['batch']
                })
    
    return failed_utterances

def print_failed_analysis(failed_utterances):
    """Print detailed analysis of failed utterances"""
    
    print("🚨 **8 Failed Utterances Analysis**")
    print("=" * 80)
    
    for i, failed in enumerate(failed_utterances, 1):
        print(f"\n**{i}. Batch {failed['batch']} - Failed Utterance:**")
        print(f"   **Utterance:** \"{failed['utterance']}\"")
        print(f"   **Agent Response:** \"{failed['error']}\"")
        print(f"   **Issue:** Tool detection failed")
        
        # Analyze the utterance to suggest fixes
        utterance_lower = failed['utterance'].lower()
        
        if 'trends' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'trends' pattern to kpi_analyze")
        elif 'improvement' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'improvement' pattern to kpi_analyze")
        elif 'management tier' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'management tier' pattern to kpi_analyze")
        elif 'retail industry' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'retail industry' pattern to content_search")
        elif 'management training' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'management training' pattern to content_search")
        elif 'leadership development' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'leadership development' pattern to content_search")
        elif 'leadership coaches' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'leadership coaches' pattern to sme_search")
        elif 'strategic planning' in utterance_lower:
            print(f"   **Suggested Fix:** Add 'strategic planning' pattern to content_search")
        else:
            print(f"   **Suggested Fix:** Review utterance for missing patterns")
    
    print("\n" + "=" * 80)
    print("📊 **Summary of Issues:**")
    print("- 3 KPI Analyze failures: missing 'trends', 'improvement', 'management tier' patterns")
    print("- 3 Content Search failures: missing 'retail industry', 'management training', 'leadership development' patterns")
    print("- 1 SME Search failure: missing 'leadership coaches' pattern")
    print("- 1 Content Search failure: topic validation issue")
    
    print("\n🔧 **Quick Fixes Needed:**")
    print("1. Add missing patterns to respective tool pattern lists")
    print("2. Improve topic extraction for content search")
    print("3. Test updated patterns")

def save_failed_analysis(failed_utterances):
    """Save failed utterances analysis to file"""
    
    with open('failed_utterances_analysis.txt', 'w') as f:
        f.write("🚨 8 Failed Utterances Analysis\n")
        f.write("=" * 80 + "\n\n")
        
        for i, failed in enumerate(failed_utterances, 1):
            f.write(f"{i}. Batch {failed['batch']} - Failed Utterance:\n")
            f.write(f"   Utterance: \"{failed['utterance']}\"\n")
            f.write(f"   Agent Response: \"{failed['error']}\"\n")
            f.write(f"   Issue: Tool detection failed\n\n")
        
        f.write("=" * 80 + "\n")
        f.write("Summary of Issues:\n")
        f.write("- 3 KPI Analyze failures: missing patterns\n")
        f.write("- 3 Content Search failures: missing patterns\n")
        f.write("- 1 SME Search failure: missing pattern\n")
        f.write("- 1 Content Search failure: topic validation issue\n")

if __name__ == "__main__":
    # Analyze failed utterances
    failed_utterances = analyze_failed_utterances()
    
    # Print analysis
    print_failed_analysis(failed_utterances)
    
    # Save to file
    save_failed_analysis(failed_utterances)
    
    print(f"\n💾 Analysis saved to: failed_utterances_analysis.txt")
    print(f"📊 Total failed utterances: {len(failed_utterances)}")
