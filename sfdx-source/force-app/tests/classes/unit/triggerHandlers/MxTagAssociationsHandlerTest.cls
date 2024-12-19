/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Mx_Tag_Association__c Object Trigger Handler Test
 */
@isTest(SeeAllData=false)
private class MxTagAssociationsHandlerTest {
    private static final String UNEXPECTED_RESULT_MESSAGE = 'Unexpected result: both constructs are similar.';

    /**
     * @description @description To test class instantiation.
     */
    @isTest
    private static void testWhenClassInstantiatesThenCheck() {
        List<Mx_Tag_Association__c> newMxTagAssociation = new List<Mx_Tag_Association__c>();
        MxTagAssociationsHandler mxTagObject = new MxTagAssociationsHandler(newMxTagAssociation);
        MxTagAssociationsHandler.Constructor objConstructor = new MxTagAssociationsHandler.Constructor();
        objConstructor.construct(newMxTagAssociation);
        System.assertNotEquals(
            mxTagObject,
            objConstructor.construct(newMxTagAssociation),
            UNEXPECTED_RESULT_MESSAGE
        );
    }

    /**
     * @description To test method call on MxTagAssociation insert
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTagAssociationInsertedThenCallAssignOpportunityLookup() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        List<Mx_Tag_Association__c> newLeads = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(Opportunity__c = opportunityId, Account__c = accountId)
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxTagAssociations mxTagAssociationMock = (IMxTagAssociations) mocks.mock(
            IMxTagAssociations.class
        );
        mocks.startStubbing();
        mocks.when(mxTagAssociationMock.getType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(mxTagAssociationMock);
        fflib_SObjectDomain.Test.Database.onInsert(newLeads);
        fflib_SObjectDomain.triggerHandler(MxTagAssociationsHandler.class);
        ((IMxTagAssociations) mocks.verify(mxTagAssociationMock, 1))
            .assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent();
    }

    /**
     * @description To test method call on MxTagAssociation update
     */
    @IsTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenMxTagAssociationUpdatedThenCallAssignOpportunityLookup() {
        Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
        Id opportunityId = fflib_IDGenerator.generate(Opportunity.SObjectType);
        Id mxTagAssociation = fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType);
        Id accountOldId = fflib_IDGenerator.generate(Account.SObjectType);
        List<Mx_Tag_Association__c> newLeads = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(
                Id = mxTagAssociation,
                Opportunity__c = opportunityId,
                Account__c = accountId
            )
        };

        List<Mx_Tag_Association__c> oldLeads = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(
                Id = mxTagAssociation,
                Opportunity__c = opportunityId,
                Account__c = accountOldId
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IMxTagAssociations mxTagAssociationMock = (IMxTagAssociations) mocks.mock(
            IMxTagAssociations.class
        );
        mocks.startStubbing();
        mocks.when(mxTagAssociationMock.getType())
            .thenReturn(Schema.Mx_Tag_Association__c.SObjectType);
        mocks.stopStubbing();
        Application.Domain.setMock(mxTagAssociationMock);
        fflib_SObjectDomain.Test.Database.onUpdate(newLeads, new Map<Id, SObject>(oldLeads));
        fflib_SObjectDomain.triggerHandler(MxTagAssociationsHandler.class);
        ((IMxTagAssociations) mocks.verify(mxTagAssociationMock, 1))
            .updateOpportunityLookUpOnMxTagAssociationUpdate(new Map<Id, SObject>(oldLeads));
        ((IMxTagAssociations) mocks.verify(mxTagAssociationMock, 1))
            .assignOpportunityLookUpOnInsertOrUpdateWhenAccountLookupIsPresent();
    }

    /**
     * @description Test method to call opportunity service to update concatenated MxTags on opportunities on Mx_Tag_Association__c delete
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    static void testWhenOnAfterDeleteThenUpdateConcatenatedMxTagsOnOpportunities() {
        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>{
            new Mx_Tag_Association__c(
                Id = fflib_IDGenerator.generate(Mx_Tag_Association__c.SObjectType),
                MxTag__c = fflib_IDGenerator.generate(MxTag__c.SObjectType),
                Account__c = fflib_IDGenerator.generate(Account.SObjectType)
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunitiesService opportunityServiceMock = (IOpportunitiesService) mocks.mock(
            IOpportunitiesService.class
        );
        Application.SERVICE.setMock(IOpportunitiesService.class, opportunityServiceMock);

        fflib_SObjectDomain.Test.Database.onDelete(
            new Map<ID, Mx_Tag_Association__c>{ mxTagAssociations[0].Id => mxTagAssociations[0] }
        );
        fflib_SObjectDomain.triggerHandler(MxTagAssociationsHandler.class);

        ((IOpportunitiesService) mocks.verify(opportunityServiceMock, 1))
            .concatenateMxTagsOnSObjects(mxTagAssociations);
    }
}