/**
 * @description SBQQ__Quote__c Object Trigger Handler
 * @author ATG
 * @date 2022-04-06
 */
public class QuotesHandler extends ApplicationDomainHandler {
    public static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String AMENDMENT = 'Amendment';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String QUOTE_STATUS_APPROVED = 'Approved';
    public static final String OPPORTUNITY_TYPE = 'Existing';
    /**
     * @description Constructor Method
     * @param sObjectList - Quotes Record List
     */
    public QuotesHandler(List<SBQQ__Quote__c> sObjectList) {
        super(sObjectList);
        setContextBypass(SBQQ__Quote__c.SObjectType, QuotesHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return AccountHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new QuotesHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        Quotes.newInstance(quotesWithExistingOpportunityType())
            .VerifyAlcoholEligibilityForExistingOpportunity();
    }

    /**
     * @description Retrieve quotes where opportunity type is Existing.
     * @return List<SBQQ__Quote__c>
     */
    private List<SBQQ__Quote__c> quotesWithExistingOpportunityType() {
        List<SBQQ__Quote__c> quoteData = new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.Opportunity_Type__c,
                OPPORTUNITY_TYPE
            )
        );
        return quoteData;
    }
    /**
     * @description Called to perform after insert processing
     */
    public override void onafterInsert() {
        Quotes.newInstance(amendmentQuotes())
            .updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes();
        Quotes.newInstance(this.records).initiateRedliningApproversCreationByManagerId();
    }

    /**
     * @description Called to perform before update processing
     * @param existingRecords - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        Quotes.newInstance(this.records).validateIfUniqueTermFieldsWereUpdated();
        Quotes.newInstance(quoteWithUpdatesLineItems()).populateAssignedGroupsNameOnQuotes();
        Quotes.newInstance(quotesWithUpdatedStatus()).setSignedContractLinkAndDate();
        Quotes.newInstance(quotesWithUpdatedStatus())
            .updateQuoteOutForSignatureDate(existingRecords);
        Quotes.newInstance(quotesWithUpdatedStoreAccountOrStatus())
            .populateRESSMOEligibleOnQuoteStatusIsApproved();
        Quotes.newInstance(quotesWithUpdatedStoreSpecificVariations())
            .updateContractingFlowForStoreSpecificVariations();
        Quotes.newInstance(quotesWithUpdateIroncladWorkflow()).blankUniqueIdentifier();

    }

    /**
     * @description Called to perform after update processing
     * @param existing - The map of old Quotes
     */
    public override void onAfterUpdate(Map<Id, SObject> existing) {
        Quotes.newInstance(quotesWithUpdatedStatus()).generateOrders();
        Quotes.newInstance(quotesWithUpdatedSumOfBudget()).populateDoorDashSignerOnQuote();
        Quotes.newInstance(quotesWithUpdatedStatus()).updateContractSignatoryExists();
        Quotes.newInstance(quotesWithUpdatedStatus()).syncPaymentTermsWithPaymentAccount();
        Quotes.newInstance(quotesWithUpdatedStatus()).initiateBriefsWithItemsGeneration();
        Quotes.newInstance(quotesWithUpdatedStatus()).updateOpportunityStageByQuoteStatus(existing);
        Quotes.newInstance(quotesWithUpdatedSelfServeStatus()).validateQuoteLineDrawerField();
        Quotes.newInstance(quotesWithUpdatedStatus()).validateQuoteLineDrawerField();
        Quotes.newInstance(quotesWithUpdatedTotalInvestment()).updateOpportunityInvestment();
        Quotes.newInstance(quotesWithUpdatedStatus()).updateActiveFeeActiveComissionOnQuotelines();
        Quotes.newInstance(quotesWithUpdatedStatus()).revertActiveFeeActiveComissionOnQuotelines();
        populateQuotesWithoutGroups();
        //Calling Accounts Service to update Partnership Level and Partnership expiration date on account.
        AccountsService.populatePartnershipLevelOnAccount(
            getQuotesWithChangedStatusAsContractSigned()
        );
        Quotes.newInstance(quotesWithContractingFlowUpdatedAsRedlining())
            .initiateRedliningApproversCreationByManagerId();
    }

    /**
    * @description - retunr quotes with change in Ironclad worflow field update
    * @author Soumya Dash | 10-30-2024
    * @return List<SBQQ__Quote__c>
    **/
    private List<SBQQ__Quote__c> quotesWithUpdateIroncladWorkflow(){
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>)getChangedRecords(new Set<sObjectField>{SBQQ__Quote__c.Ironclad_WF_Launched__c})
        );
    }

    /**
     * @description Retrieve quotes where the count of related quote lines is changed.
     * @return List<SBQQ__Quote__c>
     */
    private List<SBQQ__Quote__c> quoteWithUpdatesLineItems() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.SBQQ__LineItemCount__c }
            )
        );
    }

    /**
     * @description retrieve quotes where the Status has changed.
     * @return List<SBQQ__Quote__c> list of quotes that have a changed status
     */
    private List<SBQQ__Quote__c> quotesWithUpdatedSelfServeStatus() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.Self_Serve_Status__c }
            )
        );
    }

    /**
     * @description retrieve quotes where the Status has changed.
     * @return List<SBQQ__Quote__c> list of quotes that have a changed status
     */
    private List<SBQQ__Quote__c> quotesWithUpdatedStatus() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.SBQQ__Status__c }
            )
        );
    }
    /**
     * @description retrieve quotes where the Ads_Promos_Budget_Sum__cStatus has changed.
     * @return List<SBQQ__Quote__c> list of quotes that have a changed Ads_Promos_Budget_Sum__c
     */
    private List<SBQQ__Quote__c> quotesWithUpdatedSumOfBudget() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.Ads_Promos_Budget_Sum__c }
            )
        );
    }

    /**
     * @description This method is used to fetch all Quotes where Estimated Total Investment has
     * been updated.
     * @return List<SBQQ__Quote__c>
     */
    private List<SBQQ__Quote__c> quotesWithUpdatedTotalInvestment() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.Estimated_Total_Investment__c }
            )
        );
    }
    /**
     * @description This method is used to fetch all Amended Quotes
     * @return List<SBQQ__Quote__c>
     */
    private List<SBQQ__Quote__c> amendmentQuotes() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getRecordsByFieldValue(SBQQ__Quote__c.SBQQ__Type__c, AMENDMENT)
        );
    }

    /**
     * @description This method is used to fetch all Amended Quotes with Draft Status and
     * no Groups
     */
    private void populateQuotesWithoutGroups() {
        Map<Id, SBQQ__Quote__c> quoteWithoutGroups = new Map<Id, SBQQ__Quote__c>();
        for (
            SBQQ__Quote__c sbQuote : (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.SBQQ__Type__c,
                AMENDMENT
            )
        ) {
            if (sbQuote.Has_Groups__c == false && sbQuote.SBQQ__Status__c == STATUS_DRAFT) {
                quoteWithoutGroups.put(sbQuote.Id, sbQuote);
            }
        }
        QuoteLineItemsService.insertMissingAmendmentLineGroups(quoteWithoutGroups);
    }

    /**
     * @description It is used to fetch all changed quotes with Contract Signed status.
     * @return Map<Id, SBQQ__Quote__c>
     */
    private Map<Id, SBQQ__Quote__c> getQuotesWithChangedStatusAsContractSigned() {
        List<SBQQ__Quote__c> quotesWithChangedStatus = new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.SBQQ__Status__c }
            )
        );
        Map<Id, SBQQ__Quote__c> mapIdToQuote = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__Quote__c eachQuote : quotesWithChangedStatus) {
            if (eachQuote.SBQQ__Status__c == CONTRACT_SIGNED) {
                mapIdToQuote.put(eachQuote.Id, eachQuote);
            }
        }
        return mapIdToQuote;
    }
    /**
     * @description This method is used to fetch all Quotes where Store_Specific_Variations__c field is 'Yes'
     * and update the Contracting_Flow__c field to 'Redlining'.
     * @return A list of SBQQ__Quote__c records where Store_Specific_Variations__c is 'Yes'.
     */
    private List<SBQQ__Quote__c> quotesWithUpdatedStoreSpecificVariations() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.Store_Specific_Variations__c }
            )
        );
    }
    /**
     * @description retrieve quotes where the RESSMO_Store_Account_Id__c has changed.
     * @return List<SBQQ__Quote__c> list of quotes that have a changed status
     */
    private List<SBQQ__Quote__c> quotesWithUpdatedStoreAccountOrStatus() {
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.RESSMO_Store_Account_Id__c }
            )
        );
        quotes.addAll(quotesWithUpdatedStatus());
        return quotes;
    }

    /**
     * @description It is used to fetch all Quotes where Contracting_Flow__c field is updated.
     * @return List<SBQQ__Quote__c>
     */
    private List<SBQQ__Quote__c> quotesWithContractingFlowUpdatedAsRedlining() {
        return new List<SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getChangedRecords(
                new Set<SObjectField>{ SBQQ__Quote__c.Contracting_Flow__c }
            )
        );
    }
}