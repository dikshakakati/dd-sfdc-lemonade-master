/**
 * @description Advanced Approvals Quickstart package
 * @author ATG
 * @date 04/20/2022
 */
@SuppressWarnings(
    'PMD.NcssConstructorCount,PMD.CyclomaticComplexity,PMD.ApexCRUDViolation,PMD.StdCyclomaticComplexity'
)
public with sharing class AQS_QuoteExtController {
    private static final String AMENDMENT = 'Amendment';
    private static final String DRAFT_STATUS = 'Draft';
    private static final String SYSTEM_ADMIN_PROFILE_NAME = 'System Administrator';
    private static final String JIRA_URL_REGEX = '^https://doordash\\.atlassian\\.net/(servicedesk/customer/portal/70/EASD-\\d+|browse/EASD-\\d+)(\\?.*)?$';
    public static final String ERROR_MSG_MISSING_JIRA_LINK = 'Please enter in a valid Jira Request Ticket Link';
    public static final String ERROR_MSG_INVALID_JIRA_LINK = 'Please fix the formatting of your Comm Ops/Deal Desk Jira Request Ticket Link. Remove spaces before or after the link.';
    public static final String PRODUCT_CODE_STANDARD_DMF = '10035';
    public static final String REDLINING = 'Redlining';
    private static final Set<String> APPLICABLE_SEGMENTS = new Set<String>{
        System.Label.AccountSegmentEnterprise,
        System.Label.SegmentMidMarket
    };

    private static Set<String> countriesToValidateRxMerchants = new Set<String>{ 'AU', 'NZ' };
    private Id quoteId;
    private SBQQ__Quote__c quoteRec;
    private Account relatedAccount;
    private Opportunity relatedOpportunity;
    private Boolean isInvalidNumberOfStoresValue;
    private Boolean lofProductsewithCommissionForValidation;
    private Boolean isApprovalRequestReasonBlank;
    private Boolean delayAfterActivationDaysValidation = false;
    private Boolean startDateValidation = false;
    private Boolean isDeliveryTypeDistanceAndContractingFlowNotRedlining;
    private Boolean productsWithLengthOfTermForValidation;
    private Boolean productsWithFlatDiscountAndDiscountPercent = false;
    private Boolean productsWithBidAutoBidValidation = false;
    private static final List<String> PRODUCT_NAME_AP = new List<String>{
        'Custom Marketing Promotion',
        'Spend X, Get Y',
        'Order Again',
        'Buy Item, Get $X or Y% Off'
    };
    private static final String SPONSORED_LISTINGS = 'Sponsored Listings';

    /**
     * @description constructor
     * @param stdController
     */
    public AQS_QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
        isInvalidNumberOfStoresValue = false;
        if (quoteId != null) {
            quoteRec = QuotesSelector.newInstance().selectById(new Set<Id>{ quoteId })[0];

            setRelatedRecords();
            List<Account> accounts = AccountsSelector.newInstance()
                .selectById(new Set<Id>{ quoteRec.SBQQ__Account__c });
            if (!accounts.isEmpty()) {
                relatedAccount = accounts[0];
            }
        }
        if (quoteRec.Check_Delay_After_Activation_For_A_P__c) {
            delayAfterActivationDaysValidation = true;
        }
        if (quoteRec.Check_Start_Date_For_A_P_Product__c) {
            startDateValidation = true;
        }
        isInvalidNumberOfStoresValue = (quoteRec.Number_of_Stores__c <= 0 ||
        quoteRec.Number_of_Stores__c == null);

        lofProductsewithCommissionForValidation = (QuoteLineItemsSelector.newInstance()
                .selectLOFProductswithCommissionForValidation(new Set<Id>{ quoteId }))
            .isEmpty();
        productsWithLengthOfTermForValidation = (QuoteLineItemsSelector.newInstance()
                .selectLengthOfTermwithProductsForValidation(new Set<Id>{ quoteId }))
            .isEmpty();

        List<SBQQ__QuoteLine__c> quoteLines = (QuoteLineItemsSelector.newInstance()
            .selectAdsAndPromosProductsForValidation(new Set<Id>{ quoteId }));

        if (!quoteLines.isEmpty()) {
            for (SBQQ__QuoteLine__c eachQuoteLine : quoteLines) {
                if (
                    PRODUCT_NAME_AP.contains(eachQuoteLine.SBQQ__ProductName__c) &&
                    ((eachQuoteLine.Discount_Percentage_for_Consumer__c == null &&
                    eachQuoteLine.Flat_Discount_Amount_for_Consumer__c == null) ||
                    ((eachQuoteLine.Discount_Percentage_for_Consumer__c != null &&
                    eachQuoteLine.Flat_Discount_Amount_for_Consumer__c != null)))
                ) {
                    productsWithFlatDiscountAndDiscountPercent = true;
                }

                if (
                    eachQuoteLine.SBQQ__ProductName__c == SPONSORED_LISTINGS &&
                    ((eachQuoteLine.Bid__c == null && eachQuoteLine.Auto_Bidding__c == false) ||
                    ((eachQuoteLine.Bid__c != null &&
                    eachQuoteLine.Auto_Bidding__c == true)))
                ) {
                    productsWithBidAutoBidValidation = true;
                }
            }
        }

        isApprovalRequestReasonBlank = checkApprovalRequestReasonOnQuote(quoteRec, quoteId);

        isDeliveryTypeDistanceAndContractingFlowNotRedlining = checkContractingFlowForDriveDeliveryType(
            quoteRec,
            quoteId
        );

        if (
            quoteRec != null &&
            quoteRec.SBQQ__Status__c == DRAFT_STATUS &&
            quoteRec.SBQQ__Type__c == AMENDMENT &&
            quoteRec.Use_Corporate_Cherry_Picking__c == true
        ) {
            ApexPages.addmessage(
                new ApexPages.message(
                    ApexPages.severity.WARNING,
                    System.Label.Warning_Message_on_Submit_for_Approval
                )
            );
        }
    }
    /**
     * @description method for checking Contracting Flow field value on quote
     * for LOF/SOF Delivery option's Delivery Type as Distance Based.
     * @param quoteRec
     * @param quoteId
     * @return Boolean
     */
    private Boolean checkContractingFlowForDriveDeliveryType(SBQQ__Quote__c quoteRec, Id quoteId) {
        isDeliveryTypeDistanceAndContractingFlowNotRedlining = false;
        Boolean deliveryTypeDistanceBasedLines = QuoteLineItemsSelector.newInstance()
            .selectNewDriveDeliveryProductswithDeliveyTypeAsDistanceBased(new Set<Id>{ quoteId })
            .isEmpty();
        if (!deliveryTypeDistanceBasedLines && quoteRec.Contracting_Flow__c != REDLINING) {
            isDeliveryTypeDistanceAndContractingFlowNotRedlining = true;
        }
        return isDeliveryTypeDistanceAndContractingFlowNotRedlining;
    }

    /**
     * @description method for checking Approval requested reason on quote
     * @param quoteRec
     * @param quoteId
     * @return Boolean
     */
    private Boolean checkApprovalRequestReasonOnQuote(SBQQ__Quote__c quoteRec, Id quoteId) {
        isApprovalRequestReasonBlank = false;
        if (
            quoteRec.SBQQ__Status__c == DRAFT_STATUS &&
            quoteRec.Approval_Requested_Reason__c == null
        ) {
            List<sbaa__Approval__c> approvals = SBAA.ApprovalAPI.preview(
                quoteId,
                (SObjectField) sbaa__Approval__c.AQS_Quote__c
            );
            if (!approvals.isEmpty()) {
                isApprovalRequestReasonBlank = true;
            }
        }
        return isApprovalRequestReasonBlank;
    }

    /**
     * @description method for submitting Approvals used by the button on VF page
     * @param
     * @return PageReference
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public PageReference onSubmit() {
        try {
            if (quoteId != null) {
                validateDuringSubmission();
            }
            if (relatedAccount?.Segment__c == System.Label.AccountSegmentSMB) {
                validateOnSubmit();
            }
            if (
                quoteId != null &&
                (APPLICABLE_SEGMENTS.contains(relatedAccount?.Segment__c) ||
                isSMBQuoteEligibleForApprovalSubmission())
            ) {
                SBAA.ApprovalAPI.submit(quoteId, (SObjectField) sbaa__Approval__c.AQS_Quote__c);
            }
        }
        // Approval Enablement Package 4.0 - Catch any errors (Validation, Apex) during approval process
        catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }
        // Approval Enablement Package 4.0 - If no error then return user to the quote page
        PageReference pr = new PageReference('/' + quoteId);
        pr.setRedirect(true);
        if (
            APPLICABLE_SEGMENTS.contains(relatedAccount?.Segment__c) ||
            isSMBQuoteEligibleForApprovalSubmission()
        ) {
            return pr;
        }
        return null;
    }
    /**
     * @description method for validation of quote approval
     */
    private void validateOnSubmit() {
        if (isApprovalRequestReasonBlank) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.Error_Message_on_Approval_Requested_Reason
                )
            );
        }
        if (isInvalidNumberOfStoresValue) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.Error_Message_on_Number_Of_Stores_On_Quote
                )
            );
        }
        if (!lofProductsewithCommissionForValidation) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.MinMaxDeliveryFeeRequiredForDriveProducts
                )
            );
        }
        if (delayAfterActivationDaysValidation) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.Delay_after_Activation_Days_For_A_P
                )
            );
        }
        if (startDateValidation) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.Start_Date_For_A_P_Product
                )
            );
        }
        if (!productsWithLengthOfTermForValidation) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.LengthOfTermRequiredForAdvertisementPromotion
                )
            );
        }
        if (isDeliveryTypeDistanceAndContractingFlowNotRedlining) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.DriveDeliveryContractingFlowNotRedlining
                )
            );
        }
        if (productsWithFlatDiscountAndDiscountPercent) {
            ApexPages.addMessage(
                new ApexPages.Message(
                    ApexPages.Severity.ERROR,
                    System.Label.DiscountPercentFlatDiscountValidation
                )
            );
        }
        if (productsWithBidAutoBidValidation) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.ERROR, System.Label.BidAutoBidValidation)
            );
        }
    }

    /**
     * @description It is used to validate whether the SMB quote is eligible for approval submission or not.
     * Once the required validations are handled, the quote is eligible to invoke approval submission API.
     * @return Boolean
     */
    private Boolean isSMBQuoteEligibleForApprovalSubmission() {
        return (!isInvalidNumberOfStoresValue &&
        !isApprovalRequestReasonBlank &&
        lofProductsewithCommissionForValidation &&
        !startDateValidation &&
        !delayAfterActivationDaysValidation &&
        !isDeliveryTypeDistanceAndContractingFlowNotRedlining &&
        lofProductsewithCommissionForValidation &&
        !productsWithFlatDiscountAndDiscountPercent &&
        !productsWithBidAutoBidValidation);
    }

    /**
     * @description method for recalling Approvals used by the button on VF page
     * @param
     * @return PageReference
     */
    public PageReference onRecall() {
        try {
            if (quoteId != null) {
                SBAA.ApprovalAPI.recall(quoteId, sbaa__Approval__c.AQS_Quote__c);
            }
        }
        // Approval Enablement Package 4.0 - Catch any errors (Validation, Apex) during approval process
        catch (Exception ex) {
            ApexPages.addMessages(ex);
            return null;
        }

        // Approval Enablement Package 4.0 - If not error, return to quote page
        PageReference pr = new PageReference('/' + quoteId);
        pr.setRedirect(true);
        return pr;
    }

    /**
     * @description  Show a Cancel button on the page if an error occurs
     * @param
     * @return PageReference
     */
    public PageReference onCancel() {
        return new PageReference('/' + quoteId);
    }

    /**
     * @description Validate the Quote's attributes when it is submitted for approval
     **/
    private void validateDuringSubmission() {
        Boolean isEnterprise =
            relatedAccount?.Segment__c == 'Enterprise' ||
            relatedAccount?.Segment__c == 'Mid-Market';
        Boolean isRxVertical = relatedAccount?.Primary_Vertical__c == 'Rx';
        Boolean isAustraliaOrNewZealand = countriesToValidateRxMerchants.contains(
            relatedAccount?.BillingCountryCode
        );

        // Conditions common to every scenario -- Enterprise & Non-Templatized
        if (isEnterprise && quoteRec.Contract_Generation_Path__c == 'Non-Templatized') {
            // If the Primary Vertical is NOT "Rx" OR
            // we have an A&P Opportunity OR
            // there is a "Standard DMF" Product on the Quote OR
            // (AUS/NZ with an Rx Primary Vertical)
            if (
                !isRxVertical ||
                relatedOpportunity?.Opportunity_Sub_Type__c == 'Ads & Promos' ||
                hasStandardDMF(quoteId) ||
                (isRxVertical && isAustraliaOrNewZealand)
            ) {
                validateJiraLink(quoteRec.Jira_Request_Ticket_link__c);

                quoteRec.Jira_Request_Ticket_status__c = 'Waiting for Support';
                update quoteRec;
            }
        }
    }

    /**
     * @description Initializes member variables for records that are related to the Quote
     **/
    private void setRelatedRecords() {
        if (quoteRec == null) {
            return;
        }

        List<Account> accounts = AccountsSelector.newInstance()
            .selectById(new Set<Id>{ quoteRec.SBQQ__Account__c });
        if (!accounts.isEmpty()) {
            relatedAccount = accounts[0];
        }

        List<Opportunity> opportunities = OpportunitiesSelector.newInstance()
            .selectById(new Set<Id>{ quoteRec.SBQQ__Opportunity2__c });
        if (!opportunities.isEmpty()) {
            relatedOpportunity = opportunities[0];
        }
    }

    /**
     * @description Validates an inputted Jira URL, if necessary based on user permissions
     * @param jiraLink
     **/
    @TestVisible
    private static void validateJiraLink(String jiraLink) {
        // Do not run the validation for Ironclad, CommOps, or Sytem Admin users
        if (
            FeatureManagement.checkPermission('Ironclad_Workflow_Launch') ||
            FeatureManagement.checkPermission('CommOps_User') ||
            isSystemAdmin()
        ) {
            return;
        }

        checkJiraLinkFormat(jiraLink);
    }

    /**
     * @description Validates an inputted Jira URL and throws an exception if it is invalid.
     *              The Jira URL should contain `EASD` and be well-formatted.
     *              Here are examples of acceptable URLs:
     *                  https://doordash.atlassian.net/servicedesk/customer/portal/70/EASD-7490?created=true
                        https://doordash.atlassian.net/browse/EASD-13066
     * @param jiraLink
    **/
    @TestVisible
    private static void checkJiraLinkFormat(String jiraLink) {
        if (String.isBlank(jiraLink)) {
            throw new SubmitException(ERROR_MSG_MISSING_JIRA_LINK);
        }

        Pattern regEx = Pattern.compile(JIRA_URL_REGEX);
        Matcher matcherInstance = regEx.matcher(jiraLink);

        if (!matcherInstance.matches()) {
            throw new SubmitException(ERROR_MSG_INVALID_JIRA_LINK);
        }
    }

    /**
     * @description Returns `true` if the running user is a System Administrator
     * @return Boolean
     **/
    private static Boolean isSystemAdmin() {
        String profileName;

        List<Profile> profiles = ProfilesSelector.newInstance()
            .selectById(new Set<Id>{ UserInfo.getProfileId() });
        if (!profiles.isEmpty()) {
            profileName = profiles[0].Name;
        }

        return profileName == SYSTEM_ADMIN_PROFILE_NAME;
    }

    /**
     * @description Returns `true` if the Quote has the "Standard DMF" product -- we need this for validation
     * @param quoteId
     * @return Boolean
     **/
    @TestVisible
    private static Boolean hasStandardDMF(Id quoteId) {
        if (quoteId == null) {
            return false;
        }

        for (
            SBQQ__QuoteLine__c qli : QuoteLineItemsSelector.newInstance()
                .selectQuoteLineItemsFromQuoteIds(new Set<Id>{ quoteId })
        ) {
            if (qli.SBQQ__ProductCode__c == PRODUCT_CODE_STANDARD_DMF) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Custom exception for errors while submitting the Quote for approval
     **/
    public class SubmitException extends Exception {
    }
}