/**
 * @author CriticalRiver
 * @date 06/26/2022
 * @description Test class for RemoveStoresOnWorkOrderServiceImpl class.
 */
@isTest(seeAllData=false)
private class RemoveStoresOnWorkOrderServiceImplTest {
    private static final String ACCOUNT_DATA_VERIFICATION_STATUS = 'Verified';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACTIVATE_CONTRALLY = 'Yes';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_RECORD_TYPE_NAME_STORE = 'Store';
    private static final string ACCOUNT_STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_STORE)
        .getRecordTypeId();
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String ASSERT_MESSAGE_ERROR_MESSAGE_DO_NOT_MATCH = 'Unexpected result: the expected error message is not returned';
    private static final String BUNDLED_WITH_MARKETPLACE_YES = 'Yes';
    private static final String DEAD_STATUS = 'Dead';
    private static final String DELIMITER = ',';
    private static final String DISALLOW_PDOX_OVERRIDE_NO = 'No';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final String PROVISIONING_STATUS_NOT_STARTED = 'Not Started';
    private static final String STATUS_PLANNING = 'Planning';
    private static final string STORE_ACCOUNT_NAME = 'Test Account';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String TYPE_STOREFRONT = 'Storefront';
    private static final Set<String> WORK_ORDER_TYPES = new Set<String>{
        TYPE_MARKETPLACE,
        TYPE_STOREFRONT
    };
    private static final string XREF_EXTERNAL_ID = '12345';
    private static final string XREF_EXTERNAL_ID_SOURCE = 'Drive';
    private static final String XREF_STATUS_ACTIVE = 'Active';


    /**
     * @description To test child Work Order status set to Dead for stores when
     * selected store Ids are received from the Remove Stores component controller.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectedStoreIdsReceivedThenChildWorkOrderMarkedAsDead() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
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
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, selectedStoreId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake childparentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId,parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childparentWorkOrderInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(new Set<Id>{parentWorkOrderId},new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Test.startTest();
        RemoveStoresOnWorkOrderService.removeStores(parentWorkOrderId, selectedStoreId,true,null);
		Test.stopTest();
        ((IWorkOrdersSelector) mocks.verify(mockWorkOrdersSelector, 1))
            .selectChildWorkOrdersByStoreAccountIds(new Set<Id>{parentWorkOrderId},new Set<Id>{ selectedStoreId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => childWorkOrder.Id,
                            WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_NOT_STARTED,
                            WorkOrder.Status => DEAD_STATUS
                    }
                )
            );
    }

    /**
     * @description To test child Work Order are moved to a new parent Work
     * when selected store Ids are received from the Remove Stores component controller.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectedStoreIdsReceivedThenChildWorkOrderMovedToNewParentWorkOrder() {
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(parentWorkOrderInstance);
		WorkPlan parentWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            		ServiceMockDataBuilder.createWorkPlanFakeInstance(parentWorkOrder.Id)
        );

        WorkStep parentWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            		ServiceMockDataBuilder.createWorkStepFakeInstance(parentWorkOrder.Id, parentWorkPlan.Id)
        );

        Fake parentWorkstepDependencyInstance = new Fake(WorkStepDependency__c.class)
            .setField(WorkStepDependency__c.Dependent_Work_Step__c, parentWorkStep.Id)
            .setFakeId();
        WorkStepDependency__c parentWorkStepDependency = (WorkStepDependency__c) ServiceMockDataBuilder.convertToSObject(parentWorkstepDependencyInstance);

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Disallow_PDOA_Override__c, DISALLOW_PDOX_OVERRIDE_NO)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7)
            .setChildren(
                'Xrefs__r',
                new List<Fake>{
                    new Fake(Xref__c.class)
                        .setField(Xref__c.Id, xrefId)
                        .setField(Xref__c.External_ID__c, XREF_EXTERNAL_ID)
                        .setField(Xref__c.External_ID_Source__c, XREF_EXTERNAL_ID_SOURCE)
                        .setField(Xref__c.Salesforce_Account_Name__c, selectedStoreId)
                        .setField(Xref__c.Xref_Status__c, XREF_STATUS_ACTIVE)
                }
            );
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(storeAccountFakeInstance);
        Fake childparentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId,parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(childparentWorkOrderInstance);
		WorkPlan childWorkPlan = (WorkPlan) ServiceMockDataBuilder.convertToSObject(
            		ServiceMockDataBuilder.createWorkPlanFakeInstance(childWorkOrder.Id)
        );

        WorkStep childWorkStep = (WorkStep) ServiceMockDataBuilder.convertToSObject(
            		ServiceMockDataBuilder.createWorkStepFakeInstance(childWorkOrder.Id, childWorkPlan.Id)
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(IAccountsSelector.class);
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(IWorkOrdersSelector.class);
        IWorkPlansSelector mockWorkPlansSelector = (IWorkPlansSelector) mocks.mock(IWorkPlansSelector.class);
        IWorkStepsSelector mockWorkStepsSelector = (IWorkStepsSelector) mocks.mock(IWorkStepsSelector.class);
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(IWorkStepsService.class);
        IWorkStepDependenciesSelector mockWorkStepDependenciesSelector = (IWorkStepDependenciesSelector) mocks.mock(IWorkStepDependenciesSelector.class);

        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        Application.UNITOFWORK.setMock(uowMock);

        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ parentBusinessAccount.Id }))
            .thenReturn(new List<Account>{ parentBusinessAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId})).thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(new Set<Id>{parentWorkOrderId},new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.when(mockWorkPlansSelector.SObjectType()).thenReturn(WorkPlan.SObjectType);
        mocks.when(mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(new List<WorkPlan>{ parentWorkPlan });
        mocks.when(mockWorkPlansSelector.selectWorkPlansByWorkOrderIds(new Set<Id>{ childWorkOrderId }))
            .thenReturn(new List<WorkPlan>{ childWorkPlan });
        mocks.when(mockWorkStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(mockWorkStepsSelector.selectWorkStepsAllFieldsByWorkOrderIds(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(new List<WorkStep>{ parentWorkStep });
        mocks.when(mockWorkStepsSelector.selectWorkStepsAllFieldsByWorkOrderIds(new Set<Id>{ childWorkOrderId }))
            .thenReturn(new List<WorkStep>{ childWorkStep });
        mocks.when(mockWorkStepDependenciesSelector.SObjectType()).thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(mockWorkStepDependenciesSelector.selectDependenciesByWorkOrderIds(new Set<Id>{ parentWorkOrderId }))
            .thenReturn(new List<WorkStepDependency__c>{ parentWorkStepDependency });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SELECTOR.setMock(mockWorkPlansSelector);
        Application.SELECTOR.setMock(mockWorkStepsSelector);
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
		Test.startTest();
        RemoveStoresOnWorkOrderService.removeStores(parentWorkOrderId, selectedStoreId,false,System.today()+25);
        Test.stopTest();
        ((IWorkStepsSelector) mocks.verify(mockWorkStepsSelector, 1))
            .selectWorkStepsAllFieldsByWorkOrderIds(new Set<Id>{ parentWorkOrderId });
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Account.Id => selectedStoreId,
                        Account.Proposed_Date_of_Activation__c => System.today()+25
                    }
                )
            );
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 1))
            .runWorkStepStatusCalculationsOnParentRecords((Set<Id>) fflib_Match.anyObject());
    }

    /**
     * @description To test Work Step status roll up is triggered when
     * selected store Ids are received from the Remove Stores component controller
     * and Work Steps exist.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectedStoreIdsReceivedAndWorkStepExistThenTriggerWorkStepStatusRollUp() {
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(parentWorkOrderInstance);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake childparentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childparentWorkOrderInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId})).thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderId },
                    new Set<Id>{ selectedStoreId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Test.startTest();
        RemoveStoresOnWorkOrderService.removeStores(parentWorkOrderId, selectedStoreId, false, System.today()+25);
        Test.stopTest();
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 1))
            .runWorkStepStatusCalculationsOnParentRecords((Set<Id>) fflib_Match.anyObject());
    }

    /**
     * @description To test Work Order status roll up is triggered when
     * selected store Ids are received from the Remove Stores component controller
     * and Work Steps do not exist.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectedStoreIdsReceivedAndWorkStepNotExistThenTriggerWorkOrderStatusRollUp() {
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake parentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder parentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(parentWorkOrderInstance);
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7);
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstance
        );
        Fake childparentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
            .setParent('Account', storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childparentWorkOrderInstance
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersService workOrdersServiceMock = (IWorkOrdersService) mocks.mock(
            IWorkOrdersService.class
        );
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<Account>{ storeAccount });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{parentWorkOrderId})).thenReturn(new List<WorkOrder>{ parentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ parentWorkOrderId },
                    new Set<Id>{ selectedStoreId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrder });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkOrdersService.class, workOrdersServiceMock);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Test.startTest();
        RemoveStoresOnWorkOrderService.removeStores(parentWorkOrderId, selectedStoreId, false, System.today()+25);
        Test.stopTest();
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 1))
            .runWorkStepStatusCalculationsOnParentRecords((Set<Id>) fflib_Match.anyObject());
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Status => STATUS_PLANNING
                    }
                )
        );
    }

    /**
     * @description To test Work Step status roll up is triggered when
     * selected store Ids are received from the Remove Stores component controller
     * and Work Steps exists on both, original and new parent work order.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenSelectedStoreIdsReceivedAndWorkStepExistThenTriggerWorkStepStatusRollUpOnOriginalAndNewWorkOrder() {
        Id childWorkOrderIdToRemove = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderIdToKeep = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id originalParentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id retainedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake originalParentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, originalParentWorkOrderId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder originalParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(originalParentWorkOrderInstance);
        Fake storeAccountFakeInstanceToRemove = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7);
        Account storeAccountToRemove = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstanceToRemove
        );
        Fake storeAccountFakeInstanceToKeep = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, retainedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7);
        Account storeAccountToKeep = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstanceToKeep
        );
        Fake childWorkOrderInstanceToRemove = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountToRemove.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderIdToRemove)
            .setField(WorkOrder.ParentWorkOrderId, originalParentWorkOrderId)
            .setParent('Account', storeAccountFakeInstanceToRemove);
        WorkOrder childWorkOrderToRemove = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderInstanceToRemove
        );
        Fake childWorkOrderInstanceToKeep = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountToKeep.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderIdToKeep)
            .setField(WorkOrder.ParentWorkOrderId, originalParentWorkOrderId)
            .setParent('Account', storeAccountFakeInstanceToKeep);
        WorkOrder childWorkOrderToKeep = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderInstanceToKeep
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<Account>{ storeAccountToRemove });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{originalParentWorkOrderId})).thenReturn(new List<WorkOrder>{ originalParentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ originalParentWorkOrderId },
                    new Set<Id>{ selectedStoreId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrderToRemove });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ originalParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrderToKeep });
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Test.startTest();
        RemoveStoresOnWorkOrderService.removeStores(originalParentWorkOrderId, selectedStoreId, false, System.today()+25);
        Test.stopTest();
        ((IWorkStepsService) mocks.verify(workStepsServiceMock, 2))
            .runWorkStepStatusCalculationsOnParentRecords((Set<Id>) fflib_Match.anyObject());
    }

    /**
     * @description To test when no stores are retained on the original parent work order then the
     * original parent work order is updated.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenNoStoresRetainedOnOriginalParentWorkOrderThenOriginalParentWorkOrderUpdated() {
        Id childWorkOrderIdToRemove = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id originalParentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
        Fake originalParentWorkOrderInstance = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                parentBusinessAccount.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, originalParentWorkOrderId)
            .setParent('Account', parentBusinessAccountFakeInstance);
        WorkOrder originalParentWorkOrder = (WorkOrder) ServiceMockDataBuilder.convertToSObject(originalParentWorkOrderInstance);
        Fake storeAccountFakeInstanceToRemove = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CONTRALLY)
            .setField(Account.Address_Verification_Status__c, ADDRESS_VERIFICATION_STATUS)
            .setField(Account.Coverage__c, IN_COVERAGE)
            .setField(Account.Id, selectedStoreId)
            .setField(Account.Proposed_Date_of_Activation__c, System.today() + 7);
        Account storeAccountToRemove = (Account) ServiceMockDataBuilder.convertToSObject(
            storeAccountFakeInstanceToRemove
        );

        Fake childWorkOrderInstanceToRemove = ServiceMockDataBuilder.createWorkOrderFakeInstance(
                storeAccountToRemove.Id,
                TYPE_MARKETPLACE
            )
            .setField(WorkOrder.Id, childWorkOrderIdToRemove)
            .setField(WorkOrder.ParentWorkOrderId, originalParentWorkOrderId)
            .setParent('Account', storeAccountFakeInstanceToRemove);
        WorkOrder childWorkOrderToRemove = (WorkOrder) ServiceMockDataBuilder.convertToSObject(
            childWorkOrderInstanceToRemove
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountsSelector mockAccountsSelector = (IAccountsSelector) mocks.mock(
            IAccountsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkStepsService workStepsServiceMock = (IWorkStepsService) mocks.mock(
            IWorkStepsService.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountsSelector.SObjectType()).thenReturn(Account.SObjectType);
        mocks.when(mockAccountsSelector.selectById(new Set<Id>{ selectedStoreId }))
            .thenReturn(new List<Account>{ storeAccountToRemove });
        mocks.when(mockWorkOrdersSelector.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(mockWorkOrdersSelector.selectById(new Set<Id>{originalParentWorkOrderId})).thenReturn(new List<WorkOrder>{ originalParentWorkOrder });
        mocks.when(
                mockWorkOrdersSelector.selectChildWorkOrdersByStoreAccountIds(
                    new Set<Id>{ originalParentWorkOrderId },
                    new Set<Id>{ selectedStoreId }
                )
            )
            .thenReturn(new List<WorkOrder>{ childWorkOrderToRemove });
        mocks.when(
                mockWorkOrdersSelector.selectByParentWorkOrderIds(
                    new Set<Id>{ originalParentWorkOrderId }
                )
            )
            .thenReturn(new List<WorkOrder>());
        mocks.stopStubbing();
        Application.UNITOFWORK.setMock(mockUOW);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.SERVICE.setMock(IWorkStepsService.class, workStepsServiceMock);
        Test.startTest();
        RemoveStoresOnWorkOrderService.removeStores(originalParentWorkOrderId, selectedStoreId, false, System.today()+25);
        Test.stopTest();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 3)).commitWork();
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkOrder.Id => originalParentWorkOrderId,
                        WorkOrder.Provisioning_Status__c => PROVISIONING_STATUS_NOT_STARTED
                    }
                )
            );
    }

}
