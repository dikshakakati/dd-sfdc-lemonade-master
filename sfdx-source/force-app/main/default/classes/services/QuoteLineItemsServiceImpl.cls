/**
 * @author Deloitte
 * @date   26/04/2023
 * @description This is the service implementation class for QuoteLineItems
 */
public inherited sharing class QuoteLineItemsServiceImpl implements IQuoteLineItemsService {
    private static final String QUOTE_TYPE = 'Quote';
    private static final String QUOTE_LINE_TYPE_NEW = 'New';
    private static final String QUOTE_LINE_TYPE_AMENDED = 'Amended';
    private static final String RATE_CHANGE_COMMISSION = 'Commission';
    private static final String RATE_CHANGE_FEE = 'Fee';
    private static final List<String> NON_COPY_FIELDS = new List<String>{
        'id',
        'sbqq__quote__c',
        'sbqq__source__c',
        'original_quote_line_group__c',
        'ccp_unique_group_id__c',
        'legacy_id__c'
    };
    private static final String QUOTE_STATUS_APPROVED = 'Approved';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

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
     * @description populate Quote Line group on amemdment quote lines on the amendent quote.
     * @JIRA# LEM-6466
     * @param newQuotesMap
     */
    public void insertMissingAmendmentLineGroups(Map<Id, SBQQ__Quote__c> newQuotesMap) {
        if (newQuotesMap == null) {
            return;
        }
        Set<Id> newQuoteIds = new Set<Id>();
        Set<Id> prevQuoteIds = new Set<Id>();
        Set<Id> originalGroupIds = new Set<Id>();
        Map<Id, SBQQ__QuoteLine__c> prevLineIdOrSubIdToPrevQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> groupedLinesMap = new Map<Id, SBQQ__QuoteLine__c>();

        for (
            SBQQ__Quote__c newQuote : QuotesSelector.newInstance()
                .selectQuoteFieldsFromOriginalQuote(newQuotesMap.keySet())
        ) {
            prevQuoteIds.add(
                newQuote.SBQQ__MasterEvergreenContract__r.SBQQ__Order__r.SBQQ__Quote__c
            );
        }
        if (prevQuoteIds.isEmpty()) {
            return;
        }
        for (
            SBQQ__QuoteLine__c prevQL : QuoteLineItemsSelector.newInstance()
                .selectQuoteLinesFromQuoteIds(prevQuoteIds)
        ) {
            if (prevQL.SBQQ__UpgradedSubscription__c != null) {
                prevLineIdOrSubIdToPrevQuoteLineMap.put(
                    prevQL.SBQQ__UpgradedSubscription__c,
                    prevQL
                );
            } else {
                prevLineIdOrSubIdToPrevQuoteLineMap.put(prevQL.Id, prevQL);
            }
            originalGroupIds.add(prevQL.SBQQ__Group__c);
        }
        for (
            SBQQ__QuoteLine__c ql : QuoteLineItemsSelector.newInstance()
                .selectQuoteLineswithMissingGroups(newQuotesMap.keyset())
        ) {
            newQuoteIds.add(ql.SBQQ__Quote__c);
            groupedLinesMap.put(ql.id, ql);
        }
        if (groupedLinesMap.isEmpty() || originalGroupIds.isEmpty()) {
            return;
        }

        List<SBQQ__QuoteLineGroup__c> clonedGroups = collectOriginalGroupIdsFromFoundGroups(
            originalGroupIds,
            newQuoteIds,
            newQuotesMap
        );
        populateMissingGroupOnQuoteLines(
            clonedGroups,
            prevLineIdOrSubIdToPrevQuoteLineMap,
            groupedLinesMap
        );
    }

    /**
     * @description prevents clonning of any group which is already cloned
     * @return List<SBQQ__QuoteLineGroup__c>
     * @param originalGroupIds
     * @param newQuoteIds
     * @param fetchedQuotesMap
     */
    private List<SBQQ__QuoteLineGroup__c> collectOriginalGroupIdsFromFoundGroups(
        Set<Id> originalGroupIds,
        Set<Id> newQuoteIds,
        Map<id, SBQQ__Quote__c> fetchedQuotesMap
    ) {
        if (fetchedQuotesMap.isEmpty()) {
            return null;
        }
        Set<Id> removeOriginalIds = new Set<Id>();
        Map<Id, SBQQ__QuoteLineGroup__c> foundGroups = new Map<Id, SBQQ__QuoteLineGroup__c>(
            QuoteLineGroupSelector.newInstance().selectGroupRecordsFromQuote(newQuoteIds)
        );
        for (Id origGpId : originalGroupIds) {
            for (SBQQ__QuoteLineGroup__c foundGrp : foundGroups.values()) {
                if (origGpId == foundGrp.SBQQ__Source__c) {
                    removeOriginalIds.add(origGpId);
                }
            }
        }
        originalGroupIds.removeAll(removeOriginalIds);
        return getClonedGroupsFromSourceQuote(originalGroupIds, fetchedQuotesMap);
    }

    /**
     * @description populate Quote Line group on amemdment quote lines on the amendent quote.
     * @return List<SBQQ__QuoteLineGroup__c>
     * @param originalGroupIds
     * @param fetchedQuotesMap
     */
    private List<SBQQ__QuoteLineGroup__c> getClonedGroupsFromSourceQuote(
        Set<Id> originalGroupIds,
        Map<id, SBQQ__Quote__c> fetchedQuotesMap
    ) {
        if (originalGroupIds.isEmpty()) {
            return null;
        }
        List<SBQQ__QuoteLineGroup__c> clonedGroups = new List<SBQQ__QuoteLineGroup__c>();
        List<SBQQ__Quote__c> quoteUpdateList = new List<SBQQ__Quote__c>();
        fflib_ISObjectUnitOfWork uowQuoteAndQuoteGroups = Application.UNITOFWORK.newInstance();
        String uniqueGroupIndicator;
        Map<String, Schema.SObjectField> qlgFields = Schema.getGlobalDescribe()
            .get('SBQQ__QuoteLineGroup__c')
            .getDescribe()
            .fields.getMap();

        Map<Id, SBQQ__QuoteLineGroup__c> originalGroups = QuoteLineGroupSelector.newInstance()
            .selectGroupRecords(originalGroupIds);

        for (SBQQ__Quote__c quote : fetchedQuotesMap.values()) {
            if (!quote.SBQQ__LineItemsGrouped__c) {
                SBQQ__Quote__c quoteToUpdate = new SBQQ__Quote__c(
                    Id = quote.id,
                    SBQQ__LineItemsGrouped__c = true,
                    Has_Groups__c = true
                );
                quoteUpdateList.add(quoteToUpdate);
            }
            for (SBQQ__QuoteLineGroup__c oldGrp : originalGroups.values()) {
                if (String.isBlank(oldGrp.CCP_Unique_Group_Id__c)) {
                    uniqueGroupIndicator = Id.valueOf(oldGrp.id);
                } else {
                    uniqueGroupIndicator = oldGrp.CCP_Unique_Group_Id__c;
                }
                SBQQ__QuoteLineGroup__c newGrp = new SBQQ__QuoteLineGroup__c(
                    SBQQ__Quote__c = quote.id,
                    SBQQ__Source__c = oldGrp.id,
                    Original_Quote_Line_Group__c = oldGrp.id,
                    CCP_Unique_Group_Id__c = uniqueGroupIndicator
                );

                clonedGroups.add(populateNewGroupFromOldGroup(newGrp, oldGrp, qlgFields));
            }
        }

        uowQuoteAndQuoteGroups.registerDirty(quoteUpdateList);
        if (clonedGroups.size() > 0) {
            uowQuoteAndQuoteGroups.registerNew(clonedGroups);
        }
        commitUnitOfWork(uowQuoteAndQuoteGroups);
        return clonedGroups;
    }

    /**
     * @description clone group from original group
     * @return SBQQ__QuoteLineGroup__c
     * @param newGrp
     * @param oldGrp
     * @param groupFields
     */
    private SBQQ__QuoteLineGroup__c populateNewGroupFromOldGroup(
        SBQQ__QuoteLineGroup__c newGrp,
        SBQQ__QuoteLineGroup__c oldGrp,
        Map<String, Schema.SObjectField> groupFields
    ) {
        for (String fieldName : groupFields.keySet()) {
            Schema.DescribeFieldResult field = groupFields.get(fieldName).getDescribe();
            if (
                field.isUpdateable() &&
                !NON_COPY_FIELDS.contains(fieldName) &&
                oldGrp.get(fieldName) != null
            ) {
                newGrp.put(fieldName, oldGrp.get(fieldName));
            }
        }
        return newGrp;
    }
    /**
     * @description commit Quote line Group on missing Quote Lines
     * @param clonedGroups
     * @param prevLineIdOrSubIdToPrevQuoteLineMap
     * @param groupedLinesMap
     */
    private void populateMissingGroupOnQuoteLines(
        List<SBQQ__QuoteLineGroup__c> clonedGroups,
        Map<Id, SBQQ__QuoteLine__c> prevLineIdOrSubIdToPrevQuoteLineMap,
        Map<Id, SBQQ__QuoteLine__c> groupedLinesMap
    ) {
        if (clonedGroups == null || prevLineIdOrSubIdToPrevQuoteLineMap.isEmpty()) {
            return;
        }

        Id originalGroupId;
        Map<Id, SBQQ__QuoteLineGroup__c> newGroupIdByOldGroupIdMap = new Map<Id, SBQQ__QuoteLineGroup__c>();
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (SBQQ__QuoteLineGroup__c g : clonedGroups) {
            newGroupIdByOldGroupIdMap.put(g.SBQQ__Source__c, g);
        }
        for (SBQQ__QuoteLine__c ql : groupedLinesMap.Values()) {
            //checks for new ql on prev quote
            if (
                prevLineIdOrSubIdToPrevQuoteLineMap.containsKey(
                    ql.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c
                )
            ) {
                originalGroupId = prevLineIdOrSubIdToPrevQuoteLineMap.get(
                        ql.SBQQ__UpgradedSubscription__r.SBQQ__QuoteLine__c
                    )
                    .SBQQ__Group__c;
            } else {
                originalGroupId = prevLineIdOrSubIdToPrevQuoteLineMap.get(
                        ql.SBQQ__UpgradedSubscription__c
                    )
                    .SBQQ__Group__c;
            }
            if (originalGroupId != null) {
                uow.registerDirty(
                    ql,
                    SBQQ__QuoteLine__c.SBQQ__Group__c,
                    newGroupIdByOldGroupIdMap.get(originalGroupId)
                );
            }
        }
        commitUnitOfWork(uow);
    }

    /**
     * @description LEM-9452: Syncs updated fields back to the brief item
     * @param quoteLineItems
     */
    public void updateBriefItemsQuoteLineSyncFields(List<SBQQ__QuoteLine__c> quoteLineItems) {
        Map<Id, SBQQ__QuoteLine__c> quoteLineIdToQuoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>(
            quoteLineItems
        );
        fflib_ISObjectUnitOfWork uOfWork = Application.UNITOFWORK.newInstance();
        List<Quote_Line_to_Brief_Item_Mapping__mdt> quoteLineToBriefItemFieldMapping = QuoteLineBriefItemMappingSelector.newInstance()
            .getAllValues();
        Set<Id> briefItemIds = new Set<Id>();
        Map<Id, SBQQ__QuoteLine__c> briefItemIdToQuoteLine = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c quoteline : quoteLineItems) {
            briefItemIds.add(quoteline.Brief_Item__c);
            briefItemIdToQuoteLine.put(quoteline.Brief_Item__c, quoteline);
        }
        for (
            Brief_Item__c eachBriefItem : BriefItemsSelector.newInstance().selectByIds(briefItemIds)
        ) {
            SBQQ__QuoteLine__c lineItem = briefItemIdToQuoteLine.get(eachBriefItem.Id);
            for (Quote_Line_to_Brief_Item_Mapping__mdt mapping : quoteLineToBriefItemFieldMapping) {
                if (
                    mapping.BriefItemFieldAPIName__c != null &&
                    mapping.QuoteLineFieldAPIName__c != null
                ) {
                    eachBriefItem.put(
                        mapping.BriefItemFieldAPIName__c,
                        (quoteLineIdToQuoteLinesMap.get(lineItem.Id))
                            .get(mapping.QuoteLineFieldAPIName__c)
                    );
                }
            }
            uOfWork.registerDirty(eachBriefItem);
        }
        commitUnitOfWork(uOfWork);
    }
    /**
     * @description updates quotelines from amendments to have Has brief item field updated
     * @param quoteLineItems
     */
    public void updateAmendmentQuoteLines(LIst<SBQQ__QuoteLine__c> quoteLineItems) {
        for (SBQQ__QuoteLine__c line : quoteLineItems) {
            if (line.Brief_Item__c != null && line.Has_Brief_Item__c == false) {
                line.Has_Brief_Item__c = true;
            }
        }
    }
    /**
     * @description LEM-10562 It is used to updated the active price fields on quotelines on submit for approval
     * @param newQuotelines
     */
    public void updateActiveFeeActiveComissionOnQuotelines(List<SBQQ__QuoteLine__c> newQuotelines) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (SBQQ__QuoteLine__c quoteline : newQuotelines) {
            if (quoteline.SBQQ__ProductOption__r.Active_Rate_Eligible__c == true) {
                if (
                    quoteline.Active_Commission__c != quoteline.Requested_Commission__c &&
                    checkARPConditions(
                        quoteline.SBQQ__Quote__r.SBQQ__Type__c,
                        quoteline.Type__c,
                        quoteline.Rate_Change__c,
                        RATE_CHANGE_COMMISSION
                    )
                ) {
                    quoteline.Active_Commission__c = quoteline.Requested_Commission__c;
                    uow.registerDirty(quoteline);
                }
                if (
                    quoteline.Active_Fee__c != quoteline.SBQQ__SpecialPrice__c &&
                    checkARPConditions(
                        quoteline.SBQQ__Quote__r.SBQQ__Type__c,
                        quoteline.Type__c,
                        quoteline.Rate_Change__c,
                        RATE_CHANGE_FEE
                    )
                ) {
                    quoteline.Active_Fee__c = quoteline.SBQQ__SpecialPrice__c;
                    uow.registerDirty(quoteline);
                }
            }
        }
        commitUnitOfWork(uow);
    }

    /**
     * @description private method to check if active price should be updated or not
     * @param quoteType
     * @param quoteLineType
     * @param quoteLineRateChange
     * @param rateChangeIndicator
     * @return Boolean
     */
    private Boolean checkARPConditions(
        String quoteType,
        String quoteLineType,
        String quoteLineRateChange,
        String rateChangeIndicator
    ) {
        if (
            quoteType == QUOTE_TYPE ||
            quoteLineType == QUOTE_LINE_TYPE_NEW ||
            quoteLineRateChange.contains(rateChangeIndicator)
        ) {
            return true;
        }
        return false;
    }

    /**
     * @description LEM-10562 It is used to revert the active price fields on quotelines on when quote is moved back to draft status
     * @param newQuotelines
     */
    public void revertActiveFeeActiveComissionOnQuotelines(List<SBQQ__QuoteLine__c> newQuotelines) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Decimal activeFee;
        Decimal activeCommission;
        for (SBQQ__QuoteLine__c quoteline : newQuotelines) {
            if (quoteline.SBQQ__ProductOption__r.Active_Rate_Eligible__c == true) {
                if (
                    quoteline.SBQQ__Quote__r.SBQQ__Type__c == QUOTE_TYPE ||
                    quoteline.Type__c == QUOTE_LINE_TYPE_NEW
                ) {
                    activeCommission = null;
                    activeFee = null;
                } else if (
                    quoteline.Type__c == QUOTE_LINE_TYPE_AMENDED &&
                    quoteline.SBQQ__Source__c != null
                ) {
                    activeCommission = quoteline.SBQQ__Source__r.Active_Commission__c;
                    activeFee = quoteline.SBQQ__Source__r.Active_Fee__c;
                } else {
                    //No need to check for Deleted and Existing Quote lines as we are not updating active rates on those.
                    activeCommission = quoteline.Active_Commission__c;
                    activeFee = quoteline.Active_Fee__c;
                }
                if (quoteline.Active_Fee__c != activeFee) {
                    quoteline.Active_Fee__c = activeFee;
                    uow.registerDirty(quoteline);
                }
                if (quoteline.Active_Commission__c != activeCommission) {
                    quoteline.Active_Commission__c = activeCommission;
                    uow.registerDirty(quoteline);
                }
            }
        }
        commitUnitOfWork(uow);
    }

    /**
     * @description LEM-13065 Calls a method from QuoteLineItemsServiceUtility to delete Brief Items before delete an associated Quote Line.
     * The method implementation is written in QuoteLineItemsServiceUtility which is a without sharing class.
     * @param existingQuoteLines
     */
    public void deleteBriefItemBeforeQuoteLineIsDeleted(List<SBQQ__QuoteLine__c> existingQuoteLines){

        QuoteLineItemsServiceUtility.deleteBriefItemBeforeQuoteLineIsDeletedImpl(existingQuoteLines);

    }
    /**
     * @description - Update Prior Fields on Quote Lines when Approval is Approved.
     * @JIRA# LEM-22670
     * @param quoteLines
     */
    @InvocableMethod(label='Update Prior Fields on Quote Lines')
    public static void updatePriorFieldsOnQuoteLines(
        List<List<SBQQ__QuoteLine__c>> quoteLines
    ) {
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        for (List<SBQQ__QuoteLine__c> quoteLinesRecord : quoteLines) {
        quoteLinesToUpdate.addAll(quoteLinesRecord);
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        uow.registerDirty(quoteLinesToUpdate);
        SBQQ.TriggerControl.disable();
        uow.commitWork();
        SBQQ.TriggerControl.enable();
    }
}