/**
 * @author DoorDash
 * @date 03/22/2023
 * @description Test class for IntegrationRequestScheduler class.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
public class IntegrationRequestSchedulerTest {
    private static final String INTEGRATION_TYPE_ACTIVATION_CHECKLIST = 'Activation Checklist';
    private static final String MOCK_BATCH_ID = 'Batch001';
    private static final String PRODUCT_STATUS_COMPLETED = 'completed';
    private static final String SFDC_STATUS_PENDING = 'Pending';
    private static final Set<String> SFDC_STATUS = new Set<String>{ SFDC_STATUS_PENDING };
    private static final Set<String> SFDC_ORG = new Set<String>{ 'Lemonade' };
    private static final String INTEGRATION_REQUEST_JOB_QUERY_LAST_N_DAYS = 'IntegrationRequestQueryLostNDays';
    private static Integer integrationRequestQueryLostNDays;

    @isTest
    private static void testWhenSchduelarRanThenQueryPendingIntReqAndPublishTheEvents() {
        collectStaticConfigurations();
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = 'Pending',
            Batch_Id__c = 'Batch001',
            Product_status__c = 'completed'
        );
        Integration_Request__c integrationRequest2 = new Integration_Request__c(
            Id = intId,
            sfdc_status__c = 'Pending',
            Batch_Id__c = 'Batch001',
            Product_status__c = 'completed'
        );
        List<Integration_Request__c> intRequests = new List<Integration_Request__c>{
            integrationRequest,
            integrationRequest2
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUow = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        IIntegrationRequestsSelector mockIntegrationSelector = (IIntegrationRequestsSelector) mocks.mock(
            IntegrationRequestsSelector.class
        );
        IIntegrationRequestsService mockIntegrationService = (IIntegrationRequestsService) mocks.mock(
            IIntegrationRequestsService.class
        );
        mocks.startStubbing();
        mocks.when(mockIntegrationSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                mockIntegrationSelector.selectIntegrationRequestsByStatusAndOrg(
                    SFDC_STATUS,
                    SFDC_ORG,
                    integrationRequestQueryLostNDays
                )
            )
            .thenReturn(intRequests);
        mocks.stopStubbing();
        Application.Selector.setMock(mockIntegrationSelector);
        Application.SERVICE.setMock(IIntegrationRequestsService.class, mockIntegrationService);
        Application.UnitOfWork.setMock(mockUow);

        IntegrationRequestScheduler schedule = new IntegrationRequestScheduler();
        schedule.execute(null);

        ((IIntegrationRequestsService) mocks.verify(mockIntegrationService))
            .publishEventsForProcessing(new Map<Id, Integration_Request__c>(), intRequests, true);
    }

    /**
     * @description To test Activation Checklist Integration Requests are not picked for retry.
     */
    @isTest
    private static void testWhenSchedulerRanThenActivationChecklistRequestsNotRetried() {
        collectStaticConfigurations();
        Id intId = fflib_IDGenerator.generate(Integration_Request__c.SObjectType);
        Integration_Request__c integrationRequest = new Integration_Request__c(
            Id = intId,
            Sfdc_Status__c = SFDC_STATUS_PENDING,
            Batch_Id__c = MOCK_BATCH_ID,
            Product_Status__c = PRODUCT_STATUS_COMPLETED
        );
        Integration_Request__c activationChecklistIntegrationRequest = new Integration_Request__c(
            Id = intId,
            Sfdc_Status__c = SFDC_STATUS_PENDING,
            Batch_Id__c = MOCK_BATCH_ID,
            Product_Status__c = PRODUCT_STATUS_COMPLETED,
            Integration_Type__c = INTEGRATION_TYPE_ACTIVATION_CHECKLIST
        );
        List<Integration_Request__c> intRequests = new List<Integration_Request__c>{
            integrationRequest,
            activationChecklistIntegrationRequest
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IIntegrationRequestsSelector mockIntegrationSelector = (IIntegrationRequestsSelector) mocks.mock(
            IntegrationRequestsSelector.class
        );
        IIntegrationRequestsService mockIntegrationService = (IIntegrationRequestsService) mocks.mock(
            IIntegrationRequestsService.class
        );
        mocks.startStubbing();
        mocks.when(mockIntegrationSelector.sObjectType())
            .thenReturn(Integration_Request__c.SObjectType);
        mocks.when(
                mockIntegrationSelector.selectIntegrationRequestsByStatusAndOrg(
                    SFDC_STATUS,
                    SFDC_ORG,
                    integrationRequestQueryLostNDays
                )
            )
            .thenReturn(intRequests);
        mocks.stopStubbing();
        Application.Selector.setMock(mockIntegrationSelector);
        Application.SERVICE.setMock(IIntegrationRequestsService.class, mockIntegrationService);
        IntegrationRequestScheduler schedule = new IntegrationRequestScheduler();
        schedule.execute(null);
        ((IIntegrationRequestsService) mocks.verify(mockIntegrationService))
            .publishEventsForProcessing(
                new Map<Id, Integration_Request__c>(),
                new List<Integration_Request__c>{ integrationRequest },
                true
            );
    }

    /**
     * @description get static static onfiguration from metadata
     */
    private static void collectStaticConfigurations() {
        integrationRequestQueryLostNDays = Integer.valueOf(
            StaticConfigurationsSelector.newInstance()
                .getInstanceValue(INTEGRATION_REQUEST_JOB_QUERY_LAST_N_DAYS)
                .Configuration_Value__c
        );
    }
}