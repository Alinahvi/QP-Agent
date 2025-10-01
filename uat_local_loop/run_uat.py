#!/usr/bin/env python3
"""
Local Loop UAT Runner for MCP Agent Integration
Tests MCP locally, then calls Salesforce Apex directly
Bypasses Zscaler issues by using local MCP + direct Apex calls
"""

import csv
import json
import time
import requests
import argparse
import os
from typing import Dict, List, Any
from dataclasses import dataclass
from datetime import datetime
import sys

@dataclass
class TestCase:
    utterance: str
    expected_tool: str
    expected_keys: str
    description: str

@dataclass
class TestResult:
    case_id: int
    utterance: str
    description: str
    mcp_success: bool
    mcp_tool: str
    mcp_args: Dict[str, Any]
    mcp_response_time_ms: float
    apex_success: bool
    apex_response: str
    apex_response_time_ms: float
    overall_success: bool
    error_message: str = ""

class LocalUATRunner:
    def __init__(self, mcp_url: str = "http://localhost:8787", sf_base_url: str = None, sf_token: str = None):
        self.mcp_url = mcp_url
        self.sf_base_url = sf_base_url
        self.sf_token = sf_token
        self.results: List[TestResult] = []
        
    def load_test_cases(self, csv_file: str) -> List[TestCase]:
        """Load test cases from CSV"""
        cases = []
        with open(csv_file, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                cases.append(TestCase(
                    utterance=row['utterance'],
                    expected_tool=row['expected_tool'],
                    expected_keys=row['expected_keys'],
                    description=row['description']
                ))
        return cases
    
    def test_mcp_route(self, utterance: str) -> tuple[bool, str, Dict[str, Any], float]:
        """Test MCP /route endpoint"""
        try:
            start_time = time.time()
            response = requests.post(
                f"{self.mcp_url}/route",
                json={"text": utterance},
                timeout=10
            )
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                data = response.json()
                if "error" in data:
                    return False, data["error"], {}, response_time
                else:
                    return True, data.get("tool", ""), data.get("args", {}), response_time
            else:
                return False, f"HTTP {response.status_code}: {response.text}", {}, response_time
                
        except Exception as e:
            return False, str(e), {}, 0
    
    def test_apex_call(self, tool: str, args: Dict[str, Any]) -> tuple[bool, str, float]:
        """Test Apex call via Salesforce REST API"""
        if not self.sf_base_url or not self.sf_token:
            return False, "Salesforce not configured", 0
            
        try:
            start_time = time.time()
            
            # Map MCP tools to Apex classes
            apex_class_map = {
                "open_pipe_analyze": "AN_OpenPipeV3_FromMCP_Simple",
                "kpi_analyze": "AN_KPI_FromMCP_Simple", 
                "content_search": "AN_SearchContent_FromMCP_Simple",
                "sme_search": "AN_SearchSME_FromMCP_Simple",
                "workflow": "AN_Workflow_FromMCP_Simple",
                "future_pipeline": "AN_FuturePipeline_FromMCP_Simple"
            }
            
            apex_class = apex_class_map.get(tool)
            if not apex_class:
                return False, f"Unknown tool: {tool}", 0
            
            # Prepare Apex REST call
            endpoint = f"{self.sf_base_url}/services/apexrest/agent/{apex_class.lower()}"
            headers = {
                'Authorization': f'Bearer {self.sf_token}',
                'Content-Type': 'application/json'
            }
            
            # Convert args to the format expected by Apex
            normalized_args_json = json.dumps(args)
            
            response = requests.post(
                endpoint,
                json={"normalizedArgsJson": normalized_args_json},
                headers=headers,
                timeout=30
            )
            
            response_time = (time.time() - start_time) * 1000
            
            if response.status_code == 200:
                return True, response.text, response_time
            else:
                return False, f"HTTP {response.status_code}: {response.text}", response_time
                
        except Exception as e:
            return False, str(e), 0
    
    def run_test_case(self, case_id: int, case: TestCase) -> TestResult:
        """Run a single test case"""
        print(f"🧪 Testing Case {case_id}: {case.description}")
        print(f"   Utterance: {case.utterance}")
        
        # Test MCP routing
        mcp_success, mcp_tool, mcp_args, mcp_time = self.test_mcp_route(case.utterance)
        
        if not mcp_success:
            print(f"   ❌ MCP failed: {mcp_tool}")
            return TestResult(
                case_id=case_id,
                utterance=case.utterance,
                description=case.description,
                mcp_success=False,
                mcp_tool=mcp_tool,
                mcp_args={},
                mcp_response_time_ms=mcp_time,
                apex_success=False,
                apex_response="",
                apex_response_time_ms=0,
                overall_success=False,
                error_message=f"MCP Error: {mcp_tool}"
            )
        
        print(f"   ✅ MCP Success: {mcp_tool}")
        print(f"   📊 Args: {json.dumps(mcp_args, indent=2)}")
        
        # Test Apex call
        apex_success, apex_response, apex_time = self.test_apex_call(mcp_tool, mcp_args)
        
        if apex_success:
            print(f"   ✅ Apex Success ({apex_time:.1f}ms)")
        else:
            print(f"   ❌ Apex failed: {apex_response}")
        
        overall_success = mcp_success and apex_success
        
        return TestResult(
            case_id=case_id,
            utterance=case.utterance,
            description=case.description,
            mcp_success=mcp_success,
            mcp_tool=mcp_tool,
            mcp_args=mcp_args,
            mcp_response_time_ms=mcp_time,
            apex_success=apex_success,
            apex_response=apex_response,
            apex_response_time_ms=apex_time,
            overall_success=overall_success,
            error_message="" if overall_success else f"Apex Error: {apex_response}"
        )
    
    def run_uat(self, csv_file: str, filter_tool: str = None, dry_run: bool = False):
        """Run UAT on all test cases"""
        print("🚀 Starting Local Loop UAT...")
        print(f"   MCP URL: {self.mcp_url}")
        print(f"   Salesforce: {'DRY RUN' if dry_run else 'LIVE'}")
        print(f"   Filter: {filter_tool or 'ALL'}")
        print()
        
        # Load test cases
        cases = self.load_test_cases(csv_file)
        if filter_tool:
            cases = [c for c in cases if filter_tool.lower() in c.expected_tool.lower()]
        
        print(f"📋 Running {len(cases)} test cases...")
        print()
        
        # Run tests
        for i, case in enumerate(cases, 1):
            if dry_run:
                # Dry run - just test MCP
                mcp_success, mcp_tool, mcp_args, mcp_time = self.test_mcp_route(case.utterance)
                result = TestResult(
                    case_id=i,
                    utterance=case.utterance,
                    description=case.description,
                    mcp_success=mcp_success,
                    mcp_tool=mcp_tool,
                    mcp_args=mcp_args,
                    mcp_response_time_ms=mcp_time,
                    apex_success=True,  # Skip Apex in dry run
                    apex_response="DRY RUN - Apex skipped",
                    apex_response_time_ms=0,
                    overall_success=mcp_success,
                    error_message="" if mcp_success else f"MCP Error: {mcp_tool}"
                )
            else:
                result = self.run_test_case(i, case)
            
            self.results.append(result)
            print()
        
        # Generate report
        self.generate_report()
    
    def generate_report(self):
        """Generate UAT report"""
        total = len(self.results)
        passed = sum(1 for r in self.results if r.overall_success)
        mcp_passed = sum(1 for r in self.results if r.mcp_success)
        apex_passed = sum(1 for r in self.results if r.apex_success)
        
        print("📊 UAT RESULTS SUMMARY")
        print("=" * 50)
        print(f"Total Cases: {total}")
        print(f"Overall Pass: {passed}/{total} ({passed/total*100:.1f}%)")
        print(f"MCP Pass: {mcp_passed}/{total} ({mcp_passed/total*100:.1f}%)")
        print(f"Apex Pass: {apex_passed}/{total} ({apex_passed/total*100:.1f}%)")
        print()
        
        # Show failures
        failures = [r for r in self.results if not r.overall_success]
        if failures:
            print("❌ FAILURES:")
            for result in failures:
                print(f"   Case {result.case_id}: {result.description}")
                print(f"      Error: {result.error_message}")
                print()
        
        # Save detailed results
        self.save_results_csv()
        print(f"📄 Detailed results saved to: uat_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv")
    
    def save_results_csv(self):
        """Save detailed results to CSV"""
        filename = f"uat_results_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        
        with open(filename, 'w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([
                'Case ID', 'Description', 'Utterance', 'MCP Success', 'MCP Tool', 
                'MCP Args', 'MCP Time (ms)', 'Apex Success', 'Apex Time (ms)', 
                'Overall Success', 'Error Message'
            ])
            
            for result in self.results:
                writer.writerow([
                    result.case_id,
                    result.description,
                    result.utterance,
                    result.mcp_success,
                    result.mcp_tool,
                    json.dumps(result.mcp_args),
                    f"{result.mcp_response_time_ms:.1f}",
                    result.apex_success,
                    f"{result.apex_response_time_ms:.1f}",
                    result.overall_success,
                    result.error_message
                ])

def main():
    parser = argparse.ArgumentParser(description='Local Loop UAT Runner')
    parser.add_argument('--mcp-url', default='http://localhost:8787', help='MCP server URL')
    parser.add_argument('--sf-base-url', help='Salesforce base URL')
    parser.add_argument('--sf-token', help='Salesforce access token')
    parser.add_argument('--filter', help='Filter by tool name (e.g., "open_pipe")')
    parser.add_argument('--dry-run', action='store_true', help='Test MCP only, skip Apex calls')
    parser.add_argument('--cases', default='cases.csv', help='Test cases CSV file')
    
    args = parser.parse_args()
    
    # Load environment variables
    sf_base_url = args.sf_base_url or os.getenv('SF_BASE_URL')
    sf_token = args.sf_token or os.getenv('SF_ACCESS_TOKEN')
    
    if not args.dry_run and not sf_base_url:
        print("❌ Error: Salesforce configuration required for live testing")
        print("   Set SF_BASE_URL and SF_ACCESS_TOKEN environment variables")
        print("   Or use --dry-run to test MCP only")
        sys.exit(1)
    
    runner = LocalUATRunner(
        mcp_url=args.mcp_url,
        sf_base_url=sf_base_url,
        sf_token=sf_token
    )
    
    runner.run_uat(
        csv_file=args.cases,
        filter_tool=args.filter,
        dry_run=args.dry_run
    )

if __name__ == "__main__":
    main()
