/**
 * @author ATG
 * @date 2022-04-07
 * @description  Interface to add domain class methods
 */
public interface IQuotes extends fflib_ISObjects {
    /**
     * @description set Ordered checkbox on Quote.
     *   LEM-2768 additions: Populate the Signed_Contract_link__c with the newly-added
     *   document when a quote moves to 'Contract Signed'. Also sets Contract_Signed_Date__c
     *   with the current date.
     */
    void generateOrders();

    /**
	* @description LEM-1343 Populate DoorDashSigner on Quote based on the
                   Budget Sum for Ads and Promos
	*/
    void populateDoorDashSignerOnQuote();

    /**
     * @description updates the contract signatory exists flag
     */
    void updateContractSignatoryExists();

    /**
     * @description Sync payment terms from quote to payment account.
     */
    void syncPaymentTermsWithPaymentAccount();

    /**
     * @description It is used the check whether Quotes with status Contract Signed are valid to
     * create related Brief and Brief Items.
     */
    void initiateBriefsWithItemsGeneration();

    /**
     * @description It is used to update the Estimated Total Investment on associated Opportunity.
     */
    void updateOpportunityInvestment();

    /**
     * @description LEM-2831 It is used to validate the Quote Line's required drawer field are filled or not.
     */
    void validateQuoteLineDrawerField();
    /**
     * @description LEM-2768 additions: Populate the Signed_Contract_link__c with the newly-added
     *   document when a quote moves to 'Contract Signed'. Also sets Contract_Signed_Date__c
     *   with the current date. (Moved this logic into new method as part of LEM-5411 ticket)
     */
    void setSignedContractLinkAndDate();

    /**
     * @description LEM-10562 It is used to update Active Price Fields on Submit for approval
     */
    void updateActiveFeeActiveComissionOnQuotelines();

    /**
     * @description It is used to revert Active Price Fields when approvals are recalled
     */
    void revertActiveFeeActiveComissionOnQuotelines();

    /**
     * @description LEM-9455 It is used to update fields on Amnendment Quotes from original/
     * most recent quote from which it is amended
     */
    void updateMissingFieldsOnAmendmentQuotesFromOriginalQuotes();

    /**
     * @description It is used to update Users Approval Groups on  Quotes based on Quote Qwner
     * @JIRA# LEM-14013
     */
    void populateAssignedGroupsNameOnQuotes();
    /**
     * @description It updates 'Out For Signature Date' field on Quote whenever a Quote
     * status is changed to "Out For Signature".
     * @param existingRecords
     */
    void updateQuoteOutForSignatureDate(Map<Id, SObject> existingRecords);

    /**
     * @description It updates Stage on Opportunity to 'Contracting' or 'Closed Won' whenever a Quote's
     * 'Status' is changed to 'Out For Signature' and 'Contract Signed' respectively.
     * @JIRA# LEM-14174
     * @param existingQuotes
     */

    void updateOpportunityStageByQuoteStatus(Map<Id, SObject> existingQuotes);
    /**
     * @description Quote status change to approved setting RESSMO_Eligible__c = true
     * @JIRA# LEM-16422
     */
    void populateRESSMOEligibleOnQuoteStatusIsApproved();
    /**
     * @description Contracting flow is updated to Redlining.
     * @JIRA# LEM-17422
     */
    void updateContractingFlowForStoreSpecificVariations();
    /**
     * @description  It used to check Alcohol Eligibility for Amendment Quotes.
     * @JIRA# LEM-17960
     */
    void verifyAlcoholEligibilityForExistingOpportunity();
    /**
     * @description  It is used to enforce validation for ANZ users when they attempt to update unique term fields.
     * @JIRA# LEM-21443
     */
    void validateIfUniqueTermFieldsWereUpdated();

    /**
     * @description It is used to initiate the creation of approver records for 'Redlining'
     * dynamic approval rule for given user's manager ids.
     */
    void initiateRedliningApproversCreationByManagerId();


    /**
    * @description - blank quote Unique Identifier if its opportunity ressmo link is not blank (On before update , Ironclad workflow updated to true)
    * @author Soumya Dash | 10-30-2024
    **/
    void blankUniqueIdentifier();
}