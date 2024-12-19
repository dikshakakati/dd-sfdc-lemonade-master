/**
 * @description Test class for the LookupSearchCtrl Controller class
 * @author BizApps
 * @date 29-April-2024
 **/
@IsTest
private class LookupSearchCtrlTest {
    @IsTest
    static void testWhenQueryingExistingRecordsThenReturnCorrectRecords() {
        LookupSearchCtrl.mockRecords = new List<SObject>{
            new Payment_Account__c(),
            new Payment_Account__c()
        };

        LookupSearchCtrl.SearchWrapper inputWrapper = new LookupSearchCtrl.SearchWrapper();
        inputWrapper.objectApiName = 'Payment_Account__c';
        inputWrapper.primaryFieldToSearch = 'Name';
        inputWrapper.secondaryField = 'Business_Account__r.Name';
        inputWrapper.fieldsToQuery = 'Name,Entity_Type__c,Business_Account__r.Name';
        inputWrapper.searchString = 'PA-';

        Test.startTest();
        List<LookupSearchCtrl.ResultWrapper> results = LookupSearchCtrl.fetchRecords(inputWrapper);
        Test.stopTest();

        System.assertEquals(
            2,
            results.size(),
            'Two Payment Account records should be returned from the mock list'
        );
    }

    @isTest
    static void testWhenSubmittingSearchInfoToFetchRecordsThenReturnResultWrapper() {
        // Initialize SearchWrapper instance
        LookupSearchCtrl.SearchWrapper wrapper = new LookupSearchCtrl.SearchWrapper();
        wrapper.objectApiName = 'Account';
        wrapper.primaryFieldToSearch = 'Name';
        wrapper.secondaryField = 'Industry';
        wrapper.searchString = 'Test';

        List<LookupSearchCtrl.ResultWrapper> results = LookupSearchCtrl.fetchRecords(wrapper);

        System.assertNotEquals(
            null,
            results,
            'When passing null to the fetch() method, we should receive null.'
        );
        System.assertEquals(
            0,
            results.size(),
            'When passing null to the fetch() method, we should receive null.'
        );

        // Validate fields
        for (LookupSearchCtrl.ResultWrapper res : results) {
            System.assertNotEquals(null, res.mainField, 'All fields shoul be null from `results`');
            System.assertNotEquals(null, res.subField, 'All fields shoul be null from `results`');
            System.assertNotEquals(null, res.record, 'All fields shoul be null from `results`');
        }

        // Pass a null SearchWrapper
        List<LookupSearchCtrl.ResultWrapper> shouldBeNullResults = LookupSearchCtrl.fetchRecords(
            null
        );

        System.assertEquals(
            null,
            shouldBeNullResults,
            'When passing null to the fetch() method, we should receive null.'
        );

        // Initialize SearchWrapper with incorrect data
        LookupSearchCtrl.SearchWrapper invalidWrapper = new LookupSearchCtrl.SearchWrapper();
        invalidWrapper.objectApiName = 'InvalidObject';

        // Test exception handling
        try {
            LookupSearchCtrl.fetchRecords(invalidWrapper);
        } catch (AuraHandledException e) {
            System.assertNotEquals(
                null,
                e.getMessage(),
                'An exception should be thrown with an invalid input.'
            );
        }
    }

    @IsTest
    static void testWhenPassingSingleIdThenReturnRecord() {
        Id paymentAccountId = Fake.generateId(Payment_Account__c.class);

        LookupSearchCtrl.mockRecords = new List<SObject>{
            new Payment_Account__c(Id = paymentAccountId, Entity_Type__c = 'Company')
        };

        Test.startTest();
        LookupSearchCtrl.ResultWrapper result = LookupSearchCtrl.fetchRecordById(paymentAccountId);
        Test.stopTest();

        System.assertNotEquals(null, result, 'The result should return a valid wrapper object');

        Boolean errorThrown = false;
        try {
            LookupSearchCtrl.fetchRecordById(null);
        } catch (Exception ex) {
            errorThrown = true;
        }

        System.assert(
            errorThrown,
            'An exception should have been thrown if there is a null ID passed'
        );

        errorThrown = false;
        LookupSearchCtrl.mockRecords = null;
        try {
            LookupSearchCtrl.fetchRecordById(paymentAccountId);
        } catch (Exception ex) {
            errorThrown = true;
        }

        System.assert(errorThrown, 'An exception should have been thrown if no records were found');
    }

    @IsTest
    static void testWhenPassingIdsToSearchMethodThenReturnRecords() {
        Id paymentAccountId1 = Fake.generateId(Payment_Account__c.class);
        Id paymentAccountId2 = Fake.generateId(Payment_Account__c.class);
        Id paymentAccountId3 = Fake.generateId(Payment_Account__c.class);
        Id paymentAccountId4 = Fake.generateId(Payment_Account__c.class);

        Set<Id> recordIds = new Set<Id>{
            paymentAccountId1,
            paymentAccountId2,
            paymentAccountId3,
            paymentAccountId4
        };

        LookupSearchCtrl.mockRecords = new List<SObject>{
            new Payment_Account__c(Id = paymentAccountId1),
            new Payment_Account__c(Id = paymentAccountId2),
            new Payment_Account__c(Id = paymentAccountId3),
            new Payment_Account__c(Id = paymentAccountId4)
        };

        Test.startTest();
        List<LookupSearchCtrl.ResultWrapper> results = LookupSearchCtrl.retrieveResultsByIds(
            recordIds
        );

        List<LookupSearchCtrl.ResultWrapper> resultsShouldBeNull = LookupSearchCtrl.retrieveResultsByIds(
            null
        );
        Test.stopTest();

        System.assertEquals(
            recordIds.size(),
            results.size(),
            recordIds.size() + ' records should be returned'
        );
        System.assertEquals(0, resultsShouldBeNull.size(), 'Records should be empty');

        Boolean exceptionThrown = false;
        try {
            LookupSearchCtrl.retrieveResultsByIds(new Set<Id>{ UserInfo.getUserId() });
        } catch (Exception ex) {
            exceptionThrown = ex != null;
        }

        System.assert(
            exceptionThrown,
            'An error should be thrown due to an unsupported object inputted'
        );
    }
}