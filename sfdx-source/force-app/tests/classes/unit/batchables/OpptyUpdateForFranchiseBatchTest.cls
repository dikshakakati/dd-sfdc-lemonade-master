/**
 * @author Deloitte
 * @date 08/22/2022
 * @description This is a test class for OpptyUpdateForFranchiseAmendmentBatch.
 */
@isTest(SeeAllData=false)
private class OpptyUpdateForFranchiseBatchTest {
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenFranchiseAmendmentProcessIsNotNullThenUpdateOpportunityStage() {
        // Arrange
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };
        Id opportunityRecordId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id quoteId = fflib_IDGenerator.generate(SBQQ__Quote__c.SObjectType);
        Fake quoteFakeInstance = new Fake(SBQQ__Quote__c.class)
            .setField(SBQQ__Quote__c.Id, quoteId)
            .setField(SBQQ__Quote__c.SBQQ__Type__c, 'Quote')
            .setField(SBQQ__Quote__c.SBQQ__Status__c, 'Draft')
            .setField(SBQQ__Quote__c.SBQQ__Account__c, accountList[0].Id)
            .setField(SBQQ__Quote__c.SBQQ__Opportunity2__c, opportunityRecordId)
            .setField(SBQQ__Quote__c.SBQQ__Primary__c, 'true')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c, 'FSA')
            .setField(SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c, '2')
            .setField(SBQQ__Quote__c.Opt_Out_Save_Period_days__c, '1')
            .setField(SBQQ__Quote__c.SBQQ__SubscriptionTerm__c, '12')
            .setField(SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c, 'Merchant');
        Fake contractFakeInstance = new Fake(Contract.class)
            .setField(Contract.StartDate, system.today())
            .setField(Contract.AccountId, accountList[0].Id)
            .setField(Contract.CurrencyIsoCode, 'USD - U.S. Dollar')
            .setField(Contract.Status, 'Activated')
            .setField(Contract.ContractTerm, '12')
            .setField(Contract.SBQQ__Opportunity__c, opportunityRecordId)
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setParent('SBQQ__Quote__r', quoteFakeInstance)
            .setFakeId();
        Contract contractRecord = (Contract) contractFakeInstance.toSObject();
        Opportunity opportunityRecord = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Id, opportunityRecordId)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setField(Opportunity.ContractId, contractRecord.Id)
            .setField(Opportunity.FranchiseAmendmentProcess__c, 'FSA')
            .setField(Opportunity.Nintex_Use_Case__c, 'Rate Change')
            .setField(Opportunity.StageName, 'Pitching')
            .setField(Opportunity.createdDate, System.today().addDays(1))
            .setField(Contract.SBQQ__Quote__c, quoteId)
            .setField(Opportunity.Nintex_Signed_Date__c, System.today().addDays(3))
            .setParent('Contract', contractFakeInstance)
            .toSObject();
        List<Opportunity> opportunityList = new List<Opportunity>{ opportunityRecord };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OpportunitiesSelector opportunitiesSelectorMock = (OpportunitiesSelector) mocks.mock(
            OpportunitiesSelector.class
        );
        mocks.startStubbing();
        mocks.when(opportunitiesSelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(opportunitiesSelectorMock.selectOpportunitiesWithNintexUseCaseQueryLocator())
            .thenReturn(null);
        mocks.stopStubbing();

        Application.SELECTOR.setMock(opportunitiesSelectorMock);

        // Act
        OpptyUpdateForFranchiseAmendmentBatch batch = new OpptyUpdateForFranchiseAmendmentBatch();
        batch.start(null);
        batch.execute(null, opportunityList);
        batch.finish(null);

        // Assert
        ((IOpportunitiesSelector) mocks.verify(opportunitiesSelectorMock, 1))
            .selectOpportunitiesWithNintexUseCaseQueryLocator();
        System.assertEquals(
            'Closed Won',
            opportunityRecord.StageName,
            'Mismatch in Opportunity Stage Name'
        );
    }

    @isTest
    static void testWhenBatchIsScheduledThenOpportunityStageIsUpdated() {
        String cronExp = '0 0 1 * * ?';
        Test.startTest();
        String jobId = System.schedule(
            OpptyUpdateForFranchiseBatchTest.class.getName(),
            cronExp,
            new OpptyUpdateForFranchiseAmendmentBatch()
        );
        Test.stopTest();
        CronTrigger cronTriggerRecord = [
            SELECT Id, CronExpression, TimesTriggered, NextFireTime
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(
            Time.newInstance(1, 0, 0, 0),
            cronTriggerRecord.NextFireTime.time(),
            'The Batch has not been triggered yet'
        );
    }
}