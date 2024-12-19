/**
 * @author Deloitte
 * @date 11/14/2022
 * @description Test class for OpportunityUpdateListenerController.
 */
@isTest(SeeAllData=false)
private class OpportunityUpdateListenerControllerTest {
    private static final String TYPE_MARKETPLACE = 'Marketplace';
    /**
     * @description This method is used to test to get Opportunity Line Item.
     */
    @isTest
    private static void testWhenOpportunityLineItemsAreReturnedThenControllerReturnsTrue() {
        Id opportunityId = Fake.generateId(Opportunity.class);
        //Id productId = Fake.generateId(Product2.class);
        Id opportunityLineItemId = Fake.generateId(OpportunityLineItem.class);

        Fake productInstance = ServiceMockDataBuilder.createProductFakeInstance(TYPE_MARKETPLACE)
            .setField(Product2.Family, 'Advertisement');

        OpportunityLineItem lineItemInstance = (OpportunityLineItem) new Fake(
                OpportunityLineItem.class
            )
            .setField(OpportunityLineItem.Id, opportunityLineItemId)
            .setField(OpportunityLineItem.OpportunityId, opportunityId)
            .setParent('Product2', productInstance)
            .toSObject();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityLineItemsSelector lineItemSelectorMock = (IOpportunityLineItemsSelector) mocks.mock(
            IOpportunityLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(lineItemSelectorMock.sObjectType()).thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(lineItemSelectorMock.selectByOpportunities(new Set<Id>{ opportunityId }))
            .thenReturn(new List<OpportunityLineItem>{ lineItemInstance });
        mocks.stopStubbing();
        Application.SELECTOR.setMock(lineItemSelectorMock);

        Boolean isOpportunityRequiredToHavePurchaseOrder = OpportunityUpdateListenerController.getOpportunityLineItems(
            opportunityId
        );

        System.assertEquals(
            isOpportunityRequiredToHavePurchaseOrder,
            true,
            'The Opportunity should have a Line Item associated.'
        );
    }
    /**
     * @description This method is used to test to get Opportunity Line Item.
     */
    @isTest
    private static void testWhenOpportunityLineItemsAreReturnedThenControllerReturnsFalse() {
        Id opportunityId = Fake.generateId(Opportunity.class);

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        IOpportunityLineItemsSelector lineItemSelectorMock = (IOpportunityLineItemsSelector) mocks.mock(
            IOpportunityLineItemsSelector.class
        );
        mocks.startStubbing();
        mocks.when(lineItemSelectorMock.sObjectType()).thenReturn(OpportunityLineItem.SObjectType);
        mocks.when(lineItemSelectorMock.selectByOpportunities(new Set<Id>{ opportunityId }))
            .thenReturn(new List<OpportunityLineItem>{});
        mocks.stopStubbing();
        Application.SELECTOR.setMock(lineItemSelectorMock);

        Boolean isOpportunityRequiredToHavePurchaseOrder = OpportunityUpdateListenerController.getOpportunityLineItems(
            opportunityId
        );

        System.assertEquals(
            isOpportunityRequiredToHavePurchaseOrder,
            false,
            'The Opportunity should not have any Line Item associated.'
        );
    }
}