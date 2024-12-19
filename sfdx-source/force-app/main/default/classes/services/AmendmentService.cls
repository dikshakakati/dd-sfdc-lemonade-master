/**
 * @author Aetherus
 * @date 30/05/2024
 * @description Service  Custom Amendment Quote related logic.
 */
public inherited sharing class AmendmentService {

    private static IAmendmentService service() {
        return (IAmendmentService) Application.SERVICE.newInstance(IAmendmentService.class);
    }

    /**
     * @description  Update the opportunity with the contract ID
     * @param opportunityId ammended Quot It
     * @param contractId list of subscriptions
     * @param isDifferentSubtype Boolean whether Contract is Ads or Promo or Core
     */
    public  void updateOpportunityWithAmendedContract(String opportunityId, String contractId, boolean isDifferentSubtype) {
        service().updateOpportunityWithAmendedContract(opportunityId,contractId,isDifferentSubtype);
    }

     /**
     * @description Method to create an amendment from an opportunity
     * @param opportunityId
     * @param contractId
     * @return amendmentQuoteId
     */
    @AuraEnabled
    public static String createAmendmentFromOpportunity(String opportunityId, String contractId) {
        return service().createAmendmentFromOpportunity(opportunityId, contractId);
    }

    /**
    * @description
    * @author rishab.goyal | 06-13-2024
    * @param opportunity
    * @param contract
    * @return SBQQ__Quote__c
    **/
    public SBQQ__Quote__c createAmendmentQuote(Opportunity opportunity, Contract contract){
        return service().createAmendmentQuote(opportunity, contract);
    }


    /**
    * @description
    * @author rishab.goyal | 06-13-2024
    * @param quote
    * @param contract
    * @return Boolean
    **/
    public Boolean insertAmendedQuoteLines(SBQQ__Quote__c quote,  Contract contract) {
        return service().insertAmendedQuoteLines(quote, contract);
    }

    /**
    * @description
    * @author rishab.goyal | 06-13-2024
    **/
    public void prepareMapforCustomAmendmentFields(){
         service().prepareMapforCustomAmendmentFields();
    }
}