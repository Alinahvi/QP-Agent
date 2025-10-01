#!/usr/bin/env python3
"""
Direct utterance testing without MCP server complexity
Tests the core utterance parsing logic directly
"""

import re
from typing import Optional, Dict, Any

class DirectUtteranceTester:
    def __init__(self):
        # Tool detection patterns
        self.tool_patterns = {
            'kpi_analyze': [
                r'kpi', r'key performance', r'performance analysis', r'metrics',
                r'quarterly results', r'performance indicators', r'avg calls', r'average calls',
                r'calls.*germany', r'calls.*break.*down', r'ramping.*aes', r'ramp.*status',
                r'coverage', r'meetings', r'acv', r'pipeline generation', r'call connections',
                r'meeting statistics', r'performance.*germany', r'performance.*us',
                r'compare.*coverage', r'this month', r'last year', r'break.*down',
                r'slow ramping', r'fast ramping', r'ramp.*analysis'
            ],
            'content_search': [
                r'show.*act', r'find.*content', r'act.*article', r'act.*course',
                r'content.*search', r'knowledge.*base', r'documentation'
            ],
            'sme_search': [
                r'sme', r'expert', r'subject matter', r'find.*expert', r'search.*expert'
            ],
            'workflow': [
                r'workflow', r'process', r'how.*do', r'set.*up', r'procedure'
            ],
            'future_pipeline': [
                r'future.*pipeline', r'pipeline.*generation', r'opportunity', r'stage',
                r'renewal', r'create.*pipeline'
            ],
            'open_pipe_analyze': [
                r'open.*pipe', r'passed.*stage', r'stage.*analysis', r'products.*stage'
            ]
        }
        
        # OU patterns
        self.ou_patterns = {
            r'AMER\s+ACC(?:\s+OU)?': 'AMER ACC',
            r'AMER-ACC': 'AMER ACC',
            r'ACC\s+in\s+AMER': 'AMER ACC',
            r'EMEA\s+ENTR(?:AISE)?': 'EMEA ENTR',
            r'EMEA-ENTR': 'EMEA ENTR',
            r'Enterprise\s+EMEA': 'EMEA ENTR',
            r'SMB\s*-\s*AMER\s+SMB': 'SMB - AMER SMB',
            r'SMB\s*-\s*EMEA\s+SMB': 'SMB - EMEA SMB',
            r'UKI': 'UKI',
            r'LATAM': 'LATAM',
            r'ANZ': 'ANZ',
            r'APAC': 'APAC',
            r'AMER': 'AMER'
        }
        
        # Country mapping
        self.country_ou_mapping = {
            'GERMANY': 'EMEA ENTR',
            'US': 'AMER ACC', 
            'USA': 'AMER ACC',
            'UNITED STATES': 'AMER ACC',
            'UK': 'UKI',
            'UNITED KINGDOM': 'UKI',
            'FRANCE': 'EMEA ENTR',
            'CANADA': 'AMER ACC',
            'AUSTRALIA': 'ANZ',
            'JAPAN': 'APAC',
            'EMEA': 'EMEA ENTR',
            'AMER': 'AMER ACC',
            'APAC': 'APAC'
        }

    def detect_tool(self, text: str) -> Optional[str]:
        """Detect tool type from text"""
        text_lower = text.lower()
        
        for tool, patterns in self.tool_patterns.items():
            for pattern in patterns:
                if re.search(pattern, text_lower):
                    return tool
        return None

    def extract_ou_name(self, text: str) -> Optional[str]:
        """Extract OU name from text"""
        text_upper = text.upper()
        
        # First, try to find explicit OU patterns
        for pattern, ou_name in self.ou_patterns.items():
            match = re.search(pattern, text_upper)
            if match:
                return ou_name
        
        # Check for "by country" patterns
        if 'BY COUNTRY' in text_upper or 'RATES BY COUNTRY' in text_upper:
            return 'AMER ACC'  # Default OU for multi-country queries
        
        # If no explicit OU found, try to infer from country/region
        for country, ou_name in self.country_ou_mapping.items():
            if country in text_upper:
                return ou_name
                
        return None

    def extract_country(self, text: str) -> Optional[str]:
        """Extract country from text"""
        # Check for "by country" patterns first
        if re.search(r'by\s+country|rates\s+by\s+country', text, re.IGNORECASE):
            return "MULTIPLE_COUNTRIES"
            
        country_patterns = [
            r'country\s*=\s*([A-Za-z\s]+?)(?:\s|$)',
            r'in\s+([A-Za-z\s]+?)(?:\s+country|\s+top|\s+for|\s+within|\s+passed|\s+post|\s+stage|\s+quarter|\s+open|\s+pipe|\s+products|\s+filter|\s+show|\s+compare|\s+where|\s+and|\s+order|\s+by|\s+amount|\s+stage|\s+in|\s+\(|\s+\)|\s+>|\s+<|\s+=|\s+$|$)',
        ]
        
        for pattern in country_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                country = match.group(1).strip()
                country = re.sub(r'\s+', ' ', country)
                if len(country) > 50:
                    continue
                if country.upper() in ['AMER ACC', 'EMEA ENTR', 'UKI', 'LATAM', 'ANZ']:
                    continue
                return country
        
        if 'country = US' in text or 'country=US' in text:
            return "United States"
        
        return None

    def test_utterance(self, text: str) -> Dict[str, Any]:
        """Test a single utterance"""
        result = {
            'utterance': text,
            'tool': None,
            'ou_name': None,
            'country': None,
            'success': False,
            'error': None
        }
        
        try:
            # Detect tool
            tool = self.detect_tool(text)
            result['tool'] = tool
            
            if not tool:
                result['error'] = "No tool detected"
                return result
            
            # Extract OU name
            ou_name = self.extract_ou_name(text)
            result['ou_name'] = ou_name
            
            # Extract country
            country = self.extract_country(text)
            result['country'] = country
            
            # For KPI analysis, check if OU is required
            if tool == 'kpi_analyze' and not ou_name:
                result['error'] = "Operating Unit (ouName) is required for KPI analysis"
                return result
            
            result['success'] = True
            
        except Exception as e:
            result['error'] = str(e)
        
        return result

def main():
    """Test the problematic utterances"""
    tester = DirectUtteranceTester()
    
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
    
    print("🚀 Direct Utterance Testing")
    print("=" * 80)
    
    success_count = 0
    total_count = len(test_utterances)
    
    for i, utterance in enumerate(test_utterances, 1):
        print(f"\n🔍 Test {i}: '{utterance}'")
        print("-" * 60)
        
        result = tester.test_utterance(utterance)
        
        if result['success']:
            print("✅ SUCCESS")
            print(f"   Tool: {result['tool']}")
            print(f"   OU: {result['ou_name']}")
            print(f"   Country: {result['country']}")
            success_count += 1
        else:
            print("❌ FAILED")
            print(f"   Error: {result['error']}")
            print(f"   Tool: {result['tool']}")
            print(f"   OU: {result['ou_name']}")
            print(f"   Country: {result['country']}")
    
    print(f"\n🎯 Results Summary")
    print("=" * 80)
    print(f"Total utterances tested: {total_count}")
    print(f"Successful: {success_count}")
    print(f"Failed: {total_count - success_count}")
    print(f"Success Rate: {(success_count/total_count)*100:.1f}%")

if __name__ == "__main__":
    main()
