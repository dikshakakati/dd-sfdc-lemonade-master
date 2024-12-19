/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Opportunity Object Trigger Handler
 */
public class OpportunitiesHandler extends ApplicationDomainHandler {
    private static final Set<String> APPLICABLE_SOURCE_FOR_OCR_CREATION = new Set<String>{
        'SSMO',
        'SSOB',
        'Mx Portal'
    };
    static final String BYPASS_OPPORTUNITY_VALIDATIONS = 'Bypass_Opportunity_Validation_Rules';
    static final String STAGE_NAME_CLOSED_WON = 'Closed Won';
    static final String STAGE_NAME_CLOSED_LOST = 'Closed Lost';
    static final String EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION = 'EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION';
    static final String SMB_ACCOUNT_SEGMENT = 'SMB';
    static final String SUB_TYPE_ADS_AND_PROMO = 'Ads & Promos';
    static final String DEAL_TYPE_SELF_SERVE = 'Self-Serve';
    static final String OPPORTUNITY_SOURCE_LEAD = 'Lead';
    static final String OPPORTUNITY_SOURCE_MANUAL = 'Manual';
    static final String OPPORTUNITY_SOURCE_VSP_RECOMMENDATION = 'VSP Recommendation';
    public static Boolean isUpdateRestricted = false;

    /**
     * @description Constructor to instantiate List of Opportunities
     * @param sObjectList - Opportunity Record List
     */
    public OpportunitiesHandler(List<Opportunity> sObjectList) {
        super(sObjectList);
        setContextBypass(Opportunity.SobjectType, OpportunitiesHandler.class);
    }

    /**
     * @description Constructor Class implements fflib_SObjectDomain.IConstructable class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflibSObjectDomain.IConstructable
         * @param sObjectList
         * @return OpportunitiesHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunitiesHandler(sObjectList);
        }
    }

    //Override to apply defaults to the records, this is called by the handleBeforeInsert method
    public override void onApplyDefaults() {
        IOpportunities opportunitiesInstance = Opportunities.newInstance(
            (List<Opportunity>) getRecords()
        );
        //Logic to assign default values post lead conversion.
        opportunitiesInstance.assignValuesPostLeadConversion();
        opportunitiesInstance.assignNameOnInsertOrNameUpdate();
        //Logic to assign the standard pricebook for each oppty
        opportunitiesInstance.assignPriceBook();
        //Logic to assign ContractId
        opportunitiesInstance.assignContractAndPreventOpportunityNewTypeCreation();
        //logic to validate contact role on Opportunity creation in Negotiation, Contracting or Closed Won stage for Standard Opportunity
        opportunitiesInstance.contactRoleValidationOnOpportunityCreation();
        //logic to update Opportunity Currency as Account Currency on Opportunity creation
        opportunitiesInstance.defaultOpportunityCurrencyToAccountCurrency();
        //logic to update Active Account Plan on Opportunity creation LEM-17006
        opportunitiesInstance.assignActiveAccountPlanId();
    }

    /**
     * @description Called to perform before update processing
     * @param existingRecords - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        if (!isUpdateRestricted) {
            Opportunities.newInstance(opportunitiesWithAllUpdatedNameComponents())
                .validateOpportunityNameChange((Map<Id, Opportunity>) existingRecords);
            Opportunities.newInstance(opportunitiesWithUpdatedName())
                .assignNameOnInsertOrNameUpdate();
            Opportunities.newInstance(opportunitiesWithUpdatedNameComponents())
                .assignNameOnNamingComponentsUpdates((Map<Id, Opportunity>) existingRecords);
            restoreForecastAndProbabilityOnStageChangeToStalled(existingRecords);
            defaultOpportunityCurrencyToAccountCurrency();
            contactRoleValidationBeforeStageChangePastPitching(existingRecords);
            beforeUpdateValidations(existingRecords);
            collectOpportunitiesWithChangedStage(existingRecords);
            Opportunities.newInstance(parentAccountMergedOpportunities())
                .updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
            setAccountIsParentAccountMergedToFalse();
            List<Opportunity> opportunitiesFromConvertedLeads = new List<Opportunity>(
                (List<Opportunity>) getChangedRecords(
                    new Set<SObjectField>{ Opportunity.Converted_Lead_Id__c }
                )
            );
            Opportunities.newInstance(opportunitiesFromConvertedLeads)
                .processOpportunitiesOnLeadConversion(existingRecords);
            Opportunities.newInstance(opportunitiesWithUpdatedPrimaryCampaignSource())
                .updateLastInboundDateTime();
            Opportunities.newInstance(opportunitiesWithUpdatedNameComponents())
                .vspOpportunityNameUpdate((Map<Id, Opportunity>) existingRecords);
        }
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        Opportunities.newInstance(this.records)
            .updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
        //LEM-3269 Nintex calls on insert must only happen in OpportunityChangeEventsHandler

        //LEM-4974 Automatically add oppty creator's manager to oppty team
        //After Insert
        Opportunities.newInstance(this.records)
            .createOpportunityTeamMembersForManagersOnOwnerUpdate(
                EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION
            );
        Opportunities.newInstance(this.records).createBrandRelationshipOnOpportunityInsert();
        createOCRForOpportunities(this.records);
        //LEM-14104
        Opportunities.newInstance(this.records).addMxTagAssociationToNewlyCreatedOpportunity();
        Opportunities.newInstance(this.records)
            .evaluateAndInitiateWorkOrderCreationForMxPortalStoreAddition();
    }

    /**
     * @description Called to perform after delete processing
     */
    public override void onAfterDelete() {
        Opportunities.newInstance(existingRecords.values())
            .checkAccountLifecycleStatusWhenOpportunityDeleted();
    }

    /**
     * @description Called to perform after Undelete processing
     */
    public override void onAfterUndelete() {
        Opportunities.newInstance(this.records)
            .updateAccountLifecycleStatusOnOpportunityInsertOrUndelete();
    }
    /**
     * @description Called to perform after Update processing
     * @param existingRecords - The map of old requests
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        if (!isUpdateRestricted) {
            Map<Id, Opportunity> idOpportunityMap = new Map<Id, Opportunity>();
            idOpportunityMap.putAll(opportunitiesWithPrimaryQuoteChanged());
            //Calling Opportunities Contact Role Service to update Opportunities Contact Role from Opportunity.
            OpportunityContactRoleService.stampPrimaryQuoteOnOppContactRole(idOpportunityMap);
            OpportunityContactRoleService.updateContractSignatoryContactRole(
                closedWonOpportunities()
            );
            SObjectsStatusUpdateService.updateSObjectsStatusFieldValue(
                getClosedLostOpportunities()
            );
            Opportunities.newInstance(nintexOppsUpdatedToClosedWon(existingRecords))
                .createAgreementsFromOpportunities();
            Opportunities.newInstance(opportunitiesWithChangedAccount())
                .updateAccountLifecycleStatusOnOpportunityUpdate(
                    (Map<Id, Opportunity>) existingRecords
                );

            Opportunities.newInstance(opportunitiesWithUpdatedOwner())
                .createOpportunityTeamMembersForManagersOnOwnerUpdate(
                    EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION
                );
            List<Opportunity> oppsToSyncBackToBrief = oppsWithUpdatedFieldsToSyncBackToBrief();
            if (!oppsToSyncBackToBrief.isEmpty()) {
                Map<Id, List<Brief__c>> oppIdToBriefMap = OpportunitiesService.mapOpportunityIdToListOfBrief(
                    BriefsSelector.newInstance()
                        .selectByOpportunityBriefRelationship(getIdSet(oppsToSyncBackToBrief))
                );

                OpportunitiesService.updateBriefsFromOpportunity(
                    oppsToSyncBackToBrief,
                    oppIdToBriefMap
                );
            }
            if (!opportunitiesWithUpdatedOwner().isEmpty()) {
                OpportunitiesService.updateBriefItemsFromOpportunity(
                    opportunitiesWithUpdatedOwner()
                );
            }
        }
        List<Opportunity> opportunitiesWithChangedSource = getChangedRecords(
            new Set<SObjectField>{ Opportunity.Source__c  }
        );
        createOCRForOpportunities(opportunitiesWithChangedSource);
        isUpdateRestricted = false;
    }

    /**
     * @description Collects Closed Won Opportunities
     * @return Map<Id,Opportunity>
     */
    private Map<Id, Opportunity> closedWonOpportunities() {
        List<Opportunity> opptyChangedRecList = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(new Set<Schema.SObjectField>{ Opportunity.IsWon })
        );

        Map<Id, Opportunity> idsToOpportunity = new Map<Id, Opportunity>();
        idsToOpportunity.putAll((List<Opportunity>) opptyChangedRecList);

        return idsToOpportunity;
    }

    /**
     * @description It collects Opportunities with changed stage and passes
     * further for validation on the contracting stage.
     * @param existing
     */
    private void collectOpportunitiesWithChangedStage(Map<Id, SObject> existing) {
        List<Opportunity> opportunitiesWithChangedStage = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.StageName }
            )
        );
        List<Opportunity> nonSMBopportunitiesWithChangedStage = filterOutSMBOpportunities(
            opportunitiesWithChangedStage
        );
        Opportunities.newInstance(nonSMBopportunitiesWithChangedStage)
            .validateOpportunitiesInContractingStage();
        Opportunities.newInstance(opportunitiesWithChangedStage)
            .stampDeckRankAndMedalRankValues(opportunitiesWithChangedStage);
        Opportunities.newInstance(opportunitiesWithChangedStage)
            .validateOpportunitiesMovedToNegotiatingWithoutHeldEvents();
    }

    /**
     * @description It is used to filter out Opportunity based on Account Segment != SMB.
     * #JIRA LEM-15825
     * @param opportunitiesWithChangedStage
     * @return List<Opportunity>
     */
    private List<Opportunity> filterOutSMBOpportunities(
        List<Opportunity> opportunitiesWithChangedStage
    ) {
        List<Opportunity> filteredOpportunities = new List<Opportunity>();
        for (Opportunity eachOpportunity : opportunitiesWithChangedStage) {
            if (eachOpportunity.Account_Segment__c != SMB_ACCOUNT_SEGMENT) {
                filteredOpportunities.add(eachOpportunity);
            }
        }
        return filteredOpportunities;
    }

    /**
     * @description This method is used to update Opportunity Name based on changes to
     * Opportunity Name or Account Name or CloseDate or Sub-type
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithUpdatedName() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(new Set<Schema.SObjectField>{ Opportunity.Name })
        );
    }

    /**
     * @description This method is used to update Opportunity Name based on changes to
     * Opportunity Name or Account Name or CloseDate or Sub-type
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithUpdatedNameComponents() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Opportunity.CloseDate,
                    Opportunity.Opportunity_Sub_Type__c,
                    Opportunity.AccountId,
                    Opportunity.Is_Parent_Account_Merged__c,
                    Opportunity.Name
                }
            )
        );
    }

    /**
     * @description This method is used to update Opportunity Name based on changes to
     * Opportunity Name or Account Name or CloseDate or Sub-type
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithAllUpdatedNameComponents() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{
                    Opportunity.CloseDate,
                    Opportunity.Opportunity_Sub_Type__c,
                    Opportunity.AccountId,
                    Opportunity.Name
                }
            )
        );
    }

    /**
     * @description This method returns the Opportunities that have a changed Stage/Account
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithUpdatedStageOrAccount() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.StageName, Opportunity.AccountId }
            )
        );
    }

    /**
     * @description This method contains Logic to update the Probability and Forecase Category of the Opportunity
     * @param existing - The map of old requests
     */
    private void restoreForecastAndProbabilityOnStageChangeToStalled(Map<Id, SObject> existing) {
        List<Opportunity> opptyChangedRecList = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.StageName }
            )
        );
        Opportunities.newInstance(opptyChangedRecList)
            .restoreForecastAndProbabilityOnStageChangeToStalled(existing, opptyChangedRecList);
    }

    /**
     * @description Fetches changed records for all before update validations
     * @param existingRecords
     */
    private void beforeUpdateValidations(Map<Id, SObject> existingRecords) {
        List<Opportunity> opportunitiesWithChangedAccount = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.AccountId }
            )
        );
        List<Opportunity> opportunitiesWithChangedPitchAmount = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.Pitch_Amount__c }
            )
        );
        List<Opportunity> opportunitiesWithChangedSubType = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.Opportunity_Sub_Type__c }
            )
        );
        List<Opportunity> opportunitiesWithChangedStage = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.StageName }
            )
        );

        List<Opportunity> allChangedOpportunities = new List<Opportunity>();
        allChangedOpportunities.addAll(opportunitiesWithChangedAccount);
        allChangedOpportunities.addAll(opportunitiesWithChangedPitchAmount);
        Set<Id> opportunitiesWithQuotes = Opportunities.newInstance(allChangedOpportunities)
            .getOpportunitiesWithQuotes(allChangedOpportunities);

        Opportunities.newInstance(opportunitiesWithChangedAccount)
            .opportunityReparentingValidation(
                opportunitiesWithChangedAccount,
                opportunitiesWithQuotes
            );
        Opportunities.newInstance(opportunitiesWithChangedPitchAmount)
            .validateChangeInPitchAmount(opportunitiesWithQuotes);

        Opportunities.newInstance(opportunitiesWithChangedSubType).validateChangeInSubType();
        Opportunities.newInstance(opportunitiesWithChangedStage)
            .validatePrimaryOrderForOpportunityCloseWin();
    }

    /**
     * @description This method is used to set the Opportunity as Account currency
     */
    private void defaultOpportunityCurrencyToAccountCurrency() {
        List<Opportunity> opptyChangedRecList = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.AccountId, Opportunity.CurrencyIsoCode }
            )
        );
        Opportunities.newInstance(opptyChangedRecList)
            .defaultOpportunityCurrencyToAccountCurrency();
    }

    /**
     * @description This method is used to check the contact role on opportunity before changing the stage for Standard Opportunity
     * @param existing - The map of old requests
     */
    private void contactRoleValidationBeforeStageChangePastPitching(Map<Id, SObject> existing) {
        List<Opportunity> opptyChangedRecList = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.StageName }
            )
        );

        if (!opptyChangedRecList.isEmpty()) {
            Opportunities.newInstance(opptyChangedRecList)
                .validateOpportunitiesInNegotiatingStage(existing, opptyChangedRecList);
        }

        List<Opportunity> liteOpportunities = new List<Opportunity>(
            (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.Deal_Type__c,
                new Set<Object>{ System.Label.Opportunity_Lite }
            )
        );

        for (Opportunity oppty : liteOpportunities) {
            if (opptyChangedRecList.contains(oppty)) {
                Integer num = opptyChangedRecList.indexOf(oppty);
                opptyChangedRecList.remove(num);
            }
        }

        if (!opptyChangedRecList.isEmpty()) {
            Opportunities.newInstance(opptyChangedRecList)
                .contactRoleValidationBeforeStageChangePastPitching(existing, opptyChangedRecList);
        }
    }

    /**
     * @description This method is used to update Opportunity Contact Role
     * When the Primary Quote Changes on the Opportunity
     * @return Map<Id,Opportunity>
     */
    private Map<Id, Opportunity> opportunitiesWithPrimaryQuoteChanged() {
        List<Opportunity> opptyChangedRecList = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.SBQQ__PrimaryQuote__c }
            )
        );
        Map<Id, Opportunity> idsToOpportunity = new Map<Id, Opportunity>();
        idsToOpportunity.putAll((List<Opportunity>) opptyChangedRecList);
        return idsToOpportunity;
    }

    /**
     * @description This method is used to find Opportunities where Nintex_Use_Case__c is not null,
     *              And the StageName changed to 'Closed Won'
     * @param existingRecords
     * @return Set<Id>
     */
    private List<Opportunity> nintexOppsUpdatedToClosedWon(Map<Id, SObject> existingRecords) {
        List<Opportunity> closedWonNintexOpps = new List<Opportunity>();
        List<Opportunity> stageNameChangedRecList = new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.StageName }
            )
        );
        for (Opportunity currentOpp : stageNameChangedRecList) {
            Opportunity existingOpp = (Opportunity) existingRecords.get(currentOpp.Id);
            String existingOppStageName = (existingOpp != null) ? existingOpp.StageName : '';
            if (
                (currentOpp.StageName == STAGE_NAME_CLOSED_WON) &&
                (existingOppStageName != STAGE_NAME_CLOSED_WON) &&
                (currentOpp.Nintex_Use_Case__c != null)
            ) {
                closedWonNintexOpps.add(currentOpp);
            }
        }
        return closedWonNintexOpps;
    }

    /**
     * @description This method is used to get opportunities with parent account changed.
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithChangedAccount() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.AccountId }
            )
        );
    }

    /**
     * @description This method is used to get opportunities with parent account merged.
     * @return List<Opportunity>
     */
    private List<Opportunity> parentAccountMergedOpportunities() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.Is_Parent_Account_Merged__c }
            )
        );
    }

    /**
     * @description To set IsParentAccountMerged field as false
     */
    private void setAccountIsParentAccountMergedToFalse() {
        for (Opportunity eachOpportunity : (List<Opportunity>) this.records) {
            eachOpportunity.Is_Parent_Account_Merged__c = false;
        }
    }
    /**
     * @description LEM-4974 This method is used to get Opportunities with ownerId
     * Opportunity owner ID
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithUpdatedOwner() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                new Set<Schema.SObjectField>{ Opportunity.ownerId }
            )
        );
    }
    /**
     * @description LEM-9264 Used to get a list of opportunites that have updated fields that need to
     * sync back to the Brief
     * @return List<Opportunity>
     */
    private List<Opportunity> oppsWithUpdatedFieldsToSyncBackToBrief() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(
                OpportunityToBriefMappingSelector.newInstance().getOpportunityFieldSet()
            )
        );
    }
    /**
     * @description helper method to pluck Ids from List
     * @param objects
     * @return Set<Id>
     */
    private Set<Id> getIdSet(List<SObject> objects) {
        Set<Id> idSet = new Set<Id>();
        for (SObject obj : objects) {
            idSet.add(obj.Id);
        }
        return idSet;
    }

    private void createOCRForOpportunities(List<Opportunity> opportunityRecords) {
        List<Opportunity> opportunitiesCreatedFromLeadConversion = new List<Opportunity>();
        List<Opportunity> opportunitiesCreatedManually = new List<Opportunity>();
        for (Opportunity eachOpportunity : opportunityRecords) {
          if (checkSegmentCondition(eachOpportunity)){
            if (eachOpportunity.Source__c == OPPORTUNITY_SOURCE_LEAD) {
                opportunitiesCreatedFromLeadConversion.add(eachOpportunity);
            } else if (
                eachOpportunity.Source__c == OPPORTUNITY_SOURCE_MANUAL ||
                eachOpportunity.Source__c == OPPORTUNITY_SOURCE_VSP_RECOMMENDATION ||
                APPLICABLE_SOURCE_FOR_OCR_CREATION.contains(eachOpportunity.Source__c)
            ) {
                opportunitiesCreatedManually.add(eachOpportunity);
            }
        }
    }
        if (opportunitiesCreatedFromLeadConversion != null) {
            Opportunities.newInstance(opportunitiesCreatedFromLeadConversion)
                .updateOCRForLeadConvertedOpportunities();
        }
        if (opportunitiesCreatedManually != null) {
            Opportunities.newInstance(opportunitiesCreatedManually)
                .createOCRForManuallyCreatedOpportunities();
        }
    }

    private Boolean checkSegmentCondition(Opportunity opportunityRecord){
        return opportunityRecord.Account_Segment__c == SMB_ACCOUNT_SEGMENT ||
        (opportunityRecord.Account_Segment__c != SMB_ACCOUNT_SEGMENT &&
        opportunityRecord.Deal_Type__c == DEAL_TYPE_SELF_SERVE &&
        opportunityRecord.Opportunity_Sub_Type__c == SUB_TYPE_ADS_AND_PROMO);
    }

    /**
     * @description It  is used to get Opportunities with StageName as Closed Lost.
     * @return List<Opportunity>
     */
    private List<Opportunity> getClosedLostOpportunities() {
        return new List<Opportunity>(
            (List<Opportunity>) getRecordsByFieldValue(
                Opportunity.StageName,
                STAGE_NAME_CLOSED_LOST
            )
        );
    }

    /**
     * @description It is used to collect Opportunities with updated Primary Campaign Source field
     * @return List<Opportunity>
     */
    private List<Opportunity> opportunitiesWithUpdatedPrimaryCampaignSource() {
        return new List<Opportunity>(
            (List<Opportunity>) getChangedRecords(new Set<SObjectField>{ Opportunity.CampaignId })
        );
    }
}