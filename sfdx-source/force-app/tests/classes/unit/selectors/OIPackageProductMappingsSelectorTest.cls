/**
 * @author Deloitte
 * @date 06/26/2024
 * @description Test class for OIPackageProductMappingsSelector class.
 * Suppressed Warnings since mock verify method does not require system assert statements.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class OIPackageProductMappingsSelectorTest {
    private static final String ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST = 'Unexpected result: there is a mismatch in fields list.';
    private static final String ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE = 'Unexpected result: the object type must be OIPackageProductMapping custom metadata';
    private static final String ASSERT_MESSAGE_PACKAGE_PRODUCT_MAPPINGS_RETURNED = 'Unexpected result: selector call failed to return all package product Mappings';
    private static final String CUSTOM_METADATA_DEVELOPER_NAME = 'Marketplace_Marketplace';
    private static final String CUSTOM_METADATA_MASTER_LABEL = 'Marketplace Marketplace';
    private static final String MARKETPLACE = 'Marketplace';

    /**
     * @description To test standard methods in OIPackageProductMappingsSelector.
     */
    @isTest
    private static void testWhenStandardSelectorMethodsCalledThenReturnAppropriateValues() {
        List<Schema.SObjectField> sObjectFieldsMock = new List<Schema.SObjectField>{
            OIPackageProductMapping__mdt.DeveloperName,
            OIPackageProductMapping__mdt.MasterLabel,
            OIPackageProductMapping__mdt.Package__c,
            OIPackageProductMapping__mdt.Product_Category__c
        };
        OIPackageProductMappingsSelector packageProductMappingsSelector = new OIPackageProductMappingsSelector();
        Schema.SObjectType typeOfObject = packageProductMappingsSelector.SObjectType();
        List<Schema.SObjectField> sObjectFields = packageProductMappingsSelector.getSObjectFieldList();
        System.assertEquals(
            typeOfObject,
            OIPackageProductMapping__mdt.SObjectType,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
        System.assertEquals(
            sObjectFields,
            sObjectFieldsMock,
            ASSERT_MESSAGE_MISMATCH_IN_FIELDS_LIST
        );
    }

    /**
     * @description To test selection of all Pakage Product Mappings.
     */
    @isTest
    private static void testWhenGetAllMappingsCalledThenAllCustomMetadataRecordsReturned() {
        List<OIPackageProductMapping__mdt> customMetadataMocks = new List<OIPackageProductMapping__mdt>{
            new OIPackageProductMapping__mdt(
                DeveloperName = CUSTOM_METADATA_DEVELOPER_NAME,
                MasterLabel = CUSTOM_METADATA_MASTER_LABEL,
                Package__c = MARKETPLACE,
                Product_Category__c = MARKETPLACE
            )
        };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OIPackageProductMappingsSelector mockOIPackageProductMappingsSelector = (OIPackageProductMappingsSelector) mocks.mock(
            OIPackageProductMappingsSelector.class
        );
        mocks.startStubbing();
        mocks.when(mockOIPackageProductMappingsSelector.getSObjectType())
            .thenReturn(OIPackageProductMapping__mdt.SObjectType);
        mocks.when(mockOIPackageProductMappingsSelector.getAllMappings())
            .thenReturn(customMetadataMocks);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(mockOIPackageProductMappingsSelector);
        List<OIPackageProductMapping__mdt> productPackageMappings = OIPackageProductMappingsSelector.newInstance()
            .getAllMappings();
        System.assertEquals(
            !productPackageMappings.isEmpty(),
            true,
            ASSERT_MESSAGE_MISMATCH_IN_OBJECT_TYPE
        );
    }
}