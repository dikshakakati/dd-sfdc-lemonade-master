/**
 * @description       : RESSMO Service class
 * @author            : VenkateshDD
 * @group             : RESSMO DDMx - Aethereus
 * @last modified on  : 08-26-2024
 * @last modified by  : Pankaj
**/
@SuppressWarnings('PMD.excessivepubliccount')
public with sharing class RESSMOService {

    /**
    * @description Method to avoid repetitive null checks and get field value from Sobject map
    * @author VenkateshDD | 07-10-2024
    * @param objName
    * @param fieldName
    * @param ddmxObjectToSobject
    * @return Object
    **/
    public static Object getFieldValueFromSobject(String objName, String fieldName, Map<String, sObject> ddmxObjectToSobject){
        return service().getFieldValueFromSobject(objName, fieldName, ddmxObjectToSobject);
    }

    /**
    * @description This will check If the Quote Line Field is Blank or not based on the Mapping Field Name from the Custom Metadata Type
    * @author VenkateshDD | 07-09-2024
    * @param quoteLines
    * @param ressmoMap
    * @return Boolean
    **/
    public static Boolean isQuoteLineFieldBlank(List<SBQQ__QuoteLine__c> quoteLines, RESSMO_Mapping__mdt ressmoMap){
        return service().isQuoteLineFieldBlank(quoteLines, ressmoMap);
    }

    /**
    * @description Check If all the Required Fields based out of metaData in sObject and  Quote Lines
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLines
    **/
    public static void verifyRequiredFields(Map<String,List<String>> objectVsEligibilityMessages, List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines){
        service().verifyRequiredFields(objectVsEligibilityMessages,ressmoMappings, ddmxObjectToSobject, quoteLines);
    }

    /**
    * @description checks and adds If all the Quote Lines are Eligible or  based on the Product Check and If Required quote lines are present
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param quoteLines
    * @param validationMessages
    **/
    public static void verifyQuoteLinesEligibility(Map<String,List<String>> objectVsEligibilityMessages, List<SBQQ__QuoteLine__c> quoteLines, List<String> validationMessages){
        service().verifyQuoteLinesEligibility(objectVsEligibilityMessages, quoteLines, validationMessages);
    }

    /**
    * @description Validates the Eligibility Rules of the Business Account
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param bizAcc
    **/
    public static void businessAccountValidations(Map<String,List<String>> objectVsEligibilityMessages,SObject bizAcc){
        service().businessAccountValidations(objectVsEligibilityMessages,bizAcc);
    }


    /**
    * @description Returns All the quote Level Eligibility Failures for RESSMO
    * @author VenkateshDD | 07-09-2024
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLines
    * @return Map<String,List<String>>
    **/
    public static Map<String,List<String>> quoteEligibilityMessagesForRESSMO(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines){
        return service().quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLines);
    }

    /**
    * @description Store Account Level Eligibility Rules
    * @author VenkateshDD | 07-09-2024
    * @param ddmxObjectToSobject
    * @return Map<String,List<String>>
    **/
    public static Map<String,List<String>> storeEligibilityMessagesForRESSMO(Map<String, sObject> ddmxObjectToSobject){
        return service().storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
    }

    /**
     * @description : Prepares the request JSON for a given quote and list of RESSMO mappings.
     *
     * @param quoteId The ID of the quote.
     * @param ressmoMappings The list of RESSMO mappings.
     * @param isValidateOnly A boolean flag to indicate if the JSON is for validation only.
     * @return The prepared request JSON.
     */
    public static String prepareRequestJSON(Id quoteId, List<RESSMO_Mapping__mdt> ressmoMappings, Boolean isValidateOnly){
        return service().prepareRequestJSON(quoteId, ressmoMappings, isValidateOnly);
    }

    /**
    * @description Based on the country it will check the mandatory banking information exists or not
    * @author VenkateshDD | 07-09-2024
    * @param ddmxObjectToSobject
    * @return Boolean
    **/
    public static Boolean bankingInfoExists(Map<String, sObject> ddmxObjectToSobject){
        return service().bankingInfoExists(ddmxObjectToSobject);
    }

    /**
     * @description : Returns a map of SObject names as keys and sets of field names as values.
     *
     * @param ressmoMappings A list of RESSMO_Mapping__mdt records used to generate the map.
     * @return A map where each key represents an SObject name and the corresponding value is a set of field names.
     */
    public static Map<String, Set<String>> getMapOfSobjectAndSetOfField(List<RESSMO_Mapping__mdt> ressmoMappings){
        return service().getMapOfSobjectAndSetOfField(ressmoMappings);
    }

    /**
     * @description : Retrieves a quote record with quote lines and specified fields from metadata.
     *
     * @param sobjectToSetOfField A map containing the object name as the key and a set of field names as the value.
     * @param quoteId The ID of the quote record to retrieve.
     * @return The quote record with quote lines and specified fields.
     */
    public static SBQQ__Quote__c getQuoteWithQuoteLinesWithFieldsFromMetaData(Map<String, Set<String>> sobjectToSetOfField, Id quoteId){
        return service().getQuoteWithQuoteLinesWithFieldsFromMetaData(sobjectToSetOfField, quoteId);
    }

    /**
     * @description : Retrieves an Account record with cross-references to Decision Maker and Payment Account.
     *
     * @param sobjectToSetOfField A map containing the object name as the key and a set of field names as the value.
     * @param accountId The ID of the Account record to retrieve.
     * @return The Account record with cross-references to Decision Maker and Payment Account.
     */
    public static Account getAccountWithXrefsDecisionMakerPaymentAccount(Map<String, Set<String>> sobjectToSetOfField, Id accountId){
        return service().getAccountWithXrefsDecisionMakerPaymentAccount(sobjectToSetOfField, accountId);
    }

    /**
     * @description : Retrieves the quote fields from the given mapping of sObjects to sets of fields.
     *
     * @param sobjectToSetOfField A map containing the mapping of sObjects to sets of fields.
     * @return A map containing the quote fields for each sObject in the given mapping.
     */
    public static Map<String, Set<String>> getQuoteFieldsFromMapping(Map<String, Set<String>> sobjectToSetOfField){
        return service().getQuoteFieldsFromMapping(sobjectToSetOfField);
    }

    /**
     * @description : Retrieves all accounts and their related object fields based on the provided map of sObjects and fields.
     *
     * @param sobjectToSetOfField A map containing sObjects as keys and a set of fields as values.
     * @return A map containing account names as keys and a set of related object fields as values.
     */
    public static Map<String, Set<String>> getAllAccountsandRelatedObjectFields(Map<String, Set<String>> sobjectToSetOfField){
        return service().getAllAccountsandRelatedObjectFields(sobjectToSetOfField);
    }

    /**
     * @description : Generates a JSON string based on the provided quote, store account, and ressmo mappings.
     *
     * @param quote The SBQQ__Quote__c object representing the quote.
     * @param storeAccount The Account object representing the store account.
     * @param ressmoMappings A list of RESSMO_Mapping__mdt objects representing the ressmo mappings.
     * @param isValidateOnly A boolean flag to indicate if the JSON is for validation only.
     * @return A JSON string generated based on the provided inputs.
     */
    public static String generateJSON(SBQQ__Quote__c quote, Account storeAccount, List<RESSMO_Mapping__mdt> ressmoMappings, Boolean isValidateOnly){
        return service().generateJSON(quote, storeAccount, ressmoMappings, isValidateOnly);
    }

    /**
     * @description : Populates the given map with related objects to the quote and sObjects related to the quote.
     *
     * @param ddmxObjectToSobject - The map to populate with related objects.
     * @param quoteLineItems - The list of quote line items.
     * @param quote - The quote object.
     */
    public static void populateQuoteAndSobjectsRelatedToQuote(Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLineItems, SBQQ__Quote__c quote){
        service().populateQuoteAndSobjectsRelatedToQuote(ddmxObjectToSobject, quoteLineItems, quote);
    }

    /**
     * @description : Populates the given map with related sObjects for a store account.
     *
     * @param ddmxObjectToSobject The map to populate with related sObjects.
     * @param storeAccount The store account for which to retrieve related sObjects.
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void populateStoreAccountSobjectsRelatedToStore(Map<String, sObject> ddmxObjectToSobject, Account storeAccount){
        service().populateStoreAccountSobjectsRelatedToStore(ddmxObjectToSobject, storeAccount);
    }

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
     * @param isValidateOnly A boolean flag to indicate if the JSON is for validation only.
     * @return The generated JSON string.
     */
    public static String writeJSON(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines, Boolean isValidateOnly){
        return service().writeJSON(ressmoMappings, ddmxObjectToSobject, quoteLines,isValidateOnly);
    }

    /**
    * @description SSMO API Call
    * @param requestBody
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    public static SSMOWrapper.ResultMessageWrapper ssmoAPICall(String requestBody){
        return service().ssmoAPICall(requestBody);
    }

    /**
     * @description  Calling SSMO API Call from sendQuote
     * @param quoteId
     * @param ressmoLink
     * @param isValidateOnly
     * @return SSMOWrapper.ResultMessageWrapper
     **/
    public static SSMOWrapper.ResultMessageWrapper sendQuote(Id quoteId, String ressmoLink, Boolean isValidateOnly){
        return service().sendQuote(quoteId,ressmoLink,isValidateOnly);
    }

    /**
    * @description
    * @author Soumya Dash | 07-09-2024
    * @param quoteId
    * @return Map<String, List<String>>
    **/
    public static Map<String,List<String>> getEligibilityMessagesForQuote(Id quoteId){
        return service().getEligibilityMessagesForQuote(quoteId);
    }


     /**
     * @description records along with their related quote line items, with specific fields included based on metadata provided as input.
     * @author Pankaj | 07-10-2024
     * @param quoteIds
     * @param sobjectToSetOfField
     * @return List<SBQQ__Quote__c>
     **/
    public static List<SBQQ__Quote__c> getQuotesAndQuoteLinesWithFieldsFromMetaData(
        set<Id> quoteIds,
        Map<String, Set<String>> sobjectToSetOfField
    ) {
        return service().getQuotesAndQuoteLinesWithFieldsFromMetaData(quoteIds, sobjectToSetOfField);
    }

    /**
    * @description updating Unique Identifier Field On Sobjects after send to ssmo API call success.
    * @author Pankaj | 07-16-2024
    * @param quoteId
    * @param result
    **/
    public static void updateRESSMOSobjectRecords(Id quoteId , SSMOWrapper.ResultMessageWrapper result){
        service().updateRESSMOSobjectRecords(quoteId, result);
    }

    /**
     * @description Updates SSMO validations for a record of a specific sObject type.
     * @param recordId
     * @param messages
     * @param sObjectTypeName
     * @return SSMO validations.
     */
    public static String updateSSMOValidations(Id recordId , List<String> messages , String sObjectTypeName){
        Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(sObjectTypeName);
        return service().updateSSMOValidations(recordId, messages, sObjectType);
    }
    /**
    * @description getting contract and related subscrtion product
    * @JIRA# LEM-17378
    * @param contractId
    * @return Contract
    **/
    public static Contract getContractsWithSubscriptionsProducts(Id contractId){
        return service().getContractsWithSubscriptionsProducts(contractId);
    }


    /**
    * @description Validating Contract and related subscription and product
    * @author Pankaj | 08-22-2024
    * @param contract
    * @param storeAccount
    * @param contractSignatory
    * @param quote
    * @return Map<string, List<String>>
    **/
    public static Map<string,List<String>> getEligibilityMessagesForContract(Contract contract, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote) {
        return service().getEligibilityMessagesForContract(contract,storeAccount,contractSignatory,quote);
    }

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
    public static SSMOWrapper.ResultMessageWrapper sendNewStore(Id contractId, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote, Boolean isValidateOnly){
        return service().sendNewStore(contractId, storeAccount, contractSignatory, quote, isValidateOnly);
    }

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
    public static String generateRESSMOPayloadForNewStore(Id contractId, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote, Boolean isValidateOnly){
        return service().generateRESSMOPayloadForNewStore(contractId, storeAccount, contractSignatory, quote, isValidateOnly);
    }

    /**
     * @description : Returns an instance of the IRESSMOService interface.
     *
     * @return An instance of the IRESSMOService interface.
     */
    private static IRESSMOService service() {
        return (IRESSMOService) Application.Service.newInstance(IRESSMOService.class);
    }

    /**
    * @description SSMO API Call
    * @param requestBody
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    public static SSMOWrapper.ResultMessageWrapper ssmoManageRESSMOLinkAPICall(String requestBody){
        return service().ssmoManageRESSMOLinkAPICall(requestBody);
    }
}