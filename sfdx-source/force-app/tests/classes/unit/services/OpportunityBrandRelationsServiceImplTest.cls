/**
 * @author Venkatesh Rimmalapudi (Git: VenkateshDD)
 * @date 03/07/2024
 * @description Service Implementation of Opportunity_Brand_Relationship related logic
 */
@isTest(seeAllData=false)
private class OpportunityBrandRelationsServiceImplTest {

    private static final String LICENSOR = 'Licensor';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();

    /**
     * @description This test method tests the behavior of the createOpportunityBrandRelationShip method in the OpportunityBrandRelationshipsServiceImpl class.
     * It verifies that when the opportunity ID and brand association ID are provided, a new Opportunity_Brand_Relationship__c record is created with the correct values.
     *
     * Test Steps:
     * 1. Arrange the necessary data for the test.
     * 2. Set up the mock UnitOfWork.
     * 3. Call the createOpportunityBrandRelationShip method with the required parameters.
     * 4. Assert that the Opportunity__c and Brand__c fields of the created Opportunity_Brand_Relationship__c record are set correctly.
     * 5. Verify that the registerNew and commitWork methods of the mock UnitOfWork are called exactly once.
     */
    @isTest
    static void testWhenOpportunityIdAndBrandAssocianIdAreThenCreateOBR() {
        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();
        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        Brand_Association__c brandAssociation = (Brand_Association__c) new Fake(
                Brand_Association__c.class
            )
            .setField(Brand_Association__c.Brand_Name__c, brand.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setFakeId()
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);

        // Act
        Opportunity_Brand_Relationship__c obr = OpportunityBrandRelationshipsService.createOpportunityBrandRelationShip(parentAccountId, brandAssociation.Id);

        // Assert
        System.assertEquals(parentAccountId, obr.Opportunity__c, 'Opportunity__c field should be set correctly');
        System.assertEquals(brandAssociation.Id, obr.Brand__c, 'Brand__c field should be set correctly');

        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(obr);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

    /**
     * @description This is a test method that verifies the behavior of creating Opportunity Brand Relations (OBRs)
     * when the Opportunity Id and the Brand Association Ids are provided.
     */
    @isTest
    static void testWhenOpportunityIdAndBrandAssocianIdsAreThenCreateOBRs() {

        Id parentAccountId = Fake.generateId(Account.class);
        Brand__c brand01 = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();
        Brand__c brand02 = (Brand__c) new Fake(Brand__c.class)
        .setField(Brand__c.Name, 'McDonalds')
        .setFakeId()
        .toSObject();
        Account parentAccount = new Account(
            Id = parentAccountId,
            name = 'Mcdonald USA',
            RecordTypeId = BUSINESS_RECORD_TYPE_ID
        );
        Brand_Association__c brandAssociation01 = (Brand_Association__c) new Fake(
                Brand_Association__c.class
            )
            .setField(Brand_Association__c.Brand_Name__c, brand01.Id)
            .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
            .setFakeId()
            .toSObject();

        Brand_Association__c brandAssociation02 = (Brand_Association__c) new Fake(
            Brand_Association__c.class
        )
        .setField(Brand_Association__c.Brand_Name__c, brand02.Id)
        .setField(Brand_Association__c.Business_Account_Name__c, parentAccount.Id)
        .setFakeId()
        .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);

        // Act
        List<Opportunity_Brand_Relationship__c> obrs = OpportunityBrandRelationshipsService.createOpportunityBrandRelationShips(parentAccountId, new Set<Id>{brandAssociation01.Id, brandAssociation02.Id});

        // Assert
        System.assertEquals(parentAccountId, obrs[0].Opportunity__c, 'Opportunity__c field should be set correctly');
        System.assertEquals(brandAssociation01.Id, obrs[0].Brand__c, 'Brand__c field should be set correctly');
        System.assertEquals(parentAccountId, obrs[1].Opportunity__c, 'Opportunity__c field should be set correctly');
        System.assertEquals(brandAssociation02.Id, obrs[1].Brand__c, 'Brand__c field should be set correctly');

        // Assert
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).registerNew(obrs);
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
    }

}