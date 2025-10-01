#!/bin/bash

# Copy Agent Classes to QP-Agent Repository
# This script helps you copy specific agent-related Apex classes for versioning

echo "=== Copying Agent Classes to QP-Agent Repository ==="

# Source and destination directories
SOURCE_DIR="force-app/main/default/classes"
DEST_DIR="../QP-Agent/src/classes"

# List of key agent classes to copy (you can modify this list)
AGENT_CLASSES=(
    "ANAgentKPIAnalysisHandler"
    "ANAgentKPIAnalysisService" 
    "ANAgentOpenPipeAnalysisHandler"
    "ANAgentOpenPipeAnalysisService"
    "ANAgentKnowledgeHandler"
    "ANAgentKnowledgeService"
    "ANAgentEmailHandler"
    "ANAgentEmailService"
    "ANAgentSimpleCSVService"
    "ANAgentCallSchedulerHandler"
    "ANAgentCallSchedulerService"
)

echo "Available agent classes:"
ls $SOURCE_DIR/ANAgent*Handler.cls | sed 's/.*\///' | sed 's/\.cls//' | nl

echo ""
echo "Classes to copy:"
for class in "${AGENT_CLASSES[@]}"; do
    echo "- $class"
done

echo ""
read -p "Do you want to copy these classes? (y/n): " -n 1 -r
echo

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Copying classes..."
    
    # Create destination directory if it doesn't exist
    mkdir -p $DEST_DIR
    
    for class in "${AGENT_CLASSES[@]}"; do
        if [ -f "$SOURCE_DIR/$class.cls" ]; then
            echo "Copying $class.cls..."
            cp "$SOURCE_DIR/$class.cls" "$DEST_DIR/"
            
            if [ -f "$SOURCE_DIR/$class.cls-meta.xml" ]; then
                echo "Copying $class.cls-meta.xml..."
                cp "$SOURCE_DIR/$class.cls-meta.xml" "$DEST_DIR/"
            fi
        else
            echo "Warning: $class.cls not found"
        fi
    done
    
    echo ""
    echo "=== Copy Complete ==="
    echo "Classes copied to: $DEST_DIR"
    echo ""
    echo "Next steps:"
    echo "1. Go to QP-Agent directory: cd ../QP-Agent"
    echo "2. Review copied classes: git status"
    echo "3. Add to git: git add src/classes/"
    echo "4. Commit: git commit -m 'feat: add core agent classes'"
    echo "5. Push: git push origin main"
else
    echo "Copy cancelled. You can manually copy specific classes as needed."
fi
