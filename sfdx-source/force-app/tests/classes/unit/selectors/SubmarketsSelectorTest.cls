/**
 * @author DoorDash
 * @date 04/02/2024
 * @description This is test class for SubmarketsSelector class
 */
@isTest
private class SubmarketsSelectorTest {
    private static final String UNVERIFIED_STATUS = 'Unverified';
    private static final String ASSERT_MESSAGE = 'Mismatch in count';
    private static final String SUBMARKET_NAME = 'test-market';
    private static final String SUBMARKET_ID = '122';

    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> submarketFieldsMock = new List<Schema.SObjectField>{
            Submarket__c.Id,
            Submarket__c.Name,
            Submarket__c.Submarket_ID__c
        };

        Schema.SObjectType typeOfObject = SubmarketsSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = SubmarketsSelector.newInstance()
            .getSObjectFieldList();

        System.assertEquals(
            Submarket__c.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Submarket__c'
        );
        System.assertEquals(
            submarketFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    /**
     * @description To test the query to retrieve Submarket records by using submarket Id and Name.
     */
    @isTest
    private static void testWhenIdAndNamePassedThenReturnSubmarkets() {
        String submarketId = SUBMARKET_ID;
        String submarketName = SUBMARKET_NAME;
        insert new Submarket__c(
            Name = submarketName,
            Submarket_ID__c = submarketId,
            Status__c = UNVERIFIED_STATUS
        );
        Test.startTest();
        List<Submarket__c> submarkets = SubmarketsSelector.newInstance()
            .getSubmarketsByIdAndName(submarketId, submarketName);
        Test.stopTest();
        System.assertEquals(1, submarkets.size(), ASSERT_MESSAGE);
    }

    /**
     * @description To test the query to retrieve Submarket records by using a submarket Id.
     */
    @isTest
    private static void testWhenSubmarketIdPassedThenReturnSubmarket() {
        String submarketId = SUBMARKET_ID;
        String submarketName = SUBMARKET_NAME;
        insert new Submarket__c(
            Name = submarketName,
            Submarket_ID__c = submarketId,
            Status__c = UNVERIFIED_STATUS
        );
        Test.startTest();
        List<Submarket__c> submarkets = SubmarketsSelector.newInstance()
            .getSubmarketById(submarketId);
        Test.stopTest();
        System.assertEquals(1, submarkets.size(), ASSERT_MESSAGE);
    }

    /**
     * @description To test the query to retrieve Submarket records by using the submarket Ids.
     */
    @isTest
    private static void testWhenSubmarketIdsPassedThenReturnSubmarkets() {
        String submarketId = SUBMARKET_ID;
        String submarketName = SUBMARKET_NAME;
        insert new Submarket__c(
            Name = submarketName,
            Submarket_ID__c = submarketId,
            Status__c = UNVERIFIED_STATUS
        );
        Test.startTest();
        List<Submarket__c> submarkets = SubmarketsSelector.newInstance()
            .getSubmarketsByIds(new Set<String>{ subMarketId });
        Test.stopTest();
        System.assertEquals(1, submarkets.size(), ASSERT_MESSAGE);
    }
}