/**
 * @author Deloitte
 * @date 11/10/2022
 * @description Service implementation class for logic related to Brief.
 */
public inherited sharing class BriefsServiceImpl implements IBriefsService {
    private static final String NOT_APPLICABLE_TEXTAREA = 'N/A';
    private static final String STANDARD_CONFIGURATION = 'Standard (Mx Services)';
    private static final String SPONSORED_PRODUCTS = 'Sponsored Products';
    private static final Set<String> SPONSORED_PRODUCTS_PACKAGE = new Set<String>{
        'CnG Search',
        'CnG DoubleDash',
        'CnG Collections',
        'CnG Categories'
    };
    private static final String SPONSORSHIPS = 'Sponsorships';
    private static final String CPG = 'CPG';
    private static final String CUSTOM_AD_OPS = 'Custom (Ad Ops)';
    private static final String STANDARD_LAUNCH_OPS = 'Standard (Launch Ops)';
    private static final String YES = 'Yes';
    private static final String MARKETING_FUND = 'Marketing Fund';
    private Map<Id, Set<String>> quoteToCampaigns;
    private fflib_ISObjectUnitOfWork unitOfWorkBriefCreation;
    /**
     * Business Account Type as Agency
     */
    private static final String AGENCY = 'Agency';
    /**
     * Picklist value is No
     */
    private static final String PICKLIST_VALUE_NO = 'No';
    /**
     * @description Default constructor to initialize the class variables.
     */
    public BriefsServiceImpl() {
        quoteToCampaigns = new Map<Id, Set<String>>();
        unitOfWorkBriefCreation = Application.UNITOFWORK.newInstance();
    }

    /**
     * @description It is used to create Briefs for a unique set of Campaigns from Quote Line Items
     * and relate them to a Quote.
     * @param quoteLineItems
     */
    public void generateBriefsByQuoteLineItems(List<SBQQ__QuoteLine__c> quoteLineItems) {
        Map<Id, List<Brief__c>> quoteToBriefs = new Map<Id, List<Brief__c>>();
        Map<Id, List<Brief__c>> oppToBriefs = new Map<Id, List<Brief__c>>();
        List<Brief__c> newBriefs = new List<Brief__c>();
        //LEM-16580 - Added check for empty list to prevent further processing
        if (quoteLineItems.isEmpty()) {
            return;
        }
        //Remove boolean variables.
        for (SBQQ__QuoteLine__c eachQuoteLineItem : quoteLineItems) {
            if (eachQuoteLineItem.Create_Brief_Item__c == PICKLIST_VALUE_NO) {
                continue;
            }
            if (!quoteToCampaigns.containsKey(eachQuoteLineItem.SBQQ__Quote__c)) {
                quoteToCampaigns.put(eachQuoteLineItem.SBQQ__Quote__c, new Set<String>());
            }
            if (
                !quoteToCampaigns.get(eachQuoteLineItem.SBQQ__Quote__c)
                    .contains(eachQuoteLineItem.Campaign_Name__c) &&
                !SPONSORED_PRODUCTS_PACKAGE.contains(eachQuoteLineItem.SBQQ__ProductName__c)
            ) {
                quoteToCampaigns.get(eachQuoteLineItem.SBQQ__Quote__c)
                    .add(eachQuoteLineItem.Campaign_Name__c);
                Brief__c briefInstance = createBriefInstance(eachQuoteLineItem);
                newBriefs.add(briefInstance);
                if (!quoteToBriefs.containsKey(eachQuoteLineItem.SBQQ__Quote__c)) {
                    quoteToBriefs.put(eachQuoteLineItem.SBQQ__Quote__c, new List<Brief__c>());
                }
                quoteToBriefs.get(eachQuoteLineItem.SBQQ__Quote__c).add(briefInstance);
                if (
                    !oppToBriefs.containsKey(eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c)
                ) {
                    oppToBriefs.put(
                        eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                        new List<Brief__c>()
                    );
                }
                oppToBriefs.get(eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c)
                    .add(briefInstance);
                unitOfWorkBriefCreation.registerNew(briefInstance);
            }
        }
        commitUnitOfWork(unitOfWorkBriefCreation);
        createQuoteBriefRelationship(quoteToBriefs, quoteLineItems);
        createOppBriefRelationship(oppToBriefs);
    }

    /**
     * @description It is used to create the Quote Brief Relationship for the newly created list of
     * Brief records
     * @param quoteToBrief
     * @param quoteLineItems
     */
    private void createQuoteBriefRelationship(
        Map<Id, List<Brief__c>> quoteToBrief,
        List<SBQQ__QuoteLine__c> quoteLineItems
    ) {
        fflib_ISObjectUnitOfWork unitOfWorkRelationshipCreation = Application.UNITOFWORK.newInstance();
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>();
        for (Id eachQuoteId : quoteToBrief.keySet()) {
            for (Brief__c eachBrief : quoteToBrief.get(eachQuoteId)) {
                Quote_Brief_Relationship__c newQuoteBriefRelationship = new Quote_Brief_Relationship__c(
                    Quote__c = eachQuoteId,
                    Brief__c = eachBrief.Id,
                    Campaign_of_Brief__c = eachBrief.CampaignName__c
                );
                quoteBriefRelationships.add(newQuoteBriefRelationship);
                unitOfWorkRelationshipCreation.registerNew(newQuoteBriefRelationship);
            }
        }
        commitUnitOfWork(unitOfWorkRelationshipCreation);
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItems,
            QuoteBriefRelationshipsSelector.newInstance()
                .selectById(getQuoteBriefRelationshipIds(quoteBriefRelationships))
        );
    }

    /**
     * @description It is used to get the set of Ids of Quote Brief Relationships
     * @param quoteBriefRelationships
     * @return Set<Id>
     */
    private Set<Id> getQuoteBriefRelationshipIds(
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    ) {
        Set<Id> relationshipIds = new Set<Id>();
        for (Quote_Brief_Relationship__c eachRelationship : quoteBriefRelationships) {
            relationshipIds.add(eachRelationship.Id);
        }
        return relationshipIds;
    }

    /**
     * @description It is used to update Brief status based on related Brief Items status.
     * @param briefsWithItemsWaitingForInputs
     * @param briefsWithItemsInCampaignBuilding
     */
    public void updateBriefBasedOnBriefItemsStatus(
        Set<Id> briefsWithItemsWaitingForInputs,
        Set<Id> briefsWithItemsInCampaignBuilding
    ) {
        Set<Id> allBriefIds = new Set<Id>();
        allBriefIds.addAll(briefsWithItemsWaitingForInputs);
        allBriefIds.addAll(briefsWithItemsInCampaignBuilding);
        Map<Id, Brief__c> briefsToBeUpdated = new Map<Id, Brief__c>(
            BriefsSelector.newInstance().selectById(allBriefIds)
        );
        for (Id eachBriefId : briefsToBeUpdated.keySet()) {
            if (briefsWithItemsWaitingForInputs.contains(eachBriefId)) {
                briefsToBeUpdated.get(eachBriefId)
                    .Are_All_Brief_Items_in_Campaign_Building__c = false;
            }
            if (briefsWithItemsInCampaignBuilding.contains(eachBriefId)) {
                briefsToBeUpdated.get(eachBriefId)
                    .Are_All_Brief_Items_in_Campaign_Building__c = true;
            }
        }
        unitOfWorkBriefCreation.registerDirty(briefsToBeUpdated.values());
        commitUnitOfWork(unitOfWorkBriefCreation);
    }

    /**
     * @description It is used to update Brief Date based on related Brief Items dates.
     * @param briefIds
     * @param briefsToStartDate
     * @param briefsToEndDate
     */
    public void updateBriefDateBasedOnBriefItemsDate(
        Set<Id> briefIds,
        Map<Id, Date> briefsToStartDate,
        Map<Id, Date> briefsToEndDate
    ) {
        Map<Id, Brief__c> briefsToBeUpdated = new Map<Id, Brief__c>(
            BriefsSelector.newInstance().selectById(briefIds)
        );
        for (Id eachBriefId : briefsToBeUpdated.keySet()) {
            if (briefsToStartDate.containsKey(eachBriefId)) {
                briefsToBeUpdated.get(eachBriefId).Start_Date__c = briefsToStartDate.get(
                    eachBriefId
                );
            }
            if (briefsToEndDate.containsKey(eachBriefId)) {
                briefsToBeUpdated.get(eachBriefId).End_Date__c = briefsToEndDate.get(eachBriefId);
            }
        }
        unitOfWorkBriefCreation.registerDirty(briefsToBeUpdated.values());
        commitUnitOfWork(unitOfWorkBriefCreation);
    }
    /**
     * @description update Opportunities when brief is updated
     * @param briefs
     */
    public void updateOpportunityFromBrief(List<Brief__c> briefs) {
        Set<Id> briefOppIds = new Set<Id>();
        Map<Id, Opportunity> oppIdMap = new Map<Id, Opportunity>();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (Brief__c brief : briefs) {
            if (brief.Opportunity_Name__c != null) {
                briefOppIds.add(brief.Opportunity_Name__c);
            } else if (brief.Agency_Opportunity_Name__c != null) {
                briefOppIds.add(brief.Agency_Opportunity_Name__c);
            }
        }
        List<Opportunity> opps = OpportunitiesSelector.newInstance()
            .getOpportunitiesToSyncFromBriefs(briefOppIds);
        for (Opportunity opp : opps) {
            oppIdMap.put(opp.Id, opp);
        }
        for (Brief__c brief : briefs) {
            if (
                oppIdMap.containskey(brief.Opportunity_Name__c) ||
                oppIdMap.containsKey(brief.Agency_Opportunity_Name__c)
            ) {
                Opportunity briefOpp = opportunityInstanceToUpdate(brief, oppIdMap);
                if (briefOpp != null) {
                    uow.registerDirty(briefOpp);
                }
            }
        }
        commitUnitOfWork(uow);
    }

    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
    /**
     * @description It is used to create the Opportunity Brief Relationship for the newly created list of
     * Brief records
     * @param oppToBrief
     */
    private void createOppBriefRelationship(Map<Id, List<Brief__c>> oppToBrief) {
        fflib_ISObjectUnitOfWork unitOfWorkRelationshipCreation = Application.UNITOFWORK.newInstance();
        Set<Id> briefIdSet = pluckBriefIdsFromMap(oppToBrief);
        Map<Id, Opportunity_Brief_Relationship__c> briefIdToOBR = new Map<Id, Opportunity_Brief_Relationship__c>();
        List<Opportunity_Brief_Relationship__c> oppBriefsRelationship = OppBriefRelationshipsSelector.newInstance()
            .selectByOpportunities(oppToBrief.keySet());
        briefIdToOBR = mapBriefIdToExistingOppBriefRelationship(oppBriefsRelationship, oppToBrief);
        Map<Id, Brief__c> briefsWithAccountIdMap = new Map<Id, Brief__c>(
            BriefsSelector.newInstance().selectByIdIncludingAccountId(briefIdSet)
        );
        for (Id eachOppId : oppToBrief.keySet()) {
            for (Brief__c eachBrief : oppToBrief.get(eachOppId)) {
                if (
                    !briefIdToOBR.containsKey(eachBrief.Id) &&
                    briefsWithAccountIdMap.containsKey(eachBrief.Id) &&
                    (briefsWithAccountIdMap.get(eachBrief.Id).Opportunity_Name__c != null ||
                    briefsWithAccountIdMap.get(eachBrief.Id).Agency_Opportunity_Name__c != null)
                ) {
                    Opportunity_Brief_Relationship__c newOppBriefRelationship = new Opportunity_Brief_Relationship__c(
                        Opportunity__c = eachOppId,
                        Brief__c = eachBrief.Id,
                        Account__c = briefsWithAccountIdMap.get(eachBrief.Id).Opportunity_Name__c !=
                            null
                            ? briefsWithAccountIdMap.get(eachBrief.Id).Opportunity_Name__r.AccountId
                            : briefsWithAccountIdMap.get(eachBrief.Id)
                                  .Agency_Opportunity_Name__r.AccountId
                    );

                    unitOfWorkRelationshipCreation.registerNew(newOppBriefRelationship);
                }
            }
        }
        commitUnitOfWork(unitOfWorkRelationshipCreation);
    }
    /**
     * @description retrieves all of the Ids from a Map of List of Briefs
     * @param oppIdToBriefListMap
     * @return Set<Id>
     */
    private Set<Id> pluckBriefIdsFromMap(Map<Id, List<Brief__c>> oppIdToBriefListMap) {
        Set<Id> briefIdSet = new Set<Id>();
        for (List<Brief__c> briefList : oppIdToBriefListMap.values()) {
            for (Brief__c brief : briefList) {
                briefIdSet.add(brief.Id);
            }
        }
        return briefIdSet;
    }
    /**
     * @description LEM-9347 update agency fields on brief for existing briefs
     * @param mapBriefIdToQuoteLineContractSigned
     */
    public void updateAgencyFieldOnExistingBriefs(
        Map<Id, SBQQ__QuoteLine__c> mapBriefIdToQuoteLineContractSigned
    ) {
        fflib_ISObjectUnitOfWork briefUoW = Application.UNITOFWORK.newInstance();
        Map<Id, List<Brief__c>> oppToBriefs = new Map<Id, List<Brief__c>>();
        List<Brief__c> briefs = BriefsSelector.newInstance()
            .selectByIdIncludingAccountId(mapBriefIdToQuoteLineContractSigned.keySet());
        for (Brief__c brief : briefs) {
            SBQQ__Quoteline__c quotelineItem = mapBriefIdToQuoteLineContractSigned.get(brief.Id);
            brief.Opportunity_Owner__c = quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId;
            if (
                quotelineItem.SBQQ__Quote__r.Invoicing_Payment_Account__r.Business_Account_Type__c ==
                AGENCY
            ) {
                brief.Agency_Netsuite_ID__c = quotelineItem.SBQQ__Quote__r.Payment_Account__r.NetSuite_ID__c;
            } else {
                brief.Netsuite_ID__c = quotelineItem.SBQQ__Quote__r.Payment_Account__r.NetSuite_ID__c;
            }
            if (quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Agency__c != null) {
                brief.Agency_Quote__c = quotelineItem.SBQQ__Quote__c;
                brief.Agency_Contract__c = quotelineItem.SBQQ__Quote__r.Signed_Contract_link__c;
                brief.Agency_Opportunity_Name__c = quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c;
            } else {
                brief.SBQQ_Quote__c = quotelineItem.SBQQ__Quote__c;
                brief.Opportunity_Name__c = quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c;
            }
            if (!oppToBriefs.containsKey(quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c)) {
                oppToBriefs.put(
                    quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                    new List<Brief__c>()
                );
            }
            oppToBriefs.get(quotelineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(brief);
            briefUoW.registerDirty(brief);
        }
        commitUnitOfWork(briefUoW);
        if (!oppToBriefs.isEmpty()) {
            createOppBriefRelationship(oppToBriefs);
        }
    }
    /**
     * @description this method returns a map of brief ids to an existing Opportunity Brief Relationship
     * that exists for said brief
     * @param oppBriefsRelationship
     * @param oppToBrief
     * @return Map<Id, Opportunity_Brief_Relationship__c>
     */
    public Map<Id, Opportunity_Brief_Relationship__c> mapBriefIdToExistingOppBriefRelationship(
        List<Opportunity_Brief_Relationship__c> oppBriefsRelationship,
        Map<Id, List<Brief__c>> oppToBrief
    ) {
        Map<Id, Opportunity_Brief_Relationship__c> briefIdToOBR = new Map<Id, Opportunity_Brief_Relationship__c>();
        for (Opportunity_Brief_Relationship__c oppBriefRelation : oppBriefsRelationship) {
            List<Brief__c> briefsToCheck = oppToBrief.get(oppBriefRelation.Opportunity__c);
            for (Brief__c brief : briefsToCheck) {
                if (oppBriefRelation.Brief__c == brief.Id) {
                    briefIdToOBR.put(brief.Id, oppBriefRelation);
                }
            }
        }
        return briefIdToOBR;
    }

    /**
     * @description this method returns the brief we plan to insert
     * @param eachQuoteLineItem
     * @return Brief__c
     */
    public Brief__c createBriefInstance(SBQQ__Quoteline__c eachQuoteLineItem) {
        Brief__c briefInstance = new Brief__c(
            CampaignName__c = eachQuoteLineItem.Campaign_Name__c,
            CurrencyIsoCode = eachQuoteLineItem.SBQQ__Quote__r.CurrencyIsoCode,
            Additional_Notes__c = eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Notes__c,
            Opportunity_Owner__c = eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId,
            Purchase_Order__c = eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Purchase_Order__c,
            Campaign_Program_lookup__c = eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Campaign_Program__c
        );
        if (
            eachQuoteLineItem.SBQQ__Quote__r.Invoicing_Payment_Account__r.Business_Account_Type__c ==
            AGENCY
        ) {
            briefInstance.Agency_Netsuite_ID__c = eachQuoteLineItem.SBQQ__Quote__r.Payment_Account__r.NetSuite_ID__c;
        } else {
            briefInstance.Netsuite_ID__c = eachQuoteLineItem.SBQQ__Quote__r.Payment_Account__r.NetSuite_ID__c;
        }
        if (eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Agency__c != null) {
            briefInstance.Agency_Quote__c = eachQuoteLineItem.SBQQ__Quote__c;
            briefInstance.Agency_Contract__c = eachQuoteLineItem.SBQQ__Quote__r.Signed_Contract_link__c;
            briefInstance.Agency_Opportunity_Name__c = eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c;
        } else {
            briefInstance.SBQQ_Quote__c = eachQuoteLineItem.SBQQ__Quote__c;
            briefInstance.Opportunity_Name__c = eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__c;
        }
        return briefInstance;
    }
    /**
     * @description this method builds the opportunity we want ot update from the brief
     * @param brief
     * @param oppIdMap
     * @return Opportunity
     */
    public Opportunity opportunityInstanceToUpdate(Brief__c brief, Map<Id, Opportunity> oppIdMap) {
        Opportunity briefOpp = new Opportunity();
        if (
            oppIdMap.containskey(brief.Opportunity_Name__c) ||
            oppIdMap.containsKey(brief.Agency_Opportunity_Name__c)
        ) {
            briefOpp = oppIdMap.get(brief.Opportunity_Name__c) != null
                ? oppIdMap.get(brief.Opportunity_Name__c)
                : oppIdMap.get(brief.Agency_Opportunity_Name__c);
            if (
                briefOpp.Campaign_TLDR__c != brief.Campaign_TLDR__c ||
                briefOpp.Campaign_Program__c != brief.Campaign_Program_lookup__c ||
                briefOpp.Purchase_Order__c != brief.Purchase_Order__c
            ) {
                briefOpp.Campaign_TLDR__c = brief.Campaign_TLDR__c;
                briefOpp.Campaign_Program__c = brief.Campaign_Program_lookup__c;
                briefOpp.Purchase_Order__c = brief.Purchase_Order__c;
            }
        }
        return briefOpp;
    }

    /**
     * @description This method is used to update config field on Briefs based on brief item fields
     * @param briefsToBriefItems
     * @param briefsWithVert
     */
    public void updateBriefConfiguration(
        Map<Id, List<Brief_Item__c>> briefsToBriefItems,
        List<Brief__c> briefsWithVert
    ) {
        //fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id, Brief__c> briefsToBeUpdated = new Map<Id, Brief__c>();
        List<Brief__c> briefList = new List<Brief__c>();
        for (Brief__c brief : briefsWithVert) {
            if (brief.Primary_Vertical__c == CPG) {
                Brief__c briefToInsert = new Brief__c(
                    Id = brief.ID,
                    Configuration__c = CUSTOM_AD_OPS
                );
                briefList.add(briefToInsert);
                briefsToBriefItems.remove(brief.Id);
            }
        }
        for (Id briefId : briefsToBriefItems.keySet()) {
            for (Brief_Item__c briefItem : briefsToBriefItems.get(briefId)) {
                if (briefItem.Brief_Routing__c == CUSTOM_AD_OPS) {
                    Brief__c briefToInsert = new Brief__c(
                        Id = briefId,
                        Configuration__c = CUSTOM_AD_OPS
                    );
                    briefList.add(briefToInsert);
                    briefsToBriefItems.remove(briefId);
                    break;
                }
            }
        }
        briefList = checkForCustomCreativeField(briefsToBriefItems, briefList);
        briefsToBeUpdated.putAll(briefList);
        unitOfWorkBriefCreation.registerDirty(briefsToBeUpdated.values());
        commitUnitOfWork(unitOfWorkBriefCreation);
    }

    /**
     * @description helper method for updateBriefConfiguration, checks map for presence of
     * Custom_Creative_Field
     * @param briefsToBriefItems
     * @param briefList
     * @return briefList
     */

    public static List<Brief__c> checkForCustomCreativeField(
        Map<Id, List<Brief_Item__c>> briefsToBriefItems,
        List<Brief__c> briefList
    ) {
        //check remaining brief items for custom creative field = yes
        for (Id briefId : briefsToBriefItems.keySet()) {
            Boolean isCustomCreativeFieldYes = false;
            for (Brief_Item__c briefItem : briefsToBriefItems.get(briefId)) {
                if (briefItem.Custom_Creative_Required__c == YES) {
                    isCustomCreativeFieldYes = true;
                    break;
                }
            }
            if (isCustomCreativeFieldYes == false) {
                Brief__c briefToInsert = new Brief__c(
                    Id = briefId,
                    Configuration__c = STANDARD_LAUNCH_OPS
                );
                briefList.add(briefToInsert);
            } else {
                Brief__c briefToInsert = new Brief__c(
                    Id = briefId,
                    Configuration__c = CUSTOM_AD_OPS
                );
                briefList.add(briefToInsert);
            }
        }
        return briefList;
    }
}