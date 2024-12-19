/**
 * @description Unit tests for the BusinessIdHierarchyFlowController
 */

@IsTest( IsParallel=true )
private class BusinessIdHierarchyFlowControllerTest {
    @IsTest
    static void testWhenValidAccountIdsProvidedThenReturnBusinessReferences() {
        String accountId1 = (String) Fake.generateId( Account.SObjectType );
        String accountId2 = (String) Fake.generateId( Account.SObjectType );

        Aggregate record1 = new Aggregate().put( 'AccountId', accountId1 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '111111' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record2 = new Aggregate().put( 'ParentAccountId1', accountId1 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '222222' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_restaurant_ui' );

        Aggregate record3 = new Aggregate().put( 'ParentAccountId2', accountId1 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '333333' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record4 = new Aggregate().put( 'ParentAccountId3', accountId1 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '444444' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_restaurant_ui' );

        Aggregate record5 = new Aggregate().put( 'ParentAccountId4', accountId1 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '555555' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record6 = new Aggregate().put( 'ParentAccountId5', accountId1 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '666666' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_restaurant_ui' );

        // A couple of the aggregate records will reflect the same business reference records related to multiple stores
        String record11Id = (String) Fake.generateId(Business_Reference__c.SObjectType);
        String record12Id = (String) Fake.generateId(Business_Reference__c.SObjectType);

        Aggregate record11 = new Aggregate().put( 'AccountId', accountId2 )
            .put( 'BusinessReferenceId', record11Id )
            .put( 'BusinessReferenceExternalId', '111111' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record12 = new Aggregate().put( 'ParentAccountId1', accountId2 )
            .put( 'BusinessReferenceId', record12Id )
            .put( 'BusinessReferenceExternalId', '222222' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_restaurant_ui' );

        Aggregate record13 = new Aggregate().put( 'ParentAccountId2', accountId2 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '333333' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record14 = new Aggregate().put( 'ParentAccountId3', accountId2 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '444444' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_restaurant_ui' );

        Aggregate record15 = new Aggregate().put( 'ParentAccountId4', accountId2 )
            .put( 'BusinessReferenceId', (String) Fake.generateId( Business_Reference__c.SObjectType ) )
            .put( 'BusinessReferenceExternalId', '555555' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record16 = new Aggregate().put( 'ParentAccountId4', accountId2 )
            .put( 'BusinessReferenceId', record11Id )
            .put( 'BusinessReferenceExternalId', '111111' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_retail_ui' );

        Aggregate record17 = new Aggregate().put( 'ParentAccountId3', accountId2 )
            .put( 'BusinessReferenceId', record12Id )
            .put( 'BusinessReferenceExternalId', '222222' )
            .put( 'BusinessReferenceExternalIdSource', 'MDS' )
            .put( 'BusinessReferenceVerticalName', 'flowers_restaurant_ui' );

        String[] accountIds = new String[]{
            accountId1, accountId2
        };

        Aggregate[] queryResults = new Aggregate[]{
            record1, record2, record3, record4, record5, record6,
            record11, record12, record13, record14, record15, record16, record17 // record16 & record17 have the same business reference id so they should be considered duplicates
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector selectorMock = (IBusinessReferencesSelector) mocks.mock( IBusinessReferencesSelector.class );
        mocks.startStubbing();
        mocks.when( selectorMock.sObjectType() ).thenReturn( Business_Reference__c.SObjectType );
        mocks.when( selectorMock.selectAllBusinessIdsInAccountHierarchy( accountIds ) ).thenReturn( queryResults );
        mocks.stopStubbing();
        Application.SELECTOR.setMock( selectorMock );

        List<BusinessIdHierarchyFlowController.Results> results = BusinessIdHierarchyFlowController.getBusinessReferences( accountIds );

        Assert.areEqual(2, results.size(),'Expected 2 results. Received: ' + results.size());
        Assert.areEqual(6, results[0].businessReferences.size(), 'Expected 6 results.  Received: ' + results[0].businessReferences.size()); // Account1 has 6 results. This proves the list of results are returned in the correct order
        Assert.areEqual(5, results[1].businessReferences.size(), 'Expected 5 results.  Received: ' + results[1].businessReferences.size()); // Account2 has 5 results. This proves the list of results returned in the correct order
    }

    @IsTest
    static void testWhenNoBusinessReferencesFoundThenReturnEmptyLists() {
        String[] accountIds = new String[]{
            (String) Fake.generateId( Account.SObjectType ),
            (String) Fake.generateId( Account.SObjectType )
        };
        List<Aggregate> emptyQueryResults = new List<Aggregate>();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBusinessReferencesSelector selectorMock = (IBusinessReferencesSelector) mocks.mock( IBusinessReferencesSelector.class );
        mocks.startStubbing();
        mocks.when ( selectorMock.sObjectType() ).thenReturn( Business_Reference__c.SObjectType );
        mocks.when ( selectorMock.selectAllBusinessIdsInAccountHierarchy( accountIds ) ).thenReturn( emptyQueryResults );
        mocks.stopStubbing();
        Application.SELECTOR.setMock( selectorMock );

        List<BusinessIdHierarchyFlowController.Results> results = BusinessIdHierarchyFlowController.getBusinessReferences( new String[]{} );
        System.assertEquals( 0, results.size(), 'Expected empty list when no business references are returned from the selector' );
    }

    @IsTest
    static void testWhenEmptyListOfAccountIdsProvidedThenReturnEmptyList() {
        List<BusinessIdHierarchyFlowController.Results> results = BusinessIdHierarchyFlowController.getBusinessReferences( new String[]{
        } );
        System.assertEquals( 0, results.size(), 'Expected empty list when null input provided' );
    }


    @IsTest
    static void testWhenNullAccountIdsProvidedThenReturnEmptyList() {
        List<BusinessIdHierarchyFlowController.Results> results = BusinessIdHierarchyFlowController.getBusinessReferences( null );
        System.assertEquals( 0, results.size(), 'Expected empty list when null input provided' );
    }



    @IsTest
    static void testWhenNonNullListProvidedThenResultsContainCorrectReferences() {
        List<BusinessReference> testReferences = new List<BusinessReference>{
            new BusinessReference(new Business_Reference__c( External_Id__c = '123', Business_Name__c = 'Test Business 1' )),
            new BusinessReference(new Business_Reference__c( External_Id__c = '456', Business_Name__c = 'Test Business 2' ))
        };

        BusinessIdHierarchyFlowController.Results result = new BusinessIdHierarchyFlowController.Results( testReferences );

        System.assertEquals( 2, result.businessReferences.size(), 'Expected 2 business references' );
        System.assertEquals( '123', result.businessReferences[0].ExternalId, 'Unexpected External_Id__c for first reference' );
        System.assertEquals( 'Test Business 1', result.businessReferences[0].BusinessName, 'Unexpected Business_Name__c for first reference' );
        System.assertEquals( '456', result.businessReferences[1].ExternalId, 'Unexpected External_Id__c for second reference' );
        System.assertEquals( 'Test Business 2', result.businessReferences[1].BusinessName, 'Unexpected Business_Name__c for second reference' );
    }

    @IsTest
    static void testWhenNullListProvidedThenResultsContainEmptyList() {
        BusinessIdHierarchyFlowController.Results nullResult = new BusinessIdHierarchyFlowController.Results( null );

        System.assertNotEquals( null, nullResult.businessReferences, 'businessReferences should not be null' );
        System.assertEquals( 0, nullResult.businessReferences.size(), 'businessReferences should be an empty list' );
    }

    @IsTest
    static void testWhenEmptyListProvidedThenResultsContainEmptyList() {
        BusinessIdHierarchyFlowController.Results emptyResult = new BusinessIdHierarchyFlowController.Results( new List<BusinessReference>() );

        System.assertNotEquals( null, emptyResult.businessReferences, 'businessReferences should not be null' );
        System.assertEquals( 0, emptyResult.businessReferences.size(), 'businessReferences should be an empty list' );
    }
}
