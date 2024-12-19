/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Test class for CriteriaServiceImpl class.
 */
@isTest(SeeAllData=false)
public class CriteriaServiceImplTest {
    private static final String ASSERT_MESSAGE_RELATED_RECORDS_NOT_RETURNED = 'Unexpected Result: Records not returned.';
    private static final String CONTACT_EMAIL_FIELD = 'Email';
    private static final String CONTACT_EMAIL_FIELD_REFERENCE = 'Contact.Email';
    private static final String MOCK_EXTERNAL_ID_VALUE = 'externalIdMock';
    private static final String XREF_EXTERNAL_ID_FIELD = 'External_ID__c';
    private static final String ID_FIELD = 'Id';

    /**
     * @description To test Decision Maker contact details are returned
     * based on passed Work Order Ids and fields.
     */
    @isTest
    private static void testWhenWorkOrderIdsAndFieldsReceivedThenReturnDecisionMakerContactDetails() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id contactId = fflib_IDGenerator.generate(Contact.SObjectType);
        List<SObject> workOrders = new List<SObject>{
            new WorkOrder(Id = workOrderId, AccountId = accountId, ContactId = contactId)
        };
        Set<String> sObjectFields = new Set<String>{ CONTACT_EMAIL_FIELD };
        Set<String> sObjectFieldReference = new Set<String>{ CONTACT_EMAIL_FIELD_REFERENCE };
        List<AccountContactRelation> mockACRs = new List<AccountContactRelation>{
            new AccountContactRelation(AccountId = accountId)
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IAccountContactRelationsSelector mockAccountContactRelationsSelector = (IAccountContactRelationsSelector) mocks.mock(
            IAccountContactRelationsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockAccountContactRelationsSelector.sObjectType())
            .thenReturn(AccountContactRelation.SObjectType);
        mocks.when(
                mockAccountContactRelationsSelector.selectDecisionMakerContactsByAccountIds(
                    new Set<Id>{ accountId },
                    sObjectFieldReference
                )
            )
            .thenReturn(mockACRs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockAccountContactRelationsSelector);
        Test.startTest();
        Map<Id, List<SObject>> returnedACR = CriteriaService.collectDecisionMakerContactDetails(
            workOrders,
            sObjectFields
        );
        Test.stopTest();
        System.assertEquals(
            new Map<Id, List<SObject>>{ workOrderId => new List<SObject>{ mockACRs[0].Contact } },
            returnedACR,
            ASSERT_MESSAGE_RELATED_RECORDS_NOT_RETURNED
        );
    }

    /**
     * @description To test Xref details are returned
     * based on passed Work Order Ids and fields.
     */
    @isTest
    private static void testWhenWorkOrderIdsAndFieldsReceivedThenReturnXrefDetails() {
        Id workOrderId = fflib_IDGenerator.generate(WorkOrder.SObjectType);
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        List<SObject> newWorkOrders = new List<SObject>{
            new WorkOrder(Id = workOrderId, AccountId = accountId)
        };
        List<Xref__c> mockXrefs = new List<Xref__c>{
            new Xref__c(
                External_ID__c = MOCK_EXTERNAL_ID_VALUE,
                Salesforce_Account_Name__c = accountId
            )
        };
        Set<String> sObjectFields = new Set<String>{ XREF_EXTERNAL_ID_FIELD };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IXrefsSelector mockXrefsSelector = (IXrefsSelector) mocks.mock(IXrefsSelector.class);
        mocks.startStubbing();
        mocks.when(mockXrefsSelector.sObjectType()).thenReturn(Xref__c.SObjectType);
        mocks.when(
                mockXrefsSelector.selectActiveXrefsBySalesforceAccountName(new Set<Id>{ accountId })
            )
            .thenReturn(mockXrefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockXrefsSelector);
        Test.startTest();
        Map<Id, List<SObject>> returnedXrefs = CriteriaService.collectXrefDetails(
            newWorkOrders,
            sObjectFields
        );
        Test.stopTest();
        System.assertEquals(
            new Map<Id, List<SObject>>{ workOrderId => new List<SObject>{ mockXrefs[0] } },
            returnedXrefs,
            ASSERT_MESSAGE_RELATED_RECORDS_NOT_RETURNED
        );
    }

    /**
     * @description To test Dependee Work Step details are returned
     * based on passed Work Step Ids and fields.
     */
    @isTest
    private static void testWhenWorkStepIdsAndFieldsReceivedThenReturnDependeeWorkStepDetails() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id dependeeWorkStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        List<SObject> newWorkSteps = new List<SObject>{ new WorkStep(Id = workStepId) };
        List<WorkStepDependency__c> mockWorkStepDependencies = new List<WorkStepDependency__c>{
            new WorkStepDependency__c(
                Dependee_Work_Step__c = dependeeWorkStepId,
                Dependent_Work_Step__c = workStepId
            )
        };
        Set<String> sObjectFields = new Set<String>{ ID_FIELD };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkStepDependenciesSelector mockWorkStepDependenciesSelector = (IWorkStepDependenciesSelector) mocks.mock(
            IWorkStepDependenciesSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockWorkStepDependenciesSelector.sObjectType())
            .thenReturn(WorkStepDependency__c.SObjectType);
        mocks.when(
                mockWorkStepDependenciesSelector.selectDependenciesByDependentWorkStepsIds(
                    new Set<Id>{ workStepId }
                )
            )
            .thenReturn(mockWorkStepDependencies);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockWorkStepDependenciesSelector);
        Test.startTest();
        Map<Id, List<SObject>> returnedWorkStepDependencies = CriteriaService.collectDependeeWorkSteps(
            newWorkSteps,
            sObjectFields
        );
        Test.stopTest();
        System.assertEquals(
            new Map<Id, List<SObject>>{
                workStepId => new List<SObject>{
                    mockWorkStepDependencies[0].Dependent_Work_Step__r
                }
            },
            returnedWorkStepDependencies,
            ASSERT_MESSAGE_RELATED_RECORDS_NOT_RETURNED
        );
    }

    /**
     * @description To test Merchant order details returned based on passed Work Steps and fields.
     */
    @isTest
    private static void testWhenWorkStepsAndFieldsReceivedThenReturnMxOrderDetails() {
        Id workStepId = fflib_IDGenerator.generate(WorkStep.SObjectType);
        Id mxOrderId = fflib_IDGenerator.generate(MX_Order__c.SObjectType);
        List<SObject> newWorkSteps = new List<SObject>{ new WorkStep(Id = workStepId) };
        List<MX_Order__c> mockMxOrders = new List<MX_Order__c>{
            new MX_Order__c(Id = mxOrderId, Work_Step__c = workStepId)
        };
        Set<String> sObjectFields = new Set<String>{ ID_FIELD };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMerchantOrdersSelector mockMerchantOrdersSelector = (IMerchantOrdersSelector) mocks.mock(
            IMerchantOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockMerchantOrdersSelector.sObjectType()).thenReturn(MX_Order__c.SObjectType);
        mocks.when(
                mockMerchantOrdersSelector.selectByWorkStepIds(
                    new Set<Id>{ workStepId },
                    sObjectFields
                )
            )
            .thenReturn(mockMxOrders);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockMerchantOrdersSelector);
        Test.startTest();
        Map<Id, List<SObject>> returnedMxOrders = CriteriaService.collectMxOrders(
            newWorkSteps,
            sObjectFields
        );
        Test.stopTest();
        System.assertEquals(
            new Map<Id, List<SObject>>{ workStepId => mockMxOrders },
            returnedMxOrders,
            ASSERT_MESSAGE_RELATED_RECORDS_NOT_RETURNED
        );
    }
}