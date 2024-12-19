/**
 * @author DoorDash
 * @date 02/15/2024
 * @description Test class for CcpWorkOrderValidationsSelector class.
 */
@isTest
public class CcpWorkOrderValidationsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: There is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: The object type must be CCP Workorder Validation';
    private static final String ASSERT_MESSAGE_NOT_RETRIEVED = 'Unexpected result: The Standard Rate Card Tiers were not retrieved appropriately.';

    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        CcpWorkOrderValidationsSelector ccpWorkOrderValidationsSelectorInstance = new CcpWorkOrderValidationsSelector();

        Schema.SObjectType typeOfObj = ccpWorkOrderValidationsSelectorInstance.getSObjectType();
        List<Schema.SObjectField> fieldList = ccpWorkOrderValidationsSelectorInstance.getSObjectFieldList();

        CcpWorkOrderValidationsSelector.newInstance();

        System.assertEquals(
            Schema.CCP_Workorder_Validation__mdt.SObjectType,
            typeOfObj,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            new List<Schema.SObjectField>{
                CCP_Workorder_Validation__mdt.Name__c,
                CCP_Workorder_Validation__mdt.isBusinessAccount__c,
                CCP_Workorder_Validation__mdt.isDrivePackage__c,
                CCP_Workorder_Validation__mdt.isProcessingExistingAccounts__c,
                CCP_Workorder_Validation__mdt.Package_Name__c,
                CCP_Workorder_Validation__mdt.Work_Order_Type__c,
                CCP_Workorder_Validation__mdt.Work_Order_SubType__c
            },
            fieldList,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test Standard Rate Card Tiers custom metadata query.
     */
    @isTest
    private static void testWhenGetAllValuesMethodCalledThenReturnAllMetadataRecords() {
        List<CCP_Workorder_Validation__mdt> standardRateCardTiers = CcpWorkOrderValidationsSelector.newInstance()
            .selectAllWorkOrderValidationRules();
        System.assertEquals(!standardRateCardTiers.isEmpty(), true, ASSERT_MESSAGE_NOT_RETRIEVED);
    }
}