/**
 * @author Deloitte
 * @date 24/04/2024
 * @description Test class for CommissionRatesHandler
 */
@isTest(SeeAllData = false)
private class CommissionRatesHandlerTest {

    /** 
     * @description Test for Search Key generation
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCommissionRateIsUpdatedThenSearchKeyIsAssigned() {
        Id product1 = Fake.generateId(Product2.class);
        Id product2 = Fake.generateId(Product2.class);
        Id submarket = Fake.generateId(Submarket__c.class);
        Id commissionIdOne = Fake.generateId(Commission_Rate__c.class);


        List <Commission_Rate__c> commissionRates = new List <Commission_Rate__c> {
            new Commission_Rate__c(
                Id = commissionIdOne,
                Start__c = Date.today() - 30,
                End__c = System.today() + 40,
                Package__c = product2,
                Account_Primary_Vertical__c = 'Rx',
                Product__c = product1,
                Submarket__c = submarket,
                CurrencyIsoCode = 'USD'
            )
        };
        List <Commission_Rate__c> commissionRatesUpdate = new List <Commission_Rate__c> {
            new Commission_Rate__c(
                Id = commissionIdOne,
                Search_Key__c = string.valueof(product1) + string.valueof(product2) + 'USD' + 'Rx'
            )
        };

        fflib_SObjectDomain.Test.Database.onUpdate(commissionRatesUpdate, new Map < Id,Commission_Rate__c> (commissionRates));

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICommissionRates commissionRatesMock = (ICommissionRates) mocks.mock(ICommissionRates.class);
        mocks.startStubbing();
        mocks.when(commissionRatesMock.getType()).thenReturn(Commission_Rate__c.SObjectType);
        mocks.stopStubbing();
        Application.DOMAIN.setMock(commissionRatesMock);

        fflib_SObjectDomain.triggerHandler(CommissionRatesHandler.class);
        ((ICommissionRates) mocks.verify(commissionRatesMock, 1))
        .generateSearchKey();
    }
    /** 
     * @description Test for Search Key generationn on Insertion
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenCommissionRateIsInsertedThenSearchKeyIsAssigned() {
        Id product1 = Fake.generateId(Product2.class);
        Id product2 = Fake.generateId(Product2.class);
        Id submarket = Fake.generateId(Submarket__c.class);
        Id commissionIdOne = Fake.generateId(Commission_Rate__c.class);


        List <Commission_Rate__c> commissionRates = new List <Commission_Rate__c> {
            new Commission_Rate__c(
                Id = commissionIdOne,
                Start__c = Date.today() - 30,
                End__c = System.today() + 40,
                Package__c = product2,
                Account_Primary_Vertical__c = 'Rx',
                Product__c = product1,
                Submarket__c = submarket,
                CurrencyIsoCode = 'USD'
            )
        };


        fflib_ApexMocks mocks = new fflib_ApexMocks();
        ICommissionRates commissionRatesMock = (ICommissionRates) mocks.mock(ICommissionRates.class);
        mocks.startStubbing();
        mocks.when(commissionRatesMock.getType()).thenReturn(Commission_Rate__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(commissionRatesMock);

        fflib_SObjectDomain.Test.Database.onInsert(commissionRates);
        fflib_SObjectDomain.triggerHandler(CommissionRatesHandler.class);

        ((ICommissionRates) mocks.verify(commissionRatesMock, 1)).generateSearchKey();
    }
}