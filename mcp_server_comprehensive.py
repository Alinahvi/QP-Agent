#!/usr/bin/env python3
"""
Comprehensive MCP Server for Agent Integration
Handles multiple tool types: Open Pipe, KPI, Content Search, SME Search, Workflow, Future Pipeline
"""

import json
import logging
import re
import os
import argparse
import requests
from typing import Dict, Any, Optional, List
from dataclasses import dataclass
from flask import Flask, request, jsonify
from dotenv import load_dotenv

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@dataclass
class ToolRequest:
    """Base request structure"""
    tool: str
    args: Dict[str, Any]

class ComprehensiveRouter:
    """Router for multiple tool types"""
    
    def __init__(self):
        # Tool detection patterns
        self.tool_patterns = {
            'open_pipe_analyze': [
                r'open pipe', r'pipeline', r'opportunities', r'opps', r'products.*filter',
                r'passed stage', r'post stage', r'stage \d+'
            ],
            'open_pipe_negative': [
                r'don\'t have', r'without', r'excluding', r'exclude', r'lack', r'no.*product',
                r'missing', r'not having', r'who.*don\'t', r'who.*without', r'who.*excluding',
                r'who.*lack', r'who.*missing', r'who.*not having', r'list.*don\'t',
                r'show.*don\'t', r'find.*don\'t', r'display.*don\'t'
            ],
            'kpi_analyze': [
                r'kpi', r'key performance', r'performance analysis', r'metrics',
                r'quarterly results', r'performance indicators'
            ],
            'content_search': [
                r'content search', r'search.*content', r'find.*article', r'knowledge',
                r'search.*topic', r'content.*topic', r'act.*course', r'consensus.*demo',
                r'show.*act', r'list.*act', r'find.*act', r'act.*curricula', r'act.*assets',
                r'consensus.*demo', r'consensus.*video', r'consensus.*preview',
                r'course.*related', r'course.*created', r'course.*completion', r'course.*enrollment',
                r'find.*tableau', r'show.*tableau', r'search.*tableau', r'tableau.*content',
                r'find.*agentforce', r'show.*agentforce', r'search.*agentforce', r'agentforce.*content',
                r'find.*data cloud', r'show.*data cloud', r'search.*data cloud', r'data cloud.*content',
                r'demo.*video', r'demo.*content', r'video.*demo', r'content.*demo',
                r'demo.*video', r'demo.*created', r'demo.*preview', r'demo.*access',
                r'curricula.*completion', r'assets.*tagged', r'assets.*created',
                r'top.*course', r'course.*enrollment', r'course.*completion.*rate',
                r'completion.*rate', r'enrollment.*student', r'created.*between',
                r'created.*last', r'created.*quarter', r'created.*year',
                r'tagged.*with', r'preview.*link', r'public.*access', r'completion.*tracking'
            ],
            'sme_search': [
                r'sme', r'subject matter expert', r'expert search', r'find.*expert',
                r'who.*expert', r'expertise'
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
                r'generate.*for.*renewal', r'show.*opportunities', r'find.*opportunities'
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
            r'UKI': 'UKI',
            r'LATAM': 'LATAM',
            r'ANZ': 'ANZ'
        }
        
        # Country mapping
        self.country_mapping = {
            'US': 'United States',
            'USA': 'United States',
            'UK': 'United Kingdom',
            'UAE': 'United Arab Emirates',
        }
        
        # Product patterns for negative intent
        self.product_patterns = [
            r'agentforce', r'data cloud', r'slack', r'tableau', r'mulesoft', r'sales cloud',
            r'marketing cloud', r'service cloud', r'platform', r'commerce cloud', r'experience cloud',
            r'field service', r'health cloud', r'financial services', r'manufacturing cloud',
            r'government cloud', r'nonprofit cloud', r'education cloud', r'media cloud'
        ]

    def detect_tool(self, text: str) -> Optional[str]:
        """Detect which tool to use based on text"""
        text_lower = text.lower()
        logger.info(f"Detecting tool for: {text_lower}")
        
        # Check for negative intent first (highest priority)
        if any(re.search(pattern, text_lower) for pattern in self.tool_patterns['open_pipe_negative']):
            logger.info("Detected: open_pipe_negative")
            return 'open_pipe_negative'
        
        # Check for content search second (high priority - before open_pipe_analyze)
        for pattern in self.tool_patterns['content_search']:
            if re.search(pattern, text_lower):
                logger.info(f"Detected: content_search (pattern: {pattern})")
                return 'content_search'
        
        # Check for future pipeline third (high priority)
        if any(re.search(pattern, text_lower) for pattern in self.tool_patterns['future_pipeline']):
            logger.info("Detected: future_pipeline")
            return 'future_pipeline'
        
        # Check for other tools (excluding already checked ones)
        for tool, patterns in self.tool_patterns.items():
            if tool in ['future_pipeline', 'content_search']:  # Skip already checked tools
                continue
            for pattern in patterns:
                if re.search(pattern, text_lower):
                    logger.info(f"Detected: {tool} (pattern: {pattern})")
                    return tool
        
        logger.info("No tool detected, returning None")
        return None

    def parse_negative_intent_args(self, text: str) -> Dict[str, Any]:
        """Parse arguments for negative intent queries"""
        text_lower = text.lower()
        
        # Extract OU
        ou_name = self.extract_ou_name(text)
        
        # Extract country
        country = self.extract_country(text)
        
        # Extract excluded products
        excluded_products = []
        for pattern in self.product_patterns:
            if re.search(pattern, text_lower):
                product_name = re.search(pattern, text_lower).group(0)
                excluded_products.append(product_name.title())
        
        # If no specific products found, try to extract from context
        if not excluded_products:
            # Look for "don't have X" or "without X" patterns
            for pattern in [r'don\'t have (\w+)', r'without (\w+)', r'excluding (\w+)', r'lack (\w+)']:
                matches = re.findall(pattern, text_lower)
                excluded_products.extend([match.title() for match in matches])
        
        # Extract limit if mentioned
        limit = 10  # default
        limit_match = re.search(r'(?:top|first|limit|max).*?(\d+)', text_lower)
        if limit_match:
            limit = int(limit_match.group(1))
        
        return {
            'ouName': ou_name,
            'country': country,
            'excludeProducts': ','.join(excluded_products) if excluded_products else None,
            'negativeIntent': True,
            'limit': str(limit),
            'correlationId': f'negative-{hash(text) % 10000}'
        }

    def extract_ou_name(self, text: str) -> Optional[str]:
        """Extract OU name from text"""
        text_upper = text.upper()
        for pattern, ou_name in self.ou_patterns.items():
            match = re.search(pattern, text_upper)
            if match:
                return ou_name
        return None

    def extract_country(self, text: str) -> Optional[str]:
        """Extract country from text"""
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
                return self.country_mapping.get(country, country)
        
        if 'country = US' in text or 'country=US' in text:
            return "United States"
        
        return None

    def extract_min_stage(self, text: str) -> Optional[int]:
        """Extract minimum stage from text"""
        text_lower = text.lower()
        stage_patterns = {
            r'post\s+stage\s+(\d+)': lambda m: int(m.group(1)),
            r'passed\s+stage\s+(\d+)': lambda m: int(m.group(1)),
            r'>=?\s*stage\s+(\d+)': lambda m: int(m.group(1)),
            r'stage\s+(\d+)\s*and\s+above': lambda m: int(m.group(1)),
            r'stage\s+(\d+)\+': lambda m: int(m.group(1)),
        }
        
        for pattern, extractor in stage_patterns.items():
            match = re.search(pattern, text_lower)
            if match:
                return extractor(match)
        return None

    def extract_timeframe(self, text: str) -> str:
        """Extract timeframe from text"""
        text_lower = text.lower()
        timeframe_patterns = {
            r'this\s+quarter': 'CURRENT',
            r'current\s+quarter': 'CURRENT',
            r'current': 'CURRENT',
            r'last\s+quarter': 'PREVIOUS',
            r'previous\s+quarter': 'PREVIOUS',
            r'previous': 'PREVIOUS',
        }
        
        for pattern, timeframe in timeframe_patterns.items():
            if re.search(pattern, text_lower):
                return timeframe
        return "CURRENT"

    def extract_products(self, text: str) -> Optional[str]:
        """Extract product list from text"""
        product_patterns = [
            r'filter\s+to\s+([^,]+(?:,\s*[^,]+)*)',
            r'products?\s*:\s*([^,]+(?:,\s*[^,]+)*)',
            r'include\s+([^,]+(?:,\s*[^,]+)*)',
            r'([A-Za-z\s]+(?:\s+Cloud)?)\s+and\s+([A-Za-z\s]+(?:\s+Cloud)?)',
        ]
        
        for pattern in product_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                if len(match.groups()) == 2:
                    products = f"{match.group(1).strip()}, {match.group(2).strip()}"
                else:
                    products = match.group(1).strip()
                products = re.sub(r'\s+', ' ', products)
                return products
        
        if 'data cloud' in text.lower() and 'sales cloud' in text.lower():
            return "Data Cloud, Sales Cloud"
        
        return None

    def extract_limit(self, text: str) -> int:
        """Extract limit from text"""
        limit_patterns = [
            r'top\s+(\d+)',
            r'show\s+(\d+)',
            r'limit\s+(\d+)',
            r'first\s+(\d+)',
        ]
        
        for pattern in limit_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                limit = int(match.group(1))
                return min(limit, 50)
        return 10

    def extract_topic(self, text: str) -> Optional[str]:
        """Extract topic for content search"""
        topic_patterns = [
            r'topic[:\s]+([^,]+)',
            r'search.*for\s+([^,]+)',
            r'find.*about\s+([^,]+)',
            r'content.*about\s+([^,]+)',
            r'find\s+([^,]+)\s+content',
            r'show.*me\s+([^,]+)',
            r'search.*([^,]+)',
        ]
        
        for pattern in topic_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                topic = match.group(1).strip()
                return topic
        
        # Look for common topics
        text_lower = text.lower()
        if 'data cloud' in text_lower:
            return 'Data Cloud'
        if 'sales cloud' in text_lower:
            return 'Sales Cloud'
        if 'service cloud' in text_lower:
            return 'Service Cloud'
        if 'tableau' in text_lower:
            return 'Tableau'
        if 'agentforce' in text_lower:
            return 'Agentforce'
        if 'mulesoft' in text_lower:
            return 'MuleSoft'
        if 'marketing cloud' in text_lower:
            return 'Marketing Cloud'
        if 'commerce cloud' in text_lower:
            return 'Commerce Cloud'
        if 'slack' in text_lower:
            return 'Slack'
        
        # If no specific topic found, try to extract the main search term
        # Look for words that might be topics (exclude common words)
        exclude_words = {'find', 'search', 'show', 'me', 'content', 'consensus', 'demo', 'video', 'course', 'training', 'act', 'the', 'and', 'or', 'for', 'in', 'on', 'at', 'to', 'of', 'with', 'by'}
        words = re.findall(r'\b\w+\b', text.lower())
        for word in words:
            if word not in exclude_words and len(word) > 2:
                return word.title()
        
        return None

    def extract_source(self, text: str) -> str:
        """Extract source for content search"""
        if 'act' in text.lower():
            return 'ACT'
        if 'quip' in text.lower():
            return 'QUIP'
        return 'ACT'  # Default

    def extract_region(self, text: str) -> Optional[str]:
        """Extract region for SME search"""
        region_patterns = [
            r'region[:\s]+([^,]+)',
            r'in\s+([A-Z]{2,4})',
            r'for\s+([A-Z]{2,4})',
        ]
        
        for pattern in region_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                region = match.group(1).strip().upper()
                return region
        
        return None

    def extract_expertise(self, text: str) -> Optional[str]:
        """Extract expertise area for SME search"""
        expertise_patterns = [
            r'expert.*in\s+([^,]+)',
            r'expertise[:\s]+([^,]+)',
            r'skilled.*in\s+([^,]+)',
        ]
        
        for pattern in expertise_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                expertise = match.group(1).strip()
                return expertise
        
        return None

    def extract_opportunity_type(self, text: str) -> Optional[str]:
        """Extract opportunity type for future pipeline"""
        text_lower = text.lower()
        
        if 'cross-sell' in text_lower or 'cross sell' in text_lower:
            return 'cross-sell'
        elif 'upsell' in text_lower or 'up-sell' in text_lower:
            return 'upsell'
        elif 'renewal' in text_lower:
            return 'renewal'
        
        return None

    def extract_segment(self, text: str) -> Optional[str]:
        """Extract segment for future pipeline"""
        text_lower = text.lower()
        
        if 'enterprise' in text_lower:
            return 'enterprise'
        elif 'mid-market' in text_lower or 'mid market' in text_lower:
            return 'mid-market'
        elif 'small business' in text_lower or 'sme' in text_lower:
            return 'small business'
        
        return None

    def extract_product(self, text: str) -> Optional[str]:
        """Extract product for future pipeline"""
        text_lower = text.lower()
        
        if 'data cloud' in text_lower:
            return 'Data Cloud'
        elif 'sales cloud' in text_lower:
            return 'Sales Cloud'
        elif 'service cloud' in text_lower:
            return 'Service Cloud'
        elif 'marketing cloud' in text_lower:
            return 'Marketing Cloud'
        
        return None

    def route_request(self, text: str) -> Dict[str, Any]:
        """Route natural language request to appropriate tool"""
        
        # Detect tool
        tool = self.detect_tool(text)
        if not tool:
            return {
                "error": "Could not determine the appropriate tool for this request. Please be more specific about what you want to do."
            }
        
        # Extract common parameters
        ou_name = self.extract_ou_name(text)
        country = self.extract_country(text)
        timeframe = self.extract_timeframe(text)
        limit = self.extract_limit(text)
        
        # Build args based on tool type
        args = {}
        
        if tool == 'open_pipe_negative':
            # Use negative intent parsing
            args = self.parse_negative_intent_args(text)
        elif tool == 'open_pipe_analyze':
            if not ou_name:
                return {"error": "Operating Unit (ouName) is required for open pipe analysis. Please specify an OU like 'AMER ACC' or 'EMEA ENTR'."}
            
            args = {
                "ouName": ou_name,
                "timeFrame": timeframe,
                "limitN": limit
            }
            
            if country:
                args["country"] = country
            
            min_stage = self.extract_min_stage(text)
            if min_stage is not None:
                args["minStage"] = min_stage
            
            products = self.extract_products(text)
            if products:
                args["productListCsv"] = products
        
        elif tool == 'kpi_analyze':
            if not ou_name:
                return {"error": "Operating Unit (ouName) is required for KPI analysis. Please specify an OU like 'AMER ACC' or 'EMEA ENTR'."}
            
            args = {
                "ouName": ou_name,
                "timeFrame": timeframe
            }
            
            if country:
                args["country"] = country
        
        elif tool == 'content_search':
            topic = self.extract_topic(text)
            if not topic:
                return {"error": "Please specify a topic to search for (e.g., 'Data Cloud', 'Sales Cloud')."}
            
            args = {
                "topic": topic,
                "source": self.extract_source(text)
            }
        
        elif tool == 'sme_search':
            region = self.extract_region(text)
            expertise = self.extract_expertise(text)
            
            if not region and not expertise:
                return {"error": "Please specify a region or expertise area for SME search."}
            
            args = {}
            if region:
                args["region"] = region
            if expertise:
                args["expertise"] = expertise
        
        elif tool == 'workflow':
            args = {
                "process": "general",
                "context": text
            }
        
        elif tool == 'future_pipeline':
            if not ou_name:
                return {"error": "Operating Unit (ouName) is required for pipeline generation. Please specify an OU like 'AMER ACC' or 'EMEA ENTR'."}
            
            args = {
                "ouName": ou_name,
                "timeFrame": timeframe
            }
            
            # Extract opportunity type
            opportunity_type = self.extract_opportunity_type(text)
            if opportunity_type:
                args["opportunityType"] = opportunity_type
            
            # Extract product
            product = self.extract_product(text)
            if product:
                args["product"] = product
            
            # Extract segment
            segment = self.extract_segment(text)
            if segment:
                args["segment"] = segment
            
            # Extract limit
            limit = self.extract_limit(text)
            if limit != 10:  # Only add if not default
                args["limit"] = limit
        
        return {
            "tool": tool,
            "args": args
        }

class ComprehensiveMCPServer:
    """Comprehensive MCP Server for multiple tool types"""
    
    def __init__(self, dry_run: bool = True, sf_base_url: str = None, sf_access_token: str = None):
        self.router = ComprehensiveRouter()
        self.dry_run = dry_run
        self.sf_base_url = sf_base_url
        self.sf_access_token = sf_access_token
        self.app = Flask(__name__)
        self._setup_routes()
    
    def _setup_routes(self):
        """Setup Flask routes"""
        
        @self.app.route('/health', methods=['GET'])
        def health():
            return jsonify({
                "status": "healthy",
                "service": "comprehensive-mcp",
                "dry_run": self.dry_run,
                "sf_configured": bool(self.sf_base_url and self.sf_access_token),
                "supported_tools": list(self.router.tool_patterns.keys())
            })
        
        @self.app.route('/route', methods=['POST'])
        def route():
            try:
                data = request.get_json()
                if not data or 'text' not in data:
                    return jsonify({"error": "No text provided"}), 400
                
                # Route the request
                result = self.router.route_request(data['text'])
                return jsonify(result)
                
            except Exception as e:
                logger.error(f"Error in route endpoint: {e}")
                return jsonify({"error": str(e)}), 500
        
        @self.app.route('/analyze', methods=['POST'])
        def analyze():
            try:
                data = request.get_json()
                if not data:
                    return jsonify({"error": "No JSON data provided"}), 400
                
                # Check if this is a negative intent query
                if 'negativeIntent' in data and data['negativeIntent']:
                    # Route to negative intent handler
                    return self._handle_negative_intent(data)
                
                # Handle regular open pipe analysis
                return self._handle_regular_analysis(data)
                
            except Exception as e:
                logger.error(f"Error in analyze endpoint: {e}")
                return jsonify({"error": str(e)}), 500
    
    def _handle_regular_analysis(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle regular open pipe analysis by calling Salesforce action"""
        try:
            # Prepare Salesforce action request
            sf_args = {
                'naturalLanguageQuery': data.get('text', ''),
                'ouName': data.get('ouName'),
                'limitN': data.get('limit', '10'),
                'correlationId': data.get('correlationId', f'regular-{hash(str(data)) % 10000}')
            }
            
            # Add optional parameters
            if 'country' in data:
                sf_args['country'] = data['country']
            if 'timeFrame' in data:
                sf_args['timeFrame'] = data['timeFrame']
            if 'minStage' in data:
                sf_args['minStage'] = data['minStage']
            if 'productListCsv' in data:
                sf_args['productListCsv'] = data['productListCsv']
            
            # For dry run, return the Salesforce action parameters
            if self.dry_run:
                return jsonify({
                    "status": "success",
                    "message": "Regular analysis - would call Salesforce action",
                    "salesforce_action": "ANAGENT Open Pipe Analysis V3 - MCP Enhanced",
                    "sf_args": sf_args,
                    "note": "This is a dry run. Set DRY_RUN=false to call Salesforce."
                })
            
            # Call the actual Salesforce action
            return self._call_salesforce_action("ANAGENT Open Pipe Analysis V3 - MCP Enhanced", sf_args)
            
        except Exception as e:
            logger.error(f"Error handling regular analysis: {e}")
            return jsonify({"error": f"Failed to handle regular analysis: {str(e)}"}), 500
    
    def _handle_negative_intent(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """Handle negative intent queries by calling Salesforce action"""
        try:
            # Prepare Salesforce action request
            sf_args = {
                'naturalLanguageQuery': data.get('text', ''),
                'ouName': data.get('ouName'),
                'excludeProductListCsv': data.get('excludeProducts'),
                'negativeIntent': True,
                'requireNoProductMatch': True,
                'limitN': data.get('limit', '10'),
                'correlationId': data.get('correlationId', f'negative-{hash(str(data)) % 10000}')
            }
            
            # Add optional parameters
            if 'country' in data:
                sf_args['country'] = data['country']
            
            # For dry run, return the Salesforce action parameters
            if self.dry_run:
                return jsonify({
                    "status": "success",
                    "message": "Negative intent detected - would call Salesforce action",
                    "salesforce_action": "ANAGENT Open Pipe Analysis V3 - MCP Enhanced",
                    "sf_args": sf_args,
                    "note": "This is a dry run. Set DRY_RUN=false to call Salesforce."
                })
            
            # Call the actual Salesforce action
            return self._call_salesforce_action("ANAGENT Open Pipe Analysis V3 - MCP Enhanced", sf_args)
            
        except Exception as e:
            logger.error(f"Error handling negative intent: {e}")
            return jsonify({"error": f"Failed to handle negative intent: {str(e)}"}), 500
    
    def _call_salesforce_action(self, action_name: str, args: Dict[str, Any]) -> Dict[str, Any]:
        """Call Salesforce action via REST API"""
        try:
            if not self.sf_base_url or not self.sf_access_token:
                return jsonify({"error": "Salesforce not configured"}), 500
            
            # Prepare the request payload
            payload = {
                "inputs": [args]
            }
            
            # Make the REST API call
            headers = {
                'Authorization': f'Bearer {self.sf_access_token}',
                'Content-Type': 'application/json'
            }
            
            url = f"{self.sf_base_url}/services/data/v58.0/actions/custom/{action_name}"
            
            response = requests.post(url, json=payload, headers=headers)
            
            if response.status_code == 200:
                return jsonify({
                    "status": "success",
                    "message": f"Called Salesforce action: {action_name}",
                    "result": response.json()
                })
            else:
                return jsonify({
                    "status": "error",
                    "message": f"Salesforce API error: {response.status_code}",
                    "error": response.text
                }), 500
                
        except Exception as e:
            logger.error(f"Error calling Salesforce action: {e}")
            return jsonify({"error": f"Failed to call Salesforce action: {str(e)}"}), 500
    
    def run(self, host: str = 'localhost', port: int = 8787):
        """Run the Flask server"""
        logger.info(f"Starting Comprehensive MCP server on {host}:{port}")
        logger.info(f"Dry run mode: {self.dry_run}")
        logger.info(f"Salesforce configured: {bool(self.sf_base_url and self.sf_access_token)}")
        logger.info(f"Supported tools: {list(self.router.tool_patterns.keys())}")
        
        self.app.run(host=host, port=port, debug=False)

def main():
    """Main function with CLI support"""
    parser = argparse.ArgumentParser(description='Comprehensive MCP Server')
    parser.add_argument('--port', type=int, default=8787, help='Port to run server on')
    parser.add_argument('--host', default='localhost', help='Host to bind to')
    parser.add_argument('--dry-run', action='store_true', help='Run in dry-run mode (default: True)')
    parser.add_argument('--live', action='store_true', help='Run in live mode (calls Salesforce)')
    
    args = parser.parse_args()
    
    # Load environment variables
    load_dotenv()
    
    # Get configuration from environment
    sf_base_url = os.getenv('SF_BASE_URL')
    sf_access_token = os.getenv('SF_ACCESS_TOKEN')
    dry_run = args.dry_run or (not args.live and os.getenv('DRY_RUN', 'true').lower() == 'true')
    port = int(os.getenv('PORT', args.port))
    host = os.getenv('HOST', args.host)
    
    # Start the server
    server = ComprehensiveMCPServer(
        dry_run=dry_run,
        sf_base_url=sf_base_url,
        sf_access_token=sf_access_token
    )
    server.run(host=host, port=port)

if __name__ == "__main__":
    main()
