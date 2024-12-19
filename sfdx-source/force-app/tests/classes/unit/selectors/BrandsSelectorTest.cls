/**
 * @author Deloitte
 * @date 10/31/2022
 * @description Test class for BrandsSelector class.
 */
@isTest(SeeAllData=false)
private class BrandsSelectorTest {
    private static final String LICENSOR = 'Licensor';
    private static final string INVALID_ASSERT_MESSAGE = 'Unexpected results';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String UNIQUE_IDENTIFIER = '92108a53-e8d9-4a0c-9193-9152aeb86fe4';
    /**
     * @description To test Contructor instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c = 'SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;
        Brand__c brandMcDonalds = new Brand__c(
            Name = 'McDonalds',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandMcDonalds;
        BrandsSelector brandsInstance = new BrandsSelector();
        Schema.SObjectType typeOfObj = brandsInstance.getSObjectType();
        System.assertEquals(
            Schema.Brand__c.SObjectType,
            typeOfObj,
            'The object type must be Brand'
        );
        List<Schema.SObjectField> fieldList = brandsInstance.getSObjectFieldList();
        System.assertEquals(
            new List<Schema.SObjectField>{ Brand__c.Id, Brand__c.Name, Brand__c.Price_Range__c },
            fieldList,
            'Mismatch in field list'
        );
    }

    /**
     * @description To test the selection of Brands by the passed Ids.
     */
    @isTest
    private static void testWhenSelectByIdThenReturnBrands() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;
        Brand__c brandMcDonalds = new Brand__c(
            Name = 'McDonalds',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandMcDonalds;
        List<Brand__c> queryResult = BrandsSelector.newInstance()
            .selectById(new Set<Id>{ brandKFC.Id, brandMcDonalds.Id });
        System.assertEquals(2, queryResult.size(), 'Failed to query Brands by Id');
    }

    /**
     * @description To test the selection of Brands by the passed Ids.
     * for method selectBrandsByIdWithParentIds
     */
    @isTest
    private static void testWhenSelectBrandsByIdWithParentIdsThenReturnExpectedValues() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;
        Brand__c brandMcDonalds = new Brand__c(
            Name = 'McDonalds',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandMcDonalds;
        List<Brand__c> queryResult01 = BrandsSelector.newInstance()
            .selectBrandsByIdWithParentIds(new Set<Id>{ brandKFC.Id, brandMcDonalds.Id });
        List<Brand__c> queryResult02 = BrandsSelector.newInstance()
            .selectBrandsByIdWithParentIds(new Set<Id>{ brandKFC.Id });
        List<Brand__c> queryResult03 = BrandsSelector.newInstance()
            .selectBrandsByIdWithParentIds(new Set<Id>{ brandMcDonalds.Id });
        System.assertEquals(2, queryResult01.size(), 'Failed to query Brands by Id');
        System.assertEquals(1, queryResult02.size(), 'Failed to query Brands by Id');
        System.assertEquals(1, queryResult03.size(), 'Failed to query Brands by Id');
        System.assertEquals(brandKFC.Id, queryResult02[0].Id, 'Failed to query Brands by Id');
        System.assertEquals(brandMcDonalds.Id, queryResult03[0].Id, 'Failed to query Brands by Id');
    }

    /**
     * @description To test the selection of Brands by names passed
     * for method getBrandsByBrandName
     */
    @isTest
    private static void testWhenValidateBrandNameThenReturnExpectedValues() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = businessAccountRecordTypeId,
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandKFC;
        Brand__c brandMcDonalds = new Brand__c(
            Name = 'McDonalds',
            Brand_Owner__c = corporateAccountWithBrand.Id
        );
        insert brandMcDonalds;
        List<Brand__c> queryResult01 = BrandsSelector.newInstance()
            .getBrandsByBrandName(new List<String>{ 'KFC', 'McDonalds' });
        List<Brand__c> queryResult02 = BrandsSelector.newInstance()
            .getBrandsByBrandName(new List<String>{ 'KFC' });
        List<Brand__c> queryResult03 = BrandsSelector.newInstance()
            .getBrandsByBrandName(new List<String>{ 'McDonalds' });
        System.assertEquals(2, queryResult01.size(), 'Failed to query Brands by Id');
        System.assertEquals(1, queryResult02.size(), 'Failed to query Brands by Id');
        System.assertEquals(1, queryResult03.size(), 'Failed to query Brands by Id');
        System.assertEquals(brandKFC.Id, queryResult02[0].Id, 'Failed to query Brands by Id');
        System.assertEquals(brandMcDonalds.Id, queryResult03[0].Id, 'Failed to query Brands by Id');
    }

    /**
     * @description To test the selection of Brands by the passed uuids.
     */
    @isTest
    private static void testWhenUniqueIdentifiersPassedThenReturnBrands() {
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id,
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        insert brandKFC;

        Test.startTest();
        List<Brand__c> queryResult = BrandsSelector.newInstance()
            .selectBrandsByUniqueIdentifiers(new Set<String>{ UNIQUE_IDENTIFIER });
        Test.stopTest();
        System.assertEquals(1, queryResult.size(), INVALID_ASSERT_MESSAGE);
    }
    /**
     * @description To test the selection of Brands by the passed AccountIds.
     */
    @isTest
    private static void testWhenAccountIdsPassedThenReturnBrands() {
        Account corporateAccountWithBrand = new Account(
            Name = 'McDonalds Canada',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID,
            Type = 'Corporate',
            Segment__c ='SMB'
        );
        insert corporateAccountWithBrand;
        Brand__c brandKFC = new Brand__c(
            Name = 'KFC',
            Brand_Owner__c = corporateAccountWithBrand.Id,
            Unique_Identifier__c = UNIQUE_IDENTIFIER
        );
        insert brandKFC;

        Test.startTest();
        List<Brand__c> queryResult = BrandsSelector.newInstance()
            .selectBrandsByAccountIds(new Set<Id>{ corporateAccountWithBrand.Id });
        Test.stopTest();
        System.assertEquals(1, queryResult.size(), INVALID_ASSERT_MESSAGE);
    }
}