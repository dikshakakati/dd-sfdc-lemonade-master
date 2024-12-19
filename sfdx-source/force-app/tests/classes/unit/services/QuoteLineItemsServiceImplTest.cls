/**
 * @description This is the test class for QuoteLineItemsServiceImpl
 * @author Deloitte
 * @date 25/04/2022
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public with sharing class QuoteLineItemsServiceImplTest {
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    /**
     *@description updates START DATE and END DATE of Brief Items when QLI dates changed.
     */
    @IsTest
    public static void testWhenUpdateQLIStartDateAndEndDateThenItShouldUpdateBriefItemStartDateAndEndDate() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 2)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 4)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
                .setField(Brief_Item__c.End_Date__c, System.today() + 5)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(new Set<Id>{ briefItemIdOne }))
            .thenReturn(briefItemsList);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItemIdOne }))
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMock);
        QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Start_Date__c => System.today() - 2,
                        Brief_Item__c.End_Date__c => System.today() + 4
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     *@description updates START DATE and END DATE of Brief Items when QLI dates changed.
     */
    @IsTest
    public static void testWhenUpdateQLIStartDateAndEndDateThenItShouldUpdateBriefItemStartDateAndEndDateFailed() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 2)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 4)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
                .setField(Brief_Item__c.End_Date__c, System.today() + 5)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(new Set<Id>{ briefItemIdOne }))
            .thenReturn(briefItemsList);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItemIdOne }))
            .thenReturn(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException('Exception occurred while performing DML operation'),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMock);

        try {
            QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItems);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
                .registerDirty(
                    fflib_Match.sObjectWith(
                        new Map<SObjectField, Object>{
                            Brief_Item__c.Start_Date__c => System.today() - 2,
                            Brief_Item__c.End_Date__c => System.today() + 4
                        }
                    )
                );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            System.assertEquals(
                'Exception occurred while performing DML operation',
                mockException.getMessage(),
                'Unexpected Error: The Exception fired was not a TestCommitException.'
            );
        }
    }

    /**
     *@description updates START DATE and END DATE of Brief Items when QLI dates changed.
     */
    @IsTest
    public static void testWhenNotUpdateQLIStartDateAndEndDateThenItShouldNotUpdateBriefItemStartDateAndEndDate() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(new Set<Id>{ briefItemIdOne }))
            .thenReturn(briefItemsList);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItemIdOne }))
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMock);
        QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Start_Date__c => System.today() - 2,
                        Brief_Item__c.End_Date__c => System.today() + 4
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    /**
     * @description updates Brief Items when QLI dates updated.
     */
    @IsTest
    public static void testWhenUpdateQLIThenItShouldUpdateBriefItem() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 2)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 4)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
                .setField(Brief_Item__c.End_Date__c, System.today() + 5)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(new Set<Id>{ briefItemIdOne }))
            .thenReturn(briefItemsList);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItemIdOne }))
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMock);
        QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Start_Date__c => System.today() - 2,
                        Brief_Item__c.End_Date__c => System.today() + 4
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();

        //Called below method as part of LEM-13065
	    QuoteLineItemsService.deleteBriefItemBeforeQuoteLineIsDeleted(quoteLineItems);
    }

    /**
     * @description updates Brief Items when QLI dates updated.
     */
    @IsTest
    public static void testWhenUpdateQLIThenItShouldUpdateBriefItemFailed() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 2)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 4)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setField(Brief_Item__c.Start_Date__c, System.today() - 3)
                .setField(Brief_Item__c.End_Date__c, System.today() + 5)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(new Set<Id>{ briefItemIdOne }))
            .thenReturn(briefItemsList);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItemIdOne }))
            .thenReturn(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException('Exception occurred while performing DML operation'),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMock);

        try {
            QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItems);
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
                .registerDirty(
                    fflib_Match.sObjectWith(
                        new Map<SObjectField, Object>{
                            Brief_Item__c.Start_Date__c => System.today() - 2,
                            Brief_Item__c.End_Date__c => System.today() + 4
                        }
                    )
                );
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            System.assertEquals(
                'Exception occurred while performing DML operation',
                mockException.getMessage(),
                'Unexpected Error: The Exception fired was not a TestCommitException.'
            );
        }
    }

    /**
     * @description updates Brief Items when QLI dates updated.
     */
    @IsTest
    public static void testWhenNotUpdateQLIThenItShouldNotUpdateBriefItem() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        IBriefItemsSelector briefItemSelectorMock = (IBriefItemsSelector) mocks.mock(
            IBriefItemsSelector.class
        );
        IQuoteLineItemsSelector selectorMock = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(briefItemSelectorMock.sObjectType()).thenReturn(Brief_Item__c.SObjectType);
        mocks.when(briefItemSelectorMock.selectByIds(new Set<Id>{ briefItemIdOne }))
            .thenReturn(briefItemsList);
        mocks.when(selectorMock.sObjectType()).thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(selectorMock.selectById(new Set<Id>{ quoteLineItemIdOne }))
            .thenReturn(quoteLineItems);
        mocks.stopStubbing();
        Application.Selector.setMock(briefItemSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMock);
        QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItems);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Brief_Item__c.Start_Date__c => System.today() - 2,
                        Brief_Item__c.End_Date__c => System.today() + 4
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description test clone group logic on amendment quotes
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAmendedQuoteLineItemsHavingBlankGroupsThenGroupsPopulatedWithClonedDetails() {
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id amendedQuoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id quoteLineItemIdTwo = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id groupId1 = Fake.generateId(SBQQ__QuoteLineGroup__c.class);
        Id contractId = Fake.generateId(Contract.class);
        Id orderId1 = Fake.generateId(Order.class);
        Id subscriptionId1 = Fake.generateId(SBQQ__Subscription__c.class);

        List<SBQQ__Quote__c> amendedQuoteList = new List<SBQQ__Quote__c>{
            (SBQQ__Quote__c) new Fake(SBQQ__Quote__c.class)
                .setField(SBQQ__Quote__c.id, amendedQuoteId)
                .setField(SBQQ__Quote__c.SBQQ__MasterEvergreenContract__c, contractId)
                .setParent(
                    'SBQQ__MasterEvergreenContract__r',
                    new Fake(Contract.class)
                        .setField(Contract.id, contractId)
                        .setField(Contract.SBQQ__Order__c, orderId1)
                        .setParent(
                            'SBQQ__Order__r',
                            new Fake(Order.class)
                                .setField(Order.id, orderId1)
                                .setField(Order.SBQQ__Quote__c, quoteId)
                                .setParent(
                                    'SBQQ__Quote__r',
                                    new Fake(SBQQ__Quote__c.class)
                                        .setField(SBQQ__Quote__c.id, quoteId)
                                )
                        )
                )
                .toSobject()
        };
        Map<Id, SBQQ__Quote__c> quotesMap = new Map<Id, SBQQ__Quote__c>(amendedQuoteList);

        List<SBQQ__QuoteLine__c> prevQuoteLineList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, quoteId)
                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, groupId1)
                .toSobject()
        };
        List<SBQQ__QuoteLine__c> newQuoteLineList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdTwo)
                .setField(SBQQ__QuoteLine__c.SBQQ__Quote__c, amendedQuoteId)
                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, null)
                .setField(SBQQ__QuoteLine__c.SBQQ__UpgradedSubscription__c, subscriptionId1)
                .setParent(
                    'SBQQ__Quote__r',
                    new Fake(SBQQ__Quote__c.class)
                        .setField(SBQQ__Quote__c.id, amendedQuoteId)
                        .setField(SBQQ__Quote__c.SBQQ__Type__c, 'Amendment')
                )
                .setParent(
                    'SBQQ__UpgradedSubscription__r',
                    new Fake(SBQQ__Subscription__c.class)
                        .setField(SBQQ__Subscription__c.id, subscriptionId1)
                        .setField(SBQQ__Subscription__c.SBQQ__QuoteLine__c, quoteLineItemIdOne)
                        .setParent(
                            'SBQQ__QuoteLine__r',
                            new Fake(SBQQ__QuoteLine__c.class)
                                .setField(SBQQ__QuoteLine__c.id, quoteLineItemIdOne)
                                .setField(SBQQ__QuoteLine__c.SBQQ__Group__c, groupId1)
                        )
                )
                .toSobject()
        };
        List<SBQQ__QuoteLineGroup__c> groupList = new List<SBQQ__QuoteLineGroup__c>{
            (SBQQ__QuoteLineGroup__c) new Fake(SBQQ__QuoteLineGroup__c.class)
                .setField(SBQQ__QuoteLineGroup__c.Id, groupId1)
                .setField(SBQQ__QuoteLineGroup__c.Name, 'Fake 3')
                .setField(SBQQ__QuoteLineGroup__c.SBQQ__Number__c, 1)
                .setField(SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c, 100)
                .setField(SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c, 12)
                .setField(SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c, 12)
                .setField(SBQQ__QuoteLineGroup__c.SBQQ__Source__c, null)
                .setField(SBQQ__QuoteLineGroup__c.SBQQ__Quote__c, quoteId)
                .toSobject()
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IQuotesSelector mockQuotesSelector = (IQuotesSelector) mocks.mock(IQuotesSelector.class);
        IQuoteLineItemsSelector mockQuoteLineItemsSelector = (IQuoteLineItemsSelector) mocks.mock(
            IQuoteLineItemsSelector.class
        );

        IQuoteLineGroupSelector mockQuoteGroupsSelector = (IQuoteLineGroupSelector) mocks.mock(
            IQuoteLineGroupSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockQuotesSelector.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(mockQuoteLineItemsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLine__c.SObjectType);
        mocks.when(mockQuoteGroupsSelector.sObjectType())
            .thenReturn(SBQQ__QuoteLineGroup__c.SObjectType);
        mocks.when(
                mockQuotesSelector.selectQuoteFieldsFromOriginalQuote(new Set<Id>{ amendedQuoteId })
            )
            .thenReturn(amendedQuoteList);
        mocks.when(
                mockQuoteLineItemsSelector.selectQuoteLineswithMissingGroups(
                    new Set<Id>{ amendedQuoteId }
                )
            )
            .thenReturn(newQuoteLineList);
        mocks.when(mockQuoteLineItemsSelector.selectQuoteLinesFromQuoteIds(new Set<Id>{ quoteId }))
            .thenReturn(prevQuoteLineList);
        mocks.when(
                mockQuoteGroupsSelector.selectGroupRecordsFromQuote(new Set<Id>{ amendedQuoteId })
            )
            .thenReturn(new List<SBQQ__QuoteLineGroup__c>{});
        mocks.when(mockQuoteGroupsSelector.selectGroupRecords(new Set<Id>{ groupId1 }))
            .thenReturn(new Map<Id, SBQQ__QuoteLineGroup__c>(groupList));
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockQuotesSelector);
        Application.SELECTOR.setMock(mockQuoteLineItemsSelector);
        Application.SELECTOR.setMock(mockQuoteGroupsSelector);
        Application.SELECTOR.setMock(mockQuoteGroupsSelector);

        QuoteLineItemsService.insertMissingAmendmentLineGroups(quotesMap);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty((List<SObject>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.anySObject(),
                fflib_Match.anySObjectField(),
                fflib_Match.anySObject()
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            SBQQ__QuoteLineGroup__c.SBQQ__Number__c => 1.0,
                            SBQQ__QuoteLineGroup__c.SBQQ__Source__c => groupId1,
                            SBQQ__QuoteLineGroup__c.Original_Quote_Line_Group__c => groupId1,
                            SBQQ__QuoteLineGroup__c.CCP_Unique_Group_Id__c => groupId1,
                            SBQQ__QuoteLineGroup__c.Name => 'Fake 3',
                            SBQQ__QuoteLineGroup__c.SBQQ__CustomerTotal__c => 12.0,
                            SBQQ__QuoteLineGroup__c.SBQQ__ListTotal__c => 100.0,
                            SBQQ__QuoteLineGroup__c.SBQQ__NetTotal__c => 12.0
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            SBQQ__Quote__c.Id => amendedQuoteId,
                            SBQQ__Quote__c.SBQQ__LineItemsGrouped__c => true,
                            SBQQ__Quote__c.Has_Groups__c => true
                        }
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ SBQQ__QuoteLine__c.Id => quoteLineItemIdTwo }
                ),
                fflib_Match.eqSObjectField(SBQQ__QuoteLine__c.SBQQ__Group__c),
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        SBQQ__QuoteLineGroup__c.SBQQ__Source__c => groupId1
                    }
                )
            );
    }

    /**
     * @description update active price fields when quote is submitted for approval
     */
    @IsTest
    public static void testWhenQuoteIsSubmittedForApprovalThenUpdateActivePriceFields() {
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id quoteLineId2 = Fake.generateId(SBQQ__QuoteLine__c.class);

        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId)
                .setField(SBQQ__QuoteLine__c.Requested_Commission__c, 5)
                .setField(SBQQ__QuoteLine__c.SBQQ__SpecialPrice__c, 2)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 4)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 1)
                .setField(SBQQ__QuoteLine__c.Rate_Change__c, 'Commission + Fee')
                .toSobject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId2)
                .setField(SBQQ__QuoteLine__c.Requested_Commission__c, 7)
                .setField(SBQQ__QuoteLine__c.SBQQ__SpecialPrice__c, 0)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 9)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 8)
                .setField(SBQQ__QuoteLine__c.Type__c, 'New')
                .setParent(
                    'SBQQ__ProductOption__r',
                    new Fake(SBQQ__ProductOption__c.class)
                        .setField(SBQQ__ProductOption__c.Active_Rate_Eligible__c, true)
                )
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        QuoteLineItemsService.updateActiveFeeActiveComissionOnQuotelines(quoteLineItemList);

        System.assertEquals(
            quoteLineItemList[0].Active_Commission__c,
            4,
            'Active Price Not Updated'
        );
        System.assertEquals(quoteLineItemList[1].Active_Fee__c, 0, 'Active Price Not Updated');
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description update active price fields when quote is submitted for approval
     */
    @IsTest
    public static void testWhenApprovalsRecalledThenRevertActivePriceFields() {
        Id quoteLineId = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id quoteLineId2 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id quoteLineId3 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id quoteLineId4 = Fake.generateId(SBQQ__QuoteLine__c.class);
        Id sourceQL = Fake.generateId(SBQQ__QuoteLine__c.class);

        List<SBQQ__QuoteLine__c> quoteLineItemList = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 4)
                .setParent(
                    'SBQQ__ProductOption__r',
                    new Fake(SBQQ__ProductOption__c.class)
                        .setField(SBQQ__ProductOption__c.Active_Rate_Eligible__c, true)
                )
                .toSobject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId2)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 9)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 8)
                .setField(SBQQ__QuoteLine__c.Type__c, 'New')
                .setParent(
                    'SBQQ__ProductOption__r',
                    new Fake(SBQQ__ProductOption__c.class)
                        .setField(SBQQ__ProductOption__c.Active_Rate_Eligible__c, true)
                )
                .toSobject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId4)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 123)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 88)
                .setParent(
                    'SBQQ__ProductOption__r',
                    new Fake(SBQQ__ProductOption__c.class)
                        .setField(SBQQ__ProductOption__c.Active_Rate_Eligible__c, true)
                )
                .setParent(
                    'SBQQ__Quote__r',
                    new Fake(SBQQ__Quote__c.class).setField(SBQQ__Quote__c.SBQQ__Type__c, 'Quote')
                )
                .toSobject(),
            (SBQQ__QuoteLine__c) new Fake(SBQQ__QuoteLine__c.class)
                .setField(SBQQ__QuoteLine__c.id, quoteLineId3)
                .setField(SBQQ__QuoteLine__c.Active_Commission__c, 7)
                .setField(SBQQ__QuoteLine__c.Active_Fee__c, 5)
                .setField(SBQQ__QuoteLine__c.Type__c, 'Amended')
                .setField(SBQQ__QuoteLine__c.SBQQ__Source__c, sourceQL)
                .setParent(
                    'SBQQ__ProductOption__r',
                    new Fake(SBQQ__ProductOption__c.class)
                        .setField(SBQQ__ProductOption__c.Active_Rate_Eligible__c, true)
                )
                .setParent(
                    'SBQQ__Source__r',
                    new Fake(SBQQ__QuoteLine__c.class)
                        .setField(SBQQ__QuoteLine__c.Id, sourceQL)
                        .setField(SBQQ__QuoteLine__c.Active_Commission__c, 6)
                        .setField(SBQQ__QuoteLine__c.Active_Fee__c, 6)
                )
                .toSobject()
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        QuoteLineItemsService.revertActiveFeeActiveComissionOnQuotelines(quoteLineItemList);

        System.assertEquals(
            quoteLineItemList[0].Active_Commission__c,
            4,
            'Active Price reverted incorrectly'
        );
        System.assertEquals(
            quoteLineItemList[1].Active_Fee__c,
            null,
            'Active Price reverted incorrectly'
        );
        System.assertEquals(
            quoteLineItemList[2].Active_Commission__c,
            null,
            'Active Price reverted incorrectly'
        );
        System.assertEquals(
            quoteLineItemList[3].Active_Fee__c,
            6,
            'Active Price reverted incorrectly'
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     *@description LEM-13065 if quote line associated is deleted then Brief item must be deleted before.
    */
    @IsTest
    public static void testWhenQuoteLineDeletesThenAssociatedBriefItemIsDeleted() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Id briefItemIdOne = fflib_IDGenerator.generate(Brief_Item__c.SObjectType);

        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Brief_Item__c, briefItemIdOne)
            .setField(SBQQ__QuoteLine__c.Has_Brief_Item__c, true);

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
                };

         List<Brief_Item__c> briefItemsList = new List<Brief_Item__c>{
            (Brief_Item__c) new Fake(Brief_Item__c.class)
                .setField(Brief_Item__c.Id, briefItemIdOne)
                .setField(Brief_Item__c.Quote_Line__c, quoteLineItemIdOne)
                .setField(Brief_Item__c.Quote_Line_Id__c, (String) quoteLineItemIdOne)
                .setParent('Quote_Line__r', quoteLineItemInstance)
                .toSObject()
         };

         List<Brief_Item__c> briefItemsListId = new List<Brief_Item__c>{
             new Brief_Item__c(Id = briefItemsList[0].Id)
         };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        QuoteLineItemsService.deleteBriefItemBeforeQuoteLineIsDeleted(quoteLineItems);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDeleted(
                ((List<Brief_Item__c>)fflib_Match.eqList((List<Object>) briefItemsListId)
         ));

        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW, 1)).commitWork();
    }

	/**
     * @description Used to test whether or not the Quote Lines are updated when a Quote is updated.
     * @JIRA# LEM-22670
     */
    @IsTest
    private static void testWhenQuoteLinesRecordsPassedThenUpdateQuoteLines() {
        Id quoteLineItemIdOne = fflib_IDGenerator.generate(SBQQ__QuoteLine__c.SObjectType);
        Fake quoteLineItemInstance = new Fake(SBQQ__QuoteLine__c.class)
            .setField(SBQQ__QuoteLine__c.Id, quoteLineItemIdOne)
            .setField(SBQQ__QuoteLine__c.Start_Date__c, System.today() - 2)
            .setField(SBQQ__QuoteLine__c.End_Date__c, System.today() + 4)
            .setField(SBQQ__QuoteLine__c.Prior_Approved_Commission_Fee__c , 3)
        	.setField(SBQQ__QuoteLine__c.Prior_Approved_Commission_Percent__c  , 4);
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>{
            (SBQQ__QuoteLine__c) quoteLineItemInstance.toSObject()
        };
        List<List<SBQQ__QuoteLine__c>> quoteLineRecords = new List<List<SBQQ__QuoteLine__c>>{quoteLineItems};
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);
        Application.UNITOFWORK.setMock(mockUOW);
        Test.startTest();
        QuoteLineItemsService.updatePriorFieldsOnQuoteLines(quoteLineRecords);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork)mocks.verify(mockUOW, 1)).commitWork();
    }
}