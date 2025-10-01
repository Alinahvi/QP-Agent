#!/usr/bin/env python3
"""
MCP Server for Open Pipe Analysis
Routes natural language requests to Salesforce Open Pipe Analysis handler
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
class OpenPipeRequest:
    """Structured request for Open Pipe Analysis"""
    ouName: str
    country: Optional[str] = None
    minStage: Optional[int] = None
    productListCsv: Optional[str] = None
    timeFrame: str = "CURRENT"
    limitN: int = 10

class OpenPipeRouter:
    """Router for Open Pipe Analysis requests"""
    
    def __init__(self):
        # Stage mapping patterns
        self.stage_patterns = {
            r'post\s+stage\s+(\d+)': lambda m: int(m.group(1)),
            r'passed\s+stage\s+(\d+)': lambda m: int(m.group(1)),
            r'>=?\s*stage\s+(\d+)': lambda m: int(m.group(1)),
            r'stage\s+(\d+)\s*and\s+above': lambda m: int(m.group(1)),
            r'stage\s+(\d+)\+': lambda m: int(m.group(1)),
        }
        
        # Time frame patterns
        self.timeframe_patterns = {
            r'this\s+quarter': 'CURRENT',
            r'current\s+quarter': 'CURRENT',
            r'current': 'CURRENT',
            r'last\s+quarter': 'PREVIOUS',
            r'previous\s+quarter': 'PREVIOUS',
            r'previous': 'PREVIOUS',
        }
        
        # OU normalization patterns
        self.ou_patterns = {
            r'AMER\s+ACC(?:\s+OU)?': 'AMER ACC',
            r'ACC\s+in\s+AMER': 'AMER ACC',
            r'EMEA\s+ENTR(?:AISE)?': 'EMEA ENTR',
            r'Enterprise\s+EMEA': 'EMEA ENTR',
        }
        
        # Country normalization
        self.country_mapping = {
            'US': 'United States',
            'USA': 'United States',
            'UK': 'United Kingdom',
            'UAE': 'United Arab Emirates',
        }

    def extract_min_stage(self, text: str) -> Optional[int]:
        """Extract minimum stage from text"""
        text_lower = text.lower()
        for pattern, extractor in self.stage_patterns.items():
            match = re.search(pattern, text_lower)
            if match:
                return extractor(match)
        return None

    def extract_timeframe(self, text: str) -> str:
        """Extract timeframe from text"""
        text_lower = text.lower()
        for pattern, timeframe in self.timeframe_patterns.items():
            if re.search(pattern, text_lower):
                return timeframe
        return "CURRENT"  # Default

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
        # Look for country patterns - be more specific
        country_patterns = [
            r'country\s*=\s*([A-Za-z\s]+?)(?:\s|$)',
            r'in\s+([A-Za-z\s]+?)(?:\s+country|\s+top|\s+for|\s+within|\s+passed|\s+post|\s+stage|\s+quarter|\s+open|\s+pipe|\s+products|\s+filter|\s+show|\s+compare|\s+where|\s+and|\s+order|\s+by|\s+amount|\s+stage|\s+in|\s+\(|\s+\)|\s+>|\s+<|\s+=|\s+$|$)',
        ]
        
        for pattern in country_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                country = match.group(1).strip()
                # Clean up the country name and limit length
                country = re.sub(r'\s+', ' ', country)
                if len(country) > 50:  # Avoid picking up too much text
                    continue
                # Don't extract OU names as countries
                if country.upper() in ['AMER ACC', 'EMEA ENTR', 'UKI', 'LATAM', 'ANZ']:
                    continue
                return self.country_mapping.get(country, country)
        
        # Special case for "country = US"
        if 'country = US' in text or 'country=US' in text:
            return "United States"
        
        return None

    def extract_products(self, text: str) -> Optional[str]:
        """Extract product list from text"""
        # Look for product filter patterns
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
                    # Handle "X and Y" pattern
                    products = f"{match.group(1).strip()}, {match.group(2).strip()}"
                else:
                    products = match.group(1).strip()
                # Clean up and normalize
                products = re.sub(r'\s+', ' ', products)
                return products
        
        # Special case for "Data Cloud and Sales Cloud only"
        if 'data cloud' in text.lower() and 'sales cloud' in text.lower():
            return "Data Cloud, Sales Cloud"
        
        return None

    def extract_limit(self, text: str) -> int:
        """Extract limit from text"""
        # Look for limit patterns
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
                return min(limit, 50)  # Cap at 50
        return 10  # Default

    def is_valid_request(self, text: str) -> bool:
        """Check if request is valid for open pipe analysis"""
        text_lower = text.lower()
        
        # Must contain open pipe or pipeline analysis keywords
        if not any(keyword in text_lower for keyword in ['open pipe', 'pipeline', 'opportunities', 'opps', 'products', 'filter']):
            return False
            
        # Must not be pipe generation
        if any(keyword in text_lower for keyword in ['generate', 'create', 'build', 'new pipeline']):
            return False
            
        # Must not be renewal/upsell/cross-sell
        if any(keyword in text_lower for keyword in ['renewal', 'upsell', 'cross-sell', 'expansion']):
            return False
            
        return True

    def has_unsupported_filters(self, text: str) -> bool:
        """Check for unsupported filter syntax"""
        unsupported_patterns = [
            r'amount\s*[><=]',
            r'stage\s+in\s*\(',
            r'order\s+by',
            r'where\s+.*[><=]',
            r'&&',
            r'\|\|',
        ]
        
        for pattern in unsupported_patterns:
            if re.search(pattern, text, re.IGNORECASE):
                return True
        return False

    def route_request(self, text: str) -> Dict[str, Any]:
        """Route natural language request to structured parameters"""
        
        # Check if request is valid
        if not self.is_valid_request(text):
            return {
                "error": "This request is not for open pipe analysis. Use PipeGen tools for pipeline generation."
            }
        
        # Check for unsupported filters
        if self.has_unsupported_filters(text):
            return {
                "error": "Unsupported filter syntax. Provide minStage, productListCsv, ouName, country, timeframe, limitN only."
            }
        
        # Extract parameters
        ou_name = self.extract_ou_name(text)
        if not ou_name:
            return {
                "error": "Operating Unit (ouName) is required. Please specify an OU like 'AMER ACC' or 'EMEA ENTR'."
            }
        
        country = self.extract_country(text)
        min_stage = self.extract_min_stage(text)
        products = self.extract_products(text)
        timeframe = self.extract_timeframe(text)
        limit = self.extract_limit(text)
        
        # Build request
        request = OpenPipeRequest(
            ouName=ou_name,
            country=country,
            minStage=min_stage,
            productListCsv=products,
            timeFrame=timeframe,
            limitN=limit
        )
        
        # Convert to dict, removing None values
        args = {
            "ouName": request.ouName,
            "timeFrame": request.timeFrame,
            "limitN": request.limitN
        }
        
        if request.country:
            args["country"] = request.country
        if request.minStage is not None:
            args["minStage"] = request.minStage
        if request.productListCsv:
            args["productListCsv"] = request.productListCsv
        
        return {
            "tool": "open_pipe_analyze",
            "args": args
        }

class MCPServer:
    """MCP Server for Open Pipe Analysis"""
    
    def __init__(self, dry_run: bool = True, sf_base_url: str = None, sf_access_token: str = None):
        self.router = OpenPipeRouter()
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
                "service": "open-pipe-mcp",
                "dry_run": self.dry_run,
                "sf_configured": bool(self.sf_base_url and self.sf_access_token)
            })
        
        @self.app.route('/analyze', methods=['POST'])
        def analyze():
            try:
                data = request.get_json()
                if not data:
                    return jsonify({"error": "No JSON data provided"}), 400
                
                # Extract parameters
                ou_name = data.get('ouName')
                if not ou_name:
                    return jsonify({"error": "ouName is required"}), 400
                
                # Validate parameters
                result = self.open_pipe_analyze(**data)
                return jsonify(result)
                
            except Exception as e:
                logger.error(f"Error in analyze endpoint: {e}")
                return jsonify({"error": str(e)}), 500
        
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
    
    def open_pipe_analyze(self, **kwargs) -> Dict[str, Any]:
        """
        Analyze existing opportunities ('open pipe') with stage/product/OU filters and aggregated results.
        
        Args:
            ouName (str): Operating Unit name, e.g., 'AMER ACC', 'EMEA ENTR'
            country (str, optional): Work location country filter
            minStage (int, optional): Only include opps at or beyond this stage (0-8)
            productListCsv (str, optional): CSV list of product names to include
            timeFrame (str): "CURRENT" or "PREVIOUS" (default: "CURRENT")
            limitN (int): Limit results (1-1000, default: 10)
        
        Returns:
            Dict containing analysis results
        """
        try:
            # Validate required parameters
            if not kwargs.get('ouName'):
                return {"error": "ouName is required"}
            
            # Validate parameter ranges
            if kwargs.get('minStage') is not None:
                if not (0 <= kwargs['minStage'] <= 8):
                    return {"error": "minStage must be between 0 and 8"}
            
            if kwargs.get('limitN'):
                if not (1 <= kwargs['limitN'] <= 1000):
                    return {"error": "limitN must be between 1 and 1000"}
            
            # Log the call for testing
            logger.info(f"open_pipe_analyze called with args: {kwargs}")
            
            if self.dry_run:
                # Return mock response for testing
                return {
                    "status": "success",
                    "message": "Open Pipe Analysis completed (DRY RUN)",
                    "parameters": kwargs,
                    "note": "This is a dry run. Set DRY_RUN=false to call Salesforce."
                }
            else:
                # Call Salesforce Apex REST endpoint
                return self._call_salesforce_endpoint(kwargs)
            
        except Exception as e:
            logger.error(f"Error in open_pipe_analyze: {e}")
            return {"error": f"Analysis failed: {str(e)}"}
    
    def _call_salesforce_endpoint(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Call Salesforce Apex REST endpoint"""
        try:
            if not self.sf_base_url or not self.sf_access_token:
                return {"error": "Salesforce configuration missing. Check SF_BASE_URL and SF_ACCESS_TOKEN."}
            
            # Build the endpoint URL
            endpoint = f"{self.sf_base_url}/services/apexrest/agent/openPipeAnalyze"
            
            # Prepare headers
            headers = {
                'Authorization': f'Bearer {self.sf_access_token}',
                'Content-Type': 'application/json'
            }
            
            # Make the request
            response = requests.post(endpoint, json=params, headers=headers, timeout=30)
            
            if response.status_code == 200:
                return {
                    "status": "success",
                    "message": "Open Pipe Analysis completed",
                    "parameters": params,
                    "salesforce_response": response.json() if response.content else "No content"
                }
            else:
                return {
                    "status": "error",
                    "message": f"Salesforce API error: {response.status_code}",
                    "error": response.text,
                    "parameters": params
                }
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Salesforce API request failed: {e}")
            return {"error": f"Salesforce API request failed: {str(e)}"}
        except Exception as e:
            logger.error(f"Error calling Salesforce: {e}")
            return {"error": f"Salesforce integration error: {str(e)}"}
    
    def run(self, host: str = 'localhost', port: int = 8787):
        """Run the Flask server"""
        logger.info(f"Starting MCP server on {host}:{port}")
        logger.info(f"Dry run mode: {self.dry_run}")
        logger.info(f"Salesforce configured: {bool(self.sf_base_url and self.sf_access_token)}")
        
        self.app.run(host=host, port=port, debug=False)

def main():
    """Main function with CLI support"""
    parser = argparse.ArgumentParser(description='MCP Open Pipe Analysis Server')
    parser.add_argument('--port', type=int, default=8787, help='Port to run server on')
    parser.add_argument('--host', default='localhost', help='Host to bind to')
    parser.add_argument('--test', action='store_true', help='Run router tests instead of starting server')
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
    
    if args.test:
        # Run router tests
        run_router_tests()
    else:
        # Start the server
        server = MCPServer(
            dry_run=dry_run,
            sf_base_url=sf_base_url,
            sf_access_token=sf_access_token
        )
        server.run(host=host, port=port)

def run_router_tests():
    """Run router tests"""
    server = MCPServer()
    
    # Test utterances from the requirements
    test_utterances = [
        "Show me all the products that passed stage 4 within AMER ACC for open pipe.",
        "For those products, keep timeframe to this quarter and show top 15.",
        "Filter to Data Cloud and Sales Cloud only.",
        "Open pipe passed stage 4 in AMER ACC, country = US, top 20.",
        "Compare last quarter open pipe post stage 4 for AMER ACC.",
        "Open pipe for AMER ACC where amount > 1M and stage in (3,4,5) order by secretField",
        "Generate pipeline for UKI next quarter"
    ]
    
    print("MCP Open Pipe Analysis — Test Run")
    print("=" * 50)
    
    for i, utterance in enumerate(test_utterances, 1):
        print(f"\n{i}. User: \"{utterance}\"")
        
        # Route the request
        result = server.router.route_request(utterance)
        
        if "error" in result:
            print(f"Response: {result['error']}")
        else:
            print(f"Expected: {json.dumps(result, indent=2)}")

if __name__ == "__main__":
    main()
