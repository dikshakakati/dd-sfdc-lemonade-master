/**
 * @author Deloitte
 * @date 04/10/2024
 * @description Test class for LocalTimeZoneController class.
 */
@IsTest(IsParallel=true)
public with sharing class LocalTimeControllerTest {
    static final String TEST_ACCOUNT_NAME = 'Test Account';
    static final String TEST_LEAD_NAME = 'Test Lead';
    static final String TIME_ZONE_BACKEND_VALUE = 'America/New_York';
    static final String TIME_ZONE_VALUE_DOES_NOT_MATCH = 'Time zone value does not match';
    static final String EDT = 'EDT';
    static final String PRT = 'PRT';

    /**
     * @description To test when get time zone called for acount record
     * then return record's time zone.
     */
    @IsTest
    private static void testWhenGetTimeZoneForAccountCalledThenReturnTimeZone() {
        String timeZoneBackend = '';
        String abbreviatedWrapperTimeZone = '';
        TimeZoneWrapper timeZoneWrapper = new TimeZoneWrapper(
            timeZoneBackend,
            abbreviatedWrapperTimeZone
        );
        Id accountId = Fake.generateId(Account.class);
        Set<Id> accountIds = new Set<Id>{ accountId };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = TEST_ACCOUNT_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_VALUE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(accountIds)).thenReturn(newAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        timeZoneWrapper = LocalTimeController.getTimeZoneFromBackend(accountId);
        System.assertEquals(
            EDT,
            timeZoneWrapper.abbreviatedWrapperTimeZone,
            TIME_ZONE_VALUE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test when get time zone called for lead record
     * then return record's correct time zone.
     */
    @IsTest
    private static void testWhenGetTimeZoneForLeadCalledThenReturnTimeZone() {
        String timeZoneBackend = '';
        String abbreviatedWrapperTimeZone = '';
        TimeZoneWrapper timeZoneWrapper = new TimeZoneWrapper(
            timeZoneBackend,
            abbreviatedWrapperTimeZone
        );
        Id leadId = Fake.generateId(Lead.class);
        Set<Id> leadIds = new Set<Id>{ leadId };
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                LastName = TEST_LEAD_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_VALUE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILeadsSelector selectorMock = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(selectorMock.selectById(leadIds)).thenReturn(newLeads);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        timeZoneWrapper = LocalTimeController.getTimeZoneFromBackend(leadId);
        System.assertEquals(
            EDT,
            timeZoneWrapper.abbreviatedWrapperTimeZone,
            TIME_ZONE_VALUE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test when get time zone called for lead record
     * then return record's incorrect time zone.
     */
    @IsTest
    private static void testWhenGetTimeZoneForLeadCalledThenReturnIncorrectTimeZone() {
        String timeZoneBackend = '';
        String abbreviatedWrapperTimeZone = '';
        TimeZoneWrapper timeZoneWrapper = new TimeZoneWrapper(
            timeZoneBackend,
            abbreviatedWrapperTimeZone
        );
        Id leadId = Fake.generateId(Lead.class);
        Set<Id> leadIds = new Set<Id>{ leadId };
        Lead[] newLeads = new List<Lead>{
            new Lead(
                Id = leadId,
                LastName = TEST_LEAD_NAME,
                Time_Zone_Backend__c = TIME_ZONE_BACKEND_VALUE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ILeadsSelector selectorMock = (ILeadsSelector) mocks.mock(ILeadsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Lead.SObjectType);
        mocks.when(selectorMock.selectById(leadIds)).thenReturn(newLeads);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);
        timeZoneWrapper = LocalTimeController.getTimeZoneFromBackend(leadId);
        System.assertNotEquals(
            PRT,
            timeZoneWrapper.abbreviatedWrapperTimeZone,
            TIME_ZONE_VALUE_DOES_NOT_MATCH
        );
    }

    /**
     * @description To test when a record does not exist, an exception is thrown.
     */
    @IsTest
    private static void testWhenRecordDoesNotExistThenThrowException() {
        Id nonExistentId = Fake.generateId(Account.class);
        Set<Id> accountIds = new Set<Id>{ nonExistentId };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(accountIds)).thenReturn(new List<Account>());
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        Test.startTest();
        try {
            LocalTimeController.getTimeZoneFromBackend(nonExistentId);
            System.assert(false, 'Exception was expected but not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Unexpected exception message');
        }
        Test.stopTest();
    }

    /**
     * @description To test when Time_Zone_Backend__c field is blank, an exception is thrown.
     */
    @IsTest
    private static void testWhenTimeZoneBackendIsBlankThenThrowException() {
        Id accountId = Fake.generateId(Account.class);
        Set<Id> accountIds = new Set<Id>{ accountId };
        Account[] newAccounts = new List<Account>{
            new Account(
                Id = accountId,
                Name = TEST_ACCOUNT_NAME,
                Time_Zone_Backend__c = ''
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectById(accountIds)).thenReturn(newAccounts);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(selectorMock);

        Test.startTest();
        try {
            LocalTimeController.getTimeZoneFromBackend(accountId);
            System.assert(false, 'Exception was expected but not thrown');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage(), 'Unexpected exception message');
        }
        Test.stopTest();
    }
}
