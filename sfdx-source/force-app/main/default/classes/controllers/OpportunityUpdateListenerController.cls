/**
 * @author Deloitte
 * @date 11/14/2022
 * @description Class to get Opportunity Line Items related to the Opportunity.
 */
public inherited sharing class OpportunityUpdateListenerController {
    /**
     * @description It is used to check if the Opportunity has related Opportunity Line Items.
     * @param opportunityId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean getOpportunityLineItems(Id opportunityId) {
        List<OpportunityLineItem> relatedOpportunityLineItems = OpportunityLineItemsSelector.newInstance()
            .selectByOpportunities(new Set<Id>{ opportunityId });
        if (relatedOpportunityLineItems != null && relatedOpportunityLineItems.size() > 0) {
            return true;
        }
        return false;
    }
}