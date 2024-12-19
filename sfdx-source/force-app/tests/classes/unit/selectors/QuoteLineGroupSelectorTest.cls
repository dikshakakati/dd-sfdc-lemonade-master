/**
 * @author deloitte
 * @date 11/09/2023
 * @description This is test class for QuoteLineGroupSelector class
 */
@isTest(seeAllData=false)
public class QuoteLineGroupSelectorTest {
    @testSetup
    static void setupData() {
        SBQQ.TriggerControl.disable();

        Product2 cashOnDeliveryProduct = CPQTestDataFactory.createCoDProduct(false);
        cashOnDeliveryProduct.Family = 'Drive';
        insert cashOnDeliveryProduct;
        Product2 product2 = CPQTestDataFactory.createProduct(false);
        product2.Family = 'Drive Promotion';
        insert product2;

        Account testAccount = TestDataFactory.createAccount(true);
        Opportunity testOpp = CPQTestDataFactory.createOpportunity(testAccount.Id, true);
        SBQQ__Quote__c quote = CPQTestDataFactory.createQuote(testOpp, testAccount, null, true);

        SBQQ__QuoteLineGroup__c qlGroup = CPQTestDataFactory.createGroup(quote.Id, false);
        insert qlGroup;
        SBQQ.TriggerControl.enable();
    }

    /**
     * @description This is test method to test getSObjectType and getSObjectFieldList values.
     */
    @isTest
    private static void testWhenObjectTypeAndFieldListThenReturnCorrect() {
        QuoteLineGroupSelector quoteLineGroupInstance = new QuoteLineGroupSelector();
        Schema.SObjectType typeOfObj = quoteLineGroupInstance.getSObjectType();
        System.assertEquals(
            Schema.SBQQ__QuoteLineGroup__c.SObjectType,
            typeOfObj,
            'The object type must be SBQQ__QuoteLineGroup__c'
        );

        List<Schema.SObjectField> fieldList = quoteLineGroupInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{
                SBQQ__QuoteLineGroup__c.Id,
                SBQQ__QuoteLineGroup__c.Name,
                SBQQ__QuoteLineGroup__c.SBQQ__Quote__c,
                SBQQ__QuoteLineGroup__c.SBQQ__Account__c
            },
            fieldList,
            ' Mismatch in field list'
        );
    }

    /**
     * @description This is test method tests that quote groups are fetched from groupIds
     */
    @isTest
    private static void testWhenQutoteLineGroupIdsPassedThenFetchGroups() {
        List<SBQQ__QuoteLineGroup__c> quoteGroupQueryTestData = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];
        Set<Id> quoteLineGroupQueryTestDataId = new Set<Id>();
        for (SBQQ__QuoteLineGroup__c subId : quoteGroupQueryTestData) {
            quoteLineGroupQueryTestDataId.add(subId.Id);
        }
        Test.startTest();
        Map<Id, SBQQ__QuoteLineGroup__c> quoteLineGroupQueryData = QuoteLineGroupSelector.newInstance()
            .selectGroupRecords(quoteLineGroupQueryTestDataId);
        Test.stopTest();
        System.assertEquals(
            1,
            quoteLineGroupQueryData.size(),
            'The return record is not matching with inserted record'
        );
    }

    /**
     * @description This is test method to fetch Quote line group from quotes.
     */
    @isTest
    private static void testWhenQuoteIdsPassedThenFetchQuoteLineGroups() {
        SBQQ.TriggerControl.disable();
        Set<Id> quoteQueryTestDataIds = new Set<Id>();
        SBQQ__QuoteLineGroup__c quoteLineGrp = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];
        Account testAccountRec = [SELECT id FROM Account LIMIT 1];
        Opportunity testOppId = CPQTestDataFactory.createOpportunity(testAccountRec.Id, true);
        SBQQ__Quote__c amendedQuote = CPQTestDataFactory.createQuote(
            testOppId,
            testAccountRec,
            null,
            true
        );
        SBQQ__QuoteLineGroup__c amendedqlGroup = CPQTestDataFactory.createGroup(
            amendedQuote.Id,
            true
        );
        amendedqlGroup.SBQQ__Source__c = quoteLineGrp.Id;
        update amendedqlGroup;
        SBQQ.TriggerControl.enable();
        quoteQueryTestDataIds.add(amendedQuote.Id);
        Test.startTest();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupQueryData = QuoteLineGroupSelector.newInstance()
            .selectGroupRecordsFromQuote(quoteQueryTestDataIds);
        Test.stopTest();
        System.assertEquals(1, quoteLineGroupQueryData.size(), 'No records returned');
    }

    /**
     * @description This is test method to fetch Quote line group from quotes.
     */
    @isTest
    private static void testWhenQuoteLineGorupIdsPassedThenFetchQuoteLineGroups() {
        SBQQ.TriggerControl.disable();
        Set<Id> quoteLineGroupIds = new Set<Id>();
        Set<String> quotelineGroupFields = new Set<String>();
        quotelineGroupFields.add('Id');
       	SBQQ__QuoteLineGroup__c quoteLineGrp = [
            SELECT id
            FROM SBQQ__QuoteLineGroup__c
            LIMIT 1
        ];
        Account testAccountRec = [Select id from Account Limit 1];
        Opportunity testOppId = CPQTestDataFactory.createOpportunity(testAccountRec.Id, true);
        SBQQ__Quote__c amendedQuote = CPQTestDataFactory.createQuote(testOppId, testAccountRec, null, true);
        SBQQ__QuoteLineGroup__c amendedqlGroup = CPQTestDataFactory.createGroup(amendedQuote.Id, true);
        amendedqlGroup.SBQQ__Source__c = quoteLineGrp.Id;
        update amendedqlGroup;
        SBQQ.TriggerControl.enable();
        quoteLineGroupIds.add(amendedqlGroup.Id);
        Test.startTest();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroupQueryData = QuoteLineGroupSelector.newInstance()
            .selectQuoteLineGroupByGroupIdWithDynamicFields(quoteLineGroupIds,quotelineGroupFields);
        Test.stopTest();
        System.assertEquals(
            1,
            quoteLineGroupQueryData.size(),
            'No records returned'
        );
    }
}