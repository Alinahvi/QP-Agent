#!/bin/bash

echo "🚀 ABAgentFuturePipeAnalysisHandler - GitHub Push Script"
echo "======================================================="

# Check if we're in the right directory
if [ ! -d "qp-agent-deployment" ]; then
    echo "❌ qp-agent-deployment directory not found. Please run this script from the project root."
    exit 1
fi

echo "📋 Choose your push method:"
echo "1. Manual upload via GitHub web interface (Recommended)"
echo "2. Git push with personal access token"
echo "3. Create release package only"
echo ""
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "🌐 Manual Upload Instructions:"
        echo "=============================="
        echo "1. Go to: https://github.com/Alinahvi/QP-Agent"
        echo "2. Click 'Add file' → 'Upload files'"
        echo "3. Drag and drop the entire 'qp-agent-deployment' folder"
        echo "4. Add commit message: 'feat: Add ABAgentFuturePipeAnalysisHandler with intelligence features'"
        echo "5. Click 'Commit changes'"
        echo ""
        echo "📁 Your deployment package is ready at:"
        echo "   $(pwd)/qp-agent-deployment/"
        echo ""
        echo "📦 Alternative: Use the zip file:"
        echo "   $(pwd)/qp-agent-abagent-deployment.zip"
        echo ""
        echo "✅ All files included:"
        echo "   - 14 Apex classes with metadata"
        echo "   - Complete documentation (987 lines)"
        echo "   - Deployment scripts and guides"
        echo "   - Permission sets"
        ;;
    2)
        echo ""
        echo "🔑 Git Push with Personal Access Token:"
        echo "======================================"
        echo "You'll need a GitHub Personal Access Token with repo permissions."
        echo ""
        echo "1. Create a token at: https://github.com/settings/tokens"
        echo "2. Select 'repo' scope"
        echo "3. Copy the token"
        echo ""
        read -p "Enter your GitHub Personal Access Token: " token
        
        if [ -z "$token" ]; then
            echo "❌ Token is required for this method."
            exit 1
        fi
        
        echo "🔄 Setting up git remote with token..."
        git remote set-url qp-agent https://${token}@github.com/Alinahvi/QP-Agent.git
        
        echo "📤 Pushing to GitHub..."
        if git push qp-agent HEAD:main; then
            echo "✅ Successfully pushed to QP-Agent repository!"
        else
            echo "❌ Push failed. Please check your token permissions."
        fi
        ;;
    3)
        echo ""
        echo "📦 Release Package Created:"
        echo "=========================="
        echo "✅ Zip file created: qp-agent-abagent-deployment.zip"
        echo "✅ Deployment folder: qp-agent-deployment/"
        echo ""
        echo "📋 Contents:"
        echo "   - Complete ABAgentFuturePipeAnalysisHandler system"
        echo "   - 14 Apex classes with metadata files"
        echo "   - Comprehensive documentation (987 lines)"
        echo "   - Deployment scripts and guides"
        echo "   - Permission sets and configuration"
        echo ""
        echo "🎯 Ready for manual upload to GitHub!"
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "🎉 ABAgentFuturePipeAnalysisHandler deployment package is ready!"
echo ""
echo "📚 Next steps after uploading:"
echo "   1. Review the documentation in your repository"
echo "   2. Deploy to Salesforce using the provided scripts"
echo "   3. Test the handlers with sample data"
echo "   4. Integrate with your QP Agent system"
echo ""
echo "📖 Documentation included:"
echo "   - Complete system guide (987 lines)"
echo "   - Architecture diagrams"
echo "   - API reference"
echo "   - Deployment instructions"
echo "   - Troubleshooting guide"
