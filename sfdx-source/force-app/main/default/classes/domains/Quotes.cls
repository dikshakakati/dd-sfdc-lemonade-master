/**
 * @author ATG
 * @date 2022-04-07
 * @description Domain Class for SBQQ__Quote__c Object
 */
@SuppressWarnings(
    'PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength, PMD.ExcessivePublicCount'
)
public inherited sharing class Quotes extends fflib_SObjects implements IQuotes {
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    static final String SUB_TYPE = 'Ads & Promos';
    static final String DEAL_TYPE = 'Self-Serve';
    private final static string APPLICABLE_SEGMENT_VALUE_ALL = 'All';
    public static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String HYPHEN_DELIMITER = ' - ';
    public static final String IN_REVIEW = 'In Review';
    private static final String LOG_SERVICE = 'Quote Changes';
    private static final String LOG_DOMAIN = 'CPQ';
    public static final String OPPORTUNITY_STAGE_CONTRACTING = 'Contracting';
    public static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    public static final String OPPORTUNITY_STAGE_NEGOTIATING = 'Negotiating';
    public static final String QUOTE_STATUS_OUT_FOR_SIGNATURE = 'Out for Signature';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SPONSORED_PRODUCTS = 'Sponsored Products';
    public static final String STATUS_APPROVED = 'Approved';
    public static final String ADS_PROMOS_YES_VALUE = 'Yes';
    public static final String CONTRACT_SPLIT_CATEGORY_ADS_PROMOS = 'A&P';
    public static final String REDLINING = 'Redlining';
    public static final String AMENDMENT = 'Amendment';
    public static final String QUOTE = 'Quote';
    private static final String SOURCE_RESSMO = 'RESSMO';
    private static final boolean ELIGIBLE_FOR_ALCOHOL = true;
    private static final String ANZ_FIELDSET = 'Unique_Terms';
    private static final String US_COUNTRYCODE = 'US';
    private static final String CA_COUNTRYCODE = 'CA';
    private static final String OBJECT_APINAME = 'SBQQ__Quote__c';
    private static final String FIELD_TYPE = 'Boolean';
    private static final String ANZ_VALIDATION_MESSAGE = 'The following field is applicable only for US/Canada: ';
    private final static string ACCOUNT_SEGMENT_MIDMARKET = 'Mid-Market';
    private final static string ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';

    private static final Set<String> SPONSORED_PRODUCTS_PACKAGE = new Set<String>{
        'CnG Search',
        'CnG DoubleDash',
        'CnG Collections',
        'CnG Categories'
    };
    public static final String STATUS_DRAFT = 'Draft';
    private static final Set<String> VALID_FOR_BRIEF_ITEMS_OFFSITE_PLATFORM_VALUES = new Set<String>{
        'Video',
        'Display'
    };

    public static final String STATUS_OUT_FOR_SIGNATURE = 'Out for Signature';
    private enum QUOTESTATUSES {
        QUOTE_STATUS_OUT_FOR_SIGNATURE,
        QUOTE_STATUS_CONTRACT_SIGNED,
        QUOTE_STATUS_DRAFT
    }
    private static final Map<String, QUOTESTATUSES> QUOTETOOPPORTUNITYSTATUSMAPPING = new Map<String, QUOTESTATUSES>{
        QUOTE_STATUS_OUT_FOR_SIGNATURE => QUOTESTATUSES.QUOTE_STATUS_OUT_FOR_SIGNATURE,
        CONTRACT_SIGNED => QUOTESTATUSES.QUOTE_STATUS_CONTRACT_SIGNED,
        STATUS_DRAFT => QUOTESTATUSES.QUOTE_STATUS_DRAFT
    };
    private static final Set<String> CORE_PACKAGES = new Set<String>{
        'Basic Package',
        'Plus Package',
        'Premier Package',
        'Self-Delivery'
    };
    private static final Set<String> NON_APPLICABLE_QUOTE_SOURCES_FOR_MAGIC_WAND = new Set<String>{
        'SSMO',
        'SSOB',
        'Mx Portal'
    };
    private static final Set<String> NON_APPLICABLE_QUOTE_INTEGRATION_SOURCES_FOR_MAGIC_WAND = new Set<String>{
        'RESSMO'
    };
    private static final String SEMICOLON_DELIMITER = '; ';
    @TestVisible
    private static final Integer MAX_BUDGET_FOR_SALES_REP_SIGNATURE = 100000;
    @TestVisible
    private static final Integer MAX_BUDGET_FOR_SALES_REP_MANAGER_SIGNATURE = 1000000;
    @TestVisible
    private static final String SPONSORSHIPS = 'Sponsorships';
    /**
     * This variable is made so that we do not have to hardcode the Deal Type value of an opportunity
     */
    static final String SELF_SERVE_DEAL_TYPE = 'Self-Serve';
    /**
     * This variable is made so that we do not have to hardcode the Status value of a quote
     */
    static final String SELF_SERVE_ACTIVATED = 'Activated';
    /**
     * @description This method is used to return the IOrders interface
     * @param recordList - Orders record list
     * @return IQuotes - Returns IQuotes Interface
     */
    public static IQuotes newInstance(List<SBQQ__Quote__c> recordList) {
        return (IQuotes) Application.Domain.newInstance(recordList);
    }
    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public Quotes(List<SBQQ__Quote__c> sObjectList) {
        super(sObjectList, Schema.SBQQ__Quote__c.SObjectType);
    }
    /**
     * @description set SBQQ__Ordered__c checkbox to true.
     */
    public void generateOrders() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.SBQQ__Status__c,
                CONTRACT_SIGNED
            )
        );
        for (SBQQ__Quote__c quote : quoteMap.values()) {
            Boolean dirtyRecord = false;
            SBQQ__Quote__c newQuote = new SBQQ__Quote__c(Id = quote.Id);
            if (!quote.hasPipelineProduct__c) {
                if (
                    quote.SBQQ__Ordered__c == false
                ) {
                    newQuote.SBQQ__Ordered__c = true;
                    dirtyRecord = true;
                }
            }
            if (dirtyRecord) {
                uow.registerDirty(newQuote);
            }
        }
        commitWork(uow);
    }
    /**
     *@description - moved the contract signed date and signed contract link updates to the before update context as part LEM-5411 ticket
     *   LEM-2768 additions: Populate the Signed_Contract_link__c with the newly-added document when a quote moves to 'Contract Signed'. Also sets Contract_Signed_Date__c with the current date.

     */
    public void setSignedContractLinkAndDate() {
        Date todaysDate = date.today(); // in case we're doing bulk work at 11:59:59
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.SBQQ__Status__c,
                CONTRACT_SIGNED
            )
        );
        List<ContentDocumentLink> contentDocumentList = quoteMap.size() > 0
            ? ContentDocumentLinkSelector.newInstance()
                  .selectCompletedTitlesByLinkedEntity(quoteMap.keySet())
            : new List<ContentDocumentLink>();
        for (SBQQ__Quote__c quote : quoteMap.values()) {
            for (ContentDocumentLink currentLink : contentDocumentList) {
                if (currentLink.LinkedEntityId == quote.Id) {
                    quote.Signed_Contract_link__c =
                        URL.getSalesforceBaseUrl().toExternalForm() +
                        '/lightning/r/ContentDocument/' +
                        currentLink.ContentDocumentId +
                        '/view';
                    quote.Contract_Signed_Date__c = todaysDate;
                    break;
                }
            }
        }
    }
    /**
     * @description Populate DoorDash_Signer__c on Quote based on the Ads&Promos Budget Sum
     */
    public void populateDoorDashSignerOnQuote() {
        Set<Id> salesRepIds = getSalesRepIds();
        Map<Id, User> userMap = new Map<Id, User>(
            UsersSelector.newInstance()
                .selectUserIdsByEmailAddressAndIds(
                    system.label.Docusign_Budget_Director,
                    salesRepIds
                )
        );
        Id budgetUserId = getDocuSignDirectorId(userMap);
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) getRecords()) {
            if (isSalesRepDoordashSigner(quote)) {
                SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
                    Id = quote.Id,
                    DoorDash_Signer__c = quote.SBQQ__SalesRep__c
                );
                uow.registerDirty(newQuote);
            } else if (isSalesRepManagerDoordashSigner(quote, userMap)) {
                SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
                    Id = quote.Id,
                    DoorDash_Signer__c = userMap.get(quote.SBQQ__SalesRep__c).ManagerId
                );
                uow.registerDirty(newQuote);
            } else if (isDocuSignDirectorDoordashSigner(quote, budgetUserId)) {
                SBQQ__Quote__c newQuote = new SBQQ__Quote__c(
                    Id = quote.Id,
                    DoorDash_Signer__c = budgetUserId
                );
                uow.registerDirty(newQuote);
            }
        }
        commitWork(uow);
    }
    private Set<Id> getSalesRepIds() {
        Set<Object> salesReps = getFieldValues(SBQQ__Quote__c.SBQQ__SalesRep__c);
        return (Set<Id>) JSON.deserialize(JSON.serialize(salesReps), Set<Id>.class);
    }
    private Id getDocuSignDirectorId(Map<Id, User> userMap) {
        Id budgetUserId = null;
        for (User u : userMap.values()) {
            if (u.UserName.containsIgnoreCase(system.label.Docusign_Budget_Director)) {
                budgetUserId = u.Id;
                break;
            }
        }
        return budgetUserId;
    }
    private boolean isSalesRepDoordashSigner(SBQQ__Quote__c quote) {
        return quote.Ads_Promos_Budget_Sum__c < MAX_BUDGET_FOR_SALES_REP_SIGNATURE &&
            quote.DoorDash_Signer__c != quote.SBQQ__SalesRep__c;
    }
    private boolean isSalesRepManagerDoordashSigner(SBQQ__Quote__c quote, Map<Id, User> userMap) {
        return quote.Ads_Promos_Budget_Sum__c >= MAX_BUDGET_FOR_SALES_REP_SIGNATURE &&
            quote.Ads_Promos_Budget_Sum__c < MAX_BUDGET_FOR_SALES_REP_MANAGER_SIGNATURE &&
            userMap.containsKey(quote.SBQQ__SalesRep__c) &&
            quote.DoorDash_Signer__c != userMap.get(quote.SBQQ__SalesRep__c).ManagerId;
    }
    private boolean isDocuSignDirectorDoordashSigner(SBQQ__Quote__c quote, Id budgetUserId) {
        return quote.Ads_Promos_Budget_Sum__c >= MAX_BUDGET_FOR_SALES_REP_MANAGER_SIGNATURE &&
            quote.DoorDash_Signer__c != budgetUserId;
    }
    /**
     * @description updates the contract signatory exists flag
     */
    public void updateContractSignatoryExists() {
        Set<Id> quotesToUpdate = new Set<Id>();
        for (
            SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.SBQQ__Status__c,
                STATUS_APPROVED
            )
        ) {
            quotesToUpdate.add(quote.Id);
        }
        if (quotesToUpdate.isEmpty()) {
            return;
        }
        OpportunityContactRoleService.updateContractSignatoryExists(quotesToUpdate);
    }
    /**
     * @description Sync payment terms from quote to payment account.
     */
    public void syncPaymentTermsWithPaymentAccount() {
        Map<Id, SBQQ__Quote__c> invoicingPaymentAccountIdsToQuotesMap = new Map<Id, SBQQ__Quote__c>();
        for (
            SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.SBQQ__Status__c,
                CONTRACT_SIGNED
            )
        ) {
            if (quote.Invoicing_Payment_Account__c != null) {
                invoicingPaymentAccountIdsToQuotesMap.put(
                    quote.Invoicing_Payment_Account__c,
                    quote
                );
            }
        }
        if (invoicingPaymentAccountIdsToQuotesMap.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (
            Account_Payment_Account_Relation__c accountPaymentAccount : AccountPaymentAccountRelationsSelector.newInstance()
                .selectById(invoicingPaymentAccountIdsToQuotesMap.keySet())
        ) {
            if (invoicingPaymentAccountIdsToQuotesMap.containsKey(accountPaymentAccount.Id)) {
                SBQQ__Quote__c quote = invoicingPaymentAccountIdsToQuotesMap.get(
                    accountPaymentAccount.Id
                );

                if (accountPaymentAccount.Payment_Terms__c != quote.SBQQ__PaymentTerms__c) {
                    uow.registerDirty(
                        new Payment_Account__c(
                            Id = accountPaymentAccount.Payment_Account__c,
                            Payment_Terms__c = quote.SBQQ__PaymentTerms__c
                        )
                    );
                }
            }
        }
        commitWork(uow);
    }
    /**
     * @description It is used to fetch the Ids of the Accounts related to the Quotes.
     * @param quotes
     * @return Set<Id>
     */
    private Set<Id> getAccountIds(List<SBQQ__Quote__c> quotes) {
        Set<Id> accountIds = new Set<Id>();
        for (SBQQ__Quote__c eachQuote : quotes) {
            accountIds.add(eachQuote.SBQQ__Account__c);
        }
        return accountIds;
    }
    /**
     * @description It is used the check whether Quotes with status Contract Signed are valid to create related Brief and Brief Items.
     */
    public void initiateBriefsWithItemsGeneration() {
        List<SBQQ__Quote__c> allQuotesWithRelatedQuoteLinesAndQbrs = QuotesSelector.newInstance()
            .selectQuotesWithQuoteLineAndQuoteBriefRelationships(getRecordIds());
        List<Brief__c> allExistingBriefsAssociatedWithAccountOnQuote = BriefsSelector.newInstance()
            .selectByAccountIds(
                getAccountIds(
                    (List<SBQQ__Quote__c>) getRecordsByFieldValues(
                        SBQQ__Quote__c.SBQQ__Status__c,
                        new Set<Object>{ IN_REVIEW, STATUS_APPROVED, CONTRACT_SIGNED }
                    )
                )
            );
        if (allQuotesWithRelatedQuoteLinesAndQbrs.isEmpty()) {
            return;
        }
        generateBriefsAndBriefItemsByQuoteLineItemsAndQuoteBriefRelationships(
            allQuotesWithRelatedQuoteLinesAndQbrs,
            allExistingBriefsAssociatedWithAccountOnQuote
        );
    }
    /**
     * @description It is used to generate Briefs and Brief Items after processing and filtering quote line items.
     * @param quotes
     * @param briefs
     */
    @SuppressWarnings('PMD.NcssMethodCount')
    private void generateBriefsAndBriefItemsByQuoteLineItemsAndQuoteBriefRelationships(
        List<SBQQ__Quote__c> quotes,
        List<Brief__c> briefs
    ) {
        String campaignIdentifierKey = '';
        String campaignName = '';
        List<Quote_Brief_Relationship__c> quoteBriefRelationships = new List<Quote_Brief_Relationship__c>();
        List<SBQQ__QuoteLine__c> quoteLineItemsWithBrief = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLineItemsWithBriefItem = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> quoteLinesWithoutBriefAndBriefItem = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> mapBriefItemIdToQuoteline = new Map<Id, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> mapBriefIdToQuoteLine = new Map<Id, SBQQ__Quoteline__c>();
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> quoteLineIds = new Set<Id>();
        Map<Id, SBQQ__QuoteLine__c> briefIdToQuoteLine = new Map<Id, SBQQ__QuoteLine__c>();

        for (SBQQ__Quote__c eachQuote : quotes) {
            quoteBriefRelationships.addAll(eachQuote.Quote_Brief_Relationships__r);
            quoteIds.add(eachQuote.Id);
        }
        for (Brief__c eachBrief : briefs) {
            quoteBriefRelationships.addAll(eachBrief.Quote_Brief_Relationships__r);
        }
        Map<String, Quote_Brief_Relationship__c> campaignQuoteToQuoteBriefRelationship = BriefItemsService.getCampaignQuoteRelationshipMappings(
            quoteBriefRelationships
        );
        for (
            SBQQ__QuoteLine__c eachQuoteLineItem : QuoteLineItemsSelector.newInstance()
                .selectQuoteLinesWithUpgradedSubscriptions(quoteIds)
                .values()
        ) {
            if (eachQuoteLineItem.SBQQ__Quote__r.Segment__c == SEGMENT_SMB) {
                continue;
            }
            campaignName = (SPONSORED_PRODUCTS_PACKAGE.contains(
                    eachQuoteLineItem.SBQQ__ProductName__c
                ) || eachQuoteLineItem.Package__c == SPONSORSHIPS)
                ? eachQuoteLineItem.SBQQ__RequiredBy__r.Campaign_Name__c
                : eachQuoteLineItem.Campaign_Name__c;
            campaignIdentifierKey =
                campaignName +
                HYPHEN_DELIMITER +
                eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Account__c;
            if (campaignQuoteToQuoteBriefRelationship.containsKey(campaignIdentifierKey)) {
                Quote_Brief_Relationship__c qbr = campaignQuoteToQuoteBriefRelationship.get(
                    campaignIdentifierKey
                );
                if (!briefIdToQuoteLine.containsKey(qbr.Brief__c)) {
                    briefIdToQuoteLine.put(qbr.Brief__c, eachQuoteLineItem);
                }
                if (
                    eachQuoteLineItem.Brief_Item__c == null &&
                    eachQuoteLineItem.SBQQ__Source__c == null
                ) {
                    quoteLineItemsWithBrief.add(eachQuoteLineItem);
                } else if (eachQuoteLineItem.Brief_Item__c != null) {
                    quoteLineItemsWithBriefItem.add(eachQuoteLineItem);
                    mapBriefItemIdToQuoteline.put(
                        eachQuoteLineItem.Brief_Item__c,
                        eachQuoteLineItem
                    );
                    quoteLineIds.add(eachQuoteLineItem.Id);
                    mapBriefIdToQuoteLine.put(qbr.Brief__c, eachQuoteLineItem);
                } else {
                    quoteLineItemsWithBrief.add(eachQuoteLineItem);
                }
            } else {
                if (
                    (eachQuoteLineItem.Package__c == 'DashPass Exclusive Item' ||
                    eachQuoteLineItem.SBQQ__ProductName__c == 'DashPass Exclusive Item') &&
                    eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Status__c != 'Approved'
                ) {
                    continue;
                }
                if (
                    eachQuoteLineItem.SBQQ__ProductName__c == 'Offsite Ad' &&
                    !VALID_FOR_BRIEF_ITEMS_OFFSITE_PLATFORM_VALUES.contains(
                        eachQuoteLineItem.Offsite_Platform__c
                    )
                ) {
                    continue;
                }
                // Check for Create_Brief_Item__c value, Opportunity filters, and custom label alias
                if (eachQuoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Deal_Type__c == SELF_SERVE_DEAL_TYPE)
                {
                continue;
                }
                quoteLinesWithoutBriefAndBriefItem.add(eachQuoteLineItem);
            }
        }
        if (!quoteLineItemsWithBriefItem.isEmpty()) {
            QuoteLineItemsService.updateBriefItemsQuoteLineSyncFields(quoteLineItemsWithBriefItem);
        }
        if (!briefIdToQuoteLine.isEmpty()) {
            BriefsService.updateAgencyFieldOnExistingBriefs(briefIdToQuoteLine);
        }
        BriefsService.generateBriefsByQuoteLineItems(quoteLinesWithoutBriefAndBriefItem);
        if (
            !briefIdToQuoteLine.isEmpty() &&
            !quoteLineItemsWithBriefItem.isEmpty() &&
            !mapBriefItemIdToQuoteline.isEmpty()
        ) {
            BriefItemsService.updateAgencyFieldOnExistingBriefItems(mapBriefItemIdToQuoteline);
            BriefsService.updateAgencyFieldOnExistingBriefs(mapBriefIdToQuoteLine);
        }
        BriefItemsService.generateBriefItemsByQuoteLineItems(
            quoteLineItemsWithBrief,
            quoteBriefRelationships
        );
    }
    /**
     * @description It is used to update the Estimated Total Investment on associated Opportunity.
     */
    public void updateOpportunityInvestment() {
        Map<Id, Decimal> opportunityToTotalInvestment = new Map<Id, Decimal>();
        for (
            SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecordsByFieldValues(
                SBQQ__Quote__c.SBQQ__Primary__c,
                new Set<Object>{ true }
            )
        ) {
            if (!opportunityToTotalInvestment.containsKey(eachQuote.SBQQ__Opportunity2__c)) {
                opportunityToTotalInvestment.put(
                    eachQuote.SBQQ__Opportunity2__c,
                    eachQuote.Estimated_Total_Investment__c
                );
            }
        }
        OpportunitiesService.updateEstimatedTotalInvestmentOnOpportunity(
            opportunityToTotalInvestment
        );
    }
    /**
     * @description It updates Stage on Opportunity to 'Contracting' or 'Closed Won' whenever a Quote's
     * 'Status' is changed to 'Out For Signature' and 'Contract Signed' respectively and updates the Quote's 'Number of Stores' with 'Estimated # of stores' field on Opportunity.
     * @JIRA# LEM-14174, LEM-14946
     * @param existingQuotes
     */
    public void updateOpportunityStageByQuoteStatus(Map<Id, SObject> existingQuotes) {
        Map<Id, String> opportunityIdToChangedStatus = new Map<Id, String>();
        Map<Id, Decimal> opportunityIdToNumberOfStores = new Map<Id, Decimal>();
        for (
            SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecordsByFieldValues(
                SBQQ__Quote__c.SBQQ__Status__c,
                new Set<Object>{ QUOTE_STATUS_OUT_FOR_SIGNATURE, CONTRACT_SIGNED, STATUS_DRAFT }
            )
        ) {
            SBQQ__Quote__c existingQuote = (SBQQ__Quote__c) existingQuotes.get(eachQuote.Id);
            if (
                eachQuote.SBQQ__Opportunity2__c != null &&
                (eachQuote.Segment__c == ACCOUNT_SEGMENT_SMB ||
                 (eachQuote.Segment__c != ACCOUNT_SEGMENT_SMB &&
                  eachQuote.Opportunity_Deal_Type__c == DEAL_TYPE &&
                  eachQuote.Opportunity_Sub_Type__c == SUB_TYPE))
            ) {
                switch on QUOTETOOPPORTUNITYSTATUSMAPPING.get(eachQuote.SBQQ__Status__c) {
                    when QUOTE_STATUS_OUT_FOR_SIGNATURE {
                        opportunityIdToChangedStatus.put(
                            eachQuote.SBQQ__Opportunity2__c,
                            OPPORTUNITY_STAGE_CONTRACTING
                        );
                    }
                    when QUOTE_STATUS_CONTRACT_SIGNED {
                        opportunityIdToChangedStatus.put(
                            eachQuote.SBQQ__Opportunity2__c,
                            OPPORTUNITY_STAGE_CLOSED_WON
                        );
                        opportunityIdToNumberOfStores.put(
                            eachQuote.SBQQ__Opportunity2__c,
                            eachQuote.Number_of_Stores__c
                        );
                    }
                    when QUOTE_STATUS_DRAFT {
                        if (existingQuote.SBQQ__Status__c == QUOTE_STATUS_OUT_FOR_SIGNATURE) {
                            opportunityIdToChangedStatus.put(
                                eachQuote.SBQQ__Opportunity2__c,
                                OPPORTUNITY_STAGE_NEGOTIATING
                            );
                        }
                    }
                }
            }
        }
        if (!opportunityIdToNumberOfStores.isEmpty()) {
            OpportunitiesService.updateOpportunityNoOfStoresByQuoteNoOfStores(
                opportunityIdToNumberOfStores
            );
        }
        if (!opportunityIdToChangedStatus.isEmpty()) {
            OpportunitiesService.updateOpportunityStageByQuoteStatus(opportunityIdToChangedStatus);
        }
    }
    /**
     * @description A common method to commit unit of work.
     * @JIRA# LEM-746
     * @param unitOfWork
     */
    private void commitWork(fflib_ISObjectUnitOfWork unitOfWork) {
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(ex)
            );
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            throw ex;
        }
    }
    /**
     * @description Holds a mock instance of the constructor inner class.Setting this will provide the ability to test the records being injected into the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;
    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }
    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Quotes - List of Quotes
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (Quotes.constructorMock != null) {
                return (fflib_SObjects) Quotes.constructorMock.construct(objectList);
            }
            return new Quotes((List<SObject>) objectList);
        }
    }
    /**
     * @description LEM-2831 It is used to validate the Quote Line's required drawer field are filled or not.
     */
    public void validateQuoteLineDrawerField() {
        Map<Id, SBQQ__Quote__c> quoteRecordMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, String> quoteMessageMap = new Map<Id, String>();
        Set<String> productCodes = new Set<String>();
        String accountSegment;
        Set<Id> oppIds = new Set<Id>();
        List<Opportunity> oppList = new List<Opportunity>();
        String prodCodesString = label.Product_Codes_To_Check;
        List<String> prodCodes = prodCodesString.split(',');
        for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) getRecords()) {
            if (
                !NON_APPLICABLE_QUOTE_SOURCES_FOR_MAGIC_WAND.contains(
                    quote.Opportunity_Source__c
                ) &&
                !NON_APPLICABLE_QUOTE_INTEGRATION_SOURCES_FOR_MAGIC_WAND.contains(
                    quote.Integration_Source__c
                ) &&
                (quote.SBQQ__Status__c != STATUS_DRAFT ||
                quote.Opportunity_Deal_Type__c == SELF_SERVE_DEAL_TYPE)
            ) {
                quoteRecordMap.put(quote.Id, quote);
            }
            accountSegment = (quote.Segment__c == ACCOUNT_SEGMENT_MIDMARKET
                ? ACCOUNT_SEGMENT_ENTERPRISE
                : quote.Segment__c);
        }
        List<SBQQ__QuoteLine__c> quoteLineList = QuoteLineItemsSelector.newInstance()
            .selectDrawerFieldByQuotes(quoteRecordMap.keySet());
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            productCodes.add(quoteLine.SBQQ__ProductCode__c);
            if (quoteLine.SBQQ__Quote__r.Opportunity_Deal_Type__c == SELF_SERVE_DEAL_TYPE) {
                oppIds.add(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            }
        }
        if (productCodes.isEmpty()) {
            return;
        }
        oppList = OpportunitiesSelector.newInstance().selectById(oppIds);
        if (!oppList.isEmpty()) {
            quoteMessageMap.putAll(checkProductCodes(quoteLineList, productCodes, prodCodes));
        } else {
            quoteMessageMap.putAll(
                checkIfRequiredAttributesAreBlank(productCodes, quoteLineList, accountSegment)
            );
        }
        for (Id quoteId : quoteMessageMap.keySet()) {
            SBQQ__Quote__c quote = quoteRecordMap.get(quoteId);
            quote.addError(
                label.Quote_Line_Drawer_Required_Field_Error_Message +
                    ' ' +
                    quoteMessageMap.get(quoteId)
            );
        }
    }
    /**
     * @description LEM-2831 It is used to validate the Quote Line's required drawer field are filled or not.
     * @param productCodes
     * @param quoteLineList
     * @return Map of Quotes with Error message
     */
    public static Map<Id, String> checkIfRequiredAttributesAreBlankForSelfServe(
        Set<String> productCodes,
        List<SBQQ__QuoteLine__c> quoteLineList
    ) {
        Map<Id, String> quoteErrorMessageMap = new Map<Id, String>();
        List<SBQQ__QuoteLine__c> affectedQuoteLineList = new List<SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if (
                //productCodes.contains(quoteLine.SBQQ__ProductCode__c) &&
                (String.isNotBlank(quoteLine.Package__c) || quoteline.SBQQ__Bundle__c == true)
            ) {
                continue;
            } else if (
                productCodes.contains(quoteLine.SBQQ__ProductCode__c) &&
                quoteLine.End_Date__c == null &&
                quoteLine.SBQQ__Quote__r.Self_Serve_Status__c == SELF_SERVE_ACTIVATED
            ) {
                affectedQuoteLineList.add(quoteLine);
            }
        }
        if (!affectedQuoteLineList.isEmpty()) {
            quoteErrorMessageMap = createAffectQuoteLineMessageMap(affectedQuoteLineList);
        }
        return quoteErrorMessageMap;
    }
    /**
     * @description this method creates the error message map
     * @param quotelinelist
     * @return Map of Quotes with Error message
     */
    public static Map<Id, String> createAffectQuoteLineMessageMap(
        List<SBQQ__QuoteLine__c> quotelinelist
    ) {
        Map<Id, String> quoteErrorMessageMap = new Map<Id, String>();
        for (SBQQ__QuoteLine__c quoteLine : quotelinelist) {
            if (quoteErrorMessageMap.containsKey(quoteLine.SBQQ__Quote__c)) {
                String productNames =
                    quoteErrorMessageMap.get(quoteLine.SBQQ__Quote__c) +
                    ', ' +
                    quoteLine.SBQQ__ProductName__c;
                quoteErrorMessageMap.put(quoteLine.SBQQ__Quote__c, productNames);
            } else {
                quoteErrorMessageMap.put(quoteLine.SBQQ__Quote__c, quoteLine.SBQQ__ProductName__c);
            }
        }
        return quoteErrorMessageMap;
    }
    /**
     * @description this method creates the error message map
     * @param quotelinelist
     * @param productCodes
     * @param prodCodes
     * @return Map of Quotes with Error message
     */
    public static Map<Id, String> checkProductCodes(
        List<SBQQ__QuoteLine__c> quotelinelist,
        Set<String> productCodes,
        List<String> prodCodes
    ) {
        Set<String> productCodesFound = new Set<String>();
        Map<Id, String> quoteMessageMap = new Map<Id, String>();
        for (String prodCode : productCodes) {
            if (prodCodes.contains(prodCode)) {
                productCodesFound.add(prodCode);
            }
        }
        if (!productCodesFound.isEmpty()) {
            quoteMessageMap.putAll(
                checkIfRequiredAttributesAreBlankForSelfServe(productCodesFound, quoteLineList)
            );
        }
        return quoteMessageMap;
    }
    /**
     * @description LEM-2831 It is used to validate the Quote Line's required drawer field are filled or not.
     * @param productCodes
     * @param quoteLineList
     * @param accountSegment
     * @return Map of Quotes with Error message
     */
    private static Map<Id, String> checkIfRequiredAttributesAreBlank(
        Set<String> productCodes,
        List<SBQQ__QuoteLine__c> quoteLineList,
        String accountSegment
    ) {
        Map<Id, String> quoteErrorMessageMap;
        String packageProduct;
        quoteErrorMessageMap = new Map<Id, String>();
        Set<String> segmentsToValidate = new Set<String>{ APPLICABLE_SEGMENT_VALUE_ALL };
        segmentsToValidate.add(accountSegment);

        Map<String, List<Quote_Line_Drawer_Attributes__mdt>> productCodeQLDAMap = new Map<String, List<Quote_Line_Drawer_Attributes__mdt>>();
        for (
            Quote_Line_Drawer_Products__mdt quoteLineProductmdt : QuoteLineProductsMappingSelector.newInstance()
                .selectQLProductsWithRequiredAttributesByProductCode(productCodes)
        ) {
            if (quoteLineProductmdt.Quote_Line_Drawer_Attributes__r == null) {
                continue;
            }
            for (
                Quote_Line_Drawer_Attributes__mdt attribute : quoteLineProductmdt.Quote_Line_Drawer_Attributes__r
            ) {
                if (segmentsToValidate.contains(attribute.Required_for_Segment__c)) {
                    if (CORE_PACKAGES.contains(quoteLineProductmdt.package__c)) {
                        packageProduct =
                            quoteLineProductmdt.Package__c + quoteLineProductmdt.Product_Code__c;
                    } else {
                        packageProduct = quoteLineProductmdt.Product_Code__c;
                    }
                    if (!productCodeQLDAMap.containsKey(packageProduct)) {
                        productCodeQLDAMap.put(
                            packageProduct,
                            new List<Quote_Line_Drawer_Attributes__mdt>()
                        );
                    }
                    productCodeQLDAMap.get(packageProduct).add(attribute);
                }
            }
        }
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if (
                (quoteLine.SBQQ__Quantity__c != 0 &&
                CORE_PACKAGES.contains(quoteLine.package__c) &&
                quoteLine.SBQQ__Quote__r.Custom_Partnership_Type__c != null)
            ) {
                packageProduct = quoteLine.Package__c + quoteLine.SBQQ__ProductCode__c;
            } else {
                packageProduct = quoteLine.SBQQ__ProductCode__c;
            }
            if (
                productCodeQLDAMap.containsKey(packageProduct) &&
                checkRequiredDrawerFields(quoteLine, productCodeQLDAMap.get(packageProduct))
            ) {
                if (quoteErrorMessageMap.containsKey(quoteLine.SBQQ__Quote__c)) {
                    String productNames =
                        quoteErrorMessageMap.get(quoteLine.SBQQ__Quote__c) +
                        ', ' +
                        quoteLine.SBQQ__ProductName__c;
                    quoteErrorMessageMap.put(quoteLine.SBQQ__Quote__c, productNames);
                } else {
                    quoteErrorMessageMap.put(
                        quoteLine.SBQQ__Quote__c,
                        quoteLine.SBQQ__ProductName__c
                    );
                }
            }
        }
        return quoteErrorMessageMap;
    }
    /**
     * @description LEM-2831 It is used to check the Quote Line's required drawer field are filled or not.
     * @param quoteLine
     * @param quoteLineAttributemdtList
     * @return Boolean - List of Quotes
     */
    public static Boolean checkRequiredDrawerFields(
        SBQQ__QuoteLine__c quoteLine,
        List<Quote_Line_Drawer_Attributes__mdt> quoteLineAttributemdtList
    ) {
        for (Quote_Line_Drawer_Attributes__mdt quoteLineAttributemdt : quoteLineAttributemdtList) {
            if (
                (String.isNotBlank(quoteLine.Package__c) &&
                String.isNotBlank(quoteLineAttributemdt.Eligible_Packages__c) &&
                (quoteLineAttributemdt.Eligible_Packages__c.Split(SEMICOLON_DELIMITER))
                    .contains(quoteLine.Package__c)) ||
                (String.isBlank(quoteLine.Package__c) &&
                quoteLineAttributemdt.Eligible_For_Product__c)
            ) {
                if (
                    quoteLine.get(quoteLineAttributemdt.Field_API_Name__c) == null ||
                    quoteLine.get(quoteLineAttributemdt.Field_API_Name__c) == ''
                ) {
                    return true;
                }
            }
        }
        return false;
    }
    /**
     * @description LEM-10562 It is used to update the active price fields on quotelines on submit for approval
     */
    public void updateActiveFeeActiveComissionOnQuotelines() {
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getRecordsByFieldValues(
                SBQQ__Quote__c.SBQQ__Status__c,
                new Set<Object>{ IN_REVIEW, STATUS_APPROVED }
            )
        );
        if (quoteMap.isEmpty()) {
            return;
        }
        List<SBQQ__QuoteLine__c> newQuotelines = QuoteLineItemsSelector.newInstance()
            .selectActivePriceFieldsByQuotes(quoteMap.keySet());
        if (newQuotelines.isEmpty()) {
            return;
        }
        QuoteLineItemsService.updateActiveFeeActiveComissionOnQuotelines(newQuotelines);
    }
    /**
     * @description It is used to revert active price fields on quotelines when approvals are recalled
     */
    public void revertActiveFeeActiveComissionOnQuotelines() {
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(
            (List<SBQQ__Quote__c>) getRecordsByFieldValues(
                SBQQ__Quote__c.SBQQ__Status__c,
                new Set<Object>{ STATUS_DRAFT }
            )
        );
        if (quoteMap.isEmpty()) {
            return;
        }
        List<SBQQ__QuoteLine__c> newQuotelines = QuoteLineItemsSelector.newInstance()
            .selectActivePriceFieldsByQuotes(quoteMap.keySet());
        if (newQuotelines.isEmpty()) {
            return;
        }
        QuoteLineItemsService.revertActiveFeeActiveComissionOnQuotelines(newQuotelines);
    }
    /**
     * @description LEM-2831 It is used to update fields on Amnendment Quotes from original most recent quote from which it is amended
     * */
    public void updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes() {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        List<SBQQ__Quote__c> quoteList = (List<SBQQ__Quote__c>) getRecords();
        if (quoteList.isEmpty()) {
            return;
        }
        Map<Id, SBQQ__Quote__c> quoteMap = new Map<Id, SBQQ__Quote__c>(quoteList);
        for (
            SBQQ__Quote__c quote : QuotesSelector.newInstance()
                .selectQuoteFieldsFromOriginalQuote(quoteMap.keySet())
        ) {
            if (
                quote.SBQQ__MasterEvergreenContract__r.SBQQ__Order__r.SBQQ__Quote__r.Is_this_for_Ads_Promos__c ==
                ADS_PROMOS_YES_VALUE ||
                quote.SBQQ__MasterEvergreenContract__r.Contract_Split_Category__c ==
                CONTRACT_SPLIT_CATEGORY_ADS_PROMOS
            ) {
                quote.Is_this_for_Ads_Promos__c = ADS_PROMOS_YES_VALUE;
            }
            uow.registerDirty(quote);
        }
        commitWork(uow);
    }
    /**
     * @description It updates 'Out For Signature Date' field on Quote whenever a Quote status is changed to "Out For Signature".
     * @param existingRecords
     * @JIRA# LEM-13475, LEM-13561
     */
    public void updateQuoteOutForSignatureDate(Map<Id, sObject> existingRecords) {
        for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) getRecords()) {
            SBQQ__Quote__c oldquote = (SBQQ__Quote__c) existingRecords.get(quote.Id);
            if (
                oldquote.SBQQ__Status__c != QUOTE_STATUS_OUT_FOR_SIGNATURE &&
                quote.SBQQ__Status__c == QUOTE_STATUS_OUT_FOR_SIGNATURE
            ) {
                quote.Out_For_Signature_Date__c = System.today();
            } else if (
                quote.SBQQ__Primary__c &&
                (quote.SBQQ__Status__c != CONTRACT_SIGNED &&
                oldquote.SBQQ__Status__c != QUOTE_STATUS_OUT_FOR_SIGNATURE)
            ) {
                quote.Out_For_Signature_Date__c = null;
            }
        }
    }
    /**
     * @description It is used to update Users Approval Groups on  Quotes based on Quote Qwner
     * @JIRA# LEM-14013
     */
    public void populateAssignedGroupsNameOnQuotes() {
        Set<ID> quoteManagerIds = new Set<ID>();
        Map<ID, Set<string>> quoteManagerIdToGroup = new Map<ID, Set<String>>();
        for (SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecords()) {
            quoteManagerIds.add(eachQuote.Users_Manager_Id__c);
        }
        List<String> applicableGroups = getApprovalGroups();
        if (applicableGroups.isEmpty()) {
            return;
        }
        quoteManagerIdToGroup = getGroupsQuoteOwnerIsMemberOf(applicableGroups, quoteManagerIds);
        if (quoteManagerIdToGroup.isEmpty()) {
            return;
        }
        for (SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecords()) {
            if (quoteManagerIdToGroup.containskey(eachQuote.Users_Manager_Id__c)) {
                Set<String> groupsOwnerIsMemberOf = quoteManagerIdToGroup.get(
                    eachQuote.Users_Manager_Id__c
                );
                groupsOwnerIsMemberOf.retainAll(applicableGroups);
                String applicableGroupsForUser = String.join(
                    new List<String>(groupsOwnerIsMemberOf),
                    ','
                );
                eachQuote.Users_Approval_Group__c = applicableGroupsForUser;
            }
        }
    }
    /**
     * @description It is used to return groups in which Quote Owner is group member.
     * @JIRA# LEM-14013
     * @param applicableGroups
     * @param quoteOwnerIds
     * @return quoteOwnerToGroup
     */
    private Map<ID, Set<string>> getGroupsQuoteOwnerIsMemberOf(
        List<String> applicableGroups,
        Set<Id> quoteOwnerIds
    ) {
        Map<ID, Set<string>> quoteOwnerToGroup = new Map<ID, Set<string>>();
        for (
            GroupMember eachGroupMember : GroupMembersSelector.newInstance()
                .selectGroupMembersByGroupNamesAndUserIds(applicableGroups, quoteOwnerIds)
        ) {
            if (quoteOwnerToGroup.containsKey(eachGroupMember.UserOrGroupId)) {
                Set<String> groupNames = quoteOwnerToGroup.get(eachGroupMember.UserOrGroupId);
                groupNames.add(eachGroupMember.Group.DeveloperName);
                quoteOwnerToGroup.put(eachGroupMember.UserOrGroupId, groupNames);
            } else {
                quoteOwnerToGroup.put(
                    eachGroupMember.UserOrGroupId,
                    new Set<String>{ eachGroupMember.Group.DeveloperName }
                );
            }
        }
        return quoteOwnerToGroup;
    }
    /**
     * @description It is used to return Approval Groups required for Approval Rules routing.
     * @JIRA# LEM-14013
     * @return List<String>
     */
    private List<String> getApprovalGroups() {
        List<String> applicableGroups = new List<String>();
        for (
            Approval_Group__mdt eachApprovalGroup : ApprovalGroupsSelector.newInstance()
                .selectApprovalGroups()
        ) {
            applicableGroups.add(eachApprovalGroup.DeveloperName);
        }
        return applicableGroups;
    }
    /**
     * @description  Quote status change to approved setting RESSMO_Eligible__c = true
     * @JIRA# LEM-16422
     */
    public void populateRESSMOEligibleOnQuoteStatusIsApproved() {
        Set<SBQQ__Quote__c> setOfQuotestoCheckEligibilty = new Set<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quotestoCheckEligibilty = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>) getRecordsByFieldValue(
            SBQQ__Quote__c.SBQQ__Status__c,
            STATUS_APPROVED
        );
        quotes.addAll(
            (List<SBQQ__Quote__c>) getRecordsWithNotBlankFieldValues(
                SBQQ__Quote__c.RESSMO_Store_Account_Id__c
            )
        );
        for (SBQQ__Quote__c qot : quotes) {
            if (qot.Segment__c == SEGMENT_SMB && !qot.RESSMO_Eligible__c) {
                setOfQuotestoCheckEligibilty.add(qot);
            }
        }
        quotestoCheckEligibilty.addAll(setOfQuotestoCheckEligibilty);
        Set<Id> eligibleQuoteIds = RESSMOEligibilityController.quotesEligibilityForRESSMO(
            quotestoCheckEligibilty
        );
        if (eligibleQuoteIds != null) {
            for (SBQQ__Quote__c quote : quotes) {
                if (quote.Segment__c == SEGMENT_SMB && !quote.RESSMO_Eligible__c && eligibleQuoteIds.contains(quote.Id)) {
                    quote.RESSMO_Eligible__c = true;
                }
            }
        }
    }
    /**
     * @description Updates Contracting_Flow__c to 'REDLINING' for quotes with Store_Specific_Variations__c set to 'Yes'
     */
    public void updateContractingFlowForStoreSpecificVariations() {
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>) getRecordsByFieldValue(
            SBQQ__Quote__c.Store_Specific_Variations__c,
            ADS_PROMOS_YES_VALUE
        );
        for (SBQQ__Quote__c quote : quotes) {
            if (quote.Contracting_Flow__c != REDLINING) {
                quote.Contracting_Flow__c = REDLINING;
            }
        }
    }
    /**
     * @description  It used to check Alcohol Eligibility for Amendment Quotes.
     * @JIRA# LEM-17960
     */
    public void verifyAlcoholEligibilityForExistingOpportunity() {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Integer> subscriptionsToAccountId = new Map<Id, Integer>();
        for (SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecords()) {
            accountIds.add(eachQuote.SBQQ__Account__c);
        }
        if (accountIds.IsEmpty()) {
            return;
        }
        for (
            SBQQ__Subscription__c eachSubscription : SubscriptionSelector.newInstance()
                .selectAlcoholSubscriptionByAccount(accountIds)
        ) {
            if (subscriptionsToAccountId.containsKey(eachSubscription.SBQQ__Account__c)) {
                subscriptionsToAccountId.put(
                    eachSubscription.SBQQ__Account__c,
                    subscriptionsToAccountId.get(eachSubscription.SBQQ__Account__c) + 1
                );
            }
            subscriptionsToAccountId.put(eachSubscription.SBQQ__Account__c, 1);
        }
        for (SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecords()) {
            if (
                (eachQuote.SBQQ__Type__c == AMENDMENT || eachQuote.SBQQ__Type__c == QUOTE) &&
                subscriptionsToAccountId.containsKey(eachQuote.SBQQ__Account__c)
            ) {
                eachQuote.Is_Alcohol_Delivery_Pickup_Exists__c = ELIGIBLE_FOR_ALCOHOL;
            }
        }
    }

    /**
     * @description It is used to initiate the creation of approver records for 'Redlining'
     * dynamic approval rule for given user's manager ids.
     * @JIRA# LEM-22071
     */
    public void initiateRedliningApproversCreationByManagerId() {
        Set<Id> userIds = new Set<Id>();
        for (
            SBQQ__Quote__c eachQuoteAsRedlining : (List<SBQQ__Quote__c>) getRecordsByFieldValue(
                SBQQ__Quote__c.Contracting_Flow__c,
                REDLINING
            )
        ) {
            if (eachQuoteAsRedlining.Users_Manager_Id__c != null) {
                userIds.add(eachQuoteAsRedlining.Users_Manager_Id__c);
            }
        }
        if (userIds.isEmpty()) {
            return;
        }
        ApproversService.createApproversByUserIds(userIds);
    }

    /**
     * @description  It is used to enforce validation for ANZ users when they attempt to update unique term fields.
     * @JIRA# LEM-21443
     */
    public void validateIfUniqueTermFieldsWereUpdated() {
        // Retrieve the field set for SBQQ__Quote__c
        Schema.FieldSet fieldSet = Schema.getGlobalDescribe()
            .get(OBJECT_APINAME)
            .getDescribe()
            .fieldSets.getMap()
            .get(ANZ_FIELDSET);

        if (fieldSet == null) {
            return;
        }

        List<Schema.FieldSetMember> fields = fieldSet.getFields();

        if (fields.isEmpty()) {
            return;
        }

        // Assuming getRecords() returns a list of SBQQ__Quote__c records
        for (SBQQ__Quote__c eachQuote : (List<SBQQ__Quote__c>) getRecords()) {
            boolean isAnyBooleanFieldTrue = false;
            boolean isAnyNonBooleanFieldPopulated = false;
            List<String> fieldsNotApplicableForANZUsers = new List<String>();

            for (Schema.FieldSetMember field : fields) {
                String fieldName = field.getFieldPath();
                String fieldLabel = field.getLabel();

                // Get the field's describe result
                SObjectField sObjectField = eachQuote.getSObjectType()
                    .getDescribe()
                    .fields.getMap()
                    .get(fieldName);
                Schema.DescribeFieldResult fieldDescribe = sObjectField.getDescribe();

                String fieldType = fieldDescribe.getType().name();
                Object fieldValue = eachQuote.get(fieldName);

                // Handling Boolean fields
                if (fieldType == Schema.DisplayType.BOOLEAN.name()) {
                    if (fieldValue != null && (Boolean) fieldValue) {
                        isAnyBooleanFieldTrue = true;
                        fieldsNotApplicableForANZUsers.add(fieldLabel);
                    }
                }
                // Handling non-Boolean fields
                else if (fieldValue != null) {
                    isAnyNonBooleanFieldPopulated = true;
                    fieldsNotApplicableForANZUsers.add(fieldLabel);
                }
            }

            if (!fieldsNotApplicableForANZUsers.isEmpty()) {
                validationForANZUsers(fieldsNotApplicableForANZUsers, eachQuote);
            }
        }
    }

    /**
     * @description  It is used to enforce validation for ANZ users when they attempt to update unique term fields.
     * @JIRA# LEM-21443
     * @param  fieldsNotApplicableForANZUsers
     * @param  eachQuote
     */
    private void validationForANZUsers(
        List<String> fieldsNotApplicableForANZUsers,
        SBQQ__Quote__c eachQuote
    ) {
        // Check if validation is required for non-US/CA SMB customers
        if (
            !fieldsNotApplicableForANZUsers.isEmpty() &&
            eachQuote.Account_Billing_Country_Code__c != US_COUNTRYCODE &&
            eachQuote.Account_Billing_Country_Code__c != CA_COUNTRYCODE &&
            eachQuote.Segment__c == ACCOUNT_SEGMENT_SMB
        ) {
            String str = String.join(fieldsNotApplicableForANZUsers, ', ');
            eachQuote.addError(ANZ_VALIDATION_MESSAGE + str);
        }
    }


    /**
    * @description - blank quote Unique Identifier if its opportunity ressmo link is not blank (On before update , Ironclad workflow updated to true)
    * @author Soumya Dash | 10-30-2024
    **/
    public void blankUniqueIdentifier() {
        List<SBQQ__Quote__c> quotes = (List<SBQQ__Quote__c>)getRecordsByFieldValue(SBQQ__Quote__c.Ironclad_WF_Launched__c,true);
        if (quotes.isEmpty()) {
            return;
        }

        map<Id,SBQQ__Quote__c> opportunityIdToQuote = new map<Id,SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quotes){
            if(quote.SBQQ__Opportunity2__c != null){
                opportunityIdToQuote.put(quote.SBQQ__Opportunity2__c,quote);
            }
        }
        List<Opportunity> opprtunities = OpportunitiesSelector.newInstance().selectById(opportunityIdToQuote.keySet());
        for(Opportunity opp : opprtunities){
            if(opp.RESSMO_Link__c != null){
                opportunityIdToQuote.get(opp.Id).Unique_Identifier__c = '';
            }
        }
    }

}