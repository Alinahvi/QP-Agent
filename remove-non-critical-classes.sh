#!/bin/bash

# Script to remove non-critical Apex classes from Salesforce org
# Created: $(date)

set -e

BACKUP_DIR="backup/non-critical-classes-removal-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "🚀 Starting removal of non-critical Apex classes..."
echo "📁 Backup directory: $BACKUP_DIR"

# Define non-critical classes to remove (starting with safest ones)
declare -a NON_CRITICAL_CLASSES=(
    # Small utility classes (< 1,000 bytes)
    "WithoutSharingUtilities"
    "AHMayQueryException"
    "attendanceController"
    "AHMayQueryHandler"
    "AHMayCourseQueryHandler"
    "GCalStatusResponseBatchHelper"
    "GcalHandler"
    "GCalStatusResponseBatch"
    "SiteLink"
    "EmailLogo"
    
    # Data/Constants classes
    "ResultData"
    "MediaConstants"
    "AHMayQueryRequest"
    "AHMayQueryResult"
    "AHMayEmployeeRecord"
    
    # Small helper classes
    "AHMayValidator"
    "AHMayUnsupportedQueryHandler"
    "AHMayOrConditionQueryHandler"
    "AHMayCrossTopicContext"
    "AHMayMonitoringService"
    "AHMayErrorHandler"
    "AHMayFieldConstants"
    
    # Assessment helper classes
    "assessmentResponseTriggerHelper"
    "assessmentLearnerList"
    "SkillAssessmentReassign"
    
    # Simple batch jobs
    "ThCompletionBatch"
    "RecommendationsCreateBatch"
    "RecommendationsDeactivateBatch"
    "SlackEscalationNotificationBatch"
    "SlackNotificationBatch"
    "SlackSecurityNotificationBatch"
    
    # UI/Display classes
    "FilterModal"
    "QuizDesigner"
    "learningItemDetailQuiz"
    
    # Simple notification classes
    "SurveyNotification"
    "RecommendationNotification"
    "RecommendationNotificationHelper"
    "SessionReminderNotificationBatch"
    "SessionSlackNotification"
    "SessionAttendedNotification"
    "SessionOwnerRoleNotification"
    "LearningAppCaseNotification"
    "LearningAppCaseStatusNotification"
    "SkillAssessmentAssessorNotifiction"
    
    # Upload/Import classes
    "UploadLearnersByCSV"
    "UploadSessionAttendeesByCsv"
    "UploadSessionRolesByCsv"
    "TrailheadImportModules"
    
    # Zoom Integration classes
    "ZoomAttendanceBatch"
    "ZoomAttendanceBatchHelper"
    "ZoomAttendanceTracker"
    "ZoomAsyncDeleteSession"
    "UpdateZoomSessionQueueable"
    "DeleteZoomSessionQueueable"
    "SessionGuestReassignZoomQueueable"
    
    # Generic utilities
    "Utilities"
    "ExceptionUtility2"
    
    # Small action classes
    "SessionCloneAction"
    "UnenrollLearning"
    "UpdateMediaAssignmentStatus"
    "UpdateMediaVersion"
    "SessionTriggerQueueable"
    "SessionGuestTriggerHelper"
    "TrainerWorkingRegionTriggerHelper"
    
    # Survey/Assessment classes
    "SurveyQuestionScoreHelper"
    "SEF_AssessmentConsumer"
    
    # Data Cloud classes
    "RecommendationDataCloudSkillBatch"
    "RecommendationDataCloudSkillHelper"
    "RecommendationDataCloudBatch"
    "SEEDDataCloudTaxonomyHelper"
    
    # Approval classes
    "TrainerApproval"
    "TrainerManagerApproval"
    
    # Other small classes
    "TrailheadAuth"
    "newEventOverride"
    "availabilityList"
    "SlackQueueableNotification"
    "SlackNotificationLog"
    "SlackEscalationNotificationBatchHelper"
    "ContentTagging"
    "manageAttendance"
    "ThCompletionBatchHelper"
    "EventManager"
    "LearnerSessionManager"
    "CourseAssetTriggerHelper"
    "CurriculumCourseTriggerHelper"
    "Lookup"
)

# Function to backup and remove a class
remove_class() {
    local class_name="$1"
    local class_file="force-app/main/default/classes/${class_name}.cls"
    local meta_file="force-app/main/default/classes/${class_name}.cls-meta.xml"
    
    echo "📦 Processing: $class_name"
    
    # Check if class exists
    if [ ! -f "$class_file" ]; then
        echo "   ⚠️  Class not found: $class_name"
        return 0
    fi
    
    # Backup the class
    echo "   💾 Backing up to $BACKUP_DIR/"
    cp "$class_file" "$BACKUP_DIR/" 2>/dev/null || true
    cp "$meta_file" "$BACKUP_DIR/" 2>/dev/null || true
    
    # Remove the class files
    echo "   🗑️  Removing class files..."
    rm -f "$class_file" "$meta_file"
    
    echo "   ✅ Removed: $class_name"
}

# Process each class
for class in "${NON_CRITICAL_CLASSES[@]}"; do
    remove_class "$class"
done

echo ""
echo "🎉 Non-critical class removal completed!"
echo "📁 Backup saved to: $BACKUP_DIR"
echo "📊 Total classes processed: ${#NON_CRITICAL_CLASSES[@]}"
echo ""
echo "⚠️  Next steps:"
echo "1. Deploy changes to your org"
echo "2. Run tests to verify functionality"
echo "3. Check for any remaining references"
echo "4. If issues arise, restore from backup"
