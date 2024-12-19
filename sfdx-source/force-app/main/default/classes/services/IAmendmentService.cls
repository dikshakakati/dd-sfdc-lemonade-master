/**
 * @author Aetheueus
 * @date 29/05/2024
 * @description Interface of service class for AmendmentService.
 */
public interface IAmendmentService {
    /**
     * @description Method to create an amendment from an opportunity
     * @param opportunityId
     * @param contractId
     * @return amendmentQuoteId
     */
    String createAmendmentFromOpportunity(String opportunityId, String contractId);

    /**
     * @description  Update the opportunity with the contract ID
     * @param opportunityId ammended Quot It
     * @param contractId list of subscriptions
     * @param isDifferentSubtype Boolean whether Contract is Ads or Promo or Core
     */
    void updateOpportunityWithAmendedContract(String opportunityId, String contractId, boolean isDifferentSubtype);

    /**
     * @description  Create a new quote based on the provided contract ID
     * @param opportunity
     * @param contract
     * @return Id
     */
    SBQQ__Quote__c createAmendmentQuote(Opportunity opportunity, Contract contract);

    /**
     * @description  We create Quoteline Groups and Quoteline in this method
     * @param quote
     * @param contract
     * @return If the process is successful
     */
    Boolean insertAmendedQuoteLines(SBQQ__Quote__c quote, Contract contract);

    /**
     * @description  Create quote lines based on subscriptions and field mappings
     * @param amendedQuoteId ammended Quote Id
     */
    void createAmendedQuoteLines(String amendedQuoteId);

    /**
    * @description
    * @author rishab.goyal | 06-13-2024
    * @param ;
    **/
    void prepareMapforCustomAmendmentFields();

    /**
     * @description  create opportunity  and  work order for Rate Change
     * @param opportunitySubType
     * @param accountId
     * @param contractId
     * @return Map<String, String>
     */

    Map<String, String> createOpportunityAndWorkOrder(String opportunitySubType, Id accountId, Id contractId);

}