/**
 * @author Deloitte
 * @date 04/19/2023
 * @description Test class for DisplayBriefs.
 */
@isTest(seeAllData=false)
private class DisplayBriefsControllerTest {
    /**
     * @description To test the retrieved fields when get fields method is called.
     */
    @isTest
    private static void testWhenFieldsRetrievedFromFieldSetThenDefaultFieldsAndAttributesReturned() {
        String jsonData = DisplayBriefsController.getFields();
        List<DynamicColumn> dynamicColumn = (List<DynamicColumn>) JSON.deserialize(
            jsonData,
            List<DynamicColumn>.class
        );
        System.assertEquals(
            'briefNameHyperlink',
            dynamicColumn[0].fieldName,
            'Unexpected Error:Field Name is not matching'
        );
        System.assertEquals(
            'url',
            dynamicColumn[0].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[1].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Campaign Name',
            dynamicColumn[1].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[2].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'Start Date',
            dynamicColumn[2].label,
            'Unexpected Error: Field Label is not matching'
        );
        System.assertEquals(
            'string',
            dynamicColumn[3].type,
            'Unexpected Error: Field Type__c is not matching'
        );
        System.assertEquals(
            'End Date',
            dynamicColumn[3].label,
            'Unexpected Error: Field Label is not matching'
        );
    }

    /**
     * @description To test if unique brief records are retrieved when get Brief details is called.
     */
    @isTest
    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    private static void testWhenOpportunityIdReceivedThenReturnRelatedBriefRecords() {
        Id opportunityId = Fake.generateId(Opportunity.class);

        List<Brief__c> briefs = new List<Brief__c>{
            new Brief__c(
                Id = Fake.generateId(Brief__c.class),
                CampaignName__c = 'Campaign 1',
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today()
            ),
            new Brief__c(
                Id = Fake.generateId(Brief__c.class),
                CampaignName__c = 'Campaign 2',
                Start_Date__c = System.today() - 1,
                End_Date__c = System.today()
            )
        };

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IBriefsSelector selectorMock = (IBriefsSelector) mocks.mock(IBriefsSelector.class);
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Brief__c.SObjectType);
        mocks.when(selectorMock.selectByOpportunities(new Set<Id>{ opportunityId }))
            .thenReturn(briefs);
        mocks.stopStubbing();
        Application.SELECTOR.setMock(selectorMock);
        List<Brief__c> uniqueBriefs = DisplayBriefsController.getBriefDetails(opportunityId);
        System.assertEquals(2, uniqueBriefs.size(), 'The list size does not match');
    }
}