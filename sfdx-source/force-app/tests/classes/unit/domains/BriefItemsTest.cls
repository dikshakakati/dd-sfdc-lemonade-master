/**
 * @author Deloitte
 * @date 11/30/2022
 * @description This is the test class for Brief Item domain class
 */
@isTest(SeeAllData=false)
private class BriefItemsTest {
    private static final String ASSERT_ERROR_MESSAGE_INITIALISATION = 'These objects should not be similar';
    private static final String STATUS_WAITING_FOR_INPUTS = 'Waiting for Inputs';
    private static final String CAMPAIGN_THANKSGIVING = 'Thanksgiving Offers';
    private static final String CAMPAIGN_ID = '8092732c-3774-4004-af92-315612ea8c';
    /**
     * @description It is used to test the initialisation of the domain class.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>();
        BriefItems.newInstance(briefItemsList);
        BriefItems briefItemObject = new BriefItems(briefItemsList);
        BriefItems.Constructor constructorObject = new BriefItems.Constructor();
        constructorObject.construct(briefItemsList);

        System.assertNotEquals(
            BriefItems.newInstance(briefItemsList),
            briefItemObject,
            ASSERT_ERROR_MESSAGE_INITIALISATION
        );
    }

    /**
     * @description It is used to test if the Brief is updated when related Brief Item Status is
     * changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemStatusIsUpdatedThenRelatedBriefIsUpdated() {
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = STATUS_WAITING_FOR_INPUTS,
                Brief__c = briefId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefItemsSelector selectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IBriefsService briefsServiceMock = (IBriefsService) mocks.mock(IBriefsService.class);
        BriefItems brirefItemsInstance = new BriefItems(briefItems);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(selectorMock.selectByBriefAndStatus(new Set<Id>{ briefId }))
            .thenReturn(briefItems);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Service.setMock(IBriefsService.class, briefsServiceMock);
        brirefItemsInstance.updateStatusOnRelatedBrief();

        ((IBriefsService) mocks.verify(briefsServiceMock, 1))
            .updateBriefBasedOnBriefItemsStatus(new Set<Id>{ briefId }, new Set<Id>());
    }

    /**
     * @description It is used to test if the Brief is updated when related Brief Item Status is
     * changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemDateIsUpdatedThenRelatedBriefIsUpdated() {
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = STATUS_WAITING_FOR_INPUTS,
                Start_Date__c = Date.today() - 5,
                End_Date__c = Date.today() + 6,
                Brief__c = briefId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefItemsSelector selectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IBriefsService briefsServiceMock = (IBriefsService) mocks.mock(IBriefsService.class);
        BriefItems brirefItemsInstance = new BriefItems(briefItems);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(selectorMock.selectByBrief(new Set<Id>{ briefId })).thenReturn(briefItems);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Service.setMock(IBriefsService.class, briefsServiceMock);
        brirefItemsInstance.updateDateOnRelatedBrief();

        ((IBriefsService) mocks.verify(briefsServiceMock, 1))
            .updateBriefDateBasedOnBriefItemsDate(
                new Set<Id>{ briefId },
                new Map<Id, Date>{ briefId => briefItems[0].Start_Date__c },
                new Map<Id, Date>{ briefId => briefItems[0].End_Date__c }
            );
    }

    /**
     * @description It is used to test if the Brief is updated when related Brief Item Status is
     * changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMultipleBriefItemDateIsUpdatedThenRelatedBriefIsUpdated() {
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = STATUS_WAITING_FOR_INPUTS,
                Start_Date__c = Date.today() - 5,
                End_Date__c = Date.today() + 6,
                Brief__c = briefId
            ),
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = STATUS_WAITING_FOR_INPUTS,
                Start_Date__c = Date.today() - 9,
                End_Date__c = Date.today() + 10,
                Brief__c = briefId
            ),
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = STATUS_WAITING_FOR_INPUTS,
                Start_Date__c = Date.today() - 1,
                End_Date__c = Date.today() + 1,
                Brief__c = briefId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefItemsSelector selectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IBriefsService briefsServiceMock = (IBriefsService) mocks.mock(IBriefsService.class);
        BriefItems brirefItemsInstance = new BriefItems(briefItems);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(selectorMock.selectByBrief(new Set<Id>{ briefId })).thenReturn(briefItems);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Service.setMock(IBriefsService.class, briefsServiceMock);
        brirefItemsInstance.updateDateOnRelatedBrief();

        ((IBriefsService) mocks.verify(briefsServiceMock, 1))
            .updateBriefDateBasedOnBriefItemsDate(
                new Set<Id>{ briefId },
                new Map<Id, Date>{ briefId => briefItems[1].Start_Date__c },
                new Map<Id, Date>{ briefId => briefItems[1].End_Date__c }
            );
    }

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemFieldIsUpdatedThenSubscriptionFieldIsUpdated(){
        //use Mock functionality
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Id subscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id childSubscriptionId = fflib_IDGenerator.generate(SBQQ__Subscription__c.SObjectType);
        Id quoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id subQuoteLineId = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id contractSignedQuote = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id productId = fflib_IDGenerator.generate(Product2.SObjectType);
        Id subProductId = fflib_IDGenerator.generate(Product2.SObjectType);

        Fake parentQuoteLineInstane = new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, quoteLineId)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, contractSignedQuote)
                .setField(SBQQ__QuoteLine__c.CurrencyIsoCode, 'USD')
                .setField(SBQQ__QuoteLine__c.Campaign_Name__c, CAMPAIGN_THANKSGIVING)
                .setField(SBQQ__Quoteline__c.Brief_Item__c, briefItemId)
                .setField(SBQQ__Quoteline__c.Has_Brief_Item__c, true)
                .setField(SBQQ__QuoteLine__c.SBQQ__ProductName__c, 'CRM');

        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
            .setField(Brief_Item__c.Id, briefItemId)
            .setField(Brief_Item__c.Brief__c, briefId)
            .setField(Brief_Item__c.Quote_Line__c, quoteLineId)
            .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
            .setField(Brief_Item__c.End_Date__c, System.today() + 5)
            .setField(Brief_Item__c.Banner_Dates__c, 'teest')
            .setField(Brief_Item__c.Categories_Bid__c, 2.50)
            .setParent('Quote_Line__r', parentQuoteLineInstane)
            .toSObject()
        };

        List<SBQQ__Subscription__c> subscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, subscriptionId)
            .setField(SBQQ__Subscription__c.Brief_Item__c, briefItemId)
            .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineId)
            .setField(SBQQ__Subscription__c.Start_Date__c, System.today() - 3)
            .setField(SBQQ__Subscription__c.End_Date__c, System.today() + 5)
            .setField(SBQQ__Subscription__c.Banner_Dates__c, 'teest')
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
            .setField(SBQQ__Subscription__c.SBQQ__Product__c, productId)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1.00)
            .setFIeld(SBQQ__Subscription__c.SBQQ__ProductName__c, 'CRM')
            .setParent('SBQQ__QuoteLine__r', parentQuoteLineInstane)
            .toSObject()
        };
        List<SBQQ__Subscription__c> childSubscriptions = new List<SBQQ__Subscription__c>{
            (SBQQ__Subscription__c) new Fake(SBQQ__Subscription__c.class)
            .setField(SBQQ__Subscription__c.Id, childSubscriptionId)
            .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, subQuoteLineId)
            .setField(SBQQ__Subscription__c.Start_Date__c, System.today() - 3)
            .setField(SBQQ__Subscription__c.End_Date__c, System.today() + 5)
            .setField(SBQQ__Subscription__c.Banner_Dates__c, 'teest')
            .setField(SBQQ__Subscription__c.SBQQ__Contract__c, contractId)
            .setField(SBQQ__Subscription__c.SBQQ__Account__c, accountId)
            .setField(SBQQ__Subscription__c.SBQQ__Product__c, subProductId)
            .setField(SBQQ__Subscription__c.SBQQ__Quantity__c, 1.00)
            .setField(SBQQ__Subscription__c.SBQQ__ProductName__c, 'CnG Categories')
            .setField(SBQQ__Subscription__c.SBQQ__RequiredById__c, quoteLineId)
            .setParent('SBQQ__QuoteLine__r', parentQuoteLineInstane)
            .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        fflib_IDomainConstructor constructor = (fflib_IDomainConstructor) mocks.mock(
            fflib_IDomainConstructor.class
        );
        IBriefItemsSelector selectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IBriefsService briefsServiceMock = (IBriefsService) mocks.mock(IBriefsService.class);
        ISubscriptionSelector subSelectorMock = (ISubscriptionSelector) mocks.mock(
            ISubscriptionSelector.class
        );
        BriefItems brirefItemsInstance = new BriefItems(briefItemsList);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(selectorMock.selectByQuoteLineItems(new Set<Id>{ quoteLineId })).thenReturn(briefItemsList);
        mocks.when(subSelectorMock.SObjectType()).thenReturn(SBQQ__Subscription__c.SObjectType);
        mocks.when(subSelectorMock.selectSubscriptionsWithFieldsToSyncWithBriefItems(new List<String>{quoteLineId})).thenReturn(subscriptions);
        mocks.when(subSelectorMock.selectChildSubscriptions(new Set<String>{subscriptionId})).thenReturn(childSubscriptions);

        mocks.stopStubbing();
        BriefItems.setConstructorMock(constructor);
        Application.Selector.setMock(selectorMock);
        Application.Selector.setMock(subSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Service.setMock(IBriefsService.class, briefsServiceMock);
        brirefItemsInstance.syncSubscriptionFields();
    }
    /**
     * @description It is used to to test updateConfigurationOnRelatedBrief method which queries
     * and organizes date to pass to BriefsService class to update related configuration field
    */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemFieldIsUpdatedThenConfigurationFieldIsUpdated() {
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                Brief__c = briefId
            )
        };
        List<Brief__c> briefList = new List<Brief__c>{
            new Brief__c(
                Id = briefId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefItemsSelector selectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IBriefsSelector briefsSelectorMock = (IBriefsSelector) mocks.mock(
            IBriefsSelector.class
        );
        IBriefsService briefsServiceMock = (IBriefsService) mocks.mock(IBriefsService.class);
        BriefItems briefItemsInstance = new BriefItems(briefItems);
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(selectorMock.selectBriefItemsWithRoutingAndCustomCreative(new Set<Id>{ briefId }))
            .thenReturn(briefItems);
        mocks.when(briefsSelectorMock.selectBriefWithPrimaryVertical(new Set<Id>{ briefId }))
            .thenReturn(briefList);

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.Selector.setMock(briefsSelectorMock);
        Application.Service.setMock(IBriefsService.class, briefsServiceMock);
        briefItemsInstance.updateConfigurationOnRelatedBrief();
    }

    /**
     * @description It is used to test if the CampaignId field is validated when related Brief Item CampaignId field is
     * changed
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenBriefItemCampaignIdFieldIsUpdatedThenItsGotValidated() {
        Id briefId = fflib_IDGenerator.generate(Brief__c.SObjectType);
        Id briefItemId = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        List<Brief_Item__c> briefItems = new List<Brief_Item__c>{
            new Brief_Item__c(
                Id = briefItemId,
                Status__c = STATUS_WAITING_FOR_INPUTS,
                Campaign_ID_s_36_digit_ID_only__c = CAMPAIGN_ID,
                Brief__c = briefId
            )
        };
        BriefItems brirefItemsInstance = new BriefItems(briefItems);
        brirefItemsInstance.validateCampaignIdField();
        System.assertEquals(
            1,
            ApexPages.getMessages().size(),
            'The BriefItem did not fire an error'
        );
    }
}