/**
 * @author Deloitte
 * @date 16/06/2022
 * @description Service class for Opportunity related logic.
 */
public inherited sharing class OpportunitiesService implements IHandleNotifierEvents {
    /**
     * @description It is used to activate banner message indicator on parent Work Order when
     * Rate Change Opportunity is Closed Won.
     * @JIRA# LEM-3711
     * @param opportunityIds
     */
    public static void activateBannerOnClosedWonRateChangeOpportunities(Set<Id> opportunityIds) {
        service().activateBannerOnClosedWonRateChangeOpportunities(opportunityIds);
    }

    /**
     * @description This method is used to delete Opportunity Account Relationship records filtered
     * by OpportunityIds
     * @param reparentedOpportunityIds
     */
    public static void deleteOpportunityAccountRelationships(Set<String> reparentedOpportunityIds) {
        service().deleteOpportunityAccountRelationships(reparentedOpportunityIds);
    }

    /**
     * @description This method is used to handle the published Notifier events.
     * @param notifierEvents list of platform events with payload
     */
    public static void execute(List<Notifier__e> notifierEvents) {
        service().handleNotifierEvents(notifierEvents);
    }

    /**
     * @description This method is used to retrieve Opportunity Brand Relationships for all
     * opportunities and extract the set of parent Opportunities.
     * @param opportunities
     * @return Set<Id>
     */
    public static Set<Id> getOpportunitiesWithOpportunityBrandRelationships(
        List<Opportunity> opportunities
    ) {
        return service().getOpportunitiesWithOpportunityBrandRelationships(opportunities);
    }

    /**
     * @description This method is used to create Opportunities on the passed Franchise Accounts.
     * @param franchiseAccountIds
     * @param contractId
     * @param useCase
     * @param daysToAdd
     */
    public static void createOpportunitiesOnFranchiseAccounts(
        List<String> franchiseAccountIds,
        String contractId,
        String useCase,
        String daysToAdd
    ) {
        service()
            .createOpportunitiesOnFranchiseAccounts(
                franchiseAccountIds,
                contractId,
                useCase,
                daysToAdd
            );
    }

    /**
     * @description It collects corporate Opportunities in contracting stage
     * without associated Work Order.
     * @param opportunitiesWithChangedStage
     * @return List<Opportunity>
     */
    public static List<Opportunity> collectOpportunitiesWithoutWorkOrderInContractingStage(
        List<Opportunity> opportunitiesWithChangedStage
    ) {
        return service()
            .collectOpportunitiesWithoutWorkOrderInContractingStage(opportunitiesWithChangedStage);
    }

    /**
     * @description It initiates child Work Orders creation using the Opportunities collected
     * on creation/update through Nintex.
     * @JIRA# LEM-3658
     * @param opportunityIds
     */
    public static void initiateChildWorkOrdersCreationByNintexUseCase(Set<Id> opportunityIds) {
        service().initiateChildWorkOrdersCreationByNintexUseCase(opportunityIds);
    }

    /**
     * @description It is used to collect valid Opportunities (having Nintex Id) to initiate
     * parent Work Order creation.
     * @param opportunityIds
     */
    public static void initiateParentWorkOrdersCreation(Set<Id> opportunityIds) {
        service().initiateParentWorkOrdersCreation(opportunityIds);
    }

    /**
     * @description This method is called from Batch class to update the Opportunity Stage to
     * Closed Won or Closed Lost based on value of Franchise Amendment process field on Quote.
     *  @param opportunities
     */
    public static void updateStageToClosedByFranchiseAmendmentProcessByBatch(
        List<Opportunity> opportunities
    ) {
        service().updateStageToClosedByFranchiseAmendmentProcessByBatch(opportunities);
    }

    /**
     * @description It is used to update the Estimated Total Investment on the Opportunities.
     * @param opportunityToTotalInvestment
     */
    public static void updateEstimatedTotalInvestmentOnOpportunity(
        Map<Id, Decimal> opportunityToTotalInvestment
    ) {
        service().updateEstimatedTotalInvestmentOnOpportunity(opportunityToTotalInvestment);
    }

    /**
     * @description This method is called from Change Event class to update the Opportunity Stage
     * to Closed Won or Closed Lost based on value of Franchise Amendment process field on Quote.
     * @param opportunityIds
     * @param isCreateEvent
     */
    public static void updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
        Set<Id> opportunityIds,
        Boolean isCreateEvent
    ) {
        service()
            .updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
                opportunityIds,
                isCreateEvent
            );
    }

    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed opportunities which triggers the further processing on AccountId change on opportunities.
     * @param opportunities
     */
    public static void processMergedAccountsRelatedRecords(List<Opportunity> opportunities) {
        service().processMergedAccountsRelatedRecords(opportunities);
    }

    /**
     * @description This method is used to create an instance of OpportunitiesService class.
     * @return IOpportunitiesService - return instance of OpportunitiesServiceImpl
     */
    private static IOpportunitiesService service() {
        return (IOpportunitiesService) Application.SERVICE.newInstance(IOpportunitiesService.class);
    }
    /**
     * @description update opp owner on Brief Item
     * @param opps
     */
    public static void updateBriefItemsFromOpportunity(List<Opportunity> opps) {
        service().updateBriefItemsFromOpportunity(opps);
    }
    /**
     * @description maps the Opportunity Id to a List of briefs
     * @param briefs
     * @return Map<Id,List<Brief__c>>
     */
    public static Map<Id, List<Brief__c>> mapOpportunityIdToListOfBrief(List<Brief__c> briefs) {
        return service().mapOpportunityIdToListOfBrief(briefs);
    }
    /**
     * @description this method syncs the opportunity field data back to the Brief
     * @param opportunities
     * @param oppIdToBriefMap
     */
    public static void updateBriefsFromOpportunity(
        List<Opportunity> opportunities,
        Map<Id, List<Brief__c>> oppIdToBriefMap
    ) {
        service().updateBriefsFromOpportunity(opportunities, oppIdToBriefMap);
    }

    /**
     * @description It updates Estimated # of Stores on opportunity to the value on Quote's 'Number of Stores' field.
     * @JIRA# LEM-14946
     * @param opportunityIdToNumberOfStores
     */
    public static void updateOpportunityNoOfStoresByQuoteNoOfStores(
        Map<Id, Decimal> opportunityIdToNumberOfStores
    ) {
        service().updateOpportunityNoOfStoresByQuoteNoOfStores(opportunityIdToNumberOfStores);
    }

    /**
     * @description It updates Stage on Opportunity to 'Contracting' or 'Closed Won' whenever a Quote's
     * 'Status' is changed to 'Out For Signature' and 'Contract Signed' respectively.
     * @JIRA# LEM-14174
     * @param opportunityIdToChangedStatus
     */
    public static void updateOpportunityStageByQuoteStatus(
        Map<Id, String> opportunityIdToChangedStatus
    ) {
        service().updateOpportunityStageByQuoteStatus(opportunityIdToChangedStatus);
    }

    /**
     * @description It updates the Primary contact on the Opportunity.
     * @JIRA# LEM-14152
     * @param opportunityIdToPrimaryOCRContactId
     */
    public static void updatePrimaryOCRContactOnOpportunity(
        Map<Id, Id> opportunityIdToPrimaryOCRContactId
    ) {
        service().updatePrimaryOCRContactOnOpportunity(opportunityIdToPrimaryOCRContactId);
    }
    /**
     * @description It creates renewal Opportunity on Accounts having partnership expiration date
     * in next 90 days from today.
     * @param accountsToStartBatch
     */
    public static void createRenewalOpportunityFromBatch(List<Account> accountsToStartBatch) {
        service().createRenewalOpportunityFromBatch(accountsToStartBatch);
    }

    /**
     * @description It is used to concatenate 'Active' Mx Tag Associations on
     * Opportunities and Accounts.
     * @param activeMxTagAssociations
     */
    public static void concatenateMxTagsOnSObjects(
        List<Mx_Tag_Association__c> activeMxTagAssociations
    ) {
        service().concatenateMxTagsOnSObjects(activeMxTagAssociations);
    }
}