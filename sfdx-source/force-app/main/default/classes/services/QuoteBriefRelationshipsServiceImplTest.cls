/**
 * @author Deloitte
 * @date 03/27/2023
 * @description Test class for QuoteBriefRelationshipsService.
 */
@isTest(SeeAllData=false)
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
private class QuoteBriefRelationshipsServiceImplTest {
    @isTest
    private static void testWhenBriefsToQuoteIdsArePassedThenQuoteBriefRelationshipsAreCreated() {
        Id briefId = Fake.generateId(Brief__c.class);
        Id holiSpecialQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Id diwaliSpecialQuoteId = Fake.generateId(SBQQ__Quote__c.class);
        Map<Id, Set<Id>> briefsToQuoteIds = new Map<Id, Set<Id>>{
            briefId => new Set<Id>{ holiSpecialQuoteId, diwaliSpecialQuoteId }
        };
        Map<Id, String> briefsToCampaign = new Map<Id, String>{ briefId => 'Halloween Deals' };
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        Application.UNITOFWORK.setMock(mockUOW);
        QuoteBriefRelationshipsService.createQuoteBriefRelationshipsWithBriefToQuoteMapping(
            briefsToQuoteIds,
            briefsToCampaign
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1))
            .registerNew(
                fflib_Match.sObjectWith(
                    new Map<SObjectField, Object>{
                        Quote_Brief_Relationship__c.Quote__c => holiSpecialQuoteId,
                        Quote_Brief_Relationship__c.Brief__c => briefId,
                        Quote_Brief_Relationship__c.Campaign_of_Brief__c => 'Halloween Deals'
                    }
                )
            );
    }
}