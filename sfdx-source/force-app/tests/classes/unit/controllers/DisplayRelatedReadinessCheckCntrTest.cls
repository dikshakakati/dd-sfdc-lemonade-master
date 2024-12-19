/*
*@author Deloitte
*@date 26 June 2024
*@description Test class for DisplayRelatedReadinessCheckController.
*/

@isTest(SeeAllData=false)
public class DisplayRelatedReadinessCheckCntrTest{
    private static final String ERROR_MESSAGE = 'Unexpected Error: Values do not match.';
    private static final String COLUMNS_TO_DISPLAY_STATIC_CONFIG = 'RelatedReadinessCheckColumnsViewOrder';


    /*
    *@description-To test the retrieved field values when getFields method is called.
    */
    @isTest
    private static void testWhenGetFieldsMethodCalledThenReturnColumnsWithCorrectFieldsAndAttributes() {
        String jsonData = DisplayRelatedReadinessCheckController.getFields();
        List<DynamicColumn> dynamicColumns = (List<DynamicColumn>) JSON.deserialize(jsonData,List<DynamicColumn>.class);
        String columnsToDisplay = StaticConfigurationsSelector.newInstance().getInstanceValue(COLUMNS_TO_DISPLAY_STATIC_CONFIG).Configuration_Value__c;
        for (DynamicColumn eachDynamicColumn : dynamicColumns) {
            System.assertEquals(true,columnsToDisplay.contains(eachDynamicColumn.label),ERROR_MESSAGE);
        }
    }

    /*
    *@description To test if Readiness_Check_Failure__c details are retrieved when getReadinessCheckFailureDetails method is called.
    */
    @isTest
    private static void testWhenGetReadinessCheckRecordsThenReturnParentWorkOrder() {
        Id parentWorkOrderId = Fake.generateId(WorkOrder.class);
        Readiness_Check_Failure__c[] newReadinessFailureRecords = new List<Readiness_Check_Failure__c>{
            new Readiness_Check_Failure__c(
                Id = Fake.generateId(Readiness_Check_Failure__c.class),
                Account_Name__c = Fake.generateId(Account.class),
                Field_Name__c = 'Phone',
                Error_Message__c ='Please ensure Tax ID is populated.',
                Status__c='Active',
                Object_Name__c='Account',
                Parent_Work_Order__c=parentWorkOrderId
            ),
            new Readiness_Check_Failure__c(
                Id = Fake.generateId(Readiness_Check_Failure__c.class),
                Account_Name__c = Fake.generateId(Account.class),
                Field_Name__c = 'Phone',
                Error_Message__c ='Please ensure the Contact with Decision Maker role is created on the store account.',
                Status__c='Active',
                Object_Name__c='Contact',
                Parent_Work_Order__c=parentWorkOrderId
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IReadinessCheckFailuresSelector selectorMock = (IReadinessCheckFailuresSelector) mocks.mock(IReadinessCheckFailuresSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Readiness_Check_Failure__c.SObjectType);
        mocks.when(selectorMock.selectByParentWorkOrderIds((Set<Id>) fflib_Match.anyObject())).thenReturn(newReadinessFailureRecords);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        List<Readiness_Check_Failure__c> relatedReadinessCheckRecords = DisplayRelatedReadinessCheckController.getReadinessCheckFailureDetails(parentWorkOrderId);
        List<Readiness_Check_Failure__c> relatedReadinessCheckUpdatedRecords = DisplayRelatedReadinessCheckController.getReadinessCheckFailureUpdatedDetails(parentWorkOrderId);
        System.assertEquals(2, relatedReadinessCheckRecords.size(), ERROR_MESSAGE);
        System.assertEquals(relatedReadinessCheckRecords[0].Object_Name__c, 'Account', ERROR_MESSAGE);
        System.assertEquals(relatedReadinessCheckUpdatedRecords[1].Object_Name__c, 'Contact', ERROR_MESSAGE);
    }
}