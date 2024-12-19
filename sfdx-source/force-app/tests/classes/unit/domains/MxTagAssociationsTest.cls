/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Mx_Tag_Association__c Object Trigger Domain class Test
 */
@isTest(SeeAllData=false)
public class MxTagAssociationsTest {
    private static final String ACCOUNT_ID_ASSERT_MESSAGE = 'Account Id Should be Same';
    private static final String ACCOUNT_NAME = 'Account 1';
    private static final String ACTIVE = 'Active';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String CONSTRUCTOR_ASSERT_MESSAGE = 'Unexpected result: The objects are matching';
    private static final String END_DATE_ASSERT_MESSAGE = 'End Date is updated as current date which is expected';
    private static final String ERROR_ASSERT_MESSAGE = 'No error shown';
    private static final String ERROR_MESSAGE = 'Values do not match';
    private static final String INACTIVE = 'Inactive';
    private static final String MX_TAG_MARKET_MAKER = 'Market Maker';
    private static final String MX_TAG_ASSOCIATION_TOP_MX = 'Mx Tag Association Top Mx';
    private static final String MX_TAG_ASSOCIATION_MARKET_MAKER = 'Mx Tag Association Market Maker';
    private static final String MX_TAGS = 'Top Mx,Market Maker';
    private static final String MX_TAG_TOP_MX = 'Top Mx';
    private static final String OPPORTUNITY_NAME = 'Opportunity 1';
    private static final String OPPORTUNITY_STAGE_NAME = 'Prospecting';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String START_DATE_ASSERT_MESSAGE = 'Start Date is updated as current date which is expected';
    private static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Store')
        .getRecordTypeId();
    private static final String VERTICAL = 'Floral';

    /**
     * @description @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenRun() {
        List<Mx_Tag_Association__c> mxTagAssociationToInstantiate = new List<Mx_Tag_Association__c>();
        MxTagAssociations.newInstance(mxTagAssociationToInstantiate);
        MxTagAssociations newMxTagAssociation = new MxTagAssociations(
            mxTagAssociationToInstantiate
        );
        MxTagAssociations.Constructor constructorObject = new MxTagAssociations.Constructor();
        constructorObject.construct(mxTagAssociationToInstantiate);
        System.assertNotEquals(
            MxTagAssociations.newInstance(mxTagAssociationToInstantiate),
            newMxTagAssociation,
            CONSTRUCTOR_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when status is Inactive then End Date should be current date.
     */
    @isTest
    private static void testWhenStatusIsInActiveThenEndDateShouldBeCurrentDate() {
        Id mxTagAssociationId = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, mxTagAssociationId)
            .setField(Mx_Tag_Association__c.MxTagAssociation_Status__c, INACTIVE)
            .setField(Mx_Tag_Association__c.Start_Date__c, null)
            .setField(Mx_Tag_Association__c.End_Date__c, null)
            .toSObject();
        List<Mx_Tag_Association__c> tagAssociations = new List<Mx_Tag_Association__c>{
            mxTagAssociation
        };
        IMxTagAssociations mxTagInstance = MxTagAssociations.newInstance(tagAssociations);
        mxTagInstance.updateStartAndEndDate();
        System.assertEquals(Date.Today(), tagAssociations[0].End_Date__c, END_DATE_ASSERT_MESSAGE);
    }

    /**
     * @description To test when status is Active then Start Date should be current date.
     */
    @isTest
    private static void testWhenStatusIsActiveThenStartDateShouldBeCurrentDate() {
        Id mxTagAssociationId = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, mxTagAssociationId)
            .setField(Mx_Tag_Association__c.MxTagAssociation_Status__c, ACTIVE)
            .setField(Mx_Tag_Association__c.Start_Date__c, null)
            .setField(Mx_Tag_Association__c.End_Date__c, null)
            .toSObject();
        List<Mx_Tag_Association__c> tagAssociations = new List<Mx_Tag_Association__c>{
            mxTagAssociation
        };
        //  IMxTagAssociations mxTagInstance = MxTagAssociations.newInstance(tagAssociations);
        // mxTagInstance.updateStartAndEndDate();
        MxTagAssociations.newInstance(new List<Mx_Tag_Association__c>{ mxTagAssociation })
            .updateStartAndEndDate();
        System.assertEquals(
            Date.Today(),
            tagAssociations[0].Start_Date__c,
            START_DATE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test when Mx Tag Associations created on 'SMB' store account then clone Mx Tag Associations on corresponding Parent Account.
     * Suppressed Warnings since mock.verify() method is equivalent to System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTagAssociationCreatedOnSMBStoreAccountThenCloneMxTagAssociationsOnParentAccount() {
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent')
            .setFakeId()
            .toSObject();
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Account 1')
            .setField(Account.ParentId, parentAccount.Id)
            .setFakeId()
            .setField(Account.RecordTypeId, STORE_RECORD_TYPE_ID)
            .toSObject();

        Id mxTagAssociationId = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, mxTagAssociationId)
            .setField(Mx_Tag_Association__c.Account__c, account.Id)
            .toSObject();

        List<Mx_Tag_Association__c> tagAssociations = new List<Mx_Tag_Association__c>{
            mxTagAssociation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IMxTagAssociations mxTagInstance = MxTagAssociations.newInstance(tagAssociations);
        IMxTagAssociationsSelector selectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );
        mocks.startStubbing();

        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(accountSelectorMock.selectStoreAccountsById(new Set<Id>{ account.Id }))
            .thenReturn(new List<Account>{ account });

        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(selectorMock.selectByBusinessAccountIds(new Set<Id>{ account.Id }))
            .thenReturn(new List<Mx_Tag_Association__c>{ mxTagAssociation });

        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(selectorMock);
        mxTagInstance.createMxTagAssociationsOnParentAccount();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description To test when Mx Tag Associations created on 'Enterprise' store account then do not clone Mx Tag Associations on corresponding Parent Account.
     * Suppressed Warnings since mock.verify() method is equivalent to System.assert statement.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTagAssociationCreatedOnEnterpriseStoreAccountThenDoNotCloneMxTagAssociations() {
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME)
            .setFakeId()
            .toSObject();

        Id mxTagAssociationId = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, mxTagAssociationId)
            .setField(Mx_Tag_Association__c.Account__c, account.Id)
            .toSObject();

        List<Mx_Tag_Association__c> tagAssociations = new List<Mx_Tag_Association__c>{
            mxTagAssociation
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IAccountsSelector accountSelectorMock = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        IMxTagAssociations mxTagInstance = MxTagAssociations.newInstance(tagAssociations);
        IMxTagAssociationsSelector selectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );
        mocks.startStubbing();

        mocks.when(accountSelectorMock.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(accountSelectorMock.selectStoreAccountsById(new Set<Id>{ account.Id }))
            .thenReturn(new List<Account>{ account });

        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(selectorMock.selectByBusinessAccountIds(new Set<Id>{ account.Id }))
            .thenReturn(new List<Mx_Tag_Association__c>{ mxTagAssociation });

        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(accountSelectorMock);
        Application.SELECTOR.setMock(selectorMock);
        mxTagInstance.createMxTagAssociationsOnParentAccount();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).registerNew(fflib_Match.anySObject());
    }

    /**
     * @description To test whether opportunity lookup field is set on Mx_Tag_Association__c record
     * when account lookup is present on it.
     */
    @isTest
    private static void testWhenAccountLookupIsSetThenSetOpportunityLookup() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testMxTagId1 = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, testMxTagId1)
            .setField(Mx_Tag_Association__c.Account__c, testAccountId1)
            .setField(Mx_Tag_Association__c.MxTagAssociation_Status__c, ACTIVE)
            .toSObject();

        List<Mx_Tag_Association__c> mxTagAssociationList = new List<Mx_Tag_Association__c>();
        mxTagAssociationList.add(mxTagAssociation);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxTagAssociations mxTagInstance = MxTagAssociations.newInstance(mxTagAssociationList);
        IOpportunitiesSelector selectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(selectorMock.selectOpportunitiesByAccountId(new Set<Id>{ account.Id }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);

        Map<Id, Mx_Tag_Association__c> oldMxTagAssociation = new Map<Id, Mx_Tag_Association__c>();
        oldMxTagAssociation.put(mxTagAssociation.Id, mxTagAssociation);

        Test.startTest();
        mxTagInstance.assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent();
        System.assertEquals(
            account.Id,
            mxTagAssociationList[0].Account__c,
            ACCOUNT_ID_ASSERT_MESSAGE
        );
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), ERROR_ASSERT_MESSAGE);
        Test.stopTest();
    }

    /**
     * @description To test whether opportunity lookup field is changed on Mx_Tag_Association__c
     * record when account lookup is changed on it.
     */
    @isTest
    private static void testWhenAccountLookupIsChangedThenUpdateOpportunityLookup() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testMxTagId1 = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, testMxTagId1)
            .toSObject();

        List<Mx_Tag_Association__c> mxTagAssociationList = new List<Mx_Tag_Association__c>();
        mxTagAssociationList.add(mxTagAssociation);

        Map<Id, Mx_Tag_Association__c> oldMxTagAssociation = new Map<Id, Mx_Tag_Association__c>();
        oldMxTagAssociation.put(mxTagAssociation.Id, mxTagAssociation);

        Test.startTest();
        MxTagAssociations.newInstance(new List<Mx_Tag_Association__c>{ mxTagAssociation })
            .updateOpportunityLookUpOnMxTagAssociationUpdate(oldMxTagAssociation);

        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), ERROR_ASSERT_MESSAGE);
        Test.stopTest();
    }

    /**
     * @description To test when MxTagAssociation is deleted from an Business account
     * then it should be deleted from all the related opportunity of that business account.
     */
    @isTest
    private static void testWhenMxTagAssociationIsDeletedThenRemoveItFromOpportunity() {
        Id testAccountId1 = Fake.generateId(Account.class);
        Account account = (Account) new Fake(Account.class)
            .setField(Account.Id, testAccountId1)
            .setField(Account.Name, ACCOUNT_NAME)
            .toSObject();

        Id testOppId1 = Fake.generateId(Opportunity.class);
        Opportunity opportunity = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, testOppId1)
            .setField(Opportunity.Name, OPPORTUNITY_NAME)
            .setField(Opportunity.StageName, OPPORTUNITY_STAGE_NAME)
            .setField(Opportunity.CloseDate, Date.newInstance(2027, 12, 31))
            .setField(Opportunity.AccountId, testAccountId1)
            .toSObject();

        Id testMxTagId1 = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, testMxTagId1)
            .setField(Mx_Tag_Association__c.Account__c, testAccountId1)
            .setField(Mx_Tag_Association__c.Opportunity__c, testOppId1)
            .toSObject();

        Id testMxTagId2 = Fake.generateId(Mx_Tag_Association__c.class);
        Mx_Tag_Association__c mxTagAssociation2 = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Id, testMxTagId2)
            .setField(Mx_Tag_Association__c.Account__c, testAccountId1)
            .setField(Mx_Tag_Association__c.Opportunity__c, testOppId1)
            .toSObject();

        List<Mx_Tag_Association__c> mxTagAssociationList = new List<Mx_Tag_Association__c>();
        mxTagAssociationList.add(mxTagAssociation);
        mxTagAssociationList.add(mxTagAssociation2);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxTagAssociationsSelector mocksMxTagAssociationsselector = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );
        IOpportunitiesSelector mocksOpportunitiesSelector = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        IAccountsSelector mocksAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mocksAccountsSelector.sObjectType()).thenReturn(Schema.Account.SObjectType);
        mocks.when(mocksAccountsSelector.selectById(new Set<Id>{ testAccountId1 }))
            .thenReturn(account);

        mocks.when(mocksOpportunitiesSelector.sObjectType())
            .thenReturn(Schema.Opportunity.SObjectType);
        mocks.when(mocksOpportunitiesSelector.selectById(new Set<Id>{ testOppId1 }))
            .thenReturn(new List<Opportunity>{ opportunity });
        mocks.when(
                mocksOpportunitiesSelector.selectOpportunitiesByAccountId(
                    new Set<Id>{ testAccountId1 }
                )
            )
            .thenReturn(new List<Opportunity>{ opportunity });

        mocks.when(mocksMxTagAssociationsselector.sObjectType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.when(mocksMxTagAssociationsselector.selectByOpportunityIds(new Set<Id>{ testOppId1 }))
            .thenReturn(mxTagAssociationList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mocksMxTagAssociationsselector);
        Application.SELECTOR.setMock(mocksOpportunitiesSelector);
        Application.SELECTOR.setMock(mocksAccountsSelector);

        Test.startTest();
        MxTagAssociations.newInstance(new List<Mx_Tag_Association__c>{ mxTagAssociation })
            .updateOpportunityLookUpOnMxTagAssociationDelete();
        System.assertEquals(0, fflib_SObjects.Errors?.getAll().size(), ERROR_ASSERT_MESSAGE);
        Test.stopTest();
    }

    /**
     * @description To test when Active Mx tag association is present on business account
     * business account to Mx Tags is returned
     */
    @isTest
    private static void testWhenActiveMxTagAssociationsPresentThenAccountToMxTagsReturned() {
        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL,
            Segment__c = SEGMENT_SMB
        );
        MxTag__c mxTagTopMx = (MxTag__c) new Fake(MxTag__c.class)
            .setField(MxTag__c.Name__c, MX_TAG_TOP_MX)
            .setFakeId()
            .toSObject();
        MxTag__c mxTagMarketMaker = (MxTag__c) new Fake(MxTag__c.class)
            .setField(MxTag__c.Name__c, MX_TAG_MARKET_MAKER)
            .setFakeId()
            .toSObject();
        Mx_Tag_Association__c mxTagAssociationTopMx = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Name, MX_TAG_ASSOCIATION_TOP_MX)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTagTopMx.Id)
            .setField(Mx_Tag_Association__c.Account__c, parentAccount.Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_TOP_MX)
            .setField(
                Mx_Tag_Association__c.MxTagAssociation_Status__c,
                ACTIVE
            )
            .setFakeId()
            .toSObject();
        Mx_Tag_Association__c mxTagAssociationMarketMaker = (Mx_Tag_Association__c) new Fake(
                Mx_Tag_Association__c.class
            )
            .setField(Mx_Tag_Association__c.Name, MX_TAG_ASSOCIATION_MARKET_MAKER)
            .setField(Mx_Tag_Association__c.MxTag__c, mxTagMarketMaker.Id)
            .setField(Mx_Tag_Association__c.Account__c, parentAccount.Id)
            .setField(Mx_Tag_Association__c.MxTagName__c, MX_TAG_MARKET_MAKER)
            .setField(
                Mx_Tag_Association__c.MxTagAssociation_Status__c,
                ACTIVE
            )
            .setFakeId()
            .toSObject();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxTagAssociationsSelector mxTagAssociationsSelectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mxTagAssociationsSelectorMock.sObjectType())
            .thenReturn(Mx_Tag_Association__c.SObjectType);
        mocks.when(
                mxTagAssociationsSelectorMock.selectByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(
                new List<Mx_Tag_Association__c>{
                    mxTagAssociationTopMx,
                    mxTagAssociationMarketMaker
                }
            );

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mxTagAssociationsSelectorMock);
        Test.startTest();
        Map<Id, Set<String>> accountIdToMxTagAssociations = MxTagAssociations.newInstance(new List<Mx_Tag_Association__c>{ mxTagAssociationTopMx,mxTagAssociationMarketMaker })
            .getActiveMxTagAssociationsByBusinessAccountIds(new Set<Id>{ parentAccount.Id });
        Test.stopTest();
        System.assertEquals(accountIdToMxTagAssociations.get(parentAccount.Id).size(), 2, ERROR_MESSAGE);
    }

    /**
     * @description To test when no Active Mx tag association is present
     * no business account to Mx Tags returned
     */
    @isTest
    private static void testWhenNoActiveMxTagAssociationsPresentThenNoAccountToMxTagsReturned() {

        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.sobjectType),
            Name = ACCOUNT_NAME,
            Primary_Vertical__c = VERTICAL,
            Segment__c = SEGMENT_SMB
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        IMxTagAssociationsSelector mxTagAssociationsSelectorMock = (IMxTagAssociationsSelector) mocks.mock(
            IMxTagAssociationsSelector.class
        );

        mocks.startStubbing();
        mocks.when(mxTagAssociationsSelectorMock.sObjectType())
            .thenReturn(Mx_Tag_Association__c.SObjectType);
        mocks.when(
                mxTagAssociationsSelectorMock.selectByBusinessAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(new List<Mx_Tag_Association__c>());

        mocks.stopStubbing();
        Application.SELECTOR.setMock(mxTagAssociationsSelectorMock);
        Test.startTest();

        Map<Id, Set<String>> accountIdToMxTagAssociations = MxTagAssociations.newInstance(new List<Mx_Tag_Association__c>{ })
            .getActiveMxTagAssociationsByBusinessAccountIds(new Set<Id>{ parentAccount.Id });
        Test.stopTest();
        System.assertEquals(accountIdToMxTagAssociations.size(), 0, ERROR_MESSAGE);
    }
}