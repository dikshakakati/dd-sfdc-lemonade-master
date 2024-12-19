/**
 * @author Deloitte
 * @date 08/25/2022
 * @description Test class for NintexWorkOrderMappingsSelector class.
 */
@isTest(SeeAllData=false)
private class NintexWorkOrderMappingsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be Nintex To Work Order Mapping custom metadata';
    private static final String ASSERT_MESSAGE_NO_NINTEX_WORKORDER_MAPPINGS_RETURNED = 'Unexpected result: selector call failed to return all Nintex To Work Order Mappings';
    private static final String NINTEX_USE_CASE_DRIVE_FORM = 'Drive - Amendment';
    private static final String NINTEX_USE_CASE_NEW_FRANCHISE = 'New Franchise - Unknown';
    private static final String TYPE_DRIVE = 'Drive';
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_SUB_TYPE = 'Partnership creation/update';

    /**
     * @description To test Nintex WorkOrder Mappings selector standard methods.
     */
    @isTest
    private static void testWhenSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
            Nintex_Work_Order_Mapping__mdt.Work_Order_Provisioning_Process__c,
            Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c,
            Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c
        };
        NintexWorkOrderMappingsSelector nintexWorkOrderMappingsSelectorInstance = new NintexWorkOrderMappingsSelector();
        Schema.SObjectType typeOfObject = nintexWorkOrderMappingsSelectorInstance.SObjectType();
        List<Schema.SObjectField> sObjectFields = nintexWorkOrderMappingsSelectorInstance.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            Nintex_Work_Order_Mapping__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test selection of all Nintex To Work Order Mappings.
     */
    @isTest
    private static void testWhenGetAllMappingsCalledThenAllCustomMetadataRecordsReturned() {
        List<Nintex_Work_Order_Mapping__mdt> nintexToWorkOrderMappings = new List<Nintex_Work_Order_Mapping__mdt>();
        Fake marketplaceWorkOrderMappingFakeInstance = new Fake(
                Nintex_Work_Order_Mapping__mdt.class
            )
            .setField(
                Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c,
                NINTEX_USE_CASE_NEW_FRANCHISE
            )
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_MARKETPLACE)
            .setFakeId();
        nintexToWorkOrderMappings.add(
            (Nintex_Work_Order_Mapping__mdt) marketplaceWorkOrderMappingFakeInstance.toSObject()
        );
        Fake driveWorkOrderMappingFakeInstance = new Fake(Nintex_Work_Order_Mapping__mdt.class)
            .setField(Nintex_Work_Order_Mapping__mdt.Nintex_Use_Case__c, NINTEX_USE_CASE_DRIVE_FORM)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Type__c, TYPE_DRIVE)
            .setField(Nintex_Work_Order_Mapping__mdt.Work_Order_Sub_Type__c, WORK_ORDER_SUB_TYPE)
            .setFakeId();
        nintexToWorkOrderMappings.add(
            (Nintex_Work_Order_Mapping__mdt) driveWorkOrderMappingFakeInstance.toSObject()
        );
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        NintexWorkOrderMappingsSelector mockNintexWorkOrderMappingsSelector = (NintexWorkOrderMappingsSelector) mocks.mock(
            NintexWorkOrderMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockNintexWorkOrderMappingsSelector.getSObjectType())
            .thenReturn(Nintex_Work_Order_Mapping__mdt.SObjectType);
        mocks.when(mockNintexWorkOrderMappingsSelector.getAllMappings())
            .thenReturn(nintexToWorkOrderMappings);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockNintexWorkOrderMappingsSelector);
        List<Nintex_Work_Order_Mapping__mdt> queryResult = NintexWorkOrderMappingsSelector.newInstance()
            .getAllMappings();
        System.assertEquals(
            Nintex_Work_Order_Mapping__mdt.getall().values(),
            queryResult,
            ASSERT_MESSAGE_NO_NINTEX_WORKORDER_MAPPINGS_RETURNED
        );
    }
}