/**
 * @author Deloitte
 * @date 03/22/2023
 * @description Test class for FigmentToDdmxSyncService class.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
private class FigmentToDdmxSyncServiceImplTest {
    private static final String TEST_MESSAGE = 'HTTP:TIMEOUT';
    private static final String INTEGRATION_TYPE = 'Tablet Case Sync';
    private static final String BUSINESS_FRIENDLY_MAPPING_LABEL = 'Http Timeout';
    private static final String BUSINESS_FRIENDLY_MESSAGE = 'Process Timeout - Reattempting Submission';
    private static final String EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS = 'UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS';
    private static final String STORE_ID = '24680';
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_PRIMARY_VERTICAL_GIFTS = 'Gifts';
    private static final String TYPE_POS = 'POS';
    private static final String INTEGRATION_ID = '112223344';
    private static final String WORK_STEP_TYPE = 'Deliver Tablet';
    private static final String WORKSTEP_STATUS = 'Not Started';
    private static final String STAGE = 'In Progress';
    private static final String SFDC_STATUS = 'Processed';
    private static final String DML_EXCEPTION_MESSAGE = 'Exception occurred while performing DML operation';
    private static final String UNEXPECTED_DML_EXCEPTION_MESSAGE = 'Unexpected Error: The Exception fired was not a TestCommitException.';
    private static final String ACCOUNT_ACTIVATION_STATUS_ACTIVE = 'Active';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String STATUS_NOT_STARTED = 'Not Started';
    public static final String STATUS_SUCCESS = 'Success';
    public static final String EXTERNAL_ID_SOURCE_DRIVE_DB = 'DriveDb';
    public static final String LAST_COMPLETED_CONFIGURATION_CREATED = 'Business Configuration Created';
    private static final String WORKORDER_TYPE = 'Marketplace';
    private static final String ACTIVATE_CENTRALLY = 'Yes';
    private static final String WORKSTEP_NAME = 'Deliver Tablet';
    private static final string ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACCOUNT_PRIMARY_VERTICAL_PREMIUM = 'Grocery';
    private static final String ACCOUNT_NAME_BUSINESS = 'Business Account';
    private static final String WORK_PLAN_NAME = 'Tablet';

    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssMethodCount')
    private static void testWhenIntegrationRequestReceviedThenUpdateWorkStepAndIntReq() {
        Id parentOpportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id parentWorkOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id parentWorkPlanId = fflib_IDGenerator.generate(WorkPlan.SObjectType);
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id businessReferenceId = fflib_IDGenerator.generate(Business_Reference__c.SObjectType);
        Id integrationRequestId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);

        Account parentAccount = createParentAccountFake(
            parentWorkOrderId,
            parentOpportunityId,
            parentWorkPlanId,
            workStepId,
            businessReferenceId
        );

        Integration_Request__c mockIntegrationRequest = (Integration_Request__c) new Fake(
                Integration_Request__c.class
            )
            .setField(Integration_Request__c.Id, integrationRequestId)
            .setField(Integration_Request__c.Onboarding_Id__c, String.valueOf(workStepId))
            .setField(Integration_Request__c.Stage__c, STAGE)
            .setField(Integration_Request__c.Notes__c, TEST_MESSAGE)
            .toSObject();

        WorkStep mockWorkStep = (WorkStep) new Fake(WorkStep.class)
            .setField(WorkStep.Id, workStepId)
            .setField(WorkStep.Name, WORKSTEP_NAME)
            .setField(WorkStep.Status__c, WORKSTEP_STATUS)
            .setField(WorkStep.Status, WORKSTEP_STATUS)
            .setField(WorkStep.Type__c, 'Deliver Tablet')
            .setField(WorkStep.WorkOrderId, parentWorkOrderId)
            .setField(WorkStep.WorkPlanId, parentWorkPlanId)
            .setField(WorkStep.Business_Reference__c, businessReferenceId)
            .setField(WorkStep.Store_Account__c, parentAccount.Id)
            .setParent(
                'WorkOrder',
                new Fake(WorkOrder.class)
                    .setField(WorkOrder.Id, parentWorkOrderId)
                    .setField(WorkOrder.Activated_Centrally_AC__c, ACTIVATE_CENTRALLY)
                    .setField(WorkOrder.Opportunity__c, parentOpportunityId)
                    .setField(WorkOrder.Proposed_Date_of_Activation__c, System.today())
                    .setField(WorkOrder.Status, STATUS_PLANNING)
                    .setField(WorkOrder.AccountID, parentAccount.Id)
                    .setField(WorkOrder.Type__c, WORKORDER_TYPE)
            )
            .toSObject();

        List<Integration_Request__c> integrationRequestList = new List<Integration_Request__c>{
            mockIntegrationRequest
        };

        Business_Friendly_Mapping__mdt businessFriendlyMessageFakeInstance = (Business_Friendly_Mapping__mdt) new Fake(
                Business_Friendly_Mapping__mdt.class
            )
            .setField(
                Business_Friendly_Mapping__mdt.id,
                fflib_IDGenerator.generate(Business_Friendly_Mapping__mdt.SObjectType)
            )
            .setField(Business_Friendly_Mapping__mdt.MasterLabel, BUSINESS_FRIENDLY_MAPPING_LABEL)
            .setField(Business_Friendly_Mapping__mdt.Integration_Key_String__c, TEST_MESSAGE)
            .setField(
                Business_Friendly_Mapping__mdt.Business_Friendly_Message__c,
                BUSINESS_FRIENDLY_MESSAGE
            )
            .setField(Business_Friendly_Mapping__mdt.Integration_Type__c, INTEGRATION_TYPE)
            .setField(Business_Friendly_Mapping__mdt.Order__c, 10)
            .setField(Business_Friendly_Mapping__mdt.Active__c, true)
            .toSObject();
        String businessFriendlyMessage = businessFriendlyMessageFakeInstance.Business_Friendly_Message__c;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        IIntegrationRequestsSelector integrationSelectorMock = (IIntegrationRequestsSelector) mocks.mock(
            IIntegrationRequestsSelector.class
        );
        mocks.startStubbing();
        mocks.when(integrationSelectorMock.SObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                integrationSelectorMock.selectIntegrationRequestsByOnboardingId(
                    new Set<Id>{ workStepId }
                )
            )
            .thenReturn(integrationRequestList);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(IntegrationSelectorMock);
        Application.UnitOfWork.setMock(mockUow);

        String onboardingId = mockWorkStep.Id;
        String eventPayload = JSON.serialize(new Set<Id>{ Id.ValueOf(onboardingId) });

        Notifier__e mockNotifierEvent = new Notifier__e(
            Payload__c = eventPayload,
            Topic__c = EVENT_TOPIC_UPDATE_WORK_STEP_STATUS_FROM_TABLET_CASE_STATUS
        );
        // Execute the service method
        FigmentToDdmxSyncService.execute(new List<Notifier__e>{ mockNotifierEvent });

        // Verify the UNIT OF WORK interactions
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        WorkStep.Id => workStepId,
                        WorkStep.Status__c => STAGE,
                        WorkStep.Status => STAGE,
                        WorkStep.Tablet_Escalation_Notes__c => businessFriendlyMessage,
                        WorkStep.Tablet_Integration_Message__c => TEST_MESSAGE,
                        WorkStep.Is_Updated_By_System__c => true
                    }
                )
            );

        // Verify the UNIT OF WORK interactions for Integration_Request__c
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerDirty(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Integration_Request__c.Id => integrationRequestId,
                        Integration_Request__c.sfdc_status__c => SFDC_STATUS
                    }
                )
            );
    }
    private static Account createParentAccountFake(
        Id parentWorkOrderId,
        Id parentOpportunityId,
        Id parentWorkPlanId,
        Id workStepId,
        Id businessRefRecord
    ) {
        Account parentAccount = (Account) new Fake(Account.class)
            .setField(Account.Name, ACCOUNT_NAME_BUSINESS)
            .setField(Account.Primary_Vertical__c, ACCOUNT_PRIMARY_VERTICAL_PREMIUM)
            .setField(Account.RecordTypeID, ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .setFakeId()
            .toSObject();
        return parentAccount;
    }
}