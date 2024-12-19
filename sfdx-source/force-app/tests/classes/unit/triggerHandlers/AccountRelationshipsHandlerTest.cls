/**
 * @author Deloitte
 * @date 26/05/2022
 * @description This is test class for AccountRelationshipsHandler class
 */
@isTest(SeeAllData=false)
public with sharing class AccountRelationshipsHandlerTest {
    private static final String DATABASE_RECORD_NOT_FOUND_ASSERT_MESSAGE = 'Unexpected result: Record are not present in database';
    /**
     * @description Test AccountRelationshipsHandler class on Relationship Insertion
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenRelationshipCreatedThenCall() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        List<Account_Relationship__c> relationshipRecords = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement Partner',
                Relationship_Status__c = 'Active'
            )
        };
        fflib_SObjectDomain.Test.Database.onInsert(relationshipRecords);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRelationships relationshipsMock = (IAccountRelationships) mocks.mock(
            IAccountRelationships.class
        );
        mocks.startStubbing();
        mocks.when(relationshipsMock.getType()).thenReturn(Account_Relationship__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(relationshipsMock);

        fflib_SObjectDomain.triggerHandler(AccountRelationshipsHandler.class);
        ((IAccountRelationships) mocks.verify(relationshipsMock, 1)).defaultOperationsOnInsertion();
        ((IAccountRelationships) mocks.verify(relationshipsMock, 1))
            .generateReciprocalRelationship();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAccountRelationshipIsUpdatedThenCall() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        Id relationshipId = fflib_IDGenerator.generate(Account_Relationship__c.SObjectType);
        Id reciprocalRelationshipId = fflib_IDGenerator.generate(
            Account_Relationship__c.SObjectType
        );
        List<Account_Relationship__c> relationshipRecords = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Id = relationshipId,
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement Partner',
                Relationship_Status__c = 'Active',
                Start_Date__c = Date.today() - 1,
                End_Date__c = Date.today().addDays(3),
                External_Id__c = accountList[0].Id +
                    'Measurement Partner' +
                    accountList[1].Id +
                    'Agency'
            )
        };

        List<Account_Relationship__c> relationshipRecordsInSystem = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Id = relationshipId,
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement Partner',
                Relationship_Status__c = 'Active',
                Start_Date__c = Date.today() - 1,
                End_Date__c = Date.today().addDays(3),
                External_Id__c = accountList[0].Id +
                    'Measurement Partner' +
                    accountList[1].Id +
                    'Agency'
            ),
            new Account_Relationship__c(
                Id = reciprocalRelationshipId,
                Account__c = accountList[1].Id,
                Related_Account__c = accountList[0].Id,
                Relationship_Type__c = 'Measurement Partner',
                Inverse_Relationship_Type__c = 'Agency',
                Relationship_Status__c = 'Active',
                Start_Date__c = Date.today() - 1,
                End_Date__c = Date.today().addDays(3),
                External_Id__c = accountList[1].Id +
                    'Agency' +
                    accountList[0].Id +
                    'Measurement Partner'
            )
        };

        Account_Relationship__c mockUpdatedRelationship = new Account_Relationship__c(
            Id = relationshipId,
            Relationship_Type__c = 'Measurement Partner'
        );
        Map<Id, Account_Relationship__c> mockOldRelationships = new Map<Id, Account_Relationship__c>(
            relationshipRecords
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRelationships relationshipsMock = (IAccountRelationships) mocks.mock(
            IAccountRelationships.class
        );
        IAccountRelationshipsSelector relationshipsSelectorMock = (IAccountRelationshipsSelector) mocks.mock(
            IAccountRelationshipsSelector.class
        );
        mocks.startStubbing();
        mocks.when(relationshipsMock.getType())
            .thenReturn(Schema.Account_Relationship__c.SObjectType);
        mocks.when(relationshipsSelectorMock.SObjectType())
            .thenReturn(Account_Relationship__c.SObjectType);
        mocks.when(relationshipsSelectorMock.selectAllRelationshipsWithExternalIds())
            .thenReturn(relationshipRecordsInSystem);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(relationshipsSelectorMock);
        Application.DOMAIN.setMock(relationshipsMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            new List<Account_Relationship__c>{ mockUpdatedRelationship },
            mockOldRelationships
        );

        fflib_SObjectDomain.triggerHandler(AccountRelationshipsHandler.class);

        ((IAccountRelationships) mocks.verify(relationshipsMock, 1))
            .updateReciprocalRelationships(mockOldRelationships);
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenRelationshipDeletedThenCall() {
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1'),
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 2')
        };
        Id relationshipId = fflib_IDGenerator.generate(Account_Relationship__c.SObjectType);

        List<Account_Relationship__c> relationshipRecordsBefore = new List<Account_Relationship__c>{
            new Account_Relationship__c(
                Id = relationshipId,
                Account__c = accountList[0].Id,
                Related_Account__c = accountList[1].Id,
                Relationship_Type__c = 'Agency',
                Inverse_Relationship_Type__c = 'Measurement Partner',
                Relationship_Status__c = 'Active',
                External_Id__c = accountList[0].Id +
                    'Measurement Partner' +
                    accountList[1].Id +
                    'Agency'
            )
        };

        Map<Id, Account_Relationship__c> testMap = new Map<Id, Account_Relationship__c>(
            relationshipRecordsBefore
        );
        fflib_SObjectDomain.Test.Database.onDelete(testMap);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountRelationships relationshipsMock = (IAccountRelationships) mocks.mock(
            IAccountRelationships.class
        );
        mocks.startStubbing();
        mocks.when(relationshipsMock.getType()).thenReturn(Account_Relationship__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(relationshipsMock);

        fflib_SObjectDomain.triggerHandler(AccountRelationshipsHandler.class);
        ((IAccountRelationships) mocks.verify(relationshipsMock, 1))
            .deleteReciprocalRelationships();
    }
}