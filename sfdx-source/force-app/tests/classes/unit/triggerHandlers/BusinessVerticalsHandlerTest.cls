/**
 * @description This is test class for BusinessVerticalHandler class
 * @author Deloitte
 * @date 11/11/2023
 */
@isTest(SeeAllData=false)
public class BusinessVerticalsHandlerTest {
    /**
     * @description Test BusinessVerticalHandler class on Business Vertical Insertion
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenBusinessVerticalCreatedThenCall() {
        List<Business_Vertical__c> businessVerticalList = new List<Business_Vertical__c>{
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
                Vertical_Name__c = 'Alcohol',
                Business_Vertical_ID__c = '13'
            )
        };
        fflib_SObjectDomain.Test.Database.onInsert(businessVerticalList);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessVerticals businessVerticalsMock = (IBusinessVerticals) mocks.mock(IBusinessVerticals.class);
        mocks.startStubbing();
        mocks.when(businessVerticalsMock.getType()).thenReturn(Business_Vertical__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(businessVerticalsMock);

        fflib_SObjectDomain.triggerHandler(BusinessVerticalsHandler.class);
        ((IBusinessVerticals) mocks.verify(businessVerticalsMock, 1)).assignNameOnInsertOrNameUpdate();
    }

    @isTest
    public static void testWhenBusinessVerticalIsInsertedThenNameIsUpdated() {
        List<Business_Vertical__c> businessVerticalList = new List<Business_Vertical__c>{
            new Business_Vertical__c(
                Active__c = true,
                Description__c = 'for Unit Testing',
                Menu_UI_Type__c = 'Retail',
                Primary_Vertical__c = 'Baby',
                Product__c = 'Drive',
                Vertical_Name__c = 'Grocery',
                Business_Vertical_ID__c = '12'
            )
        };
        insert businessVerticalList;

        List<Business_Vertical__c> insertedBusinessVerticalRecord = [
            SELECT Id, Name, Vertical_Name__c, Business_Vertical_ID__c
            FROM Business_Vertical__c
        ];

        Id bizVertRecord = insertedBusinessVerticalRecord[0].id;
		insertedBusinessVerticalRecord[0].Business_Vertical_ID__c = '';
        update insertedBusinessVerticalRecord[0];
        
  		List<Business_Vertical__c> updatedBusinessVerticalRecord = [
            SELECT Id, Name, Vertical_Name__c, Business_Vertical_ID__c
            FROM Business_Vertical__c where id =:bizVertRecord
        ];

        System.assertNotEquals(
            businessVerticalList[0].Vertical_Name__c + ' ' + '(' +
            businessVerticalList[0].Business_Vertical_ID__c + ')',
            updatedBusinessVerticalRecord[0].Name,
            'The Business Vertical Name has not been assigned correctly'
        );
    }
}
