/**
 * @description This is test class for Process_Flow_Request__c Trigger handler class
 * @author Aethereus.
 * @date 2024-03-22.
 */
@isTest(seeAllData=false)
public class ProcessFlowRequestsHandlerTest {
    private static final String PROCESSF_FLOW_REQUEST_STAGE_EXTERNAL_ID_CREATED = 'External Ids Created';
    private static final String PROCESSF_FLOW_REQUEST_STAGE_EMAIL_SEND = 'Email Sent';
    private static final String REQUEST_STATUS_IN_PROGRESS = 'In Progress';
    private static final String BRANDANDBUSINESSFLOW_RECORDTYPE = System.Label.Brand_and_Business_Reference_Flow_Record_Type_Name;


     /**
     * @description To test method call on instantiation
     */
    @IsTest
    private static void testWhenClassInstantiatesThenCheck() {
        //Constructor Call
        List<Process_Flow_Request__c> processFlowRequestList = new List<Process_Flow_Request__c>();
        ProcessFlowRequestsHandler processFlowRequestHandlerObject = new ProcessFlowRequestsHandler(
            processFlowRequestList
        );
        //Inner Class Constructor Call
        ProcessFlowRequestsHandler.Constructor objConstructor = new ProcessFlowRequestsHandler.Constructor();
        objConstructor.construct(processFlowRequestList);
        System.assertNotEquals(
            processFlowRequestHandlerObject,
            objConstructor.construct(processFlowRequestList),
            'The two constructs should not be similar'
        );
    }

     /**
     * @description To test method Process Flow Request Handler, Stage Update with External Id Created for Brand and Business Flow Record.
     */
    @IsTest
    private static void testWhenGetStatusChangedProcessFlowRequestsThenReturnWithStageExternalIdCreated() {
         Id brandAndBusinessFlowRecordTypeId = Schema.SObjectType.Process_Flow_Request__c.getRecordTypeInfosByDeveloperName()
        .get(BRANDANDBUSINESSFLOW_RECORDTYPE)
        .getRecordTypeId();

        Id processFlowRequestId = Fake.generateId(Process_Flow_Request__c.class);
        List<Process_Flow_Request__c> oldProcessFlowRequestsList = new List<Process_Flow_Request__c>{
            new Process_Flow_Request__c(
                Id = processFlowRequestId,
                Stage__c = PROCESSF_FLOW_REQUEST_STAGE_EMAIL_SEND,
                Status__c = REQUEST_STATUS_IN_PROGRESS,
                RecordTypeId = brandAndBusinessFlowRecordTypeId
            )
        };

        List<Process_Flow_Request__c> newProcessFlowRequestsList = new List<Process_Flow_Request__c>{
            new Process_Flow_Request__c(
				Id = processFlowRequestId,
                Stage__c = PROCESSF_FLOW_REQUEST_STAGE_EXTERNAL_ID_CREATED,
                Status__c = REQUEST_STATUS_IN_PROGRESS,
                RecordTypeId = brandAndBusinessFlowRecordTypeId
            )
        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IProcessFlowRequests processFlowRequestsMock = (IProcessFlowRequests) mocks.mock(IProcessFlowRequests.class);
        mocks.startStubbing();
        mocks.when(processFlowRequestsMock.getType()).thenReturn(Schema.Process_Flow_Request__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(processFlowRequestsMock);

        fflib_SObjectDomain.Test.Database.onUpdate(
            newProcessFlowRequestsList,
            new Map<Id, SObject>(oldProcessFlowRequestsList)
        );

        fflib_SObjectDomain.triggerHandler(ProcessFlowRequestsHandler.class);
        ((IProcessFlowRequests) mocks.verify(processFlowRequestsMock, 1))
            .sendNotifcationsForProcessFlowRequestWithExternalIdsCreated();

            List<Process_Flow_Request__c> updatedProcessFlowRequests = [
                SELECT Id, Stage__c
                FROM Process_Flow_Request__c
                WHERE Id IN :new Map<Id, SObject>(newProcessFlowRequestsList).keySet()
            ];
            for (Process_Flow_Request__c updatedPfr : updatedProcessFlowRequests) {
                System.assertEquals(PROCESSF_FLOW_REQUEST_STAGE_EXTERNAL_ID_CREATED, updatedPfr.Stage__c, 'The Stage__c field should be updated to PROCESSF_FLOW_REQUEST_STAGE_EXTERNAL_ID_CREATED');
            }

    }

}