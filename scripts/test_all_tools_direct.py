#!/usr/bin/env python3
"""
Direct testing of all tool types without MCP server complexity
Tests content search, SME search, and future pipeline patterns
"""

import re
from typing import Optional, Dict, Any, List

class ComprehensiveUtteranceTester:
    def __init__(self):
        # Enhanced tool detection patterns
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
                r'content search', r'search.*content', r'find.*article', r'knowledge',
                r'search.*topic', r'content.*topic', r'act.*course', r'consensus.*demo',
                r'show.*act', r'list.*act', r'find.*act', r'act.*curricula', r'act.*assets',
                r'consensus.*demo', r'consensus.*video', r'consensus.*preview',
                r'course.*related', r'course.*created', r'course.*completion', r'course.*enrollment',
                r'demo.*video', r'demo.*created', r'demo.*preview', r'demo.*access',
                r'curricula.*completion', r'assets.*tagged', r'assets.*created',
                r'top.*course', r'course.*enrollment', r'course.*completion.*rate',
                r'completion.*rate', r'enrollment.*student', r'created.*between',
                r'created.*last', r'created.*quarter', r'created.*year',
                r'tagged.*with', r'preview.*link', r'public.*access', r'completion.*tracking',
                r'find.*content.*about', r'content.*about', r'articles.*on', r'courses.*on',
                r'search.*for.*content', r'look.*for.*content', r'get.*content',
                r'documentation', r'look.*for.*documentation', r'get.*documentation'
            ],
            'sme_search': [
                r'sme', r'subject matter expert', r'expert search', r'find.*expert',
                r'who.*expert', r'expertise', r'search.*for.*expert', r'find.*sme',
                r'look.*for.*expert', r'get.*expert', r'who.*knows', r'experts.*on',
                r'specialist', r'consultant', r'advisor'
            ],
            'workflow': [
                r'workflow', r'process', r'procedure', r'step.*by.*step',
                r'how.*to', r'guide'
            ],
            'future_pipeline': [
                r'future pipeline', r'pipeline generation', r'generate.*pipeline',
                r'create.*pipeline', r'new.*pipeline', r'cross-sell.*opportunities',
                r'upsell.*opportunities', r'renewal.*opportunities', r'most valuable.*product',
                r'highest amount.*opportunity', r'highest amount.*renewal', r'how many.*opportunities',
                r'which product.*highest', r'generate.*for.*cross-sell', r'generate.*for.*upsell',
                r'generate.*for.*renewal', r'show.*opportunities', r'find.*opportunities',
                r'top.*renewal.*product', r'renewal.*product', r'products.*for', r'opportunities.*for',
                r'what.*are.*the.*top', r'which.*products', r'best.*products',
                r'potential', r'upsell.*potential', r'highest.*value', r'value.*products',
                r'value.*opportunities', r'create.*upsell', r'show.*upsell', r'upsell.*for'
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

    def extract_topic(self, text: str) -> Optional[str]:
        """Extract topic for content search"""
        topic_patterns = [
            r'topic[:\s]+([^,]+)',
            r'search.*for\s+([^,]+)',
            r'find.*about\s+([^,]+)',
            r'content.*about\s+([^,]+)',
            r'on\s+([^,]+?)(?:\s|$)',  # For "on AI and machine learning"
            r'about\s+([^,]+?)(?:\s|$)',  # For "about Service Cloud implementation"
            r'articles\s+on\s+(.+)$',  # For "articles on AI and machine learning" - capture everything to end
            r'about\s+(.+)$',  # For "about Service Cloud implementation" - capture everything to end
        ]
        
        for pattern in topic_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                topic = match.group(1).strip()
                return topic
        
        # Look for common topics
        if 'data cloud' in text.lower():
            return 'Data Cloud'
        if 'sales cloud' in text.lower():
            return 'Sales Cloud'
        if 'service cloud' in text.lower():
            return 'Service Cloud'
        if 'ai' in text.lower() and 'machine learning' in text.lower():
            return 'AI and machine learning'
        
        return None

    def extract_region(self, text: str) -> Optional[str]:
        """Extract region for SME search"""
        region_patterns = [
            r'in\s+([A-Za-z\s]+?)(?:\s|$)',
            r'for\s+([A-Za-z\s]+?)(?:\s|$)',
            r'([A-Za-z\s]+?)\s+region'
        ]
        
        for pattern in region_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                region = match.group(1).strip()
                region = re.sub(r'\s+', ' ', region)
                if len(region) > 20:
                    continue
                if region.upper() in ['AMER', 'EMEA', 'APAC', 'UKI', 'LATAM', 'ANZ']:
                    return region.upper()
        return None

    def extract_expertise(self, text: str) -> Optional[str]:
        """Extract expertise area for SME search"""
        expertise_patterns = [
            r'on\s+([^,]+?)(?:\s|$)',
            r'about\s+([^,]+?)(?:\s|$)',
            r'for\s+([^,]+?)(?:\s|$)',
            r'with\s+([^,]+?)(?:\s|$)'
        ]
        
        for pattern in expertise_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                expertise = match.group(1).strip()
                return expertise
        return None

    def test_utterance(self, text: str) -> Dict[str, Any]:
        """Test a single utterance"""
        result = {
            'utterance': text,
            'tool': None,
            'ou_name': None,
            'country': None,
            'topic': None,
            'region': None,
            'expertise': None,
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
            
            # Extract tool-specific parameters
            if tool == 'content_search':
                topic = self.extract_topic(text)
                result['topic'] = topic
                if not topic:
                    result['error'] = "Topic required for content search"
                    return result
            elif tool == 'sme_search':
                region = self.extract_region(text)
                expertise = self.extract_expertise(text)
                result['region'] = region
                result['expertise'] = expertise
                if not region and not expertise:
                    result['error'] = "Region or expertise required for SME search"
                    return result
            elif tool == 'kpi_analyze':
                if not ou_name:
                    result['error'] = "Operating Unit required for KPI analysis"
                    return result
            
            result['success'] = True
            
        except Exception as e:
            result['error'] = str(e)
        
        return result

def generate_test_utterances() -> Dict[str, List[str]]:
    """Generate 30 test utterances for each tool type"""
    
    content_search_utterances = [
        "Show me ACT articles on AI and machine learning",
        "Find content about Service Cloud implementation",
        "Search for courses on Data Cloud",
        "Look for documentation about Sales Cloud",
        "Get articles on Salesforce CRM",
        "Find content about Marketing Cloud",
        "Show me ACT courses on Einstein Analytics",
        "Search for content about Platform development",
        "Find articles on Lightning Web Components",
        "Look for courses on Apex programming",
        "Get documentation about Flow automation",
        "Search for content about Security best practices",
        "Find articles on Integration patterns",
        "Show me ACT courses on Trailhead",
        "Look for content about DevOps for Salesforce",
        "Search for articles on Custom objects",
        "Find courses on Validation rules",
        "Get content about Workflow rules",
        "Search for documentation on Process Builder",
        "Find articles on Approval processes",
        "Look for courses on Reports and Dashboards",
        "Search for content about Data migration",
        "Find articles on User management",
        "Get courses on Permission sets",
        "Search for content about Field-level security",
        "Find documentation on Sharing rules",
        "Look for articles on Data backup",
        "Search for courses on Sandbox management",
        "Find content about Release management",
        "Get articles on Performance optimization"
    ]
    
    sme_search_utterances = [
        "Search for experts on Salesforce CRM in EMEA",
        "Find SMEs for Data Cloud in AMER",
        "Who are the experts on Service Cloud?",
        "Look for specialists in APAC region",
        "Find consultants for Marketing Cloud",
        "Search for advisors on Platform development",
        "Who knows about Einstein Analytics?",
        "Find experts on Lightning Web Components",
        "Look for specialists in Apex programming",
        "Search for advisors on Flow automation",
        "Who are the experts on Security?",
        "Find SMEs for Integration patterns",
        "Look for consultants on Trailhead",
        "Search for experts on DevOps",
        "Who knows about Custom objects?",
        "Find specialists for Validation rules",
        "Look for advisors on Workflow rules",
        "Search for experts on Process Builder",
        "Who are the SMEs for Approval processes?",
        "Find consultants on Reports and Dashboards",
        "Look for experts on Data migration",
        "Search for specialists in User management",
        "Who knows about Permission sets?",
        "Find advisors on Field-level security",
        "Look for experts on Sharing rules",
        "Search for SMEs for Data backup",
        "Who are the specialists on Sandbox management?",
        "Find consultants on Release management",
        "Look for experts on Performance optimization",
        "Search for advisors on Salesforce architecture"
    ]
    
    future_pipeline_utterances = [
        "What are the top renewal products for UKI",
        "Show me opportunities for cross-sell in AMER",
        "Generate pipeline for upsell opportunities",
        "Find renewal opportunities for EMEA",
        "What are the best products for APAC?",
        "Create pipeline for Data Cloud",
        "Show me top opportunities for Sales Cloud",
        "Generate renewal pipeline for Service Cloud",
        "Find cross-sell opportunities for Marketing Cloud",
        "What are the highest value products?",
        "Create opportunities for Einstein Analytics",
        "Show me upsell potential for Platform",
        "Generate pipeline for Lightning Web Components",
        "Find renewal opportunities for Apex",
        "What are the top products for Flow?",
        "Create cross-sell opportunities for Security",
        "Show me upsell potential for Integration",
        "Generate pipeline for Trailhead",
        "Find renewal opportunities for DevOps",
        "What are the best products for Custom objects?",
        "Create opportunities for Validation rules",
        "Show me top potential for Workflow rules",
        "Generate pipeline for Process Builder",
        "Find cross-sell for Approval processes",
        "What are the highest value opportunities?",
        "Create upsell for Reports and Dashboards",
        "Show me renewal potential for Data migration",
        "Generate pipeline for User management",
        "Find opportunities for Permission sets",
        "What are the top products for Field-level security?"
    ]
    
    return {
        'content_search': content_search_utterances,
        'sme_search': sme_search_utterances,
        'future_pipeline': future_pipeline_utterances
    }

def main():
    """Test all tool types with 30 utterances each"""
    tester = ComprehensiveUtteranceTester()
    test_utterances = generate_test_utterances()
    
    print("🚀 Comprehensive Tool Testing - 30 Utterances Each")
    print("=" * 80)
    
    total_success = 0
    total_tests = 0
    
    for tool_type, utterances in test_utterances.items():
        print(f"\n🔍 Testing {tool_type.upper()} ({len(utterances)} utterances)")
        print("-" * 60)
        
        success_count = 0
        tool_total = len(utterances)
        
        for i, utterance in enumerate(utterances, 1):
            result = tester.test_utterance(utterance)
            
            if result['success']:
                print(f"✅ {i:2d}. {utterance}")
                success_count += 1
            else:
                print(f"❌ {i:2d}. {utterance} - {result['error']}")
        
        success_rate = (success_count / tool_total) * 100
        print(f"\n📊 {tool_type.upper()} Results: {success_count}/{tool_total} ({success_rate:.1f}%)")
        
        total_success += success_count
        total_tests += tool_total
    
    overall_success_rate = (total_success / total_tests) * 100
    print(f"\n🎯 Overall Results")
    print("=" * 80)
    print(f"Total utterances tested: {total_tests}")
    print(f"Successful: {total_success}")
    print(f"Failed: {total_tests - total_success}")
    print(f"Overall Success Rate: {overall_success_rate:.1f}%")

if __name__ == "__main__":
    main()
