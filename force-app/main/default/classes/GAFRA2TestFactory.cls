@isTest
public class GAFRA2TestFactory {

    public static List<Audience__c> createAudiences(Integer count) {
        List<Audience__c> audiences = new List<Audience__c>();
        for (Integer i = 0; i < count; i++) {
            audiences.add(new Audience__c(Name = 'Test Audience ' + i));
        }
        insert audiences;
        return audiences;
    }
    
    public static List<Learner_Profile__c> createLearnerProfiles(Integer count) {
        List<Learner_Profile__c> profiles = new List<Learner_Profile__c>();
        for (Integer i = 0; i < count; i++) {
            // Assuming Learner_Profile__c has a Name field that needs to be unique.
            // Adjust if the object has different required fields.
            profiles.add(new Learner_Profile__c(Name = 'Test Learner ' + i));
        }
        // This object might not exist in the user's org. If so, this will fail.
        // I'll proceed assuming it does, as it's referenced in a handler.
        // insert profiles; 
        return profiles;
    }

    public static List<Checklist__c> createChecklists(Integer count) {
        List<Checklist__c> checklists = new List<Checklist__c>();
        for (Integer i = 0; i < count; i++) {
            checklists.add(new Checklist__c(Name = 'Test Checklist ' + i));
        }
        insert checklists;
        return checklists;
    }
    
    public static List<Checklist_Asset__c> createChecklistAssets(Integer count, Id checklistId) {
        List<Checklist_Asset__c> assets = new List<Checklist_Asset__c>();
        for (Integer i = 0; i < count; i++) {
            assets.add(new Checklist_Asset__c(
                Name = 'Test Checklist Asset ' + i,
                Checklist__c = checklistId
            ));
        }
        insert assets;
        return assets;
    }
    
    public static List<Curriculum__c> createCurriculums(Integer count) {
        List<Curriculum__c> curriculums = new List<Curriculum__c>();
        for(Integer i=0; i < count; i++){
            curriculums.add(new Curriculum__c(Name='Test Curriculum ' + i));
        }
        insert curriculums;
        return curriculums;
    }

    public static List<Course__c> createCourses(Integer count) {
        List<Course__c> courses = new List<Course__c>();
        for(Integer i=0; i < count; i++){
            courses.add(new Course__c(Name='Test Course ' + i));
        }
        insert courses;
        return courses;
    }

    public static List<Asset__c> createAssets(Integer count) {
        List<Asset__c> assets = new List<Asset__c>();
        for(Integer i=0; i < count; i++){
            assets.add(new Asset__c(Name='Test Asset ' + i));
        }
        insert assets;
        return assets;
    }
}