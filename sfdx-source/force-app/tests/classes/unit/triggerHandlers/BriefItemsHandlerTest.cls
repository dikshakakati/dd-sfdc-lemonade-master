/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Test class for Brief Items Handler
 */
@isTest(SeeAllData=false)
private class BriefItemsHandlerTest {
    private static final String STATUS_WAITING_FOR_INPUTS = 'Waiting for Inputs';
    private static final String STATUS_CAMPAIGN_BUILDING = 'Campaign Building';

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemStatusIsUpdatedThenCallBriefUpdate() {
        Id briefItemId = Fake.generateId(Brief_Item__c.class);
        Contact newContact = new Contact(
            Email = 'testEMail@testEmail.com',
            Firstname = 'Testy',
            LastName = 'Testerson'
        );
        insert newContact;
        List<Brief_Item__c> briefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(Id = briefItemId, Status__c = STATUS_WAITING_FOR_INPUTS)
        };

        List<Brief_Item__c> oldBriefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(Id = briefItemId, Status__c = STATUS_CAMPAIGN_BUILDING)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IBriefItems briefItemsMocks = (IBriefItems) mocks.mock(IBriefItems.class);
        //mocking
        mocks.startStubbing();
        mocks.when(briefItemsMocks.getType()).thenReturn(Schema.Brief_Item__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(briefItemsMocks);
        mocks.stopStubbing();
        Application.Domain.setMock(briefItemsMocks);
        BriefItems.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(
            briefItemList,
            new Map<Id, SObject>(oldBriefItemList)
        );
        fflib_SObjectDomain.triggerHandler(BriefItemsHandler.class);

        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).updateStatusOnRelatedBrief();
        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).updateDateOnRelatedBrief();
        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).syncSubscriptionFields();
        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).updateConfigurationOnRelatedBrief();
    }

    /**
     * @description To test method call on Contract insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemsAreInsertedThenCallBriefUpdate() {
        Id briefItemId = Fake.generateId(Brief_Item__c.class);

        List<Brief_Item__c> briefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(Id = briefItemId, Status__c = STATUS_WAITING_FOR_INPUTS)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefItems briefItemsMocks = (IBriefItems) mocks.mock(IBriefItems.class);
        mocks.startStubbing();
        mocks.when(briefItemsMocks.getType()).thenReturn(Schema.Brief_Item__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(briefItemsMocks);

        fflib_SObjectDomain.Test.Database.onInsert(briefItemList);
        fflib_SObjectDomain.triggerHandler(BriefItemsHandler.class);

        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).updateStatusOnRelatedBrief();
        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).updateDateOnRelatedBrief();
        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).updateConfigurationOnRelatedBrief();
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemsCampaignIdFieldUpdatedThenCallValidateCampaignIdField() {
        Id briefItemId = Fake.generateId(Brief_Item__c.class);
        Contact newContact = new Contact(
            Email = 'testEMail@testEmail.com',
            Firstname = 'Testy',
            LastName = 'Testerson'
        );
        insert newContact;
        List<Brief_Item__c> briefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(Id = briefItemId, Campaign_ID_s_36_digit_ID_only__c = '8092732c-3774-4004-af92-315612ea8cde')
        };

        List<Brief_Item__c> oldBriefItemList = new List<Brief_Item__c>{
            new Brief_Item__c(Id = briefItemId, Campaign_ID_s_36_digit_ID_only__c = '')
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IBriefItems briefItemsMocks = (IBriefItems) mocks.mock(IBriefItems.class);
        mocks.startStubbing();
        mocks.when(briefItemsMocks.getType()).thenReturn(Schema.Brief_Item__c.SObjectType);
        mocks.when(constructor.construct(fflib_Match.anyList())).thenReturn(briefItemsMocks);
        mocks.stopStubbing();
        Application.Domain.setMock(briefItemsMocks);
        BriefItems.setConstructorMock(constructor);

        fflib_SObjectDomain.Test.Database.onUpdate(
            briefItemList,
            new Map<Id, SObject>(oldBriefItemList)
        );
        fflib_SObjectDomain.triggerHandler(BriefItemsHandler.class);

        ((IBriefItems) mocks.verify(briefItemsMocks, 1)).validateCampaignIdField();
    }
}