/**
 * @author DoorDash
 * @date 03/22/2023
 * @description Test class for CooWorkOrderService class.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class CooWorkOrderServiceImplTest {
    private static final String IR_BATCH_ID = 'Batch001';
    private static final String IR_STATUS_PENDING= 'Pending';
    private static final String IR_PRODUCT_STATUS_CREATED= 'created';
    private static final String IR_PRODUCT_STATUS_CANCELLED= 'cancelled';
    private static final String IR_PRODUCT_STATUS_COMPLETED= 'completed';
    private static final Set<String> WO_OPEN_STATUS = new Set<String>{'Planning', 'Confirmed', 'In Progress', 'At Risk', 'Past Due', 'Not Started'};
    private static final Set<String> TYPE_COO = new Set<String>{'COO'};
    private static final Set<String> WS_TYPE_COO_SAME_STORE =  new Set<String>{'COO Same Store'};
    private static final String MENU_COMPLETED_BY_DOORDASH_ONBOARDING_TEAM = 'DoorDash Onboarding Team';
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ADDRESS_VERIFICATION_STATUS = 'Verified';
    private static final String IN_COVERAGE = 'In Coverage';
    private static final string XREF_EXTERNAL_ID = '12345';
    private static final string XREF_EXTERNAL_ID_SOURCE = 'Drive';
    private static final String XREF_STATUS_ACTIVE = 'Active';
    private static final Set<String> WORK_STEP_TYPE_POS = new Set<String>{'Complete pre-work', 'Configure POS', 'Ingest Menu', 'QA Menu', 'Enable Integration' };
	private static final String ACTIVATE_CENTRALLY = 'Yes';

    @isTest
    private static void testWhenNewCooReqReceivedNoParentWorkOrderThenCreateWorkOrder() {
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            Account__C = fflib_IDGenerator.generate(Account.SObjectType),
            Activation_Date__c = System.Today() + 10
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Map<String, Id> batchIdToOppId = new Map<String, Id>();
        batchIdToOppId.put(IR_BATCH_ID, opportunityId);
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        Set<Id> oppIDSet = new Set<Id>{opportunityId};
        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks(); // step 1
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
         mocks.when(
                mockWorkOrdersSelector.selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
                    WO_OPEN_STATUS,TYPE_COO,WS_TYPE_COO_SAME_STORE, oppIDSet ,batchIds
                )
            )
            .thenReturn(new List<WorkOrder>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(uowMock);
        CooWorkOrderServiceImpl cooWOService = new CooWorkOrderServiceImpl();
        cooWOService.createUpdateParentWorkOrder(intReqByBatch, batchIdToOppId);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }
    @isTest
    private static void testWhenNewCooReqReceivedParentWorkOrderExistsThenUpdateWorkOrder() {
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CREATED,
            Account__C = fflib_IDGenerator.generate(Account.SObjectType),
            Activation_Date__c = System.Today() + 10
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };

        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity opportunity = new Opportunity(
            Id = opportunityId,
            Batch_Id__c = IR_BATCH_ID
        );

        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);

         WorkOrder parentWorkOrder = new WorkOrder(
            Id = workOrderId,
            Opportunity__r = opportunity,
            Proposed_Date_of_Activation__c = System.Today() + 10,
            Menu_to_be_Completed_By__c  = MENU_COMPLETED_BY_DOORDASH_ONBOARDING_TEAM
        );
        Map<String, Id> batchIdToOppId = new Map<String, Id>();
        batchIdToOppId.put(IR_BATCH_ID, opportunityId);
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        Set<Id> oppIDSet = new Set<Id>{opportunityId};
        // Set up mocks
        fflib_ApexMocks mocks = new fflib_ApexMocks(); // step 1
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
         mocks.when(
                mockWorkOrdersSelector.selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
                    WO_OPEN_STATUS,TYPE_COO,WS_TYPE_COO_SAME_STORE, oppIDSet ,batchIds
                )
            )
            .thenReturn(new List<WorkOrder>{parentWorkOrder});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(uowMock);
        CooWorkOrderServiceImpl cooWOService = new CooWorkOrderServiceImpl();
        cooWOService.createUpdateParentWorkOrder(intReqByBatch, batchIdToOppId);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

     @isTest
    private static void testWhenCompleteCooReqReceivedThenCompleteTheWorkOrder() {
         Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity opportunity = new Opportunity(
            Id = opportunityId,
            Batch_Id__c = IR_BATCH_ID
        );
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);

        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
         WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
             .setField(WorkOrder.Sub_Type__c, 'COO Same Store')
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, parentWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, null)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();
        parentWorkOrder.Opportunity__r = opportunity;
        parentWorkOrder.Opportunity__c = opportunityId;

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
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
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(storeAccountFakeInstance);
        Set<Id> storeAccountIds = new Set<Id>{storeAccount.Id};
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId,parentWorkOrderId )
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
            .setField(WorkOrder.Sub_Type__c, 'COO Same Store')

            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, childWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, childWorkOrderId)
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, childWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();

        List <WorkStep> childWorkStepList = new List<WorkStep>();
        childWorkStepList.add(childWorkOrder.WorkSteps);
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_COMPLETED,
            Account__C = storeAccount.Id,
            Activation_Date__c = System.Today() + 10
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

         IWorkStepsSelector workStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        mocks.startStubbing();

        mocks.when(workStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelector.selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(
                    storeAccountIds, WS_TYPE_COO_SAME_STORE, batchIds
                )
            )
            .thenReturn(childWorkStepList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelector);
        Application.UnitOfWork.setMock(uowMock);
        CooWorkOrderServiceImpl cooWOService = new CooWorkOrderServiceImpl();
        cooWOService.updateWorkOrderToComplete(intReqByBatch);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

     @isTest
    private static void testWhenCancelledCooReqReceivedThenDeadTheParentWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity opportunity = new Opportunity(
            Id = opportunityId,
            Batch_Id__c = IR_BATCH_ID
        );
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);

        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );
         WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
             .setField(WorkOrder.Sub_Type__c, 'COO Same Store')
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, parentWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, null)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();
        parentWorkOrder.Opportunity__r = opportunity;
        parentWorkOrder.Opportunity__c = opportunityId;
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
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
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(storeAccountFakeInstance);
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId,parentWorkOrderId )
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
            .setField(WorkOrder.Sub_Type__c, 'COO Same Store')

            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, childWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, childWorkOrderId)
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, childWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();

        List <WorkStep> childWorkStepList = new List<WorkStep>();
        childWorkStepList.add(childWorkOrder.WorkSteps);
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{};
        Map<String, Id> batchIdToOppId = new Map<String, Id>();
        batchIdToOppId.put(IR_BATCH_ID, opportunityId);
        Set<Id> oppIDSet = new Set<Id>{opportunityId};

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

         IWorkStepsSelector workStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
                    WO_OPEN_STATUS,TYPE_COO,WS_TYPE_COO_SAME_STORE, oppIDSet ,batchIds
                )
            )
            .thenReturn(new List<WorkOrder>{parentWorkOrder});

        mocks.when(workStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelector.selectAllChildWorkStepsByParentWorkOrderID(
                    new Set<Id>{parentWorkOrderId}
                )
            )
            .thenReturn(childWorkStepList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(uowMock);
        CooWorkOrderServiceImpl cooWOService = new CooWorkOrderServiceImpl();
        cooWOService.updateWorkOrderToDead(intReqByBatch,batchIdToOppId );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

     @isTest
    private static void testWhenCancelledCooReqReceivedThenDeadtheStoreWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity opportunity = new Opportunity(
            Id = opportunityId,
            Batch_Id__c = IR_BATCH_ID
        );
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);

        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );

         WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
             .setField(WorkOrder.Sub_Type__c, 'COO Same Store')
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, parentWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, null)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();
        parentWorkOrder.Opportunity__r = opportunity;
        parentWorkOrder.Opportunity__c = opportunityId;
        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
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
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(storeAccountFakeInstance);
        Set<Id> storeAccountIds = new Set<Id>{storeAccount.Id};
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId,parentWorkOrderId )
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
            .setField(WorkOrder.Sub_Type__c, 'COO Same Store')

            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, childWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, childWorkOrderId)
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, childWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();
        List <WorkStep> childWorkStepList = new List<WorkStep>();
        childWorkStepList.add(childWorkOrder.WorkSteps);
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CANCELLED,
            Account__C = storeAccount.Id,
            Activation_Date__c = System.Today() + 10
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };
        Map<String, Id> batchIdToOppId = new Map<String, Id>();
        Set<Id> oppIDSet = new Set<Id>{opportunityId};
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

         IWorkStepsSelector workStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
                    WO_OPEN_STATUS,TYPE_COO,WS_TYPE_COO_SAME_STORE, oppIDSet ,batchIds
                )
            )
            .thenReturn(new List<WorkOrder>{parentWorkOrder});

        mocks.when(workStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelector.selectChildWorkStepsByStoreAccountIdsAndBatchId(
                    storeAccountIds  ,batchIds
                )
            )
            .thenReturn(childWorkStepList);

        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(uowMock);
        CooWorkOrderServiceImpl cooWOService = new CooWorkOrderServiceImpl();
        cooWOService.updateWorkOrderToDead(intReqByBatch,batchIdToOppId );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).commitWork();
    }

     @isTest
    private static void testWhenReadyCooReqReceivedThenReEvaluateWorkOrder() {
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Opportunity opportunity = new Opportunity(
            Id = opportunityId,
            Batch_Id__c = IR_BATCH_ID
        );
        Set<String> batchIds = new Set<String>{IR_BATCH_ID};
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id childWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id childWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);

        Id selectedStoreId = fflib_IDGenerator.generate(Account.SObjectType);
        Id xrefId = fflib_IDGenerator.generate(Xref__c.SObjectType);
        Fake parentBusinessAccountFakeInstance = ServiceMockDataBuilder.createAccountFakeInstance(
            ACCOUNT_PRIMARY_VERTICAL,
            ACCOUNT_RECORD_TYPE_NAME_BUSINESS
        );
        Account parentBusinessAccount = (Account) ServiceMockDataBuilder.convertToSObject(
            parentBusinessAccountFakeInstance
        );

         WorkOrder parentWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, parentWorkOrderId)
            .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId, null)
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
             .setField(WorkOrder.Sub_Type__c, 'COO Same Store')
            .setField(WorkOrder.Opportunity__c, opportunityId)
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, parentWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, parentWorkOrderId)
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, parentWorkOrderId)
                                .setField(WorkOrder.AccountId, parentBusinessAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, null)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();
        parentWorkOrder.Opportunity__r = opportunity;
        parentWorkOrder.Opportunity__c = opportunityId;

        Fake storeAccountFakeInstance = ServiceMockDataBuilder.createStoreAccountRecordWithProvidedPrimaryVerticalValue(
                parentBusinessAccount.Id,
                ACCOUNT_PRIMARY_VERTICAL
            )
            .setField(Account.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
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
        Account storeAccount = (Account) ServiceMockDataBuilder.convertToSObject(storeAccountFakeInstance);
        storeAccount.Order_Protocol__c = 'POS';
        Set<Id> storeAccountIds = new Set<Id>{storeAccount.Id};
        WorkOrder childWorkOrder = (WorkOrder) new Fake(WorkOrder.class)
            .setField(WorkOrder.Id, childWorkOrderId)
            .setField(WorkOrder.AccountId, storeAccount.Id)
            .setField(WorkOrder.ParentWorkOrderId,parentWorkOrderId )
            .setField(WorkOrder.Status, 'Confirmed')
            .setField(WorkOrder.Type__c, 'COO')
            .setField(WorkOrder.Sub_Type__c, 'COO Same Store')
            .setChildren(
                'WorkSteps',
                new List<Fake>{
                    new Fake(WorkStep.class)
                        .setField(WorkStep.Id, childWorkStepId)
                        .setField(WorkStep.Name, 'COO Same Store')
                        .setField(WorkStep.WorkOrderId, childWorkOrderId)
                        .setField(WorkStep.Status, 'Not Started')
                        .setField(WorkStep.Type__c, 'COO Same Store')
                        .setParent(
                            'WorkOrder',
                            new Fake(WorkOrder.class)
                                .setField(WorkOrder.Id, childWorkOrderId)
                                .setField(WorkOrder.AccountId, storeAccount.Id)
                                .setField(WorkOrder.ParentWorkOrderId, parentWorkOrderId)
                                .setField(WorkOrder.Status, 'Planning')
                                .setField(WorkOrder.Type__c, 'COO')
                        )
                }
            )
            .toSObject();
        List <WorkStep> childWorkStepList = new List<WorkStep>();
        childWorkStepList.add(childWorkOrder.WorkSteps);

        Integration_Request__c parentIntReq = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            opportunity__c = opportunityId,
            opportunity__r = opportunity,
            Batch_Id__c = IR_BATCH_ID
        );
        Integration_Request__c integrationRequest1 = new Integration_Request__c(
            Id = fflib_IDGenerator.generate(Integration_Request__c.SObjectType),
            sfdc_status__c = IR_STATUS_PENDING,
            Batch_Id__c = IR_BATCH_ID,
            Product_status__c = IR_PRODUCT_STATUS_CANCELLED,
            Account__C = storeAccount.Id,
            Account__r = storeAccount,
            Activation_Date__c = System.Today() + 10,
            payload__c = mockPayloadData(),
            Parent_Integration_Request__r =  parentIntReq
        );
        List<Integration_Request__c> intReqByBatch = new List<Integration_Request__c>{
            integrationRequest1
        };
        Set<Id> oppIDSet = new Set<Id>{opportunityId};
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = (fflib_ISObjectUnitOfWork) mocks.mock(fflib_ISObjectUnitOfWork.class);

         IWorkStepsSelector workStepsSelector = (IWorkStepsSelector) mocks.mock(
            IWorkStepsSelector.class
        );
        IWorkOrdersSelector mockWorkOrdersSelector = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkOrdersSelector.SObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(
                mockWorkOrdersSelector.selectWorkOrderByStatusAndTypeAndSubTypeAndOppIDAndBatchID(
                    WO_OPEN_STATUS,TYPE_COO,WS_TYPE_COO_SAME_STORE, oppIDSet ,batchIds
                )
            )
            .thenReturn(new List<WorkOrder>{parentWorkOrder});
        mocks.when(workStepsSelector.SObjectType()).thenReturn(WorkStep.SObjectType);
        mocks.when(
                workStepsSelector.selectChildWorkStepsByStoreAccountIdsAndBatchId(
                    new Set<id>{storeAccount.Id}  ,batchIds
                )
            )
            .thenReturn(childWorkStepList);
        mocks.when(
                workStepsSelector.selectChildWorkStepsByStoreAccountIdsAndTypeAndBatchId(
                    storeAccountIds, WORK_STEP_TYPE_POS, batchIds
                )
            )
            .thenReturn(new List<WorkStep>{});
        mocks.when(
                workStepsSelector.selectChildWorkStepsByStoreAccountIdsAndType(
                    storeAccountIds, WORK_STEP_TYPE_POS
                )
            )
            .thenReturn(new List<WorkStep>{});
         mocks.when(
                mockWorkOrdersSelector.selectParentAndChildrenByIds(
                    new Set<ID> {parentWorkOrderId}
                )
            )
            .thenReturn(new List<WorkOrder>{parentWorkOrder});

        mocks.stopStubbing();
        Application.SELECTOR.setMock(workStepsSelector);
        Application.SELECTOR.setMock(mockWorkOrdersSelector);
        Application.UnitOfWork.setMock(uowMock);
        CooWorkOrderServiceImpl cooWOService = new CooWorkOrderServiceImpl();
        cooWOService.processPosIntRequestOnReadyEvent(intReqByBatch);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 2)).commitWork();
    }

     /**
     * @description Creates a mock coo payload
     * @return  A json payload.
     */
    public static String mockPayloadData(){
        return '{' +
            '"coo_event_type": "COO Event",' +
            '"changeOfownershipStrategy": "Change Ownership Strategy",' +
            '"storeChangeOfOwnershipOnboarding": {' +
            '"onboarding_id": "Onboarding001",' +
            '"business_id": "Business001",' +
            '"legal_business_name": "Test Business",' +
            '"store_id": "Store001",' +
            '"store_name": "Test Store",' +
            '"scheduled_cutoff_time": "2023-05-30 09:00:00",' +
            '"new_owner_first_name": "John",' +
            '"new_owner_last_name": "Doe",' +
            '"new_owner_email": "john.doe@example.com",' +
            '"new_owner_phone": "1234567890",' +
            '"requester_user_id": "User001",' +
            '"new_user_id": "User002",' +
            '"old_user_id": "User003",' +
            '"revoke_access": false,' +
            '"create_new_business": true,' +
            '"approved_at": "2023-05-30 10:00:00",' +
            '"approval_status": "",'+
            '"onboarding_status": "",'+
            '"payment_account_id": "Account001",' +
            '"pactsafe_activity_id": "Activity001",' +
            '"batch_request_id": "Batch001",' +
            '"additionalfields": {' +
            '"notes": "Test notes",' +
            '"order_protocol": "POS",' +
            '"pos_provider_type": "",' +
            '"pos_provider_type_str": "Cake",' +
            '"is_franchise": false,' +
            '"should_ship_tablet": true,' +
            '"legal_business_address": {' +
            '"street": "123 Main St",' +
            '"city": "Test City",' +
            '"postal_code": "12345",' +
            '"country": "US",' +
            '"state": "TX",' +
            '"owner_phone": "1234567890"' +
            '}' +
            '},' +
            '"new_user": [' +
            '{"email": "newuser@example.com",' +
            '"first_name": "James",' +
            '"last_name": "two",' +
            '"phone": "9876543210",' +
            '"SSN": "123-45-6789"}'+
            '],'+
            '"business_address_id": "Address001",' +
            '"geo_address": {'+
            '"street": "12006 corsicana",'+
            '"city": "Manor",'+
            '"zipCode": "78653",'+
            '"countryShortname": "US",'+
            '"administrativeAreaLevel1": "TX"'+
            '}'+
            '}' +
            '}';
   }
}