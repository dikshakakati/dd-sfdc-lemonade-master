/**
 * @description This is test class for Rate Change Requests Trigger handler class
 * @author Deloitte
 * @date 13-09-2023
 */
@isTest(seeAllData=false)
public class RateChangeRequestsHandlerTest {
    private static final String APPROVED = 'Approved';
    private static final String EVENT_TOPIC_CREATE_ACTIVATION_ORDER = 'CREATE_ACTIVATION_ORDER_AND_PRODUCTS';
    private static final String METADATA_INSTANCE_NAME = 'Activation_Order_Payload_Chunk_Size';
    private static final String METADATA_VALUE = '3';
    private static final String NEW_RATE_CHANGE = 'New';
    private static final String READY_FOR_ACTIVATION = 'Ready for Activation';
    private static final Date TODAY_DATE = System.today();

    /**
     * @description This method is used to test Rate Change Request TriggerHandler
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Rate_Change_Request__c> rateChangeRequestList = new List<Rate_Change_Request__c>();
        RateChangeRequestsHandler rateChangeHandlerObject = new RateChangeRequestsHandler(
            rateChangeRequestList
        );
        RateChangeRequestsHandler.Constructor objConstructor = new RateChangeRequestsHandler.Constructor();
        objConstructor.construct(rateChangeRequestList);
        System.assertNotEquals(
            rateChangeHandlerObject,
            objConstructor.construct(rateChangeRequestList),
            'Unexpected result: both constructs are similar.'
        );
    }

    /**
     * @description To test method call on RateChangeRequest update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenUpdateRateChangeRequestsThenCallCreateActivationOrders() {
        Id rateChangeReqId = Fake.generateId(Rate_Change_Request__c.class);
        Id contractId2 = Fake.generateId(Contract.class);
        Id caseId = Fake.generateId(Case.class);

        Rate_Change_Request__c[] oldRateChanges = new List<Rate_Change_Request__c>{
            new Rate_Change_Request__c(
                Id = rateChangeReqId,
                Contract__c = contractId2,
                Effective_Date__c = TODAY_DATE,
                S_O_Support_Request_Link__c = caseId,
                Activation_Status__c = NEW_RATE_CHANGE,
                Associated_stores_updated__c = true,
                Order_Products_Updated__c = true,
                Status__c = APPROVED
            )
        };

        Rate_Change_Request__c[] newRateChanges = new List<Rate_Change_Request__c>{
            new Rate_Change_Request__c(
                Id = rateChangeReqId,
                Contract__c = contractId2,
                Effective_Date__c = TODAY_DATE,
                S_O_Support_Request_Link__c = caseId,
                Activation_Status__c = READY_FOR_ACTIVATION,
                Associated_stores_updated__c = true,
                Order_Products_Updated__c = true,
                Status__c = APPROVED
            )
        };

        Set<Id> rateChangeRequestIds = new Set<Id>();
        rateChangeRequestIds.add(rateChangeReqId);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IRateChangeRequestService rateChangeRequestsMock = (IRateChangeRequestService) mocks.mock(
            IRateChangeRequestService.class
        );
        IParentWorkOrdersCreationService parentWorkOrdersCreationServiceMock = (IParentWorkOrdersCreationService) mocks.mock(
            IParentWorkOrdersCreationService.class
        );
        IRateChangeRequestSelector rateChangeSelectorMock = (IRateChangeRequestSelector) mocks.mock(
            IRateChangeRequestSelector.class
        );
        Application.SERVICE.setMock(IRateChangeRequestService.class, rateChangeRequestsMock);
        Application.SERVICE.setMock(
            IParentWorkOrdersCreationService.class,
            parentWorkOrdersCreationServiceMock
        );
        mocks.startStubbing();
        mocks.when(rateChangeSelectorMock.sObjectType())
            .thenReturn(Rate_Change_Request__c.SObjectType);
        mocks.when(
                rateChangeSelectorMock.selectRateChangeRequestById(new Set<Id>{ rateChangeReqId })
            )
            .thenReturn(newRateChanges);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(rateChangeSelectorMock);
        fflib_SObjectDomain.Test.Database.onUpdate(
            newRateChanges,
            new Map<Id, SObject>(oldRateChanges)
        );
        fflib_SObjectDomain.triggerHandler(RateChangeRequestsHandler.class);

        ((IRateChangeRequestService) mocks.verify(rateChangeRequestsMock, 1))
            .publishCreateActivationOrdersNotifierEvent(rateChangeRequestIds);
        ((IParentWorkOrdersCreationService) mocks.verify(parentWorkOrdersCreationServiceMock, 1))
            .createParentWorkOrdersByRateChangeRequest(newRateChanges);
    }
}