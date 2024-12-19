/**
 * @author DoorDash
 * @date 11/29/2022
 * @description Batch class that updates the Provisioning status on COO Work Orders to Ready for Provisioning the day before the PDOA date.
 */
@isTest
public with sharing class WorkOrdersProvisioningStatusCOOBatchTest {
    private static final String ACCOUNT_PRIMARY_VERTICAL = 'Rx';
    private static final String DAY_OF_WEEK_SATURDAY = 'Saturday';
    private static final String DAY_OF_WEEK_SUNDAY = 'Sunday';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String STATUS_PLANNING = 'Planning';
    private static final String WORK_ORDER_ACTIVATED_CENTRALLY_YES = 'Yes';
    private static final String WORK_ORDER_MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String WORK_ORDER_SOURCE_SALES = 'Sales';
    private static final String WORK_ORDER_NOT_STARTED = 'Not Started';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String SCHEDULED_JOB_NAME = WorkOrdersProvisioningStatusCOOBatch.class
        .getName();
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    /**
     * @description : This test method for validate Selector class WorkOrder List
     **/
    @isTest
    private static void testWhenPDOAIsTomorrowThenUpdateTheProvisioningStatus() {
        Account parentBusinessAccount = ServiceIntegrationDataBuilder.createBusinessAccountInstance(
            ACCOUNT_PRIMARY_VERTICAL
        );
        insert parentBusinessAccount;
        WorkOrder cooParentWorkOrder = new WorkOrder(
            AccountId = parentBusinessAccount.Id,
            Type__c = WORK_ORDER_TYPE_COO,
            Status = STATUS_PLANNING,
            Order_Protocol__c = ORDER_PROTOCOL_EMAIL,
            Menu_to_be_Completed_By__c = WORK_ORDER_MENU_TO_BE_COMPLETED_BY,
            Proposed_Date_of_Activation__c = convertPDOADateToWeekday(System.today().addDays(10)),
            Activated_Centrally_AC__c = WORK_ORDER_ACTIVATED_CENTRALLY_YES,
            Work_Order_Source__c = WORK_ORDER_SOURCE_SALES,
            Provisioning_Status__c = WORK_ORDER_NOT_STARTED
        );
        insert cooParentWorkOrder;

        cooParentWorkOrder.Proposed_Date_of_Activation__c = convertPDOADateToWeekday(System.today() + 1);
        cooParentWorkOrder.PDOA_Delay_Reason__c = 'Readiness Check Failure';
        cooParentWorkOrder.PDOA_Delay_Details__c = 'Delayed due to Readiness Failure';
        update cooParentWorkOrder;

        List<WorkOrder> workOrderList = new List<WorkOrder>{ cooParentWorkOrder };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUnitOfWork = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        WorkOrdersSelector workOrderSelectionMock = (WorkOrdersSelector) mocks.mock(
            WorkOrdersSelector.class
        );
        mocks.startStubbing();
        mocks.when(workOrderSelectionMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(workOrderSelectionMock.selectCOOWorkOrdersBasedOnPDOADate()).thenReturn(null);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(workOrderSelectionMock);
        Application.UNITOFWORK.setMock(mockUnitOfWork);
        WorkOrdersProvisioningStatusCOOBatch obj = new WorkOrdersProvisioningStatusCOOBatch();
        obj.start(null);
        obj.execute(null, workOrderList);
        obj.finish(null);
        //ASSERT
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUnitOfWork, 1)).commitWork();
        system.assertEquals(
            WorkOrdersProvisioningStatusCOOBatch.PROVISIONING_STATUS_READY_FOR_PROVISIONING,
            workOrderList[0].Provisioning_Status__c,
            'Provisioning Status not updated'
        );
    }

    /**
     * @description To validate that schedulable context execute
     * is scheduling the batch job correctly.
     **/
    @isTest
    private static void testWhenBatchIsScheduledThenBatchIsExecutedOnScheduledTime() {
        Test.startTest();
        String jobId = System.schedule(
            SCHEDULED_JOB_NAME,
            CRON_EXPRESSION,
            new WorkOrdersProvisioningStatusCOOBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            BATCH_NOT_TRIGGERED_ASSERT_MESSAGE
        );
    }

    /**
     * @description It returns a valid PDOA Date for unit testing
     * i.e. a date that falls on a weekday.
     * @param pdoaDateToConvert
     * @return Date
     **/
    private static Date convertPDOADateToWeekday(Date pdoaDateToConvert) {
        Date dateToReturn = pdoaDateToConvert;
        String dayOfWeek = ((DateTime) dateToReturn).formatGmt('EEEE');
        if (dayOfWeek == DAY_OF_WEEK_SATURDAY || dayOfWeek == DAY_OF_WEEK_SUNDAY) {
            // Set the date to a weekday
            dateToReturn = dateToReturn.addDays(3);
        }
        return dateToReturn;
    }
}