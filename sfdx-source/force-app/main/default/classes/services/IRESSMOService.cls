/**
 * @description       : IRESSMOService Interface for RESSMOService
 * @author            : VenkateshDD
 * @group             : RESSMO DDMx - Aethereus
 * @last modified on  : 08-26-2024
 * @last modified by  : Pankaj
**/
public interface IRESSMOService {
    /**
    * @description Method to avoid repetitive null checks and get field value from Sobject map
    * @author VenkateshDD | 07-10-2024
    * @param objName
    * @param fieldName
    * @param ddmxObjectToSobject
    * @return Object
    **/
    Object getFieldValueFromSobject(String objName, String fieldName, Map<String, sObject> ddmxObjectToSobject);

    /**
    * @description This will check If the Quote Line Field is Blank or not based on the Mapping Field Name from the Custom Metadata Type
    * @author VenkateshDD | 07-09-2024
    * @param quoteLines
    * @param ressmoMap
    * @return Boolean
    **/
    Boolean isQuoteLineFieldBlank(List<SBQQ__QuoteLine__c> quoteLines, RESSMO_Mapping__mdt ressmoMap);

    /**
    * @description Check If all the Required Fields based out of metaData in sObject and  Quote Lines
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLines
    **/
    void verifyRequiredFields(Map<String,List<String>> objectVsEligibilityMessages,List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines);

    /**
    * @description checks and adds If all the Quote Lines are Eligible or  based on the Product Check and If Required quote lines are present
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param quoteLines
    * @param validationMessages
    **/
    void verifyQuoteLinesEligibility(Map<String,List<String>> objectVsEligibilityMessages, List<SBQQ__QuoteLine__c> quoteLines, List<String> validationMessages);

    /**
    * @description Validates the Eligibility Rules of the Business Account
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param bizAcc
    **/
    void businessAccountValidations(Map<String,List<String>> objectVsEligibilityMessages, SObject bizAcc);

    /**
    * @description Returns All the quote Level Eligibility Failures for RESSMO
    * @author VenkateshDD | 07-09-2024
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLines
    * @return Map<String,List<String>>
    **/
    Map<String,List<String>> quoteEligibilityMessagesForRESSMO(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines);

    /**
    * @description Store Account Level Eligibility Rules
    * @author VenkateshDD | 07-09-2024
    * @param ddmxObjectToSobject
    * @return Map<String,List<String>>
    **/
    Map<String,List<String>> storeEligibilityMessagesForRESSMO(Map<String, sObject> ddmxObjectToSobject);

    /**
    * @description get's eligibility messages for the quote and store together
    * @author
    * @param quoteId
    * @return Map<String,List<String>>
    **/
    Map<String,List<String>> getEligibilityMessagesForQuote(Id quoteId);


    /**
     * @description : Prepares the request JSON for the IRESSMO service.
     * @param quoteId
     * @param ressmoMappings
     * @param isValidateOnly
     * @return String
     */
    String prepareRequestJSON(Id quoteId, List<RESSMO_Mapping__mdt> ressmoMappings, Boolean isValidateOnly);

    /**
    * @description Based on the country it will check the mandatory banking information exists or not
    * @author VenkateshDD | 07-09-2024
    * @param ddmxObjectToSobject
    * @return Boolean
    **/
    Boolean bankingInfoExists(Map<String, sObject> ddmxObjectToSobject);

    /**
     * @description : Returns a map of SObject names as keys and sets of field names as values,
     * based on the provided list of RESSMO_Mapping__mdt records.
     *
     * @param ressmoMappings The list of RESSMO_Mapping__mdt records used to generate the map.
     * @return A map where each key represents an SObject name and the corresponding value is a set of field names.
     */
    Map<String, Set<String>> getMapOfSobjectAndSetOfField(List<RESSMO_Mapping__mdt> ressmoMappings);

    /**
     * @description : Retrieves a quote record along with its quote lines and specified fields from metadata.
     *
     * @param sobjectToSetOfField A map containing the object name as the key and a set of field names as the value.
     * @param quoteId The ID of the quote record to retrieve.
     * @return The quote record with quote lines and specified fields from metadata.
     */
    SBQQ__Quote__c getQuoteWithQuoteLinesWithFieldsFromMetaData(Map<String, Set<String>> sobjectToSetOfField, Id quoteId);

    /**
     * @description : Retrieves an Account record with cross-references to Decision Maker and Payment Account.
     *
     * @param sobjectToSetOfField A map of SObject names to a set of field names to be queried.
     * @param accountId The ID of the Account record to retrieve.
     * @return The Account record with cross-references to Decision Maker and Payment Account.
     */
    Account getAccountWithXrefsDecisionMakerPaymentAccount(Map<String, Set<String>> sobjectToSetOfField, Id accountId);

    /**
     * @description : Retrieves the quote fields from the given mapping of sObjects to sets of fields.
     *
     * @param sobjectToSetOfField A mapping of sObjects to sets of fields.
     * @return A map containing the quote fields from the given mapping.
     */
    Map<String, Set<String>> getQuoteFieldsFromMapping(Map<String, Set<String>> sobjectToSetOfField);

    /**
     * @description : Retrieves all accounts and their related object fields.
     *
     * @param sobjectToSetOfField A map containing the object names as keys and a set of field names as values.
     * @return A map containing the object names as keys and a set of field names as values for all accounts and their related objects.
     */
    Map<String, Set<String>> getAllAccountsandRelatedObjectFields(Map<String, Set<String>> sobjectToSetOfField);

    /**
     * @description : Generates a JSON string based on the provided quote, store account, and ressmo mappings.
     *
     * @param quote The SBQQ__Quote__c object representing the quote.
     * @param storeAccount The Account object representing the store account.
     * @param ressmoMappings The list of RESSMO_Mapping__mdt objects representing the ressmo mappings.
     * @param isValidateOnly A boolean value indicating whether the JSON is generated for validation only.
     * @return A JSON string generated based on the provided inputs.
     */
    String generateJSON(SBQQ__Quote__c quote, Account storeAccount, List<RESSMO_Mapping__mdt> ressmoMappings, Boolean isValidateOnly);

    /**
     * @description : Populates the given map with related objects to the quote and sObjects related to the quote.
     *
     * @param ddmxObjectToSobject - The map to populate with related objects.
     * @param quoteLineItems - The list of quote line items.
     * @param quote - The quote object.
     */
    void populateQuoteAndSobjectsRelatedToQuote(Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLineItems, SBQQ__Quote__c quote);

    /**
     * @description : Populates the given map with related sObjects for a store account.
     *
     * @param ddmxObjectToSobject The map to populate with related sObjects.
     * @param storeAccount The store account for which to retrieve related sObjects.
     */
    void populateStoreAccountSobjectsRelatedToStore(Map<String, sObject> ddmxObjectToSobject, Account storeAccount);

    /**
     * @description : This method generates a JSON string based on the provided parameters.
     * It takes a list of RESSMO_Mapping__mdt records, a map of DDMX object names to sObjects,
     * and a list of SBQQ__QuoteLine__c records as input.
     * The method creates a JSONGenerator object and writes the JSON structure using the provided data.
     * It iterates over the quote lines and their associated product options to generate the JSON structure.
     * The final JSON string is returned as the result.
     *
     * @param ressmoMappings A list of RESSMO_Mapping__mdt records.
     * @param ddmxObjectToSobject A map of DDMX object names to sObjects.
     * @param quoteLines A list of SBQQ__QuoteLine__c records.
     * @param isValidateOnly A boolean value indicating whether the JSON is generated for validation only.
     * @return The generated JSON string.
     */
    String writeJSON(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines, Boolean isValidateOnly);

    /**
     * @description  Calling SSMO API Call from sendQuote
     * @param quoteId
     * @param ressmoLink
     * @param isValidateOnly
     * @return SSMOWrapper.ResultMessageWrapper
     **/
    SSMOWrapper.ResultMessageWrapper sendQuote(Id quoteId, String ressmoLink, Boolean isValidateOnly);

    /**
    * @description SSMO API Call
    * @param requestBody
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    SSMOWrapper.ResultMessageWrapper ssmoAPICall(String requestBody);

    /**
     * @description records along with their related quote line items, with specific fields included based on metadata provided as input.
     * @author Pankaj | 07-10-2024
     * @param quoteIds
     * @param sobjectToSetOfField
     * @return List<SBQQ__Quote__c>
     **/
   List<SBQQ__Quote__c> getQuotesAndQuoteLinesWithFieldsFromMetaData(
        set<Id> quoteIds,
        Map<String, Set<String>> sobjectToSetOfField
    ) ;

    /**
    * @description updating Unique Identifier Field On Sobjects after send to ssmo API call success.
    * @author Pankaj | 07-16-2024
    * @param quoteId
    * @param result
    **/
	void updateRESSMOSobjectRecords(Id quoteId , SSMOWrapper.ResultMessageWrapper result);

    /**
     * @description Update SSMO Validations for a record.
     * @param recordId
     * @param messages
     * @param sObjectType
     * @return
     */
    String updateSSMOValidations(Id recordId ,List<String> messages ,Schema.SObjectType sObjectType);
    /**
    * @description SSMO API Call
    * @param requestBody
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    SSMOWrapper.ResultMessageWrapper ssmoManageRESSMOLinkAPICall(String requestBody);

    /**
    * @description getting contract and related subscrtion product
    * @author Pankaj | 07-17-2024
    * @param contractId
    * @return Contract
    **/
    Contract getContractsWithSubscriptionsProducts(Id contractId);


    /**
    * @description Validating Contract and related subscription and product
    * @author Pankaj | 08-22-2024
    * @param contract
    * @param storeAccount
    * @param contractSignatory
    * @param quote
    * @return Map<string, List<String>>
    **/
    Map<string,List<String>> getEligibilityMessagesForContract(Contract contract, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote);

    /**
    * @description
    * @jira LEM-17697
    * @param contractId
    * @param storeAccount
    * @param contractSignatory
    * @param quote
    * @param isValidateOnly
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    SSMOWrapper.ResultMessageWrapper sendNewStore(Id contractId, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote, Boolean isValidateOnly);

     /**
    * @description
    * @jira LEM-17697
    * @param contractId
    * @param storeAccount
    * @param contractSignatory
    * @param quote
    * @param isValidateOnly
    * @return String
    **/
    String generateRESSMOPayloadForNewStore(Id contractId, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote, Boolean isValidateOnly);

}