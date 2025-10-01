#!/usr/bin/env python3
"""
Simple Agent API Server for Content Search UAT Testing
Simulates agent responses for ACT courses and Consensus demos
"""

from flask import Flask, request, jsonify
import json
import random
from datetime import datetime, timedelta

app = Flask(__name__)

# Sample data for ACT courses
ACT_COURSES = [
    {
        "title": "Data Cloud Fundamentals",
        "type": "Course",
        "link": "https://trailhead.salesforce.com/content/learn/modules/data-cloud-fundamentals",
        "created_date": "2024-01-15",
        "completion_rate": 78,
        "enrollments": 2450,
        "tags": ["Data Cloud", "Fundamentals"]
    },
    {
        "title": "Sales Cloud Essentials",
        "type": "Course", 
        "link": "https://trailhead.salesforce.com/content/learn/modules/sales-cloud-essentials",
        "created_date": "2024-01-15",
        "completion_rate": 85,
        "enrollments": 3200,
        "tags": ["Sales Cloud", "Essentials"]
    },
    {
        "title": "Service Cloud Advanced Features",
        "type": "Course",
        "link": "https://trailhead.salesforce.com/content/learn/modules/service-cloud-advanced",
        "created_date": "2024-02-10",
        "completion_rate": 82,
        "enrollments": 2800,
        "tags": ["Service Cloud", "Advanced"]
    },
    {
        "title": "Marketing Cloud Integration",
        "type": "Course",
        "link": "https://trailhead.salesforce.com/content/learn/modules/marketing-cloud-integration",
        "created_date": "2024-03-05",
        "completion_rate": 79,
        "enrollments": 2100,
        "tags": ["Marketing Cloud", "Integration"]
    }
]

# Sample data for Consensus demos
CONSENSUS_DEMOS = [
    {
        "title": "Data Cloud Platform Overview",
        "type": "Demo Video",
        "link": "https://consensus.salesforce.com/demos/data-cloud-platform-overview",
        "created_date": "2024-01-20",
        "duration": 15,
        "view_count": 12500,
        "public_preview": True,
        "tags": ["Data Cloud", "Platform"]
    },
    {
        "title": "Sales Cloud Advanced Features Demo",
        "type": "Demo Video",
        "link": "https://consensus.salesforce.com/demos/sales-cloud-advanced-features",
        "created_date": "2024-02-10",
        "duration": 25,
        "view_count": 12800,
        "public_preview": True,
        "tags": ["Sales Cloud", "Advanced"]
    },
    {
        "title": "Service Cloud Integration Demo",
        "type": "Demo Video",
        "link": "https://consensus.salesforce.com/demos/service-cloud-integration",
        "created_date": "2024-03-05",
        "duration": 20,
        "view_count": 10500,
        "public_preview": True,
        "tags": ["Service Cloud", "Integration"]
    }
]

def generate_agent_response(utterance):
    """Generate a realistic agent response based on the utterance"""
    
    # Determine if it's asking for ACT or Consensus content
    is_act = "ACT" in utterance.upper()
    is_consensus = "Consensus" in utterance.upper()
    
    # Determine product focus
    product = "Sales Cloud"
    if "Data Cloud" in utterance:
        product = "Data Cloud"
    elif "Service Cloud" in utterance:
        product = "Service Cloud"
    elif "Marketing Cloud" in utterance:
        product = "Marketing Cloud"
    
    # Generate response based on content type
    if is_act:
        return generate_act_response(utterance, product)
    elif is_consensus:
        return generate_consensus_response(utterance, product)
    else:
        # Mixed or unclear request
        return generate_mixed_response(utterance, product)

def generate_act_response(utterance, product):
    """Generate ACT course response"""
    
    # Filter courses by product
    relevant_courses = [course for course in ACT_COURSES if product.lower() in course["title"].lower()]
    
    if not relevant_courses:
        # Generate some courses if none match
        relevant_courses = [
            {
                "title": f"{product} Fundamentals",
                "type": "Course",
                "link": f"https://trailhead.salesforce.com/content/learn/modules/{product.lower().replace(' ', '-')}-fundamentals",
                "created_date": "2024-01-15",
                "completion_rate": random.randint(70, 90),
                "enrollments": random.randint(1000, 3000),
                "tags": [product, "Fundamentals"]
            },
            {
                "title": f"{product} Advanced Configuration",
                "type": "Course", 
                "link": f"https://trailhead.salesforce.com/content/learn/modules/{product.lower().replace(' ', '-')}-advanced",
                "created_date": "2024-02-20",
                "completion_rate": random.randint(75, 85),
                "enrollments": random.randint(800, 2500),
                "tags": [product, "Advanced"]
            }
        ]
    
    # Build response
    response = f"Here are the ACT courses for {product}:\n\n"
    
    for i, course in enumerate(relevant_courses[:5], 1):
        response += f"{i}. {course['title']}\n"
        response += f"   Type: {course['type']}\n"
        response += f"   Link: {course['link']}\n"
        response += f"   Created Date: {course['created_date']}\n"
        response += f"   Completion Rate: {course['completion_rate']}%\n"
        response += f"   Enrollments: {course['enrollments']:,}\n\n"
    
    # Add insights
    total_enrollments = sum(course['enrollments'] for course in relevant_courses)
    avg_completion = sum(course['completion_rate'] for course in relevant_courses) / len(relevant_courses)
    
    response += f"Key Insights:\n"
    response += f"- {len(relevant_courses)} ACT courses found for {product}\n"
    response += f"- Average completion rate: {avg_completion:.1f}%\n"
    response += f"- Total enrollments: {total_enrollments:,}\n"
    response += f"- Strong performance across all courses\n\n"
    response += f"Recommendation: Focus on {relevant_courses[0]['title']} for comprehensive foundation."
    
    return response

def generate_consensus_response(utterance, product):
    """Generate Consensus demo response"""
    
    # Filter demos by product
    relevant_demos = [demo for demo in CONSENSUS_DEMOS if product.lower() in demo["title"].lower()]
    
    if not relevant_demos:
        # Generate some demos if none match
        relevant_demos = [
            {
                "title": f"{product} Platform Overview",
                "type": "Demo Video",
                "link": f"https://consensus.salesforce.com/demos/{product.lower().replace(' ', '-')}-platform-overview",
                "created_date": "2024-01-20",
                "duration": random.randint(15, 25),
                "view_count": random.randint(5000, 15000),
                "public_preview": True,
                "tags": [product, "Platform"]
            },
            {
                "title": f"{product} Advanced Features Demo",
                "type": "Demo Video",
                "link": f"https://consensus.salesforce.com/demos/{product.lower().replace(' ', '-')}-advanced-features",
                "created_date": "2024-02-15",
                "duration": random.randint(18, 30),
                "view_count": random.randint(4000, 12000),
                "public_preview": True,
                "tags": [product, "Advanced"]
            }
        ]
    
    # Build response
    response = f"Here are the Consensus demos for {product}:\n\n"
    
    for i, demo in enumerate(relevant_demos[:5], 1):
        response += f"{i}. {demo['title']}\n"
        response += f"   Type: {demo['type']}\n"
        response += f"   Link: {demo['link']}\n"
        response += f"   Created Date: {demo['created_date']}\n"
        response += f"   Duration: {demo['duration']} minutes\n"
        response += f"   View Count: {demo['view_count']:,}\n"
        response += f"   Public Preview: {'Available' if demo['public_preview'] else 'Not Available'}\n\n"
    
    # Add insights
    total_views = sum(demo['view_count'] for demo in relevant_demos)
    avg_duration = sum(demo['duration'] for demo in relevant_demos) / len(relevant_demos)
    
    response += f"Key Insights:\n"
    response += f"- {len(relevant_demos)} Consensus demos found for {product}\n"
    response += f"- Total view count: {total_views:,}\n"
    response += f"- Average duration: {avg_duration:.1f} minutes\n"
    response += f"- All demos have public preview available\n"
    response += f"- Strong engagement across all demos\n\n"
    response += f"Recommendation: Start with {relevant_demos[0]['title']} for comprehensive understanding."
    
    return response

def generate_mixed_response(utterance, product):
    """Generate mixed ACT/Consensus response"""
    return f"Here's a comprehensive overview of {product} content:\n\n" + \
           generate_act_response(utterance, product) + "\n\n" + \
           generate_consensus_response(utterance, product)

@app.route('/api/agent/analyze', methods=['POST'])
def analyze_utterance():
    """Main API endpoint for agent analysis"""
    try:
        data = request.get_json()
        utterance = data.get('utterance', '')
        
        if not utterance:
            return jsonify({
                "error": "No utterance provided",
                "response": "Please provide a valid utterance to analyze."
            }), 400
        
        # Generate agent response
        agent_response = generate_agent_response(utterance)
        
        return jsonify({
            "success": True,
            "response": agent_response,
            "utterance": utterance,
            "timestamp": datetime.now().isoformat(),
            "source": "Agent API"
        })
        
    except Exception as e:
        return jsonify({
            "error": str(e),
            "response": f"Error processing request: {str(e)}"
        }), 500

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "service": "Agent API Server"
    })

if __name__ == '__main__':
    print("🚀 Starting Agent API Server")
    print("📡 Server will be available at: http://localhost:9999")
    print("🔗 Health check: http://localhost:9999/health")
    print("🧪 Test endpoint: http://localhost:9999/api/agent/analyze")
    print("=" * 50)
    
    app.run(host='0.0.0.0', port=9999, debug=True)
