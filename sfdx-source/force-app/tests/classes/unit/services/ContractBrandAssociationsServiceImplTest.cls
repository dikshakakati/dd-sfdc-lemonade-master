/**
 * @author Gaurav Bisht
 * @date 03/19/2024
 * @description Service Implementation of Contract_Brand_Association__c related logic
 */
@isTest(seeAllData=false)
private class ContractBrandAssociationsServiceImplTest {

    private static final String LICENSOR = 'Licensor';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();

    /**
     * @description This test method for ContractBrandAssociationServiceImp  class.
     */
    @isTest
    static void testWhenContractIdAndBrandIdAreThenCreateCBA() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();
         Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.StartDate, Date.today() + 1)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);

        // Act
        Contract_Brand_Association__c obr = ContractBrandAssociationsService.createContractBrandAssociaiton(fakeContract.ID, brand.Id);

        // Assert
        System.assertEquals(obr.Contract__c, fakeContract.ID, 'Brand__c field should be set correctly');

    }

    /**
     * @description This test method for ContractBrandAssociationServiceImp  class.
     */
    @isTest
    static void testWhenContractIdAndBrandIdAreThenCreateCBAList() {
        Id contractId = fflib_IDGenerator.generate(Contract.SObjectType);

        Brand__c brand = (Brand__c) new Fake(Brand__c.class)
            .setField(Brand__c.Name, 'KFC')
            .setFakeId()
            .toSObject();

         Contract fakeContract = (Contract) new Fake(Contract.class)
            .setField(Contract.Name, 'Contract1')
            .setField(Contract.Id, contractId)
            .setField(Contract.StartDate, Date.today() + 1)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );

        // Set up the Application class to use the mock UnitOfWork
        Application.UnitOfWork.setMock(mockUOW);

        // Act
        List<Contract_Brand_Association__c> obr = ContractBrandAssociationsService.createContractBrandAssociaitons(fakeContract.ID, new Set<Id>{brand.Id});

        // Assert
        System.assertEquals(obr[0].Contract__c, fakeContract.ID, 'Brand__c field should be set correctly');

    }



}