/**
 * @author Deloitte
 * @date 04/11/2022
 * @description Test Batch class for status update
 */
@isTest
public with sharing class WorkOrdersStatusUpdateBatchTest {
    private static final String ACCOUNT_RECORD_TYPE_NAME_BUSINESS = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByName()
        .get(ACCOUNT_RECORD_TYPE_NAME_BUSINESS)
        .getRecordTypeId();
    private static final String ACTIVITY_CENTRALLY_AC = 'Yes';
    private static final String AT_RISK_STATUS = 'At Risk';
    private static final String BATCH_NOT_TRIGGERED_ASSERT_MESSAGE = 'Unexpected Error: The Batch has not been triggered yet';
    private static final String CONFIRMED_STATUS = 'Confirmed';
    private static final String COO_TYPE = 'COO';
    private static final String CRON_EXPRESSION = '0 0 1 * * ?';
    private static final String DRIVE_SUBTYPE = 'Portal access';
    private static final String DRIVE_TYPE = 'Drive';
    private static final String IN_PROGRESS_STATUS = 'In Progress';
    private static final String MARKET_PLACE_TYPE = 'Marketplace';
    private static final String MENU_TO_BE_COMPLETED_BY = 'Merchant';
    private static final String NO_WORK_ORDERS_FOUND_ASSERT_MESSAGE = 'Unexpected Error: The list does not contain any Work Orders';
    private static final String OPPORTUNITY_NAME = 'Test Opportunity';
    private static final String OPPORTUNITY_STAGE = 'Prospecting';
    private static final String ONBOARDING_COMPLETED_STATUS = 'Onboarding Complete';
    private static final String ORDER_PROTOCOL_EMAIL = 'Email';
    private static final String PAST_DUE_STATUS = 'Past Due';
    private static final String PARENT_ACCOUNT_NAME = 'Parent Account';
    private static final String PLANNING_STATUS = 'Planning';
    private static final String SCHEDULED_JOB_NAME = WorkOrdersStatusUpdateBatchTest.class
        .getName();
    private static final String STORE_FRONT_TYPE = 'Storefront';
    private static List<WorkOrder> newWorkOrders = new List<WorkOrder>();
    private static final String SEGMENT_ACCOUNT = 'Enterprise';
    /**
     * @description : This test method for validate Selector class WOrkOrder List
     **/
    @isTest
    private static void testWhenDateLessThanCurrentDateWithTriggerThenRun() {
        Account businessAccount = new Account(
            Name = PARENT_ACCOUNT_NAME,
            RecordTypeId = ACCOUNT_BUSINESS_RECORD_TYPE_ID,
            Segment__c = SEGMENT_ACCOUNT
        );
        insert businessAccount;
        //Confirmed, In Progress, At Risk, Past Due, Onboarding Complete
        Opportunity parentOpportunity = getOpportunityRecords(
            OPPORTUNITY_NAME,
            OPPORTUNITY_STAGE,
            System.today().addMonths(2),
            null
        );
        WorkOrder parentWorkOrder = getWorkOrderRecord(
            PLANNING_STATUS,
            parentOpportunity.Id,
            COO_TYPE,
            null,
            null,
            ACTIVITY_CENTRALLY_AC,
            System.today().addDays(10),
            MENU_TO_BE_COMPLETED_BY,
            null,
            System.today().addDays(10)
        );
        parentWorkOrder.AccountId = businessAccount.Id;
        insert parentWorkOrder;
        WorkOrder parentWorkOrderUpdate = new WorkOrder(
            Id = parentWorkOrder.Id,
            Proposed_Date_of_Tablet__c = System.today() - 1
        );
        update parentWorkOrderUpdate;
        newWorkOrders.add(
            getWorkOrderRecord(
                PLANNING_STATUS,
                parentOpportunity.Id,
                COO_TYPE,
                null,
                null,
                ACTIVITY_CENTRALLY_AC,
                System.today().addDays(10),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today().addDays(10)
            )
        );
        newWorkOrders.add(
            getWorkOrderRecord(
                CONFIRMED_STATUS,
                parentOpportunity.Id,
                MARKET_PLACE_TYPE,
                null,
                ORDER_PROTOCOL_EMAIL,
                ACTIVITY_CENTRALLY_AC,
                System.today().addDays(10),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today().addDays(10)
            )
        );
        newWorkOrders.add(
            getWorkOrderRecord(
                IN_PROGRESS_STATUS,
                parentOpportunity.Id,
                MARKET_PLACE_TYPE,
                null,
                ORDER_PROTOCOL_EMAIL,
                ACTIVITY_CENTRALLY_AC,
                System.today().addDays(10),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today().addDays(10)
            )
        );
        newWorkOrders.add(
            getWorkOrderRecord(
                AT_RISK_STATUS,
                parentOpportunity.Id,
                STORE_FRONT_TYPE,
                null,
                null,
                ACTIVITY_CENTRALLY_AC,
                System.today().addDays(10),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today().addDays(10)
            )
        );
        newWorkOrders.add(
            getWorkOrderRecord(
                PAST_DUE_STATUS,
                parentOpportunity.Id,
                COO_TYPE,
                null,
                null,
                ACTIVITY_CENTRALLY_AC,
                System.today().addDays(10),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today().addDays(10)
            )
        );
        newWorkOrders.add(
            getWorkOrderRecord(
                ONBOARDING_COMPLETED_STATUS,
                parentOpportunity.Id,
                MARKET_PLACE_TYPE,
                null,
                ORDER_PROTOCOL_EMAIL,
                'Yes',
                System.today().addDays(10),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today().addDays(10)
            )
        );
        insert newWorkOrders;
        List<WorkOrder> newWorkOrdersToUpdate = new List<WorkOrder>{
            new WorkOrder(
                Id = newWorkOrders[0].Id,
                Proposed_Date_of_Tablet__c = System.today() - 1
            ),
            new WorkOrder(
                Id = newWorkOrders[1].Id,
                PDOA_Delay_Reason__c = 'Readiness Check Failure',
                PDOA_Delay_Details__c = 'Delayed due to Readiness Failure',
                Proposed_Date_of_Tablet__c = System.today() - 1
            ),
            new WorkOrder(
                Id = newWorkOrders[2].Id,
                Proposed_Date_of_Tablet__c = createPdoaDate(System.today() - 1)
            ),
            new WorkOrder(
                Id = newWorkOrders[3].Id,
                PDOA_Delay_Reason__c = 'Readiness Check Failure',
                PDOA_Delay_Details__c = 'Delayed due to Readiness Failure'
            ),
            new WorkOrder(
                Id = newWorkOrders[4].Id,
                PDOA_Delay_Reason__c = 'Readiness Check Failure',
                PDOA_Delay_Details__c = 'Delayed due to Readiness Failure',
                Proposed_Date_of_Tablet__c = System.today() - 1
            ),
            new WorkOrder(Id = newWorkOrders[5].Id, Proposed_Date_of_Tablet__c = System.today() - 1)
        };
        update newWorkOrdersToUpdate;
        //WorkOrdersService workOrderServiceInstance = new WorkOrdersService();
        List<WorkOrder> workOrderWithWorkStepsResult = WorkOrdersService.getWorkOrderRecordsForUpdateStatus();
        Database.QueryLocator workOrderWithWorkStepsResultWithQueryLocator = WorkOrdersService.getWorkOrderRecordsForUpdateStatusFromBatch();
        WorkOrdersServiceImpl workOrderImp = new WorkOrdersServiceImpl();
        workOrderImp.updateWorkOrderStatus(workOrderWithWorkStepsResult);
        System.assert(workOrderWithWorkStepsResult != null, NO_WORK_ORDERS_FOUND_ASSERT_MESSAGE);
        System.assert(
            workOrderWithWorkStepsResultWithQueryLocator != null,
            NO_WORK_ORDERS_FOUND_ASSERT_MESSAGE
        );
    }
    /**
     * @description This test method for validate batch job
     **/
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenDateLessThanCurrentDateWithBatchThenRun() {
        Map<Id, WorkOrder> workOrders = new Map<Id, WorkOrder>();
        Id opportunityRecord = fflib_IDGenerator.generate(Opportunity.SObjectType);
        WorkOrder parentWorkOrder = getWorkOrderByFakeRecordId(
            PLANNING_STATUS,
            opportunityRecord,
            COO_TYPE,
            null,
            ACTIVITY_CENTRALLY_AC,
            System.today(),
            MENU_TO_BE_COMPLETED_BY,
            null,
            System.today() - 1
        );
        newWorkOrders.add(
            getWorkOrderByFakeRecordId(
                PLANNING_STATUS,
                opportunityRecord,
                COO_TYPE,
                null,
                ACTIVITY_CENTRALLY_AC,
                System.today() - 1,
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today() - 1
            )
        );
        newWorkOrders.add(
            getWorkOrderByFakeRecordId(
                CONFIRMED_STATUS,
                opportunityRecord,
                DRIVE_TYPE,
                DRIVE_SUBTYPE,
                ACTIVITY_CENTRALLY_AC,
                System.today() - 3,
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today() - 1
            )
        );
        newWorkOrders.add(
            getWorkOrderByFakeRecordId(
                IN_PROGRESS_STATUS,
                opportunityRecord,
                DRIVE_TYPE,
                DRIVE_SUBTYPE,
                ACTIVITY_CENTRALLY_AC,
                System.today(),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today() - 1
            )
        );
        newWorkOrders.add(
            getWorkOrderByFakeRecordId(
                AT_RISK_STATUS,
                opportunityRecord,
                STORE_FRONT_TYPE,
                null,
                ACTIVITY_CENTRALLY_AC,
                System.today() - 4,
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today() - 1
            )
        );
        newWorkOrders.add(
            getWorkOrderByFakeRecordId(
                PAST_DUE_STATUS,
                opportunityRecord,
                COO_TYPE,
                null,
                ACTIVITY_CENTRALLY_AC,
                System.today() - 2,
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today() - 1
            )
        );
        newWorkOrders.add(
            getWorkOrderByFakeRecordId(
                ONBOARDING_COMPLETED_STATUS,
                opportunityRecord,
                DRIVE_TYPE,
                DRIVE_SUBTYPE,
                ACTIVITY_CENTRALLY_AC,
                System.today(),
                MENU_TO_BE_COMPLETED_BY,
                parentWorkOrder.Id,
                System.today() - 1
            )
        );
        for (WorkOrder workRecord : newWorkOrders) {
            workOrders.put(workRecord.Id, workRecord);
        }
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IWorkOrdersSelector selectorMock = (IWorkOrdersSelector) mocks.mock(
            IWorkOrdersSelector.class
        );
        IWorkOrdersService serviceMock = (IWorkOrdersService) mocks.mock(IWorkOrdersService.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(WorkOrder.SObjectType);
        mocks.when(selectorMock.getWorkOrderRecordsForUpdateStatusFromBatch()).thenReturn(null);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        Application.SERVICE.setMock(IWorkOrdersService.class, serviceMock);
        WorkOrdersStatusUpdateBatch batch = new WorkOrdersStatusUpdateBatch();
        batch.start(null);
        batch.execute(null, workOrders.values());
        batch.finish(null);
        ((IWorkOrdersService) mocks.verify(serviceMock, 1))
            .updateWorkOrderStatus(workOrders.values());
        ((IWorkOrdersSelector) mocks.verify(selectorMock, 1))
            .getWorkOrderRecordsForUpdateStatusFromBatch();
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
            new WorkOrdersStatusUpdateBatch()
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
     * @description Method for get the default Price book record
     * @return Pricebook2
     **/
    private static Pricebook2 getPriceBookRecord() {
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        return standardPricebook;
    }
    /**
     * @description Method for create an opportunity
     * @param opportunityName
     * @param stageName
     * @param closeDate
     * @param priceBookId
     * @return opportunity
     **/
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static opportunity getOpportunityRecords(
        String opportunityName,
        String stageName,
        Date closeDate,
        Id priceBookId
    ) {
        Account parentAccount = new Account(Name = PARENT_ACCOUNT_NAME, Segment__c = SEGMENT_ACCOUNT);
        Opportunity parentOpportunity = new Opportunity(
            AccountId = parentAccount.Id,
            Name = opportunityName,
            StageName = stageName,
            CloseDate = closeDate,
            Pricebook2Id = getPriceBookRecord().Id,
            Opportunity_Sub_Type__c = 'Upgrade',
            Deal_Type__c = 'Standard'
        );
        insert parentOpportunity;
        return parentOpportunity;
    }
    /**
     * @description : Method for get the Work Order record
     * @param workOrderStatus
     * @param opportunityId
     * @param workOrderType
     * @param workOrderSubType
     * @param orderProtocol
     * @param centrallyAC
     * @param pdoaDate
     * @param menutobeupdate
     * @param parentWorkRecordId
     * @param pdotDate
     * @return WorkOrder
     **/
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static WorkOrder getWorkOrderRecord(
        String workOrderStatus,
        Id opportunityId,
        String workOrderType,
        String workOrderSubType,
        String orderProtocol,
        String centrallyAC,
        Date pdoaDate,
        String menutobeupdate,
        Id parentWorkRecordId,
        Date pdotDate
    ) {
        return new WorkOrder(
            Status = workOrderStatus,
            //Opportunity__c = opportunityId,
            Type__c = workOrderType,
            Sub_Type__c = workOrderSubType,
            Order_Protocol__c = orderProtocol,
            Activated_Centrally_AC__c = centrallyAC,
            Proposed_Date_of_Activation__c = createPdoaDate(pdoaDate),
            Menu_to_be_Completed_By__c = menutobeupdate,
            Proposed_Date_of_Tablet__c = pdotDate,
            ParentWorkOrderId = parentWorkRecordId
        );
    }
    /**
     * @description Method for get the Work Order record with fake record id
     * @param workOrderStatus
     * @param opportunityId
     * @param workOrderType
     * @param workOrderSubType
     * @param centrallyAC
     * @param pdoaDate
     * @param menutobeupdate
     * @param parentWorkRecordId
     * @param pdotDate
     * @return WorkOrder
     **/
    @SuppressWarnings('PMD.ExcessiveParameterList')
    private static WorkOrder getWorkOrderByFakeRecordId(
        String workOrderStatus,
        Id opportunityId,
        String workOrderType,
        String workOrderSubType,
        String centrallyAC,
        Date pdoaDate,
        String menutobeupdate,
        Id parentWorkRecordId,
        Date pdotDate
    ) {
        WorkOrder workOrderRecord = (WorkOrder) new Fake(WorkOrder.class).setFakeId().toSObject();
        workOrderRecord.Status = workOrderStatus;
        //workOrderRecord.Opportunity__c = opportunityId;
        workOrderRecord.Type__c = workOrderType;
        workOrderRecord.Sub_Type__c = workOrderSubType;
        workOrderRecord.Activated_Centrally_AC__c = centrallyAC;
        workOrderRecord.Proposed_Date_of_Activation__c = pdoaDate;
        workOrderRecord.Proposed_Date_of_Tablet__c = createPdoaDate(pdoaDate);
        workOrderRecord.Menu_to_be_Completed_By__c = menutobeupdate;
        workOrderRecord.ParentWorkOrderId = parentWorkRecordId;
        return workOrderRecord;
    }

    /**
     * @description Retrieves a valid PDOA Date for testing - these dates cannot fall on weekends.
     * @param proposedDateToUse
     * @return Date
     **/
    private static Date createPdoaDate(Date proposedDateToUse) {
        Date dateToReturn = proposedDateToUse;
        Datetime dt = (DateTime) dateToReturn; // Needed to get the day of the week
        String dayOfWeek = dt.formatGmt('EEEE');

        if (dayOfWeek == 'Saturday' || dayOfWeek == 'Sunday') {
            // Set the date to sometime during the week
            dateToReturn = dateToReturn.addDays(3);
        }
        return dateToReturn;
    }
}