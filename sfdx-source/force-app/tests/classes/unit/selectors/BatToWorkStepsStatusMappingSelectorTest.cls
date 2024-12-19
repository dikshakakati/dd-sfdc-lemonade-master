/**
 * @author DoorDash
 * @date 03/21/2023
 * @description Test class for IntegrationRequests class.
 */
@isTest
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts, PMD.NcssTypeCount')
public class BatToWorkStepsStatusMappingSelectorTest {
    private static final String ASSERT_MESSAGE_COUNT_NOT_MATCHING = 'assert count not matching';
    private static final String BAT_STATUS_MENU_BLOCK = 'MENU_BLOCK';
    private static final String EXCLUSION_CODE_MENU_FAILURE = 'MENU_COMPLIANCE_FAILURE';
    private static final String WORK_STEP_INGEST_MENU = 'Ingest Menu';
    private static final String WORK_STEP_QA_MENU = 'QA Menu';
    private static final String WORK_STEP_STATUS_ESCALATED = 'Escalated';
    private static final String STATUS_REASON_MENU_FAILURE = 'Menu Compliance failure';
    private static final String STATUS_REASON_POS_INGESTION_FAILURE = 'POS Ingestion failure';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
	private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be BatToWorkStepsStatusMapping custom metadata';

    /**
     * @description testWhenSelectorMethodsCalledThenReturnAppropriateValues.
     */
    @isTest
    private static void testWhenSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Bat_To_WorkSteps_Status_Mapping__mdt.Bat_Status__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Exclusion_Code__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Work_Step_Status__c,
           	Bat_To_WorkSteps_Status_Mapping__mdt.Work_Step_Type__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Status_Reason__c,
            Bat_To_WorkSteps_Status_Mapping__mdt.Work_Plan_Status__c
        };
        BatToWorkStepsStatusMappingSelector batToWorkStepsStatusMappingSelectorInstance = new BatToWorkStepsStatusMappingSelector();
        Schema.SObjectType typeOfObject = BatToWorkStepsStatusMappingSelectorInstance.SObjectType();
        List<Schema.SObjectField> sObjectFields = BatToWorkStepsStatusMappingSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            Bat_To_WorkSteps_Status_Mapping__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }
    /**
     * @description To test work step mapping selector standard methods.
     */
    @isTest
    private static void testWhenUpdateIntegrationRequestReceivedThenUpdateTheWorkSteps() {
        List<Bat_To_WorkSteps_Status_Mapping__mdt> settingList = getBatToWorkStepMapping();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
        fflib_ISObjectUnitOfWork.class
        );
        IBatToWorkStepsStatusMappingSelector metaDataMappingSelector =
        (IBatToWorkStepsStatusMappingSelector) mocks.mock(BatToWorkStepsStatusMappingSelector.class);

        mocks.startStubbing();
        mocks.when(metaDataMappingSelector.SObjectType()).thenReturn(Bat_To_WorkSteps_Status_Mapping__mdt.SObjectType);
        mocks.when(metaDataMappingSelector.getAllValues()).thenReturn(settingList);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(metaDataMappingSelector);
        Application.UnitOfWork.setMock(mockUow);

        List<Bat_To_WorkSteps_Status_Mapping__mdt> settingResult = BatToWorkStepsStatusMappingSelector.newInstance().getAllValues();
            System.assertEquals(
                2,
                settingResult.size(),
                ASSERT_MESSAGE_COUNT_NOT_MATCHING
            );
    }
    private static List<Bat_To_WorkSteps_Status_Mapping__mdt> getBatToWorkStepMapping(){
        return new List<Bat_To_WorkSteps_Status_Mapping__mdt>{
            new Bat_To_WorkSteps_Status_Mapping__mdt(
                Label = 'Work Plan Mapping',
                DeveloperName = 'Work_Pan_Mapping_1',
                Bat_Status__c = BAT_STATUS_MENU_BLOCK,
                Exclusion_Code__c = '',
                Status_Reason__c = STATUS_REASON_POS_INGESTION_FAILURE,
                Work_Step_Status__c = WORK_STEP_STATUS_ESCALATED,
                Work_Step_Type__c = WORK_STEP_INGEST_MENU
            ),
            new Bat_To_WorkSteps_Status_Mapping__mdt(
                Label = 'Work Plan Mapping',
                DeveloperName = 'Work_Pan_Mapping_2',
                Bat_Status__c = BAT_STATUS_MENU_BLOCK,
                Exclusion_Code__c = EXCLUSION_CODE_MENU_FAILURE,
                Status_Reason__c = STATUS_REASON_MENU_FAILURE,
                Work_Step_Status__c = WORK_STEP_STATUS_ESCALATED,
                Work_Step_Type__c = WORK_STEP_QA_MENU
            )
        };
    }
}