/**
 * @description This is test class for AccountRollUpServiceImplTest
 * @author Deloitte
 * @date 22/03/2022
 */

@IsTest(SeeAllData=false)
public class AccountRollUpServiceImplTest {
    private static final String ACCOUNT_MEDAL_RANK_PLATINUM = 'Platinum';
    private static final String ACCOUNT_MEDAL_RANK_SILVER = 'Silver';
    private static final String ACCOUNT_MEDAL_RANK_GOLD = 'Gold';
    private static final String MEDAL_RANK_TOPIC = 'Medal Rank';
    private static final String VERTICAL = 'Floral';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String CORPORATE = 'Corporate';
    /**
     * @description To test method call on roll up event insert.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPublishStoreRollUpEventsThenCheckTypeAndRecordId() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);

        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        AccountRollupService.publishStoreRollUpEvents(parentIds);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        RollUpEvent__e.RecordId__c => accParentId1,
                        RollUpEvent__e.Type__c => 'Store Count'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        RollUpEvent__e.RecordId__c => accParentId2,
                        RollUpEvent__e.Type__c => 'Store Count'
                    }
                )
            );
    }

    /**
     * @description To test roll up stores calculation.
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenRollUpStoresThenCalculateStoreCount() {
        Id storeAccountId = Fake.generateId(Account.class);
        Id accParentId1 = Fake.generateId(Account.class);
        Id accFranchiseId1 = Fake.generateId(Account.class);
        Id accFranchiseId2 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1, accFranchiseId1, accFranchiseId2 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Store Count', new Set<Id>(parentIds));
        List<Aggregate> accountSumOfChildStoreCount = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('corporateCount', 0)
                .put('franchiseCount', 0)
                .put('activeStores', 0)
                .put('inactiveStores', 0)
                .put('MDXStores', 0)
                .put('DriveStores', 0),
            new Aggregate()
                .put('Id', accFranchiseId1)
                .put('corporateCount', 0)
                .put('franchiseCount', 0)
                .put('activeStores', 0)
                .put('inactiveStores', 0)
                .put('MDXStores', 0)
                .put('DriveStores', 0),
            new Aggregate()
                .put('Id', accFranchiseId2)
                .put('corporateCount', 0)
                .put('franchiseCount', 0)
                .put('activeStores', 0)
                .put('inactiveStores', 0)
                .put('MDXStores', 0)
                .put('DriveStores', 0)
        };
        Fake businessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
                VERTICAL,
                ACCOUNT_RECORD_TYPE_NAME_BUSINESS
            )
            .setField(Account.Id, accParentId1)
            .setField(Account.Type, CORPORATE);

        Account mcDonaldCorporate = (Account) ServiceMockDataBuilder.convertToSObject(
            businessAccountFakeInstance
        );
        List<Account> corporateAcountList = new List<Account>();
        corporateAcountList.add(mcDonaldCorporate);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                mcDonaldCorporate.Id,
                VERTICAL
            )
            .setField(Account.Id, storeAccountId)
            .setField(Account.Activation_Status__c, 'Active')
            .setParent('Parent', businessAccountFakeInstance);
        Account mcDonaldStore = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        List<Account> storeAcountList = new List<Account>{ mcDonaldStore };
        List<Aggregate> franchiseOwnedViaParentCount = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('countIds', 2),
            new Aggregate().put('Id', accFranchiseId1).put('countIds', 0),
            new Aggregate().put('Id', accFranchiseId2).put('countIds', 0)
        };
        List<Aggregate> franchiseOwnedViaFranchiseCount = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('countIds', 0),
            new Aggregate().put('Id', accFranchiseId1).put('countIds', 1),
            new Aggregate().put('Id', accFranchiseId2).put('countIds', 1)
        };
        List<Aggregate> corporateCount = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('countIds', 1),
            new Aggregate().put('Id', accFranchiseId1).put('countIds', 0),
            new Aggregate().put('Id', accFranchiseId2).put('countIds', 0)
        };
        List<Aggregate> corporateActiveStoreCount = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('countIds', 1),
            new Aggregate().put('Id', accFranchiseId1).put('countIds', 0)
        };
        List<Aggregate> corporateInActiveStoreCount = new List<Aggregate>{
            new Aggregate().put('Id', accFranchiseId2).put('countIds', 1)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectSumOfChildStoreCount(parentIds))
            .thenReturn(accountSumOfChildStoreCount);
        mocks.when(selectorMock.selectFranchiseOwnedViaParentCount(parentIds))
            .thenReturn(franchiseOwnedViaParentCount);
        mocks.when(selectorMock.selectFranchiseOwnedViaFranchiseCount(parentIds))
            .thenReturn(franchiseOwnedViaFranchiseCount);
        mocks.when(selectorMock.selectCorporateCount(parentIds)).thenReturn(corporateCount);
        mocks.when(selectorMock.selectActiveCorporateCount(parentIds))
            .thenReturn(corporateActiveStoreCount);
        mocks.when(selectorMock.selectInActiveCorporateCount(parentIds))
            .thenReturn(corporateInActiveStoreCount);
        mocks.when(selectorMock.selectAccountsWithMDSXrefs(parentIds)).thenReturn(storeAcountList);
        mocks.when(selectorMock.selectAccountsWithNonMDSXrefs(parentIds))
            .thenReturn(storeAcountList);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        AccountRollupService.calculateRollupsByType(accountIdsByType);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
    }

    /**
     * @description To test method call on roll up event insert or Update for Vertical
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPublishVerticalRollUpEventsThenCheckTypeAndRecordId() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);

        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        AccountRollupService.publishVerticalRollUpEvents(parentIds);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        RollUpEvent__e.RecordId__c => accParentId1,
                        RollUpEvent__e.Type__c => 'Vertical'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        RollUpEvent__e.RecordId__c => accParentId2,
                        RollUpEvent__e.Type__c => 'Vertical'
                    }
                )
            );
    }

    /**
     * @description Integration test for roll up veticals on business Account insert or update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountInsertedThenUpdateParentMerchantVertical() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Child1')
            .setField(Account.Primary_Vertical__c, 'Convenience')
            .setField(Account.RecordTypeId, businessRecordTypeId)
            .setField(Account.Additional_Verticals__c, 'Convenience;Gifts')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, 'Parent')
                    .setField(Account.RecordTypeId, businessRecordTypeId)
                    .setField(Account.Primary_Vertical__c, 'Alcohol')
                    .setField(Account.Additional_Verticals__c, 'Alcohol')
            )
            .setField(Account.ParentId, businessAccountId)
            .toSObject();

        List<Account> childAccounts = new List<Account>{ childAccount1 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Vertical', new Set<Id>{ childAccount1.ParentId });

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectChildMerchantVerticals(new Set<Id>{ childAccount1.ParentId }))
            .thenReturn(childAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        //Act
        AccountRollupService.calculateRollupsByType(accountIdsByType);

        //Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.ParentId,
                        Account.Additional_Verticals__c => 'Convenience;Gifts;Alcohol'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Additional_Verticals__c }
                )
            );
    }

    /**
     * @description Integration test for roll up veticals on business Account insert or update
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountInsertedThenUpdateParentMerchantVertical() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Child1')
            .setField(Account.Primary_Vertical__c, 'Convenience')
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setField(Account.Additional_Verticals__c, 'Convenience;Gifts')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Id, businessAccountId)
                    .setField(Account.Name, 'Parent')
                    .setField(Account.RecordTypeId, businessRecordTypeId)
                    .setField(Account.Primary_Vertical__c, 'Alcohol')
                    .setField(Account.Additional_Verticals__c, 'Alcohol')
            )
            .setField(Account.ParentId, businessAccountId)
            .toSObject();

        List<Account> childAccounts = new List<Account>{ childAccount1 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('StoreVertical', new Set<Id>{ childAccount1.ParentId });

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectStoreAccountsWithPrimaryVerticalByParentAccount(
                    new Set<Id>{ childAccount1.ParentId }
                )
            )
            .thenReturn(childAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        //Act
        AccountRollupService.calculateRollupsByType(accountIdsByType);

        //Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.ParentId,
                        Account.Additional_Verticals__c => 'Convenience;Alcohol'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Additional_Verticals__c }
                )
            );
    }

    /**
     * @description Integration test for roll up veticals on franchise Account insert or update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountVerticalUpdatedThenUpdateFranchiseAccountVertical() {
        // Arrange
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Id storeAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Id, storeAccountId)
            .setField(Account.Name, 'Child1')
            .setField(Account.Primary_Vertical__c, 'Convenience')
            .setField(Account.RecordTypeId, storeRecordTypeId)
            .setParent(
                'Franchise_Parent__c',
                new Fake(Account.class)
                    .setField(Account.Id, franchiseAccountId)
                    .setField(Account.Name, 'FranchiseParent')
                    .setField(Account.RecordTypeId, businessRecordTypeId)
                    .setField(Account.Primary_Vertical__c, 'Alcohol')
                    .setField(Account.Additional_Verticals__c, 'Alcohol')
            )
            .setField(Account.Franchise_Parent__c, franchiseAccountId)
            .toSObject();

        List<Account> childAccounts = new List<Account>{ childAccount1 };
        Set<Id> franchiseAccountIds = new Set<Id>();
        franchiseAccountIds.add(franchiseAccountId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.getCorporateAccountIdsByFranchiseAccount(
                    new Set<Id>{ childAccount1.Franchise_Parent__c }
                )
            )
            .thenReturn(childAccounts);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        //Act
        AccountRollupService.aggregateVerticalOnFranchiseParents(franchiseAccountIds);

        //Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
    }

    /**
     * @description To check event values when roll up event is published
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenPublishPartnershipStatusRollUpEventsThenCheckTypeAndRecordId() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);

        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        AccountRollupService.publishPartnershipStatusRollUpEvents(parentIds);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerPublishAfterSuccessTransaction(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        RollUpEvent__e.RecordId__c => accParentId1,
                        RollUpEvent__e.Type__c => 'Partnership Status'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerPublishAfterSuccessTransaction(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        RollUpEvent__e.RecordId__c => accParentId2,
                        RollUpEvent__e.Type__c => 'Partnership Status'
                    }
                )
            );
    }

    /**
     * @description To test partnership status roll up calculation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOneExistingPartnerOrActiveThenCalculatePartnershipStatus() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Partnership Status', new Set<Id>(parentIds));

        List<Account> accounts = new List<Account>{
            new Account(
                Id = accParentId1,
                Name = 'Test 1',
                Partnership_Status__c = 'Prospective Partner'
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 2',
                Partnership_Status__c = 'Former Partner'
            )
        };

        List<Aggregate> countOfBusinessAccountWithPartnershipStatus = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('status', 'Prospective Partner')
                .put('countIds', 3),
            new Aggregate()
                .put('Id', accParentId1)
                .put('status', 'Existing Partner')
                .put('countIds', 1),
            new Aggregate()
                .put('Id', accParentId1)
                .put('status', 'Former Partner')
                .put('countIds', 2),
            new Aggregate()
                .put('Id', accParentId2)
                .put('status', 'Prospective Partner')
                .put('countIds', 3),
            new Aggregate()
                .put('Id', accParentId2)
                .put('status', 'Former Partner')
                .put('countIds', 1)
        };

        List<Aggregate> countOfStoreAccountWithActivationStatus = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('status', 'Inactive ').put('countIds', 2),
            new Aggregate().put('Id', accParentId1).put('status', 'Deactivated').put('countIds', 2),
            new Aggregate().put('Id', accParentId1).put('status', 'Deactivated').put('countIds', 2),
            new Aggregate().put('Id', accParentId2).put('status', 'Inactive').put('countIds', 3),
            new Aggregate().put('Id', accParentId2).put('status', 'Active').put('countIds', 1)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectCountOfChildrenBusinessAccountsByPartnershipStatus(parentIds))
            .thenReturn(countOfBusinessAccountWithPartnershipStatus);
        mocks.when(selectorMock.selectCountOfChildrenStoreAccountsByActivationStatus(parentIds))
            .thenReturn(countOfStoreAccountWithActivationStatus);
        mocks.when(selectorMock.selectById(parentIds)).thenReturn(accounts);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        AccountRollupService.calculateRollupsByType(accountIdsByType);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId1,
                        Account.Partnership_Status__c => 'Existing Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId2,
                        Account.Partnership_Status__c => 'Existing Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
    }

    /**
     * @description To test partnership status roll up calculation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenManyProspectivePartnerOrFormerPartnerOrInactiveOrDeactivatedThenCalculatePartnershipStatus() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Partnership Status', new Set<Id>(parentIds));

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Id = accParentId1,
                Name = 'Test 1',
                Partnership_Status__c = 'Prospective Partner'
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 2',
                Partnership_Status__c = 'Former Partner'
            )
        };

        List<Aggregate> countOfBusinessAccountWithPartnershipStatus = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('status', 'Prospective Partner')
                .put('countIds', 3),
            new Aggregate()
                .put('Id', accParentId2)
                .put('status', 'Prospective Partner')
                .put('countIds', 3),
            new Aggregate()
                .put('Id', accParentId2)
                .put('status', 'Former Partner')
                .put('countIds', 1)
        };

        List<Aggregate> countOfStoreAccountWithActivationStatus = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('status', 'Inactive').put('countIds', 2),
            new Aggregate().put('Id', accParentId2).put('status', 'Inactive').put('countIds', 2),
            new Aggregate().put('Id', accParentId2).put('status', 'Deactivated').put('countIds', 1)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectCountOfChildrenBusinessAccountsByPartnershipStatus(parentIds))
            .thenReturn(countOfBusinessAccountWithPartnershipStatus);
        mocks.when(selectorMock.selectCountOfChildrenStoreAccountsByActivationStatus(parentIds))
            .thenReturn(countOfStoreAccountWithActivationStatus);
        mocks.when(selectorMock.selectById(parentIds)).thenReturn(storeAccounts);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        AccountRollupService.calculateRollupsByType(accountIdsByType);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId1,
                        Account.Partnership_Status__c => 'Prospective Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId2,
                        Account.Partnership_Status__c => 'Prospective Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
    }

    /**
     * @description To test partnership status roll up calculation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAllFormerPartnerOrAllDeactivatedThenCalculatePartnershipStatus() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Partnership Status', new Set<Id>(parentIds));

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Id = accParentId1,
                Name = 'Test 1',
                Partnership_Status__c = 'Prospective Partner'
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 2',
                Partnership_Status__c = 'Prospective Partner'
            )
        };

        List<Aggregate> countOfAccountWithPartnershipStatus = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('status', 'Former Partner')
                .put('countIds', 2)
        };

        List<Aggregate> countOfStoreAccountWithActivationStatus = new List<Aggregate>{
            new Aggregate().put('Id', accParentId2).put('status', 'Deactivated').put('countIds', 3)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectCountOfChildrenBusinessAccountsByPartnershipStatus(parentIds))
            .thenReturn(countOfAccountWithPartnershipStatus);
        mocks.when(selectorMock.selectCountOfChildrenStoreAccountsByActivationStatus(parentIds))
            .thenReturn(countOfStoreAccountWithActivationStatus);
        mocks.when(selectorMock.selectById(parentIds)).thenReturn(storeAccounts);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        AccountRollupService.calculateRollupsByType(accountIdsByType);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId1,
                        Account.Partnership_Status__c => 'Former Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId2,
                        Account.Partnership_Status__c => 'Former Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
    }

    /**
     * @description To test partnership status roll up calculation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNoRecordsRetrivedThenCalculatePartnershipStatus() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Partnership Status', new Set<Id>(parentIds));

        List<Account> storeAccounts = new List<Account>{
            new Account(
                Id = accParentId1,
                Name = 'Test 1',
                Partnership_Status__c = 'Prospective Partner'
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 2',
                Partnership_Status__c = 'Prospective Partner'
            )
        };

        List<Aggregate> countOfAccountWithPartnershipStatus = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('status', 'Former Partner')
                .put('countIds', 2)
        };

        List<Aggregate> countOfStoreAccountWithActivationStatus = new List<Aggregate>{
            new Aggregate().put('Id', accParentId1).put('status', 'Deactivated').put('countIds', 3)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectCountOfChildrenBusinessAccountsByPartnershipStatus(parentIds))
            .thenReturn(countOfAccountWithPartnershipStatus);
        mocks.when(selectorMock.selectCountOfChildrenStoreAccountsByActivationStatus(parentIds))
            .thenReturn(countOfStoreAccountWithActivationStatus);
        mocks.when(selectorMock.selectById(parentIds)).thenReturn(storeAccounts);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);

        AccountRollupService.calculateRollupsByType(accountIdsByType);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId1,
                        Account.Partnership_Status__c => 'Former Partner'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Partnership_Status__c }
                )
            );
    }

     /**
     * @description To test Medal Rank roll up calculation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoresMedalRankValuesThenCalculateMedalRankOfBusinessAccount() {
        Id accParentId1 = Fake.generateId(Account.class);
        Id accParentId2 = Fake.generateId(Account.class);
        Set<Id> parentIds = new Set<Id>{ accParentId1, accParentId2 };
        Map<String, Set<Id>> accountIdsByType = new Map<String, Set<Id>>();
        accountIdsByType.put('Medal Rank', new Set<Id>(parentIds));
        List<Account> accounts = new List<Account>{
            new Account(
                Id = accParentId1,
                Name = 'Test 1',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_SILVER
            ),
            new Account(
                Id = accParentId1,
                Name = 'Test 2',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_SILVER
            ),
            new Account(
                Id = accParentId1,
                Name = 'Test 3',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_GOLD
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 4',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 5',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_PLATINUM
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 6',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_GOLD
            ),
            new Account(
                Id = accParentId2,
                Name = 'Test 7',
                Medal_Rank__c = ACCOUNT_MEDAL_RANK_GOLD
            )
        };
        List<Aggregate> countOfStoreAccountsWithMedalRank = new List<Aggregate>{
            new Aggregate()
                .put('Id', accParentId1)
                .put('medalRank', ACCOUNT_MEDAL_RANK_SILVER)
                .put('countIds', 2),
            new Aggregate()
                .put('Id', accParentId1)
                .put('medalRank', ACCOUNT_MEDAL_RANK_GOLD)
                .put('countIds', 1),
            new Aggregate()
                .put('Id', accParentId2)
                .put('medalRank', ACCOUNT_MEDAL_RANK_GOLD)
                .put('countIds', 2),
            new Aggregate()
                .put('Id', accParentId2)
                .put('medalRank', ACCOUNT_MEDAL_RANK_PLATINUM)
                .put('countIds', 2)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectCountOfStoreAccountsByMedalRank(parentIds))
            .thenReturn(countOfStoreAccountsWithMedalRank);
        mocks.when(selectorMock.selectById(parentIds)).thenReturn(accounts);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(selectorMock);
        AccountRollupService.calculateRollupsByType(accountIdsByType);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject(), (List<SObjectField>) fflib_Match.anyList());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId1,
                        Account.Medal_Rank__c => ACCOUNT_MEDAL_RANK_SILVER
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Medal_Rank__c }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accParentId2,
                        Account.Medal_Rank__c => ACCOUNT_MEDAL_RANK_PLATINUM
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(
                    new List<SObjectField>{ Account.Medal_Rank__c }
                )
            );
    }
}