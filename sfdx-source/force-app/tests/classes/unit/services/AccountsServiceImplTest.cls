/**
 * @description This is the test class for AccountsServiceImpl
 * @author Deloitte
 * @date 04/03/2022
 */
@isTest
public with sharing class AccountsServiceImplTest {
    private static final String APPROVED = 'Approved';
    private static final String ACCOUNT_DECK_RANK = 'Jack';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String MOCK_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS = 'TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String DUPLICATE_RULE_NAME = 'Account_Low_Complexity_Duplicate_Rule';
    private static final String ACCOUNT_TYPE_CORPORATE = 'Corporate';
    private static final String CHILD_ACCOUNTS_TRICKLE_DOWN_QUERY_LIMIT_STATIC_CONFIG = 'Child_Accounts_Trickle_Down_Query_Limit';
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_QUERY_LIMIT_VALUE = '7500';
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG = 'Trickle_Down_Parent_Account_Fields';
    private static final String TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_VALUE = '10';
    private static final String EVENT_TOPIC_STORE_ACCOUNT_EXPERIENCE_UPDATE = 'STORE_ACCOUNT_EXPERIENCE_UPDATE';
    private static final String INTEGRATED_FRANCHISE = System.Label.FranchiseType_Integrated_Franchise;
    private static final String PAYMENT_METHOD_WITHHOLDING = 'Withholding';
    private static final String WITHHOLDING_OPT_OUT = System.Label.FranchiseType_Withholding_Opt_out;
    private static final String WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS = '40';
    private static final String WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG = 'Withholding_Opt_out_Limit_in_Days';
    private static final String AGGREGATE_ACCOUNTCOUNT_FIELD_ALIAS = 'countIds';
    private static final String AGGREGATE_PARENTID_FIELD_ALIAS = 'parentId';
    private static final String EVENT_TOPIC_UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT';
    private static final String ALCOHOL_PICKUP = 'Alcohol Pickup';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String BUSINESS_ACCOUNT_RECORD_TYPE_NAME = 'Business';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenUpdateParentThenItShouldSetUltimateParentFromLevel5() {
        Id rootAccount1Id = Fake.generateId(Account.class);
        Id rootAccount2Id = Fake.generateId(Account.class);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 4')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 3')
                    .setParent(
                        'Parent',
                        new Fake(Account.class)
                            .setFakeId()
                            .setField(Account.Name, 'Child 2')
                            .setParent(
                                'Parent',
                                new Fake(Account.class)
                                    .setFakeId()
                                    .setField(Account.Name, 'Child 1')
                                    .setField(Account.ParentId, rootAccount1Id)
                                    .setParent(
                                        'Parent',
                                        new Fake(Account.class)
                                            .setField(Account.Id, rootAccount1Id)
                                            .setField(Account.Name, 'Root Account')
                                    )
                            )
                    )
            )
            .toSObject();

        Account childAccount2 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 4')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 3')
                    .setParent(
                        'Parent',
                        new Fake(Account.class)
                            .setFakeId()
                            .setField(Account.Name, 'Child 2')
                            .setParent(
                                'Parent',
                                new Fake(Account.class)
                                    .setFakeId()
                                    .setField(Account.Name, 'Child 1')
                                    .setField(Account.ParentId, rootAccount2Id)
                                    .setParent(
                                        'Parent',
                                        new Fake(Account.class)
                                            .setField(Account.Id, rootAccount2Id)
                                            .setField(Account.Name, 'Root Account')
                                    )
                            )
                    )
            )
            .toSObject();

        List<Account> accountList = new List<Account>{ childAccount1, childAccount2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateUltimateParent(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount1Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount2.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount2Id
                    }
                )
            );
        system.assertNotEquals(
            Account.Ultimate_Parent_Account__c,
            null,
            'Incorrect Ultimate parent updated'
        );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenUpdateParentThenItShouldSetUltimateParentFromLevel4() {
        Id rootAccount1Id = Fake.generateId(Account.class);
        Id rootAccount2Id = Fake.generateId(Account.class);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 3')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 2')
                    .setParent(
                        'Parent',
                        new Fake(Account.class)
                            .setFakeId()
                            .setField(Account.Name, 'Child 1')
                            .setField(Account.ParentId, rootAccount1Id)
                            .setParent(
                                'Parent',
                                new Fake(Account.class)
                                    .setField(Account.Name, 'Root Account')
                                    .setField(Account.Id, rootAccount1Id)
                            )
                    )
            )
            .toSObject();

        Account childAccount2 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 3')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 2')
                    .setParent(
                        'Parent',
                        new Fake(Account.class)
                            .setFakeId()
                            .setField(Account.Name, 'Child 1')
                            .setField(Account.ParentId, rootAccount2Id)
                            .setParent(
                                'Parent',
                                new Fake(Account.class)
                                    .setField(Account.Name, 'Root Account')
                                    .setField(Account.Id, rootAccount2Id)
                            )
                    )
            )
            .toSObject();

        List<Account> accountList = new List<Account>{ childAccount1, childAccount2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateUltimateParent(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount1Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount2.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount2Id
                    }
                )
            );
        system.assertNotEquals(
            Account.Ultimate_Parent_Account__c,
            null,
            'Incorrect Ultimate parent updated'
        );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenUpdateParentThenItShouldSetUltimateParentFromLevel3() {
        Id rootAccount1Id = Fake.generateId(Account.class);
        Id rootAccount2Id = Fake.generateId(Account.class);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 2')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 1')
                    .setField(Account.ParentId, rootAccount1Id)
                    .setParent(
                        'Parent',
                        new Fake(Account.class)
                            .setField(Account.Name, 'Root Account')
                            .setField(Account.Id, rootAccount1Id)
                    )
            )
            .toSObject();

        Account childAccount2 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 2')
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 1')
                    .setField(Account.ParentId, rootAccount2Id)
                    .setParent(
                        'Parent',
                        new Fake(Account.class)
                            .setField(Account.Name, 'Root Account')
                            .setField(Account.Id, rootAccount2Id)
                    )
            )
            .toSObject();

        List<Account> accountList = new List<Account>{ childAccount1, childAccount2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateUltimateParent(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount1Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount2.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount2Id
                    }
                )
            );
        system.assertNotEquals(
            Account.Ultimate_Parent_Account__c,
            null,
            'Incorrect Ultimate parent updated'
        );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenUpdateParentThenItShouldSetUltimateParentFromLevel2() {
        Id rootAccount1Id = Fake.generateId(Account.class);
        Id rootAccount2Id = Fake.generateId(Account.class);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 1')
            .setField(Account.ParentId, rootAccount1Id)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Name, 'Root Account')
                    .setField(Account.Id, rootAccount1Id)
            )
            .toSObject();

        Account childAccount2 = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child 1')
            .setField(Account.ParentId, rootAccount2Id)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Name, 'Root Account')
                    .setField(Account.Id, rootAccount2Id)
            )
            .toSObject();

        List<Account> accountList = new List<Account>{ childAccount1, childAccount2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateUltimateParent(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount1Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount2.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount2Id
                    }
                )
            );
        system.assertNotEquals(
            Account.Ultimate_Parent_Account__c,
            null,
            'Incorrect Ultimate parent updated'
        );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenUpdateParentThenItShouldSetUltimateParentFromLevel1() {
        Id rootAccount1Id = Fake.generateId(Account.class);
        Id rootAccount2Id = Fake.generateId(Account.class);
        Account childAccount1 = (Account) new Fake(Account.class)
            .setField(Account.ParentId, rootAccount1Id)
            .setField(Account.Name, 'Child 1')
            .setFakeId()
            .toSObject();

        Account childAccount2 = (Account) new Fake(Account.class)
            .setField(Account.ParentId, rootAccount2Id)
            .setField(Account.Name, 'Child 1')
            .setFakeId()
            .toSObject();

        List<Account> accountList = new List<Account>{ childAccount1, childAccount2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateUltimateParent(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount1Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount2.Id,
                        Account.Ultimate_Parent_Account__c => rootAccount2Id
                    }
                )
            );
        system.assertNotEquals(
            Account.Ultimate_Parent_Account__c,
            null,
            'Incorrect Ultimate parent updated'
        );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @IsTest
    public static void testWhenUpdateParentThenItShouldNotSetUltimateParentFromLevel0() {
        Account childAccount1 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Child 1')
            .setFakeId()
            .toSObject();

        Account childAccount2 = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Child 1')
            .setFakeId()
            .toSObject();

        List<Account> accountList = new List<Account>{ childAccount1, childAccount2 };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateUltimateParent(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount1.Id,
                        Account.Ultimate_Parent_Account__c => childAccount1.Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount2.Id,
                        Account.Ultimate_Parent_Account__c => childAccount2.Id
                    }
                )
            );
        system.assertNotEquals(
            Account.Ultimate_Parent_Account__c,
            null,
            'Incorrect Ultimate parent updated'
        );
    }

    /**
     * @description Tests when Accounts are passed then MDS Activation is updated
     */
    @IsTest
    public static void testWhenAccountsArePassedThenMDSActivationIsUpdated() {
        Account businessAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Business')
            .setField(Account.Is_MDS_Activated__c, true)
            .setFakeId()
            .toSObject();
        Account corporateAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Corporate')
            .setFakeId()
            .toSObject();

        List<Account> accountList = new List<Account>{ businessAccount, corporateAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateAccountsForActivatingAndDeactivatingMDSXrefs(accountList);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(fflib_Match.anySObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.never()))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Account.Id => businessAccount.Id,
                            Account.Is_MDS_Activated__c => true,
                            Account.Name => 'Business'
                        },
                        new Map<SObjectField, Object>{
                            Account.Id => corporateAccount.Id,
                            Account.Is_MDS_Activated__c => false,
                            Account.Name => 'Corporate'
                        }
                    }
                )
            );

        System.assertEquals(
            true,
            businessAccount.Is_MDS_Activated__c,
            'The MDS Activation was unsuccessful.'
        );
    }

    /**
     * @description Tests when Parent is updated it reflects in Account record
     */
    @isTest(seeAllData=false)
    public static void testWhenAccUpdateThenUpdateChild() {
        Account objAccount = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Example Account Name')
            .setField(Account.Type, 'Example Type')
            .toSObject();

        List<Account> accountList = new List<Account>();
        accountList.add(objAccount);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateAccounts(accountList);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        system.assertEquals(true, true, 'Dummy assert');
    }

    /**
     * @description this method test when an Business account have any assosiated opportunitiy then the
     * Account life cycle status changes to In Pursuit.
     */
    @isTest
    private static void testWhenOpportunityRelatedWithAccountThenChangeStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        List<Account> accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 1',
                Account_Lifecycle_Status__c = 'Unvetted',
                RecordTypeId = businessRecordTypeId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Parent 2',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            )
        };

        /**List<Opportunity> opportunitiesRec = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Prospecting',
                AccountId = accounts[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Prospecting',
                AccountId = accounts[1].Id
            )
        };*/

        Set<Id> accountIds = new Set<Id>{ accounts[0].Id, accounts[1].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();

        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectUnverifiedBusinessAccountsById(accountIds))
            .thenReturn(new List<Account>{ accounts[0] });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateAcountLifeCycleStatusToInPursuit(accountIds);
        System.assertEquals(
            accounts[0].Account_Lifecycle_Status__c,
            'In Pursuit',
            'Status is not updated correctly'
        );
    }

    /**
     * @description this method test when an account doesnt have any assosiated opportunitiy(after delete) then the
     * Account life cycle status changes to Unvetted.
     */
    @isTest
    private static void testWhenNoHistoricalOpportunitiesWithAccountThenChangeStatus() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        List<Account> accounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                Account_Lifecycle_Status__c = 'In Pursuit',
                RecordTypeId = businessRecordTypeId
            )
        };
        Set<Id> accountIds = new Set<Id>{ accounts[0].Id };

        /*List<Opportunity> opportunitiesRecords = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test1',
                StageName = 'Stalled',
                AccountId = accounts[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test2',
                StageName = 'Stalled',
                AccountId = accounts[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.SObjectType),
                Name = 'Test3',
                StageName = 'Stalled'
            )
        };*/

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMockAc = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();

        mocks.when(selectorMockAc.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMockAc.selectInPursuitBusinessAccountsById(accountIds))
            .thenReturn(accounts);

        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.Selector.setMock(selectorMockAc);

        AccountsService.updateAcountLifeCycleStatusToUnvetted(accountIds, accountIds);
        System.assertEquals(
            accounts[1].Account_Lifecycle_Status__c,
            'Unvetted',
            'Status is not updated correctly'
        );
    }

    /**
     * @description To test update of account attributes in top down automation
     */
    @isTest
    private static void testWhenTopsDownThenAccountAttributesShouldBeUpdated() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id rootAccount2Id = Fake.generateId(Account.class);
        Id rootAccount1Id = Fake.generateId(Account.class);
        Account childAccount = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child')
            .setField(Account.Primary_Vertical__c, 'Alcohol')
            .setField(Account.Segment__c, 'Mid-Market')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setField(Account.BillingCountry, 'United States')
            .setField(Account.BillingState, 'California')
            .setField(Account.BillingPostalCode, '12345')
            .setField(Account.BillingCity, 'City')
            .setField(Account.BillingStreet, 'Street')
            .setField(Account.ParentId, rootAccount1Id)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setField(Account.Name, 'Child 1')
                    .setField(Account.ParentId, rootAccount2Id)
                    .setField(Account.Primary_Vertical__c, 'Gifts')
                    .setField(Account.Segment__c, 'Enterprise')
                    .setField(Account.RecordTypeID, businessRecordTypeId)
                    .setField(Account.Id, rootAccount1Id)
            )
            .setParent(
                'Ultimate_Parent_Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, 'Root Account')
                    .setField(Account.Id, rootAccount2Id)
                    .setField(Account.Primary_Vertical__c, 'Grocery')
                    .setField(Account.Segment__c, 'SMB')
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();

        List<Account> testAccounts = new List<Account>{ childAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateAccountAttributesTopDownAutomation(testAccounts);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount.Id,
                        Account.Segment__c => 'SMB'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(new List<SObjectField>{ Account.Segment__c })
            );
        System.assertNotEquals(
            childAccount.Parent.Primary_Vertical__c,
            'Alcohol',
            'Invalid primary vertical'
        );
    }

    /**
     * @description To test update of account attributes in top down automation when ultimate parent segment is null
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUltimateParentSegmentNullThenAccountAttributesShouldNotBeUpdated() {
        // Arrange
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id rootAccount2Id = Fake.generateId(Account.class);
        Account childAccount = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Name, 'Child')
            .setField(Account.Primary_Vertical__c, 'Alcohol')
            .setField(Account.Segment__c, 'Mid-Market')
            .setField(Account.RecordTypeID, storeRecordTypeId)
            .setParent(
                'Parent',
                new Fake(Account.class)
                    .setFakeId()
                    .setField(Account.Name, 'Child 1')
                    .setField(Account.ParentId, rootAccount2Id)
                    .setField(Account.Primary_Vertical__c, 'Gifts')
                    .setField(Account.Segment__c, 'Enterprise')
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .setParent(
                'Ultimate_Parent_Account__r',
                new Fake(Account.class)
                    .setField(Account.Name, 'Root Account')
                    .setField(Account.Id, rootAccount2Id)
                    .setField(Account.Primary_Vertical__c, 'Grocery')
                    .setField(Account.RecordTypeID, businessRecordTypeId)
            )
            .toSObject();

        List<Account> testAccounts = new List<Account>{ childAccount };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateAccountAttributesTopDownAutomation(testAccounts);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount.Id,
                        Account.Segment__c => 'Mid-Market'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(new List<SObjectField>{ Account.Segment__c })
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => childAccount.parent.Id,
                        Account.Segment__c => 'Enterprise'
                    }
                ),
                (List<SObjectField>) fflib_Match.eq(new List<SObjectField>{ Account.Segment__c })
            );
    }

    /**
     * @description To test PDOX update on store Account based on received store Accounts.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenStoreAccountsReceivedThenPDOXFieldsOnPassedStoreAccountUpdated() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Proposed_Date_of_Menu__c, System.today() + 6)
            .setField(Account.Proposed_Date_of_Tablet__c, System.today() + 15);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IGenericLogger genericLoggerService = (IGenericLogger) mocks.mock(GenericLoggerImpl.class);
        Application.SERVICE.setMock(IGenericLogger.class, genericLoggerService);
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.populatePDOXOnStoreAccounts(new List<Account>{ storeAccount });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(new List<Account>{ storeAccount });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test store accounts are not commited when empty list is received.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenEmptyListReceivedThenStoreAccountsNotCommited() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.populatePDOXOnStoreAccounts(new List<Account>{});
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }

    /**
     * @description To test exception log (Log__c) is created when DML Exception occurs
     * while updating the received store accounts.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDMLExceptionThenLogCreated() {
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 10)
            .setField(Account.Proposed_Date_of_Menu__c, System.today() + 6)
            .setField(Account.Proposed_Date_of_Tablet__c, System.today() + 15);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        ((fflib_ISObjectUnitOfWork) mocks.doThrowWhen(
                new TestCommitException(MOCK_EXCEPTION_MESSAGE),
                mockUOW
            ))
            .commitWork();
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        String exceptionMessage;
        try {
            AccountsService.populatePDOXOnStoreAccounts(new List<Account>{ storeAccount });
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
                .registerDirty(new List<Account>{ storeAccount });
            ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        } catch (Exception mockException) {
            exceptionMessage = mockException.getMessage();
        }
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Log__c.Detailed_Message__c => MOCK_EXCEPTION_MESSAGE,
                        Log__c.Severity_Level__c => LogEntry.SeverityLevel.HIGH.name()
                    }
                )
            );
    }

    /**
     * @author Deloitte
     * @date 08/23/2022
     * @description Exception class for customising exception on commitWork function for Tests.
     */
    class TestCommitException extends Exception {
    }

    /**
     * @description To test when IsMerged Notifier event is fired then update IsMerged flag on account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNotifierEventsReceivedThenSetFlag() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Account[] newAccounts = new List<Account>{
            new Account(Id = businessAccountId, Name = 'Test 2')
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        String eventPayload = JSON.serialize(new Set<Id>{ newAccounts[0].Id });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = 'UPDATE_ACCOUNT_ISMERGED_FLAG'
        );
        AccountsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Account.Is_Merged__c => true }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test post merge operation performed on winning account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenParentAccountIdsReceivedThenPerformAfterMergeUpdateOperation() {
        Id parentId1 = fflib_IDGenerator.generate(Account.SObjectType);
        Id parentId2 = fflib_IDGenerator.generate(Account.SObjectType);

        Set<Id> parentIds = new Set<Id>{ parentId1, parentId2 };

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountRollupService accountRollUpServiceMock = (IAccountRollupService) mocks.mock(
            IAccountRollupService.class
        );
        IAsyncBatchRunner runnerMock = (IAsyncBatchRunner) mocks.mock(IAsyncBatchRunner.class);
        mocks.startStubbing();
        mocks.when(runnerMock.executeBatch(fflib_Match.anyObject())).thenReturn(null);
        mocks.stopStubbing();

        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(IAsyncBatchRunner.class, runnerMock);
        Application.SERVICE.setMock(IAccountRollupService.class, accountRollUpServiceMock);

        AccountsService.processMergedParentAccounts(parentIds);

        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishStoreRollUpEvents(parentIds);
        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishVerticalRollUpEvents(parentIds);
        ((IAccountRollupService) mocks.verify(accountRollUpServiceMock, 1))
            .publishPartnershipStatusRollUpEvents(parentIds);
        ((IAsyncBatchRunner) mocks.verify(runnerMock, 1)).executeBatch(fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test post merge operation performed on child accounts of winning account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenChildAccountsReceivedThenPerformAfterMergeUpdateOperation() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Account parentAccount = new Account(
            Id = fflib_IDGenerator.generate(Account.SObjectType),
            RecordTypeId = businessRecordTypeId,
            Name = 'Parent 1'
        );

        Account[] childAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                RecordTypeId = storeRecordTypeId,
                Name = 'Child 1',
                Franchise_Parent__c = parentAccount.Id
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                RecordTypeId = storeRecordTypeId,
                Name = 'Child 2',
                Franchise_Parent__c = parentAccount.Id
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);

        AccountsService.processMergedAccountsRelatedRecords(childAccounts);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Account.Is_Parent_Account_Merged__c => true }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test if duplicate/non duplcate status is stamped on accounts
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNonDuplicateAccountsFoundThenUpdateDuplicateStatus() {
        List<Account> duplicateAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Corporate',
                Duplicate_Status__c = 'Non-Duplicate'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Corporate',
                Duplicate_Status__c = 'Non-Duplicate'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Frachisee',
                Duplicate_Status__c = 'Non-Duplicate'
            )
        };

        List<Id> allAccountIds = new List<Id>{
            duplicateAccounts[0].Id,
            duplicateAccounts[1].Id,
            duplicateAccounts[2].Id
        };

        Map<Id, List<Account>> originalAccountIdWithDuplicate = new Map<Id, List<Account>>();
        originalAccountIdWithDuplicate.put(
            duplicateAccounts[0].Id,
            new List<Account>{ duplicateAccounts[1] }
        );
        originalAccountIdWithDuplicate.put(
            duplicateAccounts[1].Id,
            new List<Account>{ duplicateAccounts[0] }
        );
        originalAccountIdWithDuplicate.put(duplicateAccounts[2].Id, new List<Account>{});

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ICheckDuplicatesService checkDuplicateServiceMock = (ICheckDuplicatesService) mocks.mock(
            ICheckDuplicatesService.class
        );

        mocks.startStubbing();
        mocks.when(
                checkDuplicateServiceMock.getMapOfSObjectIdWithDuplicates(
                    allAccountIds,
                    DUPLICATE_RULE_NAME
                )
            )
            .thenReturn(originalAccountIdWithDuplicate);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(ICheckDuplicatesService.class, checkDuplicateServiceMock);

        String eventPayload = JSON.serialize(
            new Set<Id>{ duplicateAccounts[0].Id, duplicateAccounts[1].Id, duplicateAccounts[2].Id }
        );

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = 'UPDATE_ACCOUNT_DUPLICATE_STATUS'
        );
        AccountsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[0].Id,
                        Account.Duplicate_Status__c => 'Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[1].Id,
                        Account.Duplicate_Status__c => 'Non-Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[2].Id,
                        Account.Duplicate_Status__c => 'Non-Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test if duplicate/non duplcate status is stamped on accounts
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUnverifiedAccountsFoundThenUpdateDuplicateStatus() {
        List<Account> duplicateAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Corporate',
                Duplicate_Status__c = 'Unverified'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Corporate',
                Duplicate_Status__c = 'Unverified'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Frachisee',
                Duplicate_Status__c = 'Unverified'
            )
        };

        List<Id> allAccountIds = new List<Id>{
            duplicateAccounts[0].Id,
            duplicateAccounts[1].Id,
            duplicateAccounts[2].Id
        };

        Map<Id, List<Account>> originalAccountIdWithDuplicate = new Map<Id, List<Account>>();
        originalAccountIdWithDuplicate.put(
            duplicateAccounts[0].Id,
            new List<Account>{ duplicateAccounts[1] }
        );
        originalAccountIdWithDuplicate.put(
            duplicateAccounts[1].Id,
            new List<Account>{ duplicateAccounts[0] }
        );
        originalAccountIdWithDuplicate.put(duplicateAccounts[2].Id, new List<Account>{});

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ICheckDuplicatesService checkDuplicateServiceMock = (ICheckDuplicatesService) mocks.mock(
            ICheckDuplicatesService.class
        );

        mocks.startStubbing();
        mocks.when(
                checkDuplicateServiceMock.getMapOfSObjectIdWithDuplicates(
                    allAccountIds,
                    DUPLICATE_RULE_NAME
                )
            )
            .thenReturn(originalAccountIdWithDuplicate);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(ICheckDuplicatesService.class, checkDuplicateServiceMock);

        String eventPayload = JSON.serialize(
            new Set<Id>{ duplicateAccounts[0].Id, duplicateAccounts[1].Id, duplicateAccounts[2].Id }
        );

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = 'UPDATE_ACCOUNT_DUPLICATE_STATUS'
        );
        AccountsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[0].Id,
                        Account.Duplicate_Status__c => 'Non-Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[1].Id,
                        Account.Duplicate_Status__c => 'Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[2].Id,
                        Account.Duplicate_Status__c => 'Non-Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test if duplicate/non duplcate status is stamped on accounts
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDuplicateAccountsFoundThenUpdateDuplicateStatus() {
        List<Account> duplicateAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Corporate',
                Duplicate_Status__c = 'Duplicate'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Corporate',
                Duplicate_Status__c = 'Duplicate'
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Account 1',
                Type = 'Frachisee',
                Duplicate_Status__c = 'Duplicate'
            )
        };

        List<Id> allAccountIds = new List<Id>{
            duplicateAccounts[0].Id,
            duplicateAccounts[1].Id,
            duplicateAccounts[2].Id
        };

        Map<Id, List<Account>> originalAccountIdWithDuplicate = new Map<Id, List<Account>>();
        originalAccountIdWithDuplicate.put(
            duplicateAccounts[0].Id,
            new List<Account>{ duplicateAccounts[1] }
        );
        originalAccountIdWithDuplicate.put(
            duplicateAccounts[1].Id,
            new List<Account>{ duplicateAccounts[0] }
        );
        originalAccountIdWithDuplicate.put(duplicateAccounts[2].Id, new List<Account>{});

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        ICheckDuplicatesService checkDuplicateServiceMock = (ICheckDuplicatesService) mocks.mock(
            ICheckDuplicatesService.class
        );

        mocks.startStubbing();
        mocks.when(
                checkDuplicateServiceMock.getMapOfSObjectIdWithDuplicates(
                    allAccountIds,
                    DUPLICATE_RULE_NAME
                )
            )
            .thenReturn(originalAccountIdWithDuplicate);
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SERVICE.setMock(ICheckDuplicatesService.class, checkDuplicateServiceMock);

        String eventPayload = JSON.serialize(
            new Set<Id>{ duplicateAccounts[0].Id, duplicateAccounts[1].Id, duplicateAccounts[2].Id }
        );

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = 'UPDATE_ACCOUNT_DUPLICATE_STATUS'
        );
        AccountsService.execute(new List<Notifier__e>{ mockNotifierEvent });

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[0].Id,
                        Account.Duplicate_Status__c => 'Non-Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[1].Id,
                        Account.Duplicate_Status__c => 'Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => duplicateAccounts[2].Id,
                        Account.Duplicate_Status__c => 'Non-Duplicate'
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test the updated Control of Price field value on child accounts when Control of Price is updated on Parent Account
     * @JIRA# LEM-8322
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenControlOfPriceIsUpdatedOnParentAccountsThenChildAccountFieldIsUpdated() {
        // Test setup code
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        String fieldApiName = 'Control_of_Price__c';
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Account> childaccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 1',
                ParentId = parentAccountId,
                Control_of_Price__c = 'Merchant',
                RecordTypeId = storeRecordTypeId
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'Test 2',
                ParentId = parentAccountId,
                Control_of_Price__c = 'Merchant',
                RecordTypeId = storeRecordTypeId
            )
        };
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Id = parentAccountId,
                Name = 'Test 3',
                Control_of_Price__c = 'Doordash',
                RecordTypeId = businessRecordTypeId
            )
        };

        Set<Id> parentAccountIds = new Set<Id>{ parentAccounts[0].Id };
        // Create mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        // Add more mocks if needed

        mocks.startStubbing();

        // Set up mock behaviors
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectChildAccounts(parentAccountIds)).thenReturn(childaccounts);
        // Set up more mock behaviors

        mocks.stopStubbing();

        // Set the mocks
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        // Set more mock objects if needed

        // Call the method under test
        AccountsService.stampFieldValueOnChildAccounts(parentAccounts, fieldApiName);

        // Verify expected registerDirty calls
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerDirty(childaccounts);

        // Verify expected method invocations
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        // Assertions and verification of results
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Account.Id => childaccounts[0].Id,
                            Account.Control_of_Price__c => 'Doordash'
                        },
                        new Map<SObjectField, Object>{
                            Account.Id => childaccounts[1].Id,
                            Account.Control_of_Price__c => 'Doordash'
                        }
                    }
                )
            );
    }

    /**
     * @description To test when active service has product platform then Experience is updated on Account
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActiveServiceHasPlatformThenUpdateExperience() {
        Id service1 = Fake.generateId(Merchant_Service__c.class);
        Id service2 = Fake.generateId(Merchant_Service__c.class);
        Id service3 = Fake.generateId(Merchant_Service__c.class);
        Id account1 = Fake.generateId(Account.class);
        Id account2 = Fake.generateId(Account.class);
        Id account3 = Fake.generateId(Account.class);
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs2 = Fake.generateId(SBQQ__Subscription__c.class);
        Id subs3 = Fake.generateId(SBQQ__Subscription__c.class);
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id orderItem2 = Fake.generateId(OrderItem.class);
        Id orderItem3 = Fake.generateId(OrderItem.class);
        Id prod1 = Fake.generateId(Product2.class);
        Id prod2 = Fake.generateId(Product2.class);
        Id prod3 = Fake.generateId(Product2.class);

        Account[] newAccounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, account1)
                .setField(Account.Name, 'account 1')
                .setchildren(
                    'Services__r',
                    new List<Fake>{
                        new Fake(Merchant_Service__c.class)
                            .setField(Merchant_Service__c.Id, service1)
                            .setField(Merchant_Service__c.Account__c, account1)
                            .setField(Merchant_Service__c.Subscription__c, subs1)
                            .setField(Merchant_Service__c.Order_Product__c, orderItem1)
                            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
                            .setField(Merchant_Service__c.Active__c, 'Yes')
                            .setParent(
                                'Product__r',
                                new Fake(Product2.class)
                                    .setField(Product2.Id, prod1)
                                    .setField(Product2.Platform__c, 'DoorDash')
                                    .setField(Product2.Name, ALCOHOL_PICKUP)
                            )
                    }
                )
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Name, 'account2')
                .setField(Account.Id, account2)
                .setchildren(
                    'Services__r',
                    new List<Fake>{
                        new Fake(Merchant_Service__c.class)
                            .setField(Merchant_Service__c.Id, service2)
                            .setField(Merchant_Service__c.Account__c, account2)
                            .setField(Merchant_Service__c.Subscription__c, subs2)
                            .setField(Merchant_Service__c.Order_Product__c, orderItem2)
                            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
                            .setField(Merchant_Service__c.Active__c, 'Yes')
                            .setParent(
                                'Product__r',
                                new Fake(Product2.class)
                                    .setField(Product2.Id, prod2)
                                    .setField(Product2.Platform__c, 'Storefront')
                            )
                    }
                )
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Name, 'account3')
                .setField(Account.Id, account2)
                .setField(Account.Experience__c, 'Storefront')
                .setchildren(
                    'Services__r',
                    new List<Fake>{
                        new Fake(Merchant_Service__c.class)
                            .setField(Merchant_Service__c.Id, service3)
                            .setField(Merchant_Service__c.Account__c, account3)
                            .setField(Merchant_Service__c.Subscription__c, subs3)
                            .setField(Merchant_Service__c.Order_Product__c, orderItem3)
                            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
                            .setField(Merchant_Service__c.Active__c, 'Yes')
                            .setParent(
                                'Product__r',
                                new Fake(Product2.class)
                                    .setField(Product2.Id, prod3)
                                    .setField(Product2.Platform__c, 'Storefront')
                            )
                    }
                )
                .toSObject()
        };

        Set<Id> accountIds = new Set<Id>{ account1, account2, account3 };
        List<Account> accountsToUpdate = new List<Account>{
            new Account(
                Id = account1,
                Experience__c = 'DoorDash',
                Alcohol_Addendum_Signed__c = false
            ),
            new Account(
                Id = account2,
                Experience__c = 'Storefront',
                Alcohol_Addendum_Signed__c = false
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectAccountsWithActiveServices(accountIds))
            .thenReturn(newAccounts);
        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateFieldsOnAccount(accountIds);

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerDirty(accountsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description It is used to check when the approved franchise form requests for Withholding Opt-out received
     * then the method to update the Withholding Opt-out Expiry Date initiated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenApprovedWithholdingOptOutFranchiseFormRequestsReceivedThenWitholdingOptOutExpiryDateStampedOnAssociatedCorporateAccounts() {
        Id corporateAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id franchiseFormRequestId = fflib_IDGenerator.generate(
            Merchant_Pop_Up_Response__c.SObjectType
        );

        Fake merchantPopUpResponseFakeInstance = new Fake(Merchant_Pop_Up_Response__c.class)
            .setField(Merchant_Pop_Up_Response__c.Id, franchiseFormRequestId)
            .setField(Merchant_Pop_Up_Response__c.Approval_Status__c, APPROVED)
            .setField(Merchant_Pop_Up_Response__c.Mx_Corporate_Account__c, corporateAccountId)
            .setField(
                Merchant_Pop_Up_Response__c.Select_the_Franchise_Type__c,
                WITHHOLDING_OPT_OUT
            );
        Merchant_Pop_Up_Response__c testMerchantPopUpResponse = (Merchant_Pop_Up_Response__c) merchantPopUpResponseFakeInstance.toSObject();
        List<Merchant_Pop_Up_Response__c> listMerchantPopUpResponse = new List<Merchant_Pop_Up_Response__c>();
        listMerchantPopUpResponse.add(testMerchantPopUpResponse);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS_STATIC_CONFIG,
                    Configuration_Value__c = WITHHOLDING_OPT_OUT_LIMIT_IN_DAYS
                )
            );
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);

        AccountsService.stampWithholdingExpiryDateOnCorporateAccounts(
            new Set<Id>{ corporateAccountId }
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{ Account.Id => corporateAccountId }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
+   * @description It is used to check when the parent account Owner Id is updated
+   * on the eligible child account.
+   */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountIdsArePassedThenAccountFieldsAreUpdatedWithParentAccountOwnerConditionally() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessOwner = fflib_IDGenerator.generate(User.SObjectType);
        List<Account> childAccounts = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'US Store Account',
                ParentId = parentAccountId,
                RecordTypeId = storeRecordTypeId,
                Franchise_Parent__c = null
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.SObjectType),
                Name = 'AUS Store Account',
                ParentId = parentAccountId,
                RecordTypeId = storeRecordTypeId,
                Franchise_Parent__c = null
            )
        };
        List<Account> parentAccounts = new List<Account>{
            new Account(
                Id = parentAccountId,
                Name = 'Corporate Business Account',
                Type = ACCOUNT_TYPE_CORPORATE,
                RecordTypeId = businessRecordTypeId,
                OwnerId = businessOwner,
                Control_of_Price__c = 'DoorDash',
                Deck_Rank__c = ACCOUNT_DECK_RANK
            )
        };
        Set<Id> parentAccountIds = new Set<Id>{ parentAccounts[0].Id };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IStaticConfigurationsSelector staticConfigurationsMock = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Aggregate mockAccountAggregate = new Aggregate();
        mockAccountAggregate.put(AGGREGATE_ACCOUNTCOUNT_FIELD_ALIAS, 2);
        mockAccountAggregate.put(AGGREGATE_PARENTID_FIELD_ALIAS, parentAccountId);
        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.selectChildAccountsForAccountFieldsTrickleDown(
                    parentAccountIds,
                    Integer.valueOf(TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_QUERY_LIMIT_VALUE)
                )
            )
            .thenReturn(childAccounts);
        mocks.when(
                selectorMock.selectCountOfNonMatchingParentAccountFieldsAccounts(
                    new Set<Id>{ parentAccountId }
                )
            )
            .thenReturn(new List<Aggregate>{ mockAccountAggregate });
        mocks.when(staticConfigurationsMock.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    CHILD_ACCOUNTS_TRICKLE_DOWN_QUERY_LIMIT_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = CHILD_ACCOUNTS_TRICKLE_DOWN_QUERY_LIMIT_STATIC_CONFIG,
                    Configuration_Value__c = TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_QUERY_LIMIT_VALUE
                )
            );
        mocks.when(
                staticConfigurationsMock.getInstanceValue(
                    TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG
                )
            )
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_STATIC_CONFIG,
                    Configuration_Value__c = TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS_PAYLOAD_CHUNK_SIZE_VALUE
                )
            );
        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(staticConfigurationsMock);
        String eventPayload = JSON.serialize(new Set<Id>{ parentAccountId });
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_TRICKLE_DOWN_PARENT_ACCOUNT_FIELDS
        );
        AccountsService.execute(new List<Notifier__e>{ mockNotifierEvent });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 2)).commitWork();
    }

    /**
     * @description To test when active service has product Alcohol Pickup or Alcohol Delivery then Alcohol Addendum Signed is updated on Account
+   * on the eligible child account.
+   */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenActiveServiceHasPlatformThenUpdateAlcoholAddendum() {
        Id service1 = Fake.generateId(Merchant_Service__c.class);
        Id account1 = Fake.generateId(Account.class);
        Id subs1 = Fake.generateId(SBQQ__Subscription__c.class);
        Id orderItem1 = Fake.generateId(OrderItem.class);
        Id prod1 = Fake.generateId(Product2.class);

        Account[] newAccounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, account1)
                .setField(Account.Name, 'account 1')
                .setField(Account.Alcohol_Addendum_Signed__c, false)
                .setchildren(
                    'Services__r',
                    new List<Fake>{
                        new Fake(Merchant_Service__c.class)
                            .setField(Merchant_Service__c.Id, service1)
                            .setField(Merchant_Service__c.Account__c, account1)
                            .setField(Merchant_Service__c.Subscription__c, subs1)
                            .setField(Merchant_Service__c.Order_Product__c, orderItem1)
                            .setField(Merchant_Service__c.Mx_Agreed_to_Product__c, 'Yes')
                            .setField(Merchant_Service__c.Active__c, 'Yes')
                            .setField(Merchant_Service__c.Name, ALCOHOL_PICKUP)
                            .setParent(
                                'Product__r',
                                new Fake(Product2.class)
                                    .setField(Product2.Id, prod1)
                                    .setField(Product2.Platform__c, 'DoorDash')
                                    .setField(Product2.Name, ALCOHOL_PICKUP)
                            )
                    }
                )
                .toSObject()
        };
        Set<Id> accountIds = new Set<Id>{ account1 };
        List<Account> accountsToUpdate = new List<Account>{
            new Account(
                Id = account1,
                Experience__c = 'DoorDash',
                Alcohol_Addendum_Signed__c = true
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectAccountsWithActiveServices(accountIds))
            .thenReturn(newAccounts);
        mocks.stopStubbing();

        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateFieldsOnAccount(accountIds);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, mocks.times(1)))
            .registerDirty(accountsToUpdate);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test franchise accounts are passsed then popualte owner Drive Specialist
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenFranchiseAccountsArePassedThenPopulateOwner() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id parentAccountId = fake.generateId(Account.SObjectType);
        Id franchiseAccountId = fake.generateId(Account.SObjectType);

        Fake parentAccountInstance = new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, 'Account1')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Type, 'Corporate')
            .setChildren(
                'AccountTeamMembers',
                new List<Fake>{
                    new Fake(AccountTeamMember.class)
                        .setField(AccountTeamMember.UserId, userId1)
                        .setField(AccountTeamMember.TeamMemberRole, 'Franchise Representative')
                        .setField(AccountTeamMember.AccountId, parentAccountId)
                        .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
                }
            );

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountInstance
        );

        Account franchiseAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, franchiseAccountId)
            .setField(Account.Name, 'AccountFranchise')
            .setField(Account.Type, 'test')
            .setField(Account.ParentId, parentAccount.Id)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectAccountWithAccTeamMembers(new Set<ID>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.fetchAndPopulateOwnerOnFranchiseAccounts(
            new List<Account>{ franchiseAccount }
        );
    }

    /**
     * @description To test franchise accounts and team member role is not Franchise Representative are passsed.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMethodCalledThenPopulateOwnerOnFranchise() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Business')
            .getRecordTypeId();

        Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
        Id parentAccountId = fake.generateId(Account.SObjectType);
        Id franchiseAccountId = fake.generateId(Account.SObjectType);

        Fake parentAccountInstance = new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, 'Account1')
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, 'SMB')
            .setField(Account.Type, 'Corporate')
            .setChildren(
                'AccountTeamMembers',
                new List<Fake>{
                    new Fake(AccountTeamMember.class)
                        .setField(AccountTeamMember.UserId, userId1)
                        .setField(AccountTeamMember.TeamMemberRole, 'Drive Specialist')
                        .setField(AccountTeamMember.AccountId, parentAccountId)
                        .setField(AccountTeamMember.AccountAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.CaseAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.ContactAccessLevel, 'Read Only')
                        .setField(AccountTeamMember.OpportunityAccessLevel, 'Read Only')
                }
            );

        Account parentAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentAccountInstance
        );

        Account franchiseAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, franchiseAccountId)
            .setField(Account.Name, 'AccountFranchise')
            .setField(Account.Type, 'test')
            .setField(Account.ParentId, parentAccount.Id)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(selectorMock.selectAccountWithAccTeamMembers(new Set<ID>{ parentAccount.Id }))
            .thenReturn(new List<Account>{ parentAccount });

        mocks.stopStubbing();
        Application.Selector.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.fetchAndPopulateOwnerOnFranchiseAccounts(
            new List<Account>{ franchiseAccount }
        );
    }

    /**
     * @description To test when EVENT TOPIC UPDATE OWNER FOR_FRANCHISE BUSINESS AND STOREACCOUNT Notifier event is fired then update franchise
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOwnerUpdateNotifierEventsReceivedThenUpdateFranchise() {
        Id businessAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id businessAccountOwnerId = fflib_IDGenerator.generate(User.SObjectType);

        Account[] newAccounts = new List<Account>{
            new Account(Id = businessAccountId, Name = 'Test 2', OwnerId = businessAccountOwnerId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);
        String accountIdWithOwnerId = newAccounts[0].Id + ':' + newAccounts[0].ownerId;
        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = accountIdWithOwnerId,
            Topic__c = 'UPDATE_OWNER_FOR_FRANCHISE_BUSINESS_AND_STORE_ACCOUNT'
        );
        AccountsService.execute(new List<Notifier__e>{ mockNotifierEvent });
    }

    /**
     * @description This method is used to update the Activation Status on store accounts based on the MDS is_Active flag updates/sync.
     * @jira# LEM-12911
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenAccountStatusChangeThenProcessStoreAccountsMdsActivationStatus() {
        Id storeRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Store')
            .getRecordTypeId();
        Id parentAccountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Account> childAccounts = new List<Account>{
            (Account) new Fake(Account.class)
                .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
                .setField(Account.Name, 'US Store Account')
                .setField(Account.ParentId, parentAccountId)
                .setField(Account.RecordTypeId, storeRecordTypeId)
                .setField(Account.Activation_Status__c, 'Active')
                .toSObject(),
            (Account) new Fake(Account.class)
                .setField(Account.Id, fflib_IDGenerator.generate(Account.SObjectType))
                .setField(Account.Name, 'AUS Store Account')
                .setField(Account.ParentId, parentAccountId)
                .setField(Account.RecordTypeId, storeRecordTypeId)
                .setField(Account.Activation_Status__c, 'Deactivated')
                .toSObject()
        };
        Set<Id> accountIdsTobeActivated = new Set<Id>{ childAccounts[0].Id };
        Set<Id> accountIdsEligibleForDeactivation = new Set<Id>{ childAccounts[1].Id };
        // Set up the mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IAccountsSelector selectorMock = (IAccountsSelector) mocks.mock(IAccountsSelector.class);

        mocks.startStubbing();
        mocks.when(selectorMock.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(
                selectorMock.getStoreAccountsWithValidActiveXrefs(accountIdsEligibleForDeactivation)
            )
            .thenReturn(new List<Account>{ childAccounts[1] });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.UNITOFWORK.setMock(mockUOW);

        AccountsService.processStoreAccountsMdsActivationStatus(
            accountIdsTobeActivated,
            accountIdsEligibleForDeactivation
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test for passed store accounts and rate change request Id, Rate_Change_Request__c field
     * on Account is updated with the same.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenManagePricingIsSubmittedForActiveRatesProvisioningThenCallUpdateRateChangeRequestOnAccount() {
        Id accountId = Fake.generateId(Account.class);
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);

        Account storeAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, 'Parent 1')
            .setField(Account.Type, 'Corporate')
            .setField(Account.Id, accountId)
            .toSObject();

        List<Account> storeAccounts = new List<Account>();
        storeAccounts.add(storeAccount);

        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        Application.UNITOFWORK.setMock(mockUOW);

        Test.startTest();
        AccountsService.updateRateChangeRequestOnAccount(storeAccounts, rateChangeReqId);
        Test.stopTest();

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectsWith(
                    new List<Map<SObjectField, Object>>{
                        new Map<SObjectField, Object>{
                            Account.Id => accountId,
                            Account.Rate_Change_Request__c => rateChangeReqId
                        }
                    }
                )
            );

        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when map of account ids and renewal opportunity passed then renewal
     * opportunity lookup on account is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAccountIdAndRenewalOpportunityMapReceivedThenRenewalOppLookupStampedOnAccount() {
        Id accountToBeUpdatedId = fflib_IDGenerator.generate(Account.SObjectType);
        Map<Id, Opportunity> accountIdToRenewalOpportunity = new Map<Id, Opportunity>();

        Opportunity renewalOpportunity = (Opportunity) new Fake(Opportunity.class)
            .setFakeId()
            .setField(Opportunity.AccountId, accountToBeUpdatedId)
            .toSObject();

        accountIdToRenewalOpportunity.put(accountToBeUpdatedId, renewalOpportunity);
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        AccountsService.updateRenewalOpportunityCreatedFromBatchLookupOnAccount(
            accountIdToRenewalOpportunity
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => accountToBeUpdatedId,
                        Account.Renewal_Opportunity__c => renewalOpportunity.Id
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when list of accounts are passed then renewal opportunity lookup is
     * nullified.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenAccountsReceivedThenRenewalOppLookupNullifiedOnAccount() {
        Account accountToBeUpdated = (Account) new Fake(Account.class)
            .setFakeId()
            .setField(Account.Partnership_Expiration_Date__c, Date.today())
            .toSObject();
        AccountsService.updateRenewalOpportunityOnAccount(new List<Account>{ accountToBeUpdated });
        System.assertEquals(null, accountToBeUpdated.Renewal_Opportunity__c, '');
    }

    /**
     * @description To test when quote id to quote map is passed then partnership level and
     * partnership expiration date are stamped on related account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenMapIdToQuoteReceivedThenPartnershipLevelUpdatedOnAccount() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Account__c = parentAccount.Id,
                SBQQ__Primary__c = true,
                SBQQ__Status__c = 'Contract Signed',
                Contract_Signed_Date__c = Date.today(),
                Initial_Term_and_Termination_Years__c = '2',
                SBQQ__StartDate__c = Date.today(),
                Custom_Partnership_Type__c = 'Exclusive'
            )
        };

        List<Partnership_Level_Mapping__mdt> metaDataRecord = new List<Partnership_Level_Mapping__mdt>{
            new Partnership_Level_Mapping__mdt(
                Label = 'Exclusive',
                DeveloperName = 'Exclusive',
                Custom_Partnership_Type__c = 'Exclusive',
                Partnership_Level__c = 'Exclusive'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IPartnershipLevelMappingSelector partnershipLevelSelectorMock = (IPartnershipLevelMappingSelector) mocks.mock(
            IPartnershipLevelMappingSelector.class
        );
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
        mocks.when(partnershipLevelSelectorMock.sObjectType())
            .thenReturn(Partnership_Level_Mapping__mdt.SObjectType);
        mocks.when(partnershipLevelSelectorMock.getAllValues()).thenReturn(metaDataRecord);
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectPrimaryQuotesBySalesforceAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(quoteList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(partnershipLevelSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Application.UNITOFWORK.setMock(mockUOW);
        Map<Id, SBQQ__Quote__c> mapIdToQuote = new Map<Id, SBQQ__Quote__c>();
        mapIdToQuote.put(quoteList[0].Id, quoteList[0]);
        AccountsService.populatePartnershipLevelOnAccount(mapIdToQuote);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => parentAccount.Id,
                        Account.Partnership_Level__c => quoteList[0].Custom_Partnership_Type__c,
                        Account.Partnership_Expiration_Date__c => quoteList[0]
                            .SBQQ__StartDate__c.addYears(2)
                    }
                )
            );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description To test when empty quote id to quote map is passed then partnership level and
     * partnership expiration date are not stamped on related account.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    public static void testWhenEmptyMapIdToQuoteReceivedThenPartnershipLevelNotUpdatedOnAccount() {
        Id businessRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get(BUSINESS_ACCOUNT_RECORD_TYPE_NAME)
            .getRecordTypeId();
        Id quoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id parentAccountId = Fake.generateId(Account.class);
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Id, parentAccountId)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.RecordTypeID, businessRecordTypeId)
            .setField(Account.Segment__c, ACCOUNT_SEGMENT_SMB)
            .toSObject();

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>{
            new SBQQ__Quote__c(
                Id = quoteId,
                SBQQ__Account__c = parentAccount.Id,
                SBQQ__Primary__c = true,
                SBQQ__Status__c = 'Contract Signed',
                Initial_Term_and_Termination_Years__c = '2',
                SBQQ__StartDate__c = Date.today(),
                Custom_Partnership_Type__c = 'Exclusive'
            )
        };

        List<Partnership_Level_Mapping__mdt> metaDataRecord = new List<Partnership_Level_Mapping__mdt>{
            new Partnership_Level_Mapping__mdt(
                Label = 'Exclusive',
                DeveloperName = 'Exclusive',
                Custom_Partnership_Type__c = 'Exclusive',
                Partnership_Level__c = 'Exclusive'
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IPartnershipLevelMappingSelector partnershipLevelSelectorMock = (IPartnershipLevelMappingSelector) mocks.mock(
            IPartnershipLevelMappingSelector.class
        );
        IQuotesSelector quotesSelectorMock = (IQuotesSelector) mocks.mock(IQuotesSelector.class);

        mocks.startStubbing();
        mocks.when(partnershipLevelSelectorMock.sObjectType())
            .thenReturn(Partnership_Level_Mapping__mdt.SObjectType);
        mocks.when(partnershipLevelSelectorMock.getAllValues()).thenReturn(metaDataRecord);
        mocks.when(quotesSelectorMock.sObjectType()).thenReturn(SBQQ__Quote__c.SObjectType);
        mocks.when(
                quotesSelectorMock.selectPrimaryQuotesBySalesforceAccountIds(
                    new Set<Id>{ parentAccount.Id }
                )
            )
            .thenReturn(quoteList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(partnershipLevelSelectorMock);
        Application.SELECTOR.setMock(quotesSelectorMock);
        Map<Id, SBQQ__Quote__c> mapIdToQuote = new Map<Id, SBQQ__Quote__c>();
        AccountsService.populatePartnershipLevelOnAccount(mapIdToQuote);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 0)).commitWork();
    }
}