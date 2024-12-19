/**
 * @description Interface to add Opportunity domain class methods
 * @author Deloitte
 */
public interface IOpportunities extends fflib_ISObjects {
    /**
     * @description Getter to return map of Opportunities grouped by Opportunity Id
     * @return Map of Opportunities grouped by Id
     */
    Map<Id, Opportunity> getById();

    /**
     * @description Getter to return Opportunities grouped by Marketplace Nintex Id
     * @return Map of Opportunities grouped by Marketplace Nintex Id
     */
    Map<String, Opportunity> getByMarketPlaceNintexId();
    /**
     * @description Getter to return Opportunities grouped by Drive Nintex Id
     * @return Map of Opportunities grouped by Drive Nintex Id
     */
    Map<String, Opportunity> getByDriveNintexId();

    /**
     * @description Getter to return map of Opportunities grouped by Nintex Use Case
     * @return Map of Opportunities grouped by Nintex Use Case
     */
    Map<String, IOpportunities> getByUseCase();

    /**
     * @description Getter to return set of Opportunities contract ids
     * @return Set of contract ids
     */
    Set<Id> getContractIds();

    /**
     * @description Getter to return set of Opportunities Account ids
     * @return Set of Account ids
     */
    Set<Id> getAccountIds();

    /**
     * @description Getter to return Map of Opportunities Account Id to Contract Id
     * @return Map<Id, Id>
     */
    Map<String, Id> getAccountIdContractIdMap();

    /**
     * @description Getter to return Map of Opportunities Account Id to Deselected MarketPlace Services
     * @return Map<Id, Map<String, String>>
     */
    Map<Id, Map<String, String>> getAccountIdDeselectedServicesMap();
    /**
     * @description It is used to validate if the Opportunities have related Opportunity Brand
     * Relationships in order to move it past Pitching.
     * @param oldOpportunityRecords
     * @param changedRecords
     */
    void validateOpportunitiesInNegotiatingStage(
        Map<Id, SObject> oldOpportunityRecords,
        List<Opportunity> changedRecords
    );

    /**
     * @description Getter to return set of Opportunities Drive nintex ids
     * @return Set of nintex ids
     */
    Set<String> getDriveNintexIds();
    /**
     * @description Getter to return set of Opportunities Marketplace nintex ids
     * @return Set of nintex ids
     */
    Set<String> getMarketplaceNintexIds();

    /**
     * @description Assigning Opportunity Name on Component Update
     * @param existingOpportunities
     */
    void assignNameOnNamingComponentsUpdates(Map<Id, Opportunity> existingOpportunities);

    /**
     * @description Assigning Opportunity Name on Name Change or Opportunity Insert
     */
    void assignNameOnInsertOrNameUpdate();

    /**
     * @description Performs a validation on changes reflecting on Opportunity Name. A manual edit to the
     *              opportunity is only permitted to bypass users on Update.
     * @param existingOpportunities
     */
    void validateOpportunityNameChange(Map<Id, Opportunity> existingOpportunities);

    /**
     * @description method declaration for Opportunity Pricebook on Insert
     */
    void assignPriceBook();

    /**
     * @description This method is used to populate the ContractId on Existing or Rescue type of Opportunity
     * and check if related Account has an activated Contract to prevent creation of New type of Opportunity.
     */
    void assignContractAndPreventOpportunityNewTypeCreation();

    /**
     * @description Updating Probability and Forecast Category
     * @param oldOpportunityRecords
     * @param changedRecords
     */
    void restoreForecastAndProbabilityOnStageChangeToStalled(
        Map<Id, SObject> oldOpportunityRecords,
        List<Opportunity> changedRecords
    );

    /**
     * @description Method to validate if an opportunity can be reparented
     * @param opportunitiesToBeReparented
     * @param opportunitiesWithQuote
     */
    void opportunityReparentingValidation(
        List<Opportunity> opportunitiesToBeReparented,
        Set<Id> opportunitiesWithQuote
    );

    /**
     * @description Thus method is used to validate if the Pitch Amount of an Opportunity was updated
     * @param opportunitiesWithQuote
     */
    void validateChangeInPitchAmount(Set<Id> opportunitiesWithQuote);

    /**
     * @description This method is used to validate if the Sub Type of an Opportunity was updated at
     * a valid opportunity stage.
     */
    void validateChangeInSubType();

    /**
     * @description This method is used to validate if the Existing Opportunity
     */
    void validatePrimaryOrderForOpportunityCloseWin();

    /**
     * @description This method is used to retrieve Quotes for all opportunities and extract the set of parent Opportunities.
     * @param opportunitiesToBeReparented
     * @return Set<Id>
     */
    Set<Id> getOpportunitiesWithQuotes(List<Opportunity> opportunitiesToBeReparented);

    /**
     * @description Method declaration for autopopulating currency
     */
    void defaultOpportunityCurrencyToAccountCurrency();

    /**
     * @description Method declaration for Contact Role gate on Stage change
     * @param oldOpportunityRecords
     * @param changedRecords
     */
    void contactRoleValidationBeforeStageChangePastPitching(
        Map<Id, SObject> oldOpportunityRecords,
        List<Opportunity> changedRecords
    );

    /**
     * @description Method declaration for validation error on
     * Opportunity Creation past Pitching Stage
     */
    void contactRoleValidationOnOpportunityCreation();

    /**
     * @description Set Account Lifecycle status when insert/undelete related opportunities
     */
    void updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();

    /**
     * @description Update Account Lifecycle status after deleting related Opportunity.
     */
    void checkAccountLifecycleStatusWhenOpportunityDeleted();

    /**
     * @description Account Life cycle status set when the update takes place on related opportunities.
     * @param oldOpportunityRecords
     */
    void updateAccountLifecycleStatusOnOpportunityUpdate(
        Map<Id, Opportunity> oldOpportunityRecords
    );

    /**
     * @description This method is to update the Opportunity in Stalled Stage to Closed Stage if there
     *              has been no activity in last 120 days.
     * @return List<Opportunity>
     */
    List<Opportunity> updateInactiveOpportunitiesInStalledStageToClosed();

    /**
     * @description This method is used to get Opportunities with Nintex values updated.
     */
    void createAgreementsFromOpportunities();

    /**
     *  @description It validates that corporate Opportunity is associated with Work Order before moving to the contracting stage.
     *
     */
    void validateOpportunitiesInContractingStage();

    /**
     * @description It creates Opportunity Brand Relationship on Opportunity insert when there is
     * only one Brand Association related to the associated Account.
     */
    void createBrandRelationshipOnOpportunityInsert();

    /**
     * @description LEM-4974 It is used to create opportunity team members for new opportunities
     * and Opportunities when owner is changed
     * @param eventName
     */
    void createOpportunityTeamMembersForManagersOnOwnerUpdate(String eventName);

    /**
     * @description It is used to update OCR's for Opportunities created by Lead Conversion
     * @JIRA# LEM-13473
     */
    void updateOCRForLeadConvertedOpportunities();

    /**
     * @description It is used to create OCR record for the manually created Opportunities.
     * @JIRA# LEM-13473
     */
    void createOCRForManuallyCreatedOpportunities();

    /**
     * @description It is used to stamp Deck Rank and Medal Rank values
     * when Opportunities are Closed.
     * @JIRA# LEM-14100
     * @param opportunitiesWithChangedStage
     */
    void stampDeckRankAndMedalRankValues(List<Opportunity> opportunitiesWithChangedStage);

    /**
     * @description It is used to set Opportunity lookup on MxTagAssociation
     * when an opportunity is created
     * @JIRA# LEM-14104
     */
    void addMxTagAssociationToNewlyCreatedOpportunity();

    /**
     * @description It is used to process opportunities post lead conversion.
     * @param existingRecords
     */
    void processOpportunitiesOnLeadConversion(Map<Id, SObject> existingRecords);

    /**
     * @description It is used to assign the default values on newly created opportunities
     * post lead conversion.
     */
    void assignValuesPostLeadConversion();

    /**
     * @description It is used to update Last Inbound Date/Time for Opportunity.
     */
    void updateLastInboundDateTime();

    /**
     * @description Prepares the name of the Opportunity with Parent Account, CloseDate
     * Sub Type and Length.
     * @param opportunityRecord
     * @param parentAccount
     * @param length
     */
    void formulateName(Opportunity opportunityRecord, Account parentAccount, Integer length);

    /**
     * @description It is used to throw validation when Opportunities are moved
     * to Negotiating stage without any Events with held Status.
     */
    void validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();

    /**
     * @description Method declaration for autopopulating Active Account Plan
     */
    void assignActiveAccountPlanId();

    /**
     * @description It is used to evaluate and initiate Work Order Creation for Stores Added through Mx
     * Portal.
     * @JIRA# LEM-16267
     */
    void evaluateAndInitiateWorkOrderCreationForMxPortalStoreAddition();

    /**
     * @description VSP Opportunity Name change when Sub Type is updated
     * Portal.
     * @param existingOpportunities
     * @JIRA# LEM-18501
     */
    void vspOpportunityNameUpdate(Map<Id, Opportunity> existingOpportunities);
}