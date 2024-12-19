/**
 * @description This is test class for ContractTableMappingSelector class
 */
@isTest(seeAllData=false)
public class ContractTableMappingSelectorTest {
    private static final String OBJECT_CONTRACT = 'Contract';
    private static final String OBJECT_SUBSCRIPTION = 'Subscription';
    private static final String SPLIT_CATEGORY_CORE = 'Core';
    private static final String ACCOUNT_SEGEMENT_SMB = 'SMB';
    private static final String ACCOUNT_SEGEMENT_ENT = 'Enterprise';
    private static final String TYPE_TEXT = 'Text';
    private static final String ASSERT_MESSAGE_ERROR = 'Number of mappings returned is not as expected';

    @isTest
    private static void testWhenAllSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Contract_Table_Mapping__mdt> customMetadataMocks = new List<Contract_Table_Mapping__mdt>{
            new Contract_Table_Mapping__mdt(
                MasterLabel = 'Contract Table Mapping',
                DeveloperName = 'Contract_Table_Mapping',
                Order__c = 1,
                Segment__c = 'Segment1',
                Hyper_Link_Display_Field__c = 'Link Field 1',
                Type__c = 'Type1'
            )
        };
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            Contract_Table_Mapping__mdt.Label,
            Contract_Table_Mapping__mdt.DeveloperName,
            Contract_Table_Mapping__mdt.API_Name__c,
            Contract_Table_Mapping__mdt.Segment__c,
            Contract_Table_Mapping__mdt.Hyper_Link_Display_Field__c,
            Contract_Table_Mapping__mdt.Order__c,
            Contract_Table_Mapping__mdt.Type__c,
            Contract_Table_Mapping__mdt.Object__c,
            Contract_Table_Mapping__mdt.Applicable_for_Product__c
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ContractTableMappingSelector mockCountryAttributesMapping = (ContractTableMappingSelector) mocks.mock(
            ContractTableMappingSelector.class
        );

        mocks.startStubbing();
        mocks.when(mockCountryAttributesMapping.getSObjectType())
            .thenReturn(Contract_Table_Mapping__mdt.SObjectType);
        mocks.when(mockCountryAttributesMapping.getAllValues()).thenReturn(customMetadataMocks);
        mocks.when(mockCountryAttributesMapping.getSObjectFieldList())
            .thenReturn(sObjectFieldsMock);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockCountryAttributesMapping);

        Schema.SObjectType typeOfObject = ContractTableMappingSelector.newInstance().SObjectType();
        List<Schema.SObjectField> sObjectFields = ContractTableMappingSelector.newInstance()
            .getSObjectFieldList();
        List<Contract_Table_Mapping__mdt> allContractTableData = ContractTableMappingSelector.newInstance()
            .getAllValues();

        System.assertEquals(
            Contract_Table_Mapping__mdt.SObjectType,
            typeOfObject,
            'Unexpected Error: The object type must be Country Attributes Mapping Metadata'
        );
        System.assertEquals(
            Contract_Table_Mapping__mdt.getAll().values(),
            allContractTableData,
            'Unexpected Error: Mismatch in list of  Country Attributes Mapping Metadata'
        );
        System.assertEquals(
            sObjectFieldsMock,
            sObjectFields,
            'Unexpected Error: Mismatch in field list'
        );
    }

    @isTest
    static void testWhenSelectContractTableMappingSortedByOrderInvokedThenReturnSortedRecords() {
        ContractTableMappingSelector selector = new ContractTableMappingSelector();

        String customerSegment = 'Test Segment';
        String initiatedFromSobject = 'Account';
        Test.startTest();
        List<Contract_Table_Mapping__mdt> result = selector.selectContractTableMappingSortedByOrder(
            initiatedFromSobject,
            customerSegment
        );
        Test.stopTest();
        System.assertEquals(0, result.size(), 'Number of mappings returned is not as expected');
    }
    /**
     * @description To validate if subscription records are returned if the Object is set as
     * Subscription and split category as Core
     */

    @isTest
    private static void testWhenSelectContractTableMappingForSubscriptionsInvokedThenReturnSortedRecords() {
        ContractTableMappingSelector contractSelectorMock = new ContractTableMappingSelector();

        String customerSegment = ACCOUNT_SEGEMENT_SMB;
        String splitCategory = SPLIT_CATEGORY_CORE;

        Test.startTest();
        List<Contract_Table_Mapping__mdt> result = contractSelectorMock.selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
            customerSegment,
            splitCategory
        );
        Test.stopTest();
        System.assertEquals(9, result.size(), ASSERT_MESSAGE_ERROR);
    }
    /**
     * @description To validate if subscription records are not returned if the Object is set as
     * Contract and split category as A&P
     */
    @isTest
    private static void testWhenSelectContractTableMappingForSubscriptionsInvokedThenDoNotReturnRecords() {
        ContractTableMappingSelector contractSelectorMock = new ContractTableMappingSelector();

        String customerSegment = ACCOUNT_SEGEMENT_ENT;
        String splitCategory = SPLIT_CATEGORY_CORE;

        Test.startTest();
        List<Contract_Table_Mapping__mdt> result = contractSelectorMock.selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
            customerSegment,
            splitCategory
        );
        Test.stopTest();
        System.assertEquals(0, result.size(), ASSERT_MESSAGE_ERROR);
    }

    /**
     * @description To validate if services records are  returned if the Object is set as
     * services.
     */
    @isTest
    private static void testWhenSelectContractTableMappingForServicesInvokedThenReturnSortedRecords() {
        ContractTableMappingSelector contractSelectorMock = new ContractTableMappingSelector();

        String customerSegment = ACCOUNT_SEGEMENT_SMB;

        Test.startTest();
        List<Contract_Table_Mapping__mdt> result = contractSelectorMock.selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
            customerSegment
        );
        Test.stopTest();
        System.assertEquals(9, result.size(), ASSERT_MESSAGE_ERROR);
    }
    /**
     * @description To validate if services records are not returned if the Object is set as
     * Contract.
     */
    @isTest
    private static void testWhenSelectContractTableMappingForServicesInvokedThenNotReturnRecords() {
        ContractTableMappingSelector contractSelectorMock = new ContractTableMappingSelector();

        String customerSegment = ACCOUNT_SEGEMENT_ENT;

        Test.startTest();
        List<Contract_Table_Mapping__mdt> result = contractSelectorMock.selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
            customerSegment
        );
        Test.stopTest();
        System.assertEquals(0, result.size(), ASSERT_MESSAGE_ERROR);
    }
}