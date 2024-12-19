/**
 * @author Deloitte
 * @date 16/06/2022
 * @description Interface of service class for Opportunities related logic.
 */
public interface IOpportunitiesService {
    /**
     * @description It is used to activate banner message indicator on parent Work Order when
     * Rate Change Opportunity is Closed Won.
     * @param opportunityIds
     */
    void activateBannerOnClosedWonRateChangeOpportunities(Set<Id> opportunityIds);

    /**
     * @description This method is used to delete Opportunity Account Relationship records filtered
     * by OpportunityIds
     * @param reparentedOpportunities
     */
    void deleteOpportunityAccountRelationships(Set<String> reparentedOpportunities);

    /**
     * @description This method is used to perform update on Opportunity currency when update currency notifier event is fired.
     * @param notifierEvents
     */
    void handleNotifierEvents(List<Notifier__e> notifierEvents);

    /**
     * @description This method is used to create Opportunities on the passed Franchise Accounts.
     * @param franchiseAccountIds
     * @param contractId
     * @param useCase
     * @param daysToAdd
     */
    void createOpportunitiesOnFranchiseAccounts(
        List<String> franchiseAccountIds,
        String contractId,
        String useCase,
        String daysToAdd
    );

    /**
     * @description This method is used to retrieve Opportunity Brand Relationships for all
     * opportunities and extract the set of parent Opportunities.
     * @param opportunities
     * @return Set<Id>
     */
    Set<Id> getOpportunitiesWithOpportunityBrandRelationships(List<Opportunity> opportunities);

    /**
     * @description It is used to update the Estimated Total Investment on the Opportunities.
     * @param opportunityToTotalInvestment
     */
    void updateEstimatedTotalInvestmentOnOpportunity(Map<Id, Decimal> opportunityToTotalInvestment);

    /**
     * @description It collects corporate Opportunities in contracting stage
     * without associated Work Order.
     * @param opportunitiesWithChangedStage
     * @return List<Opportunity>
     */
    List<Opportunity> collectOpportunitiesWithoutWorkOrderInContractingStage(
        List<Opportunity> opportunitiesWithChangedStage
    );

    /**
     * @description It initiates child Work Orders creation using the Opportunities collected
     * on creation/update through Nintex.
     * @param opportunityIds
     */
    void initiateChildWorkOrdersCreationByNintexUseCase(Set<Id> opportunityIds);

    /**
     * @description It is used to collect valid Opportunities (having Nintex Id) to initiate
     * parent Work Order creation.
     * @param opportunityIds
     */
    void initiateParentWorkOrdersCreation(Set<Id> opportunityIds);

    /**
     * @description This method is called from Change Event class to update the Opportunity Stage
     * to Closed Won or Closed Lost based on value of Franchise Amendment process field on Quote.
     * @param opportunityIds
     * @param isCreateEvent
     */
    void updateStageToClosedByFranchiseAmendmentProcessByChangeEvent(
        Set<Id> opportunityIds,
        Boolean isCreateEvent
    );

    /**
     * @description This method is called from Batch class to update the Opportunity Stage to
     * Closed Won or Closed Lost based on value of Franchise Amendment process field on Quote.
     * @param opportunities
     */
    void updateStageToClosedByFranchiseAmendmentProcessByBatch(List<Opportunity> opportunities);

    /**
     * @description It sets "Is Parent Account Merged" field as true on the passed opportunities which triggers the further processing on AccountId change on opportunities.
     * @param opportunities
     */
    void processMergedAccountsRelatedRecords(List<Opportunity> opportunities);
    /**
     * @description update opp owner on Brief Item
     * @param opps
     */
    void updateBriefItemsFromOpportunity(List<Opportunity> opps);
    /**
     * @description maps the Opportunity Id to a List of briefs
     * @param briefs
     * @return Map<Id,List<Brief__c>>
     */
    Map<Id, List<Brief__c>> mapOpportunityIdToListOfBrief(List<Brief__c> briefs);
    /**
     * @description this method syncs the opportunity field data back to the Brief
     * @param opportunities
     * @param oppIdToBriefMap
     */
    void updateBriefsFromOpportunity(
        List<Opportunity> opportunities,
        Map<Id, List<Brief__c>> oppIdToBriefMap
    );

    /**
     * @description It updates Estimated # of Stores on opportunity to the value on Quote's 'Number of Stores' field.
     * @param opportunityIdToNumberOfStores
     */
    void updateOpportunityNoOfStoresByQuoteNoOfStores(
        Map<Id, Decimal> opportunityIdToNumberOfStores
    );

    /**
     * @description It updates Stage on Opportunity to 'Contracting' or 'Closed Won' whenever a Quote's
     * 'Status' is changed to 'Out For Signature' and 'Contract Signed' respectively.
     * @JIRA# LEM-14174
     * @param opportunityIdToChangedStatus
     */
    void updateOpportunityStageByQuoteStatus(Map<Id, String> opportunityIdToChangedStatus);

    /**
     * @description It updates the Primary Contact on Opportunity.
     * @param opportunityIdToPrimaryOCRContactId
     */
    void updatePrimaryOCRContactOnOpportunity(Map<Id, Id> opportunityIdToPrimaryOCRContactId);
    /**
     * @description It creates renewal Opportunity on Accounts having partnership expiration date
     * in next 90 days from today.
     * @param accountsToStartBatch
     */
    void createRenewalOpportunityFromBatch(List<Account> accountsToStartBatch);

    /**
     * @description It is used to concatenate 'Active' Mx Tag Associations on
     * Opportunities and Accounts.
     * @param activeMxTagAssociations
     */
    void concatenateMxTagsOnSObjects(List<Mx_Tag_Association__c> activeMxTagAssociations);
}