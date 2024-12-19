/**
 * @author Deloitte
 * @date 24/05/2022
 * @description Test class for WorkStepsStatusRelatedDatesCalcSrvcImpl class.
 */
@isTest(seeAllData=false)
private class WorkStepsStatusRelatedDatesCalcSrvcTest {
    private static final String FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE = 'Unexpected result: the field is not updated with expected value';
    private static final String INITIAL_OWNER_NAME = 'Test User';
    private static final Integer PREVIOUS_NUMBER_OF_DAYS_BLOCKED = 0;
    private static final Integer TOTAL_NUMBER_OF_DAYS_BLOCKED = 4;
    private static final String WORK_STEP_STATUS_BLOCKED = 'Blocked';
    private static final String WORK_STEP_STATUS_COMPLETE = 'Complete';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String WORK_STEP_STATUS_IN_PROGRESS = 'In Progress';
    private static final String WORK_STEP_STATUS_NOT_STARTED = 'Not Started';
    private static final String WORK_STEP_STATUS_NOT_WORKABLE = 'Not Workable';
    private static final String WORK_STEP_STATUS_QA_COMPLETE = 'QA Complete';
    private static final String WORK_STEP_STATUS_READY_FOR_QA = 'Ready for QA';
    private static final String WORK_STEP_STATUS_REASON_OTHER = 'Other';
    private static final String WORK_STEP_TYPE_SETUP_BANKING = 'Setup Banking';

    /**
     * @description To test Start Date/Time and Initial Owner fields are updated
     * when WorkStep status is moved from 'Not Started' to 'In Progress'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusToInProgressThenStartDateAndTimeIsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField = newWorkStep.Start_Date_Time__c;
        Date updatedStartDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            UserInfo.getName(),
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Initial Owner field is not updated when Initial Owner field
     * is not null and WorkStep status is moved from 'Not Workable' to 'In Progress'.
     */
    @isTest
    private static void testWhenInitialOwnerIsNotNullThenInitialOwnerFieldIsNotUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_WORKABLE
            )
            .setField(WorkStep.Initial_Owner__c, INITIAL_OWNER_NAME);
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Initial_Owner__c = INITIAL_OWNER_NAME,
            Status__c = WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField = newWorkStep.Start_Date_Time__c;
        Date updatedStartDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            INITIAL_OWNER_NAME,
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time, Initial Owner and Completed Date/Time fields are
     * updated when WorkStep status is updated from 'Not Started' to 'Complete'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromNotStartedToCompleteThenAuditFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedCompletedDateTime = newWorkStep.Completed_Date_Time__c;
        DateTime updatedStartDateTime = newWorkStep.Start_Date_Time__c;
        Date updatedCompletedDate = Date.newInstance(
            updatedCompletedDateTime.year(),
            updatedCompletedDateTime.month(),
            updatedCompletedDateTime.day()
        );
        Date updatedStartDate = Date.newInstance(
            updatedStartDateTime.year(),
            updatedStartDateTime.month(),
            updatedStartDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedCompletedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            UserInfo.getName(),
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time, Initial Owner and Completed Date/Time fields are
     * updated when WorkStep status is updated from 'Not Workable' to 'Complete'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromNotWorkableToCompleteThenAuditFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_WORKABLE
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedCompletedDateTime = newWorkStep.Completed_Date_Time__c;
        DateTime updatedStartDateTime = newWorkStep.Start_Date_Time__c;
        Date updatedCompletedDate = Date.newInstance(
            updatedCompletedDateTime.year(),
            updatedCompletedDateTime.month(),
            updatedCompletedDateTime.day()
        );
        Date updatedStartDate = Date.newInstance(
            updatedStartDateTime.year(),
            updatedStartDateTime.month(),
            updatedStartDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedCompletedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            UserInfo.getName(),
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time and Initial Owner fields are not updated when WorkStep
     * status is updated to 'Complete' from status other than Not Workable/Not Started.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromInProgressToCompleteThenInitialAuditFieldsNotUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedCompletedDateTime = newWorkStep.Completed_Date_Time__c;
        Date updatedCompletedDate = Date.newInstance(
            updatedCompletedDateTime.year(),
            updatedCompletedDateTime.month(),
            updatedCompletedDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedCompletedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Start_Date_Time__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Completed Date/Time, Last QAed By, Last QA Date/Time fields are updated
     * when WorkStep status is updated from 'Ready for QA' to 'Complete'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromReadyForQaToCompleteThenQADateFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_READY_FOR_QA
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_COMPLETE
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField;
        dateTimeValueOfField = newWorkStep.Completed_Date_Time__c;
        Date updatedCompletedDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        dateTimeValueOfField = newWorkStep.Last_QA_Date_Time__c;
        Date updatedLastQaDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(
            System.today(),
            updatedCompletedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            System.today(),
            updatedLastQaDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            UserInfo.getUserId(),
            newWorkStep.Last_QAed_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Last Blocked Date/Time field is updated when WorkStep status
     * is updated to 'Blocked'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusToBlockedThenLastBlockedDateAndTimeIsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_READY_FOR_QA
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField = newWorkStep.Last_Blocked_Date_Time__c;
        Date updatedLastBlockedDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastBlockedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time, Last Escalation Date/Time and Initial Owner fields
     * are updated when WorkStep status is updated from 'Not Started' to 'Escalated'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromNotStartedToEscalatedThenAuditFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedLastEscalationDateTime = newWorkStep.Last_Escalation_Date_Time__c;
        DateTime updatedStartDateTime = newWorkStep.Start_Date_Time__c;
        Date updatedLastEscalationDate = Date.newInstance(
            updatedLastEscalationDateTime.year(),
            updatedLastEscalationDateTime.month(),
            updatedLastEscalationDateTime.day()
        );
        Date updatedStartDate = Date.newInstance(
            updatedStartDateTime.year(),
            updatedStartDateTime.month(),
            updatedStartDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastEscalationDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            UserInfo.getName(),
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Last_QA_Date_Time__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Last_QAed_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time, Last Escalation Date/Time and Initial Owner fields
     * are updated when WorkStep status is updated from 'Not Workable' to 'Escalated'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromNotWorkableToEscalatedThenAuditFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_WORKABLE
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedLastEscalationDateTime = newWorkStep.Last_Escalation_Date_Time__c;
        DateTime updatedStartDateTime = newWorkStep.Start_Date_Time__c;
        Date updatedLastEscalationDate = Date.newInstance(
            updatedLastEscalationDateTime.year(),
            updatedLastEscalationDateTime.month(),
            updatedLastEscalationDateTime.day()
        );
        Date updatedStartDate = Date.newInstance(
            updatedStartDateTime.year(),
            updatedStartDateTime.month(),
            updatedStartDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastEscalationDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            UserInfo.getName(),
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Last_QA_Date_Time__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Last_QAed_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time and Initial Owner fields are not updated when WorkStep
     * status is updated to 'Escalated' from status other than Not Workable/Not Started.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromInProgressToEscalatedThenInitialAuditFieldsNotUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_IN_PROGRESS
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedLastEscalationDateTime = newWorkStep.Last_Escalation_Date_Time__c;
        Date updatedLastEscalationDate = Date.newInstance(
            updatedLastEscalationDateTime.year(),
            updatedLastEscalationDateTime.month(),
            updatedLastEscalationDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastEscalationDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Start_Date_Time__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            null,
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Last Escalation Date/Time, Last QAed By, Last QA Date/Time fields
     * are updated when WorkStep status is updated from 'Ready for QA' to 'Escalated'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromReadyForQaToEscalatedThenQADateFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_READY_FOR_QA
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_ESCALATED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField;
        dateTimeValueOfField = newWorkStep.Last_Escalation_Date_Time__c;
        Date updatedLastEscalationDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        dateTimeValueOfField = newWorkStep.Last_QA_Date_Time__c;
        Date updatedLastQaDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastEscalationDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            System.today(),
            updatedLastQaDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            UserInfo.getUserId(),
            newWorkStep.Last_QAed_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Last Prepared By and Initial Preparation Date/Time fields are updated
     * when WorkStep status is moved to 'Ready for QA'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusToReadyForQaThenInitialPreparationDateTimeAndLastPrepardByFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_READY_FOR_QA
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField = newWorkStep.Initial_Preparation_Date_Time__c;
        Date updatedInitialPreparationDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(
            System.today(),
            updatedInitialPreparationDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            UserInfo.getUserId(),
            newWorkStep.Last_Prepared_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Initial Preparation Date/Time field is not updated when
     * Initial Preparation Date/Time field is not null and WorkStep status
     * is moved to 'Ready for QA'.
     */
    @isTest
    private static void testWhenInitialPreparationDateTimeFieldIsNotNullThenInitialPreparationDateTimeIsNotUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_NOT_STARTED
            )
            .setField(WorkStep.Initial_Preparation_Date_Time__c, System.now().addDays(-1));
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Initial_Preparation_Date_Time__c = System.now().addDays(-1),
            Status__c = WORK_STEP_STATUS_READY_FOR_QA
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField = newWorkStep.Initial_Preparation_Date_Time__c;
        Date updatedInitialPreparationDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(
            true,
            updatedInitialPreparationDate != System.today(),
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            UserInfo.getUserId(),
            newWorkStep.Last_Prepared_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Last QAed By, Last QA Date/Time fields are updated
     * when WorkStep status is updated from 'Ready for QA' to 'QA Complete'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromReadyForQaToQaCompleteThenQADateFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_READY_FOR_QA
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_QA_COMPLETE
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime dateTimeValueOfField;
        dateTimeValueOfField = newWorkStep.Last_QA_Date_Time__c;
        Date updatedLastQaDate = Date.newInstance(
            dateTimeValueOfField.year(),
            dateTimeValueOfField.month(),
            dateTimeValueOfField.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastQaDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            UserInfo.getUserId(),
            newWorkStep.Last_QAed_By__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Last QAed By, Last QA Date/Time fields are not updated
     * when WorkStep status is directly updated to 'QA Complete' from 'Not Started'.
     */
    @isTest
    private static void testWhenStatusDirectlyUpdatedToQaCompleteThenQADateFieldsNotUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStep oldMockWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldMockWorkStep.Id, oldMockWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldMockWorkStep.Id,
            Status__c = WORK_STEP_STATUS_QA_COMPLETE
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        System.assertEquals(
            true,
            newWorkStep.Last_QA_Date_Time__c == null,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(
            true,
            newWorkStep.Last_QAed_By__c == null,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test 'Previous spent days in blocked status' Field is updated
     * with 'Time spent in blocked days' previous value when WorkStep status is moved
     * from 'Blocked' to any other status.
     */
    @isTest
    private static void testWhenUnBlockedThenPreviousSpentDaysInBlockedStatusFieldIsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
                WORK_STEP_STATUS_BLOCKED
            )
            .setField(WorkStep.Status_Reason__c, WORK_STEP_STATUS_REASON_OTHER)
            .setField(
                WorkStep.Time_Spent_In_Blocked_Days_Calculated__c,
                TOTAL_NUMBER_OF_DAYS_BLOCKED
            )
            .setField(
                WorkStep.Previous_Spent_Days_In_Blocked_Status__c,
                PREVIOUS_NUMBER_OF_DAYS_BLOCKED
            );
        WorkStep oldMockWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldMockWorkStep.Id, oldMockWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldMockWorkStep.Id,
            Status__c = WORK_STEP_STATUS_NOT_STARTED
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        System.assertEquals(
            TOTAL_NUMBER_OF_DAYS_BLOCKED,
            newWorkStep.Previous_Spent_Days_In_Blocked_Status__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }

    /**
     * @description To test Start Date/Time and Initial Owner fields are updated
     * when WorkStep status is updated from 'Not Workable' to 'Blocked'.
     */
    @isTest
    private static void testWhenUpdateWorkStepStatusFromNotWorkableToBlockedThenAuditFieldsUpdated() {
        Map<Id, WorkStep> oldWorkSteps = new Map<Id, WorkStep>();
        Fake oldWorkStepFakeInstance = MockWorkStepDataBuilder.createWorkStepRecordWithProvidedStatusValue(
            WORK_STEP_STATUS_NOT_WORKABLE
        );
        WorkStep oldWorkStep = MockWorkStepDataBuilder.convertToWorkStepObject(
            oldWorkStepFakeInstance
        );
        oldWorkSteps.put(oldWorkStep.Id, oldWorkStep);
        WorkStep newWorkStep = new WorkStep(
            Id = oldWorkStep.Id,
            Status__c = WORK_STEP_STATUS_BLOCKED,
            Status_Reason__c = WORK_STEP_STATUS_REASON_OTHER
        );
        WorkStepsStatusRelatedDatesCalcService.updateAssociatedDateTrackingFieldsOnStatusChange(
            new List<WorkStep>{ newWorkStep },
            oldWorkSteps
        );
        DateTime updatedLastBlockedDateTime = newWorkStep.Last_Blocked_Date_Time__c;
        DateTime updatedStartDateTime = newWorkStep.Start_Date_Time__c;
        Date updatedLastBlockedDate = Date.newInstance(
            updatedLastBlockedDateTime.year(),
            updatedLastBlockedDateTime.month(),
            updatedLastBlockedDateTime.day()
        );
        Date updatedStartDate = Date.newInstance(
            updatedStartDateTime.year(),
            updatedStartDateTime.month(),
            updatedStartDateTime.day()
        );
        System.assertEquals(
            System.today(),
            updatedLastBlockedDate,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
        System.assertEquals(System.today(), updatedStartDate, FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE);
        System.assertEquals(
            UserInfo.getName(),
            newWorkStep.Initial_Owner__c,
            FIELD_UPDATE_NEGATIVE_ASSERT_MESSAGE
        );
    }
}