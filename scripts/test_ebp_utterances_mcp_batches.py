#!/usr/bin/env python3
"""
Test EBP Agent Utterances via MCP Server in 10 Batches
Optimized for CPU usage with 12 utterances per batch
"""

import requests
import json
import time
from typing import List, Dict, Any

def test_utterance_batch(utterances: List[str], batch_num: int) -> Dict[str, Any]:
    """Test a batch of utterances via MCP server"""
    
    results = {
        'batch': batch_num,
        'total': len(utterances),
        'successful': 0,
        'failed': 0,
        'details': []
    }
    
    print(f"\n🔍 Testing Batch {batch_num} ({len(utterances)} utterances)")
    print("-" * 60)
    
    for i, utterance in enumerate(utterances, 1):
        try:
            # Send request to MCP server
            response = requests.post(
                'http://localhost:8787/route',
                json={'text': utterance},
                timeout=10
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if 'error' in data:
                    print(f"❌ {i:2d}. {utterance[:50]}...")
                    print(f"    Error: {data['error']}")
                    results['failed'] += 1
                    results['details'].append({
                        'utterance': utterance,
                        'status': 'failed',
                        'error': data['error']
                    })
                else:
                    print(f"✅ {i:2d}. {utterance[:50]}...")
                    print(f"    Tool: {data.get('tool', 'Unknown')}")
                    results['successful'] += 1
                    results['details'].append({
                        'utterance': utterance,
                        'status': 'success',
                        'tool': data.get('tool'),
                        'args': data.get('args', {})
                    })
            else:
                print(f"❌ {i:2d}. {utterance[:50]}...")
                print(f"    HTTP Error: {response.status_code}")
                results['failed'] += 1
                results['details'].append({
                    'utterance': utterance,
                    'status': 'failed',
                    'error': f'HTTP {response.status_code}'
                })
                
        except Exception as e:
            print(f"❌ {i:2d}. {utterance[:50]}...")
            print(f"    Exception: {str(e)}")
            results['failed'] += 1
            results['details'].append({
                'utterance': utterance,
                'status': 'failed',
                'error': str(e)
            })
        
        # Small delay between requests to avoid overwhelming the server
        time.sleep(0.1)
    
    success_rate = (results['successful'] / results['total']) * 100
    print(f"\n📊 Batch {batch_num} Results: {results['successful']}/{results['total']} ({success_rate:.1f}%)")
    
    return results

def load_ebp_utterances() -> Dict[str, List[str]]:
    """Load EBP utterances from the generated file"""
    
    utterances = {
        'kpi_analyze': [
            "Show me avg calls in Germany for EMEA ENTR",
            "What's the average ACV for AMER ACC this quarter?",
            "Compare coverage rates between US and UK for this month",
            "Find meeting statistics for APAC region",
            "Show me call connections in LATAM OU",
            "Break down meetings by slow ramping vs fast ramping AEs in EMEA ENTR",
            "Compare ACV performance between ramped and ramping AEs in AMER ACC",
            "Show me coverage by ramp status in UKI OU",
            "What's the pipeline generation difference between ramped and ramping AEs in APAC?",
            "Analyze call connections by ramp status in LATAM",
            "Compare this quarter vs last quarter ACV in Germany",
            "Show me meeting trends: current vs previous quarter in EMEA ENTR",
            "What's the ACV growth from last quarter to this quarter in AMER ACC?",
            "Compare call connection improvement in UKI this quarter vs last quarter",
            "Show me coverage changes from last quarter in APAC",
            "Show me performance metrics by management level in EMEA ENTR",
            "Compare ACV by vertical industry in AMER ACC",
            "What's the meeting performance by management tier in UKI?",
            "Show me call connections by vertical in APAC",
            "Analyze coverage rates by management level in LATAM"
        ],
        'content_search': [
            "Show me ACT articles on AI and machine learning for EMEA ENTR",
            "Find ACT courses on Data Cloud implementation in AMER ACC",
            "Search for ACT content about Service Cloud best practices in UKI",
            "Look for ACT articles on Marketing Cloud automation in APAC",
            "Get ACT courses on Platform development for LATAM",
            "Find documentation about Sales Cloud configuration in EMEA ENTR",
            "Look for guides on Einstein Analytics setup in AMER ACC",
            "Search for documentation on Lightning Web Components in UKI",
            "Get guides on Apex programming best practices in APAC",
            "Find documentation about Flow automation in LATAM",
            "Show me content about healthcare industry solutions in EMEA ENTR",
            "Find articles on financial services implementations in AMER ACC",
            "Search for manufacturing industry content in UKI",
            "Look for retail industry solutions in APAC",
            "Get content about government sector implementations in LATAM",
            "Find management training content for EMEA ENTR leaders",
            "Search for executive-level Salesforce content in AMER ACC",
            "Look for team management guides in UKI",
            "Get leadership development content in APAC",
            "Find strategic planning resources for LATAM management"
        ],
        'sme_search': [
            "Search for experts on Salesforce CRM in EMEA ENTR",
            "Find SMEs for Data Cloud in AMER ACC region",
            "Who are the Service Cloud experts in UKI?",
            "Look for Marketing Cloud specialists in APAC",
            "Find Platform development experts in LATAM",
            "Who knows about healthcare industry solutions in EMEA ENTR?",
            "Find experts on financial services implementations in AMER ACC",
            "Search for manufacturing industry specialists in UKI",
            "Look for retail industry experts in APAC",
            "Who are the government sector specialists in LATAM?",
            "Find Apex programming experts in EMEA ENTR",
            "Who knows about Lightning Web Components in AMER ACC?",
            "Search for Flow automation specialists in UKI",
            "Look for Einstein Analytics experts in APAC",
            "Find Integration specialists in LATAM",
            "Who are the management consultants in EMEA ENTR?",
            "Find executive advisors in AMER ACC",
            "Search for leadership coaches in UKI",
            "Look for strategic advisors in APAC",
            "Who are the change management experts in LATAM?"
        ],
        'future_pipeline': [
            "What are the top renewal products for UKI OU?",
            "Show me renewal opportunities for EMEA ENTR",
            "Generate renewal pipeline for AMER ACC",
            "Find renewal opportunities in APAC region",
            "What are the best renewal products for LATAM?",
            "Show me cross-sell opportunities for Data Cloud in EMEA ENTR",
            "Generate cross-sell pipeline for Service Cloud in AMER ACC",
            "Find cross-sell opportunities for Marketing Cloud in UKI",
            "What are the top cross-sell products for APAC?",
            "Create cross-sell opportunities for Platform in LATAM",
            "Show me upsell potential for Einstein Analytics in EMEA ENTR",
            "Generate upsell pipeline for Lightning Web Components in AMER ACC",
            "Find upsell opportunities for Apex in UKI",
            "What are the highest value upsell products for APAC?",
            "Create upsell opportunities for Flow in LATAM",
            "What are the top products for healthcare industry in EMEA ENTR?",
            "Show me opportunities for financial services in AMER ACC",
            "Generate pipeline for manufacturing industry in UKI",
            "Find opportunities for retail sector in APAC",
            "What are the best products for government sector in LATAM?"
        ],
        'open_pipe_analyze': [
            "Show me open pipe analysis for EMEA ENTR by stage",
            "What products are in the passed stage for AMER ACC?",
            "Analyze open pipe by stage for UKI OU",
            "Show me stage breakdown for APAC region",
            "What's the open pipe analysis for LATAM by stage?",
            "Show me Data Cloud products in open pipe for EMEA ENTR",
            "What Service Cloud opportunities are in open pipe for AMER ACC?",
            "Analyze Marketing Cloud open pipe for UKI",
            "Show me Platform products in open pipe for APAC",
            "What Einstein Analytics opportunities are open for LATAM?",
            "Show me healthcare industry open pipe for EMEA ENTR",
            "What financial services opportunities are open for AMER ACC?",
            "Analyze manufacturing industry open pipe for UKI",
            "Show me retail sector open pipe for APAC",
            "What government sector opportunities are open for LATAM?",
            "Show me high-value open pipe opportunities for EMEA ENTR",
            "What are the largest open pipe deals for AMER ACC?",
            "Analyze open pipe by deal size for UKI",
            "Show me strategic open pipe opportunities for APAC",
            "What are the priority open pipe deals for LATAM?"
        ],
        'workflow': [
            "Show me the workflow for lead qualification in EMEA ENTR",
            "What's the process for opportunity management in AMER ACC?",
            "Guide me through the sales process workflow in UKI",
            "Show me the customer onboarding workflow in APAC",
            "What's the process for contract renewal in LATAM?",
            "Show me the management approval workflow in EMEA ENTR",
            "What's the process for budget approval in AMER ACC?",
            "Guide me through the performance review workflow in UKI",
            "Show me the strategic planning workflow in APAC",
            "What's the process for team management in LATAM?",
            "Show me the deployment workflow for EMEA ENTR",
            "What's the process for code review in AMER ACC?",
            "Guide me through the testing workflow in UKI",
            "Show me the release management workflow in APAC",
            "What's the process for system maintenance in LATAM?",
            "Show me the healthcare compliance workflow in EMEA ENTR",
            "What's the process for financial services approval in AMER ACC?",
            "Guide me through the manufacturing quality workflow in UKI",
            "Show me the retail inventory workflow in APAC",
            "What's the process for government procurement in LATAM?"
        ]
    }
    
    return utterances

def create_batches(utterances: Dict[str, List[str]], batch_size: int = 12) -> List[List[str]]:
    """Create batches of utterances for testing"""
    
    # Flatten all utterances into a single list
    all_utterances = []
    for action, action_utterances in utterances.items():
        for utterance in action_utterances:
            all_utterances.append((action, utterance))
    
    # Create batches
    batches = []
    for i in range(0, len(all_utterances), batch_size):
        batch = all_utterances[i:i + batch_size]
        batches.append(batch)
    
    return batches

def main():
    """Main testing function"""
    
    print("🚀 EBP Agent Utterances MCP Testing - 10 Batches")
    print("=" * 80)
    
    # Check if MCP server is running
    try:
        response = requests.get('http://localhost:8787/health', timeout=5)
        if response.status_code != 200:
            print("❌ MCP server is not responding properly")
            return
    except Exception as e:
        print(f"❌ Cannot connect to MCP server: {e}")
        print("Please ensure the MCP server is running on localhost:8787")
        return
    
    print("✅ MCP server is running")
    
    # Load utterances
    utterances = load_ebp_utterances()
    
    # Create batches
    batches = create_batches(utterances, batch_size=12)
    
    print(f"📊 Total utterances: {sum(len(action_utterances) for action_utterances in utterances.values())}")
    print(f"📊 Number of batches: {len(batches)}")
    print(f"📊 Batch size: 12 utterances")
    
    # Test each batch
    all_results = []
    total_successful = 0
    total_failed = 0
    
    for i, batch in enumerate(batches, 1):
        # Extract just the utterances for this batch
        batch_utterances = [utterance for action, utterance in batch]
        
        # Test the batch
        result = test_utterance_batch(batch_utterances, i)
        all_results.append(result)
        
        total_successful += result['successful']
        total_failed += result['failed']
        
        # Pause between batches to optimize CPU usage
        if i < len(batches):
            print(f"\n⏳ Pausing 2 seconds before next batch...")
            time.sleep(2)
    
    # Final summary
    total_utterances = total_successful + total_failed
    overall_success_rate = (total_successful / total_utterances) * 100
    
    print("\n" + "=" * 80)
    print("🎯 FINAL RESULTS")
    print("=" * 80)
    print(f"Total utterances tested: {total_utterances}")
    print(f"Successful: {total_successful}")
    print(f"Failed: {total_failed}")
    print(f"Overall Success Rate: {overall_success_rate:.1f}%")
    
    # Save detailed results
    results_file = "ebp_utterances_mcp_test_results.json"
    with open(results_file, 'w') as f:
        json.dump({
            'summary': {
                'total_utterances': total_utterances,
                'successful': total_successful,
                'failed': total_failed,
                'success_rate': overall_success_rate
            },
            'batch_results': all_results
        }, f, indent=2)
    
    print(f"\n💾 Detailed results saved to: {results_file}")

if __name__ == "__main__":
    main()
