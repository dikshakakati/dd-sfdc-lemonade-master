/**
 * @author Deloitte
 * @date   08/04/2022
 * @description This is a test class for UpdateInactiveStalledOpportunitiesBatch
 */
@isTest(SeeAllData=false)
public with sharing class UpdateInactiveStalledOppBatchTest {
    private static final String METADATA_INSTANCE_NAME = 'Update_Inactive_Opp_Batch_Number_Of_Days';
    private static final String METADATA_VALUE = '120';

    @isTest
    static void testWhenInActiveStalledOpportunityThenUpdateStageToClosed() {
        // Arrange
        List<Account> accountList = new List<Account>{
            new Account(Id = fflib_IDGenerator.generate(Account.SObjectType), Name = 'Parent 1')
        };
        Opportunity opportunityRecord1 = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test opportunity 1')
            .setField(Opportunity.LastModifiedDate, Date.today() - 120)
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setFakeId()
            .toSObject();
        Opportunity opportunityRecord2 = (Opportunity) new Fake(Opportunity.class)
            .setField(Opportunity.Name, 'Test opportunity 2')
            .setField(Opportunity.LastModifiedDate, Date.today() - 120)
            .setField(Opportunity.AccountId, accountList[0].Id)
            .setFakeId()
            .toSObject();
        List<Opportunity> opportunityList = new List<Opportunity>{
            opportunityRecord1,
            opportunityRecord2
        };
        List<ContentVersion> contentRecord = new List<ContentVersion>{
            (ContentVersion) new Fake(ContentVersion.class)
                .setField(ContentVersion.Title, 'Test Content')
                .setField(ContentVersion.PathOnClient, 'Test Content.SNOTE')
                .setField(ContentVersion.Origin, 'H')
                .setField(ContentVersion.CreatedDate, Date.today() - 120)
                .setFakeId()
                .toSObject()
        };
        List<ContentDocumentLink> contentlink = new List<ContentDocumentLink>{
            (ContentDocumentLink) new Fake(ContentDocumentLink.class)
                .setField(ContentDocumentLink.LinkedEntityId, opportunityRecord2.Id)
                .setField(ContentDocumentLink.ContentDocumentId, contentRecord[0].Id)
                .setField(ContentDocumentLink.ShareType, 'I')
                .setField(ContentDocumentLink.Visibility, 'AllUsers')
                .setFakeId()
                .toSObject()
        };
        Map<Id, Opportunity> opportunityRecordToUpdate = new Map<Id, Opportunity>(opportunityList);
        Set<Id> opportunityId = opportunityRecordToUpdate.keySet();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IContentDocumentLinkSelector contentDocumentSelectorMock = (IContentDocumentLinkSelector) mocks.mock(
            IContentDocumentLinkSelector.class
        );
        IOpportunitiesSelector opportunitySelectorMock = (IOpportunitiesSelector) mocks.mock(
            IOpportunitiesSelector.class
        );
        Opportunities opportunitiesMock = (Opportunities) mocks.mock(Opportunities.class);
        IStaticConfigurationsSelector mockStaticConfigurations = (IStaticConfigurationsSelector) mocks.mock(
            IStaticConfigurationsSelector.class
        );
        fflib_ISObjectUnitOfWork mockUOW = (fflib_ISObjectUnitOfWork) mocks.mock(
            fflib_ISObjectUnitOfWork.class
        );
        mocks.startStubbing();
        mocks.when(opportunitySelectorMock.sObjectType()).thenReturn(Opportunity.SObjectType);
        mocks.when(
                opportunitySelectorMock.selectInactiveOpportunityInStalledStage(
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(null);
        mocks.when(contentDocumentSelectorMock.sObjectType())
            .thenReturn(ContentDocumentLink.SObjectType);
        mocks.when(
                contentDocumentSelectorMock.selectNotesByLinkedEntityAndLastModifiedDate(
                    opportunityId,
                    Integer.valueOf(METADATA_VALUE)
                )
            )
            .thenReturn(contentlink);
        mocks.when(mockStaticConfigurations.sObjectType())
            .thenReturn(Static_Configurations__mdt.SObjectType);
        mocks.when(mockStaticConfigurations.getInstanceValue(METADATA_INSTANCE_NAME))
            .thenReturn(
                new Static_Configurations__mdt(
                    Label = METADATA_INSTANCE_NAME,
                    Configuration_Value__c = METADATA_VALUE
                )
            );
        mocks.stopStubbing();
        Application.SELECTOR.setMock(contentDocumentSelectorMock);
        Application.SELECTOR.setMock(mockStaticConfigurations);
        Application.SELECTOR.setMock(opportunitySelectorMock);
        Application.DOMAIN.setMock(opportunitiesMock);
        Application.UNITOFWORK.setMock(mockUOW);
        // Act
        UpdateInactiveStalledOpportunitiesBatch batch = new UpdateInactiveStalledOpportunitiesBatch();
        batch.start(null);
        batch.execute(null, opportunityList);
        batch.finish(null);
        // Assert
        ((IOpportunitiesSelector) mocks.verify(opportunitySelectorMock, 1))
            .selectInactiveOpportunityInStalledStage(Integer.valueOf(METADATA_VALUE));
        ((fflib_ISObjectUnitOfWork) mocks.verify(mockUOW, 1)).commitWork();
        system.assertEquals(
            'Closed Lost',
            opportunityList[0].StageName,
            'Stage Name does not get updated'
        );
    }
}