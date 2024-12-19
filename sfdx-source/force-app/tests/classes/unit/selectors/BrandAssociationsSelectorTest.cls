/**
 * @author Deloitte
 * @date 05/04/2022
 * @description Test class for BrandAssociationsSelector class.
 */
@isTest(SeeAllData=false)
private class BrandAssociationsSelectorTest {
    private static final String ACCOUNT_NAME = 'Business';
    private static final String PARENT_ACCOUNT_NAME = 'Business';
    private static final String ACCOUNT_BUSINESS_RECORD_TYPE_ID = 'Business';
    private static final String ACCOUNT_STORE_RECORD_TYPE_ID = 'Store';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String AGGREGATE_BUSINESSACCOUNTNAME_FIELD_ALIAS = 'businessAccountName';
    private static final String AGGREGATE_BRANDNAME_FIELD_ALIAS = 'brandName';
    private static final String AGGREGATE_BRANDASSOCIATION_COUNT_ALIAS = 'brandAssociationsCount';
    private static final String INCORRECT_NUMBER_OF_BRAND_ASSOCIATIONS_ASSERT_MESSAGE = '';
    private static final String QUERY_RETURN_NO_BRAND_NAME_ASSERT_MESSAGE = '';
    private static final String QUERY_RETURN_NO_BUSINESS_NAME_ASSERT_MESSAGE = '';

    /**
     * @description This method used to test BrandAssociationsSelector class
     */
    @isTest
    private static void testWhenClassInstantiatesThenCall() {
        BrandAssociationsSelector selector = new BrandAssociationsSelector();
        List<Schema.SObjectField> fieldList = selector.getSObjectFieldList();
        Schema.SObjectType typeOfObj = selector.getSObjectType();
        System.assertEquals(
            new List<Schema.SObjectField>{
                Brand_Association__c.Brand_Name__c,
                Brand_Association__c.Business_Account_Name__c,
                Brand_Association__c.Id
            },
            fieldList,
            ' Mismatch in field list'
        );
        System.assertEquals(
            Schema.Brand_Association__c.SObjectType,
            typeOfObj,
            'The object type must be Contacts'
        );
    }

    /**
     * @description This method used to test brandAssosiationWithLicensorRelation method
     */
    @isTest
    private static void testWhenBrandInsertedThenCallmethod() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness,Segment__c='SMB'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness,Segment__c='SMB')
        };
        insert businessAccounts;

        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = 'B1', Brand_Owner__c = businessAccounts[0].Id),
            new Brand__c(Name = 'B2', Brand_Owner__c = businessAccounts[1].Id)
        };
        insert brands;

        Set<Id> brandIds = new Set<Id>{ brands[0].Id, brands[1].Id };
        Set<Id> businessIds = new Set<Id>{ businessAccounts[0].Id, businessAccounts[1].Id };
        BrandAssociationsSelector selector = new BrandAssociationsSelector();
        List<Brand_Association__c> brandAssosiations = selector.selectBrandAssociations(
            brandIds,
            businessIds
        );
        BrandAssociationsSelector.newInstance();
        System.assertEquals(
            2,
            brandAssosiations.size(),
            'The retrieved list of Brand Association is incorrect'
        );
    }
    /**
     * @description To test the selection of Brand Association having
     * business Account name and Brand name.
     */
    @isTest
    private static void testWhenBrandAssociationsWithBusinessAccountNameAndBrandNameExistOnBusinessAccountThenBrandAssociationsReturned() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> businessAccounts = new List<Account>{
            new Account(Name = 'Canada franchise', RecordTypeId = businessAccountRecordTypeId,Segment__c='SMB'),
            new Account(Name = 'Australia franchise', RecordTypeId = businessAccountRecordTypeId,Segment__c='SMB')
        };
        insert businessAccounts;

        List<Brand__c> brands = new List<Brand__c>{
            new Brand__c(Name = 'MC Donald', Brand_Owner__c = businessAccounts[0].Id),
            new Brand__c(Name = 'Dominos', Brand_Owner__c = businessAccounts[1].Id)
        };
        insert brands;
        Set<Id> brandIds = new Set<Id>{ brands[0].Id, brands[1].Id };
        Set<Id> businessIds = new Set<Id>{ businessAccounts[0].Id, businessAccounts[1].Id };
        List<Brand_Association__c> brandAssociations = BrandAssociationsSelector.newInstance()
            .selectByBrandsAndBusinessAccountIds(brandIds, businessIds);
        System.assertEquals(
            brandAssociations[0].Business_Account_Name__c,
            businessAccounts[0].Id,
            'No business account exist for brand association'
        );
        System.assertEquals(
            brandAssociations[0].Brand_Name__c,
            brands[0].Id,
            'No brand exist for brand association'
        );
    }

    /**
     * @description To test the selection of Brand Association when
     * business Account name and Brand name are not associated.
     */
    @isTest
    private static void testWhenBrandAssociationsWithBusinessAccountNameAndBrandNameDoesNotExistOnBusinessAccountThenBrandAssociationsNotReturned() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        List<Account> businessAccounts = new List<Account>{
            new Account(Name = 'Canada franchise', RecordTypeId = businessAccountRecordTypeId,Segment__c ='SMB'),
            new Account(Name = 'Australia franchise', RecordTypeId = businessAccountRecordTypeId,Segment__c='SMB')
        };
        insert businessAccounts;
        List<Brand__c> brands = new List<Brand__c>{
            new Brand__c(Name = 'MC Donald', Brand_Owner__c = businessAccounts[1].Id),
            new Brand__c(Name = 'Dominos', Brand_Owner__c = businessAccounts[1].Id)
        };
        insert brands;
        Set<Id> brandIds = new Set<Id>{ brands[0].id };
        Set<Id> businessIds = new Set<Id>{ businessAccounts[0].id };
        List<Brand_Association__c> brandAssociations = BrandAssociationsSelector.newInstance()
            .selectByBrandsAndBusinessAccountIds(brandIds, businessIds);
        System.assertEquals(0, brandAssociations.size(), 'No brand association records found');
    }

    /**
     * @description This method used to test selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds method
     */
    @isTest
    private static void testWhenAccountIdIsPassedThenOnlyRelatedBrandAssociationsAreReturned() {
        Id accRecordTypeBusiness = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Business')
            .getRecordTypeId();
        Account[] businessAccounts = new List<Account>{
            new Account(Name = 'Name1', RecordTypeId = accRecordTypeBusiness,Segment__c ='SMB'),
            new Account(Name = 'Name2', RecordTypeId = accRecordTypeBusiness,Segment__c ='SMB'),
            new Account(Name = 'Name3', RecordTypeId = accRecordTypeBusiness,Segment__c = 'SMB')
        };
        insert businessAccounts;

        Brand__c[] brands = new List<Brand__c>{
            new Brand__c(Name = 'B1', Brand_Owner__c = businessAccounts[0].Id),
            new Brand__c(Name = 'B2', Brand_Owner__c = businessAccounts[1].Id),
            new Brand__c(Name = 'B3', Brand_Owner__c = businessAccounts[0].Id)
        };
        insert brands;

        BrandAssociationsSelector selector = new BrandAssociationsSelector();
        List<Brand_Association__c> brandAssosiations = selector.selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(
            businessAccounts[0].Id
        );
        System.assertEquals(
            businessAccounts[0].Id,
            brandAssosiations[0].Business_Account_Name__c,
            'Unrelated Brand Association returned'
        );
        System.assertEquals(
            businessAccounts[0].Id,
            brandAssosiations[1].Business_Account_Name__c,
            'Unrelated Brand Association returned'
        );
        System.assertEquals(
            2,
            brandAssosiations.size(),
            'The retrieved list of Brand Association is incorrect'
        );

        List<Brand_Association__c> brandAssosiations1 = selector.selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(
            businessAccounts[1].Id
        );
        System.assertEquals(
            businessAccounts[1].Id,
            brandAssosiations1[0].Business_Account_Name__c,
            'Unrelated Brand Association returned'
        );
        System.assertEquals(
            1,
            brandAssosiations1.size(),
            'The retrieved list of Brand Association is incorrect'
        );

        List<Brand_Association__c> brandAssosiations2 = selector.selectBrandAssociationsByAccountIdAndIgnoringExternalSourceMds(
            businessAccounts[2].Id
        );
        System.assertEquals(
            0,
            brandAssosiations2.size(),
            'The retrieved list of Brand Association is incorrect'
        );
    }

    /**
     * @description To test the selection of Brand Associations when business Account name
     * and Brand name are associated and when no brand association present.
     */
    @isTest
    private static void testWhenParentAccountIdsPassedThenReturnNumberOfBrandAssociationsGroupedByBrandId() {
        Id businessAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_BUSINESS_RECORD_TYPE_ID)
            .getRecordTypeId();
        Id storeAccountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get(ACCOUNT_STORE_RECORD_TYPE_ID)
            .getRecordTypeId();
        Integer uniqueBrandAssociationCount = 0;
        List<Account> businessAccounts = new List<Account>{
            new Account(
                Name = 'Canada franchise',
                RecordTypeId = businessAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB
            ),
            new Account(Name = 'Australia franchise', RecordTypeId = businessAccountRecordTypeId,Segment__c='SMB')
        };
        insert businessAccounts;
        List<Account> storeAccounts = new List<Account>{
            new Account(
                Name = 'Dominos Ontario',
                RecordTypeId = storeAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                ParentId = businessAccounts[0].Id
            ),
            new Account(
                Name = 'Dominos Toronto',
                RecordTypeId = storeAccountRecordTypeId,
                Segment__c = ACCOUNT_SEGMENT_SMB,
                ParentId = businessAccounts[0].Id
            )
        };
        insert storeAccounts;
        List<Brand__c> brands = new List<Brand__c>{
            new Brand__c(Name = 'Dominos', Brand_Owner__c = businessAccounts[0].Id),
            new Brand__c(Name = 'MC Donald', Brand_Owner__c = businessAccounts[1].Id)
        };
        insert brands;
        Set<Id> businessIds = new Set<Id>{ businessAccounts[0].id };
        for (
            Aggregate eachBrandAssociationAggregate : BrandAssociationsSelector.newInstance()
                .getBrandAssociationsCountFilteredByBusinessAccountIdsGroupedByBrandName(
                    businessIds
                )
        ) {
            System.assertEquals(
                businessAccounts[0].Id,
                (Id) eachBrandAssociationAggregate.get(AGGREGATE_BUSINESSACCOUNTNAME_FIELD_ALIAS),
                QUERY_RETURN_NO_BUSINESS_NAME_ASSERT_MESSAGE
            );
            System.assertEquals(
                brands[0].Id,
                (Id) eachBrandAssociationAggregate.get(AGGREGATE_BRANDNAME_FIELD_ALIAS),
                QUERY_RETURN_NO_BRAND_NAME_ASSERT_MESSAGE
            );
            System.assertNotEquals(
                businessAccounts[1].Id,
                (Id) eachBrandAssociationAggregate.get(AGGREGATE_BUSINESSACCOUNTNAME_FIELD_ALIAS),
                QUERY_RETURN_NO_BUSINESS_NAME_ASSERT_MESSAGE
            );
            System.assertNotEquals(
                brands[1].Id,
                (Id) eachBrandAssociationAggregate.get(AGGREGATE_BRANDNAME_FIELD_ALIAS),
                QUERY_RETURN_NO_BRAND_NAME_ASSERT_MESSAGE
            );
            uniqueBrandAssociationCount += Integer.valueOf(
                eachBrandAssociationAggregate.get(AGGREGATE_BRANDASSOCIATION_COUNT_ALIAS)
            );
        }
        System.assertEquals(
            1,
            uniqueBrandAssociationCount,
            INCORRECT_NUMBER_OF_BRAND_ASSOCIATIONS_ASSERT_MESSAGE
        );
    }
}