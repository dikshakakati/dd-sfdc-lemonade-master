/**
* @author Deloitte
* @date 05/20/2024
* @description This is  the test class for SSMO Contact Creation
*/
@isTest(seeAllData=false)
private class SSMOContactCreationServiceImplTest {
    private static final String STATIC_RESOURCE_TEST_JSON = 'SSMO_Contact_Ingestion_Mock_Payload';


     /**
     * @description It is used verify contact creation scenario when no matched records are
     * present in the payload
     * */
    @isTest
    private static void testWhenNoMatchingRecordThenCreateContactFromPayload() {

        StaticResource sr = fetchStaticResource();
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper)System.JSON.deserialize(payloadString,SSMOFalloutWrapper.class);
        Contact contactToInsert = new Contact();


        Contact contactsTobeInserted = SSMOContactCreationService.insertContactSSMO(parsedPayloads,contactToInsert);

        System.assertEquals(parsedPayloads.storeName, contactsTobeInserted.Company__c, 'False');
        System.assertEquals(parsedPayloads.ownerFirstName, contactsTobeInserted.FirstName, 'False');
        System.assertEquals(parsedPayloads.ownerLastName, contactsTobeInserted.LastName, 'False');
        System.assertEquals(parsedPayloads.ownerPhone, contactsTobeInserted.MobilePhone, 'False');
        System.assertEquals(parsedPayloads.email, contactsTobeInserted.Email, 'False');
	}

     /**
     * @description It is used verify contact updation scenario when matched records are
     * present in the payload
     * */
    @isTest
    private static void testWhenMatchingContactFoundThenUpdateContactFromPayload() {
        Id subMarketIdMock = fflib_IDGenerator.generate(Submarket__c.SObjectType);
        StaticResource sr = fetchStaticResource();
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper)System.JSON.deserialize(payloadString,SSMOFalloutWrapper.class);
        Contact testInsertContactSSMO = new Contact();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ISubmarketsSelector mockSubmarketsSelector = (ISubmarketsSelector) mocks.mock(
            ISubmarketsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockSubmarketsSelector.sObjectType()).thenReturn(Submarket__c.SObjectType);
        mocks.when(
                mockSubmarketsSelector.getSubmarketById('9094')
            )
            .thenReturn(new List<Submarket__c>{new Submarket__c(Id = subMarketIdMock)});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockSubmarketsSelector);


       Contact contactsTobeUpdated = SSMOContactCreationService.updateContactSSMO(parsedPayloads,testInsertContactSSMO);
       System.assertEquals(parsedPayloads.sourceUniqueId, contactsTobeUpdated.Unique_Identifier__c, 'False');
       System.assertEquals(subMarketIdMock, contactsTobeUpdated.Submarket__c, 'False');
       System.assertEquals(parsedPayloads.addressVerificationInfo ?.alcoholRules ?.alcoholAllowanceCategory, contactsTobeUpdated.Alcohol_Eligibility__c, 'False');
       System.assertEquals(parsedPayloads.addressVerificationInfo ?.addressVerificationStatus, contactsTobeUpdated.Address_Verification_Status__c, 'False');
       System.assertEquals(parsedPayloads.addressVerificationInfo ?.rejectedReason, contactsTobeUpdated.Address_Rejection_Reason__c , 'False');
    }
   	/**
     * @description It is used verify contact updation with new submarket creation scenario when matched records are
     * present in the payload
     * */
    @isTest
    private static void testWhenContactPresentThenUpdateContactWithNewSubmarket() {
        StaticResource sr = fetchStaticResource();
        Blob blobJSON = sr.Body;
        String payloadString = blobJSON.toString();
        SSMOFalloutWrapper parsedPayloads = (SSMOFalloutWrapper)System.JSON.deserialize(payloadString,SSMOFalloutWrapper.class);
        Contact testInsertContactSSMO = new Contact();

       Contact contactsTobeUpdated = SSMOContactCreationService.updateContactSSMO(parsedPayloads,testInsertContactSSMO);
       System.assertEquals(parsedPayloads.sourceUniqueId, contactsTobeUpdated.Unique_Identifier__c, 'False');
       System.assertEquals(String.valueOf(parsedPayloads.businessId), contactsTobeUpdated.Business_Id__c, 'False');
       System.assertEquals(parsedPayloads.storeHours, contactsTobeUpdated.Hours_of_Operation__c, 'False');
       System.assertEquals(String.valueof(parsedPayloads.storeId), contactsTobeUpdated.Store_Id__c , 'False');
    }

    /**
     * @description To query static resources
     * @return StaticResource
     * */
    private static StaticResource fetchStaticResource() {

        StaticResource stresource = [
            SELECT Body
            FROM StaticResource
            WHERE Name = :STATIC_RESOURCE_TEST_JSON
        ];
        return stresource;
    }
}