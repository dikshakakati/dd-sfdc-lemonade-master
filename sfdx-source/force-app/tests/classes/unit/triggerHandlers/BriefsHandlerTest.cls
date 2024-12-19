/**
 * @author ATG
 * @date 10/10/23
 * @description test class to test BriefHandler
 */
@isTest(SeeAllData = false)
public class BriefsHandlerTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefIsUpdatedThenOpportunityIsUpdated(){
        Id briefId = Fake.generateId(Brief__c.class);
        List<Brief__c> briefList = new List<Brief__c>{
            new Brief__c(Id = briefId,Campaign_TLDR__c = 'updatedValue')
        };
        List<Brief__c> oldBriefList = new List<Brief__c>{
            new Brief__c(Id = briefId, Campaign_TLDR__c = 'OriginalValue')
        };


        fflib_SObjectDomain.Test.Database.onUpdate(briefList, new Map<Id, SObject>(oldBriefList));
        fflib_SObjectDomain.triggerHandler(BriefHandler.class);
        BriefsServiceImpl briefService = new BriefsServiceImpl();
        briefService.updateOpportunityFromBrief(briefList);


    }
}