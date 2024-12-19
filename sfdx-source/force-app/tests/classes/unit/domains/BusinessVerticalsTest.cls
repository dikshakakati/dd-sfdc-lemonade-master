/**
 * @author Deloitte
 * @date 11/11/2023
 * @description This is the test class for Business Vertical domain class
 */
@isTest(seeAllData=false)
private class BusinessVerticalsTest {

    @isTest
    private static void testWhenBusinessVerticalInsertThenNameAssigned() {
        List<Business_Vertical__c> businessVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Baby',
                Product__c = 'Drive',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = '12'
            ),
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing 2',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'Alcohol'
            )
        };

        IBusinessVerticals businessVerticalsInstance = BusinessVerticals.newInstance(businessVerticalsRecords);
        businessVerticalsInstance.assignNameOnInsertOrNameUpdate();
        System.assertEquals(
            businessVerticalsRecords[0].Vertical_Name__c + ' ' + '(' + 
            businessVerticalsRecords[0].Business_Vertical_ID__c + ')',
            businessVerticalsRecords[0].Name,
            'The Business Vertical Name has not been assigned correctly'
        );
        System.assertEquals(
            businessVerticalsRecords[1].Vertical_Name__c,
            businessVerticalsRecords[1].Name,
            'The Business Vertical Name has not been assigned correctly'
        );
    }

    @isTest
    private static void testWhenOpportunityIsUpdatedThenNameIsAssigned() {
        Id businessVerticalRecord1 = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);
        Id businessVerticalRecord2 = fflib_IDGenerator.generate(Business_Vertical__c.SObjectType);

        List<Business_Vertical__c> verticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = businessVerticalRecord1,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Baby',
                Product__c = 'Drive',
                Vertical_Name__c = 'Alcohol',
                Business_Vertical_ID__c = '12'
            ),
            new Business_Vertical__c(
                Id = businessVerticalRecord2,
                Active__c = true,
                Description__c = 'for Unit Testing 2',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = '13'
            )
        };
        List<Business_Vertical__c> oldVerticalsRecords = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Id = businessVerticalRecord1,
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Baby',
                Product__c = 'Drive',
                Vertical_Name__c = 'Grocery'
            ),
            new Business_Vertical__c(
                Id = businessVerticalRecord2,
                Active__c = true,
                Description__c = 'for Unit Testing 2',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Alcohol',
                Product__c = 'Drive',
                Vertical_Name__c = 'Alcohol',
                Business_Vertical_ID__c = '13'
            )
        };

        IBusinessVerticals businessVerticalsInstance = BusinessVerticals.newInstance(verticalsRecords);
        businessVerticalsInstance.assignNameOnInsertOrNameUpdate();

        System.assertEquals(
            verticalsRecords[0].Vertical_Name__c + ' ' + '(' + 
            verticalsRecords[0].Business_Vertical_ID__c + ')',
            verticalsRecords[0].Name,
            'The Business Vertical Name has not been assigned correctly'
        );

         // Assert that the record has been updated
        System.assertNotEquals(verticalsRecords[0].Name, oldVerticalsRecords[0].Name, 'Record was not updated');
    }
}