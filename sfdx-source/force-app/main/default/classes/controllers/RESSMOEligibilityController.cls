/**
 * @description       : displayRESSMOEligibility LWC Controller
 * @author            : VenkateshDD
 * @group             : DDMx RESSMO - Aethereus
 * @last modified on  : 11-07-2024
 * @last modified by  : Pankaj
**/
@SuppressWarnings('PMD.excessivepubliccount')
public with sharing class RESSMOEligibilityController {
    static final Id  STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
    private static final Set<String> QUOTE_ELIGIBILITY_MESSAGE_OF_OBJECT = new Set<String>{
        'SBQQ__Quote__c SalesRep',
        'SBQQ__Quote__c',
        'SBQQ__QuoteLine__c'
    };
    private static final Set<String> CONTRACT_ELIGIBILITY_MESSAGE_OF_OBJECT = new Set<String>{
        'Account (Business Account)',
        'Contract',
        'SBQQ__Subscription__c'
    };

    private static final String GENERIC_LOG_DOMAIN = 'SSMO';
    private static final String LOG_SERVICE_NAME_SERVICE_NAME_QUOTE = 'RESSMO Validate Only Message Quote';
    private static final String LOG_SERVICE_NAME_SERVICE_NAME_CONTRACT = 'RESSMO Validate Only Message Contract';
    private static final String QUOTE_STATUS_CONTRACT_SIGNED = 'Contract Signed';
    private static final String LOG_SERVICE_NAME_RESSMO_BACKEND_VALIDATION_CALL_ERROR = 'RESSMO Backend Validation Call Error';
    private static final String LOG_SERVICE_NAME_RESSMO_VALIDATE_CONTRACT='RESSMO Validate Contract';
    private static final String LOG_SERVICE_NAME_RESSMO_LINKED_STORE_TO_QUOTE='RESSMO Linked Store to Quote';
    private static final String LOG_SERVICE_NAME_RESSMO_LINKED_STORE_TO_CONTRACT='RESSMO Linked Store to Contract';
    private static final String LOG_RESSMO_CATEGORY = '';
    private static final String LOG_RESSMO_LOG_LEVEL_ERROR = 'ERROR';
    private static final String LOG_RESSMO_LOG_LEVEL_INFO = 'INFO';
    private static final String RESSMO_STORE_ACCOUNT_ID_LINKED_CONTRACT ='RESSMO - Store Account Id {storeAccRecId} linked to Contract Id {contractRecId}';
    private static final String RESSMO_STORE_ACCOUNT_ID_LINKED_QUOTE ='RESSMO - Store Account Id {storeAccRecId} linked to Quote Id {quoteRecId}';
    private static final String RESSMO_VALIDATION_MESSAGES_QUOTE = 'Validation Messages from RESSMO for Quote Id {quoteRecId}';
    private static final String RESSMO_VALIDATION_MESSAGES_CONTRACT = 'Validation Messages from RESSMO for Contract Id {contractRecId}';



    /**
     * @description This method gets SSMO validations and updates the quote.
     * @param quoteId The ID of the quote to validate and update.
     * @return A string containing the validation messages.
     */
    public static String getSSMOValidationsAndUpdate(Id quoteId){

        try{
            SSMOWrapper.ResultMessageWrapper result  = RESSMOService.sendQuote(quoteId,'',true);
            if(!result.messages.isEmpty()){
                String messages = RESSMOService.updateSSMOValidations(quoteId, result.messages, 'SBQQ__Quote__c');
                String logMessage = RESSMO_VALIDATION_MESSAGES_QUOTE.replace('{quoteRecId}', quoteId);
                GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_SERVICE_NAME_QUOTE,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                    .logMessage(logMessage).logSFRecordId(new Set<String>{quoteId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                );
                return messages;
            }else{
                 return '';
            }

        }
        catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_BACKEND_VALIDATION_CALL_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{quoteId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description This method check for First load of record.
     * @param record
     * @return .
     */
   public static Boolean isFirstLoad(SObject record) {
        String ssmoValidationField = (String) record.get('SSMO_Validation__c');
        Id storeAccountId = (Id) record.get('RESSMO_Store_Account_Id__c');
        if ((ssmoValidationField == null || ssmoValidationField == '') && storeAccountId != null) {
            return true;
        }
        return false;
    }
    /**
    * @description AuraEnabled Controller which returns the wrapper used in the component
    * @author VenkateshDD | 07-10-2024
    * @param quoteId
    * @param isRefresh
    * @return RESSMOEligibilityWrapper
    **/
    @AuraEnabled
    public static RESSMOEligibilityWrapper quoteEligibilityForRESSMO(Id quoteId,Boolean isRefresh){
        if(quoteId == null){
            return null;
        }

        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectAllRessmoMappings();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);

        SBQQ__Quote__c quote = RESSMOService.getQuoteWithQuoteLinesWithFieldsFromMetaData(sobjectToSetOfField, quoteId);
        RESSMO_Configuration__mdt ressmoEligibilityConfiguration = RessmoConfigurationsSelector.newInstance().selectRessmoEligibilityConfiguration();

        if(quote.RESSMO_Store_Account_Id__c != null && ressmoEligibilityConfiguration.Enable_Backend_Eligibility__c  && String.isBlank(quote.SBQQ__Opportunity2__r.RESSMO_Link__c) && quote.SBQQ__Status__c != QUOTE_STATUS_CONTRACT_SIGNED && (isFirstload(quote) || isRefresh)){
           quote.SSMO_Validation__c = getSSMOValidationsAndUpdate(quoteId);
        }

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        RESSMOService.populateQuoteAndSobjectsRelatedToQuote(
            ddmxObjectToSobject,
            quoteLineItems,
            quote
        );
        if(quote.RESSMO_Store_Account_Id__c != null){
            Account storeAccount = RESSMOService.getAccountWithXrefsDecisionMakerPaymentAccount(sobjectToSetOfField, quote.RESSMO_Store_Account_Id__c);
            RESSMOService.populateStoreAccountSobjectsRelatedToStore(ddmxObjectToSobject, storeAccount);
        }
        return quoteEligibilityForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLineItems);

    }

    /**
    * @description Helper method for the AuraEnabled method
    * @author VenkateshDD | 07-10-2024
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLineItems
    * @return RESSMOEligibilityWrapper
    **/
    public static RESSMOEligibilityWrapper quoteEligibilityForRESSMO(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLineItems){
        RESSMOEligibilityWrapper result = new RESSMOEligibilityWrapper();
        result.eligibilityMessages = new list<String>();
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();

        objectVsEligibilityMessages = RESSMOService.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLineItems);
        Map<String,List<String>> storeObjectVsEligibilityMessages = RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
        for(String objName:  storeObjectVsEligibilityMessages.keySet()){
            if (!objectVsEligibilityMessages.containsKey(objName)) {
                objectVsEligibilityMessages.put(objName, new List<String>());
            }
            objectVsEligibilityMessages.get(objName).addAll(storeObjectVsEligibilityMessages.get(objName));
        }
        for(String objectName: objectVsEligibilityMessages.keySet()){
            if (!QUOTE_ELIGIBILITY_MESSAGE_OF_OBJECT.contains(objectName)) {
                continue;
            }
            if(result.eligibilityMessages == null) {
                result.eligibilityMessages = new List<String>();
            }
            result.eligibilityMessages.addAll(objectVsEligibilityMessages.get(objectName));
        }

        result.isPrimaryQuote = (Boolean)RESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SBQQ__Primary__c', ddmxObjectToSobject);
        result.status = (String)RESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SBQQ__Status__c', ddmxObjectToSobject);
        result.ressmoLink = (String)RESSMOService.getFieldValueFromSobject('Opportunity', 'RESSMO_Link__c', ddmxObjectToSobject);
        result.oppStageName = (String)RESSMOService.getFieldValueFromSobject('Opportunity', 'StageName', ddmxObjectToSobject);
        result.expirationDate = (Date)RESSMOService.getFieldValueFromSobject('SBQQ__Quote__c', 'SSMO_Expiration_Date__c', ddmxObjectToSobject);
        result.bankingInfo = ddmxObjectToSobject.get('Account (Store Account)') == null ? null : RESSMOService.bankingInfoExists(ddmxObjectToSobject) ;
        result.storeAccountName = (String)RESSMOService.getFieldValueFromSobject('Account (Store Account)', 'Name', ddmxObjectToSobject);
        result.storeAccount = ddmxObjectToSobject.get('Account (Store Account)');
        result.quote = ddmxObjectToSobject.get('SBQQ__Quote__c');
        result.storeRecordTypeId = STORE_RECORD_TYPE_ID;
        return result;
    }

    /**
     * @description This is the RESSMOEligibilityController class.
     * It is an Apex controller class that is used to handle the eligibility messages for a specific functionality.
     * The eligibilityMessages property is an AuraEnabled public property of type List<String> that stores the eligibility messages.
     */
    public class RESSMOEligibilityWrapper{
        /**
         * @description This is the eligibilityMessages property.
         * It stores the eligibility messages for the RESSMO eligibility check.
         */
        @AuraEnabled public List<String> eligibilityMessages{get; set;}
        /**
         * @description This is the status property.
         */
        @AuraEnabled public String status{get; set;}
        /**
         * @description This is the isPrimaryQuote property.
         */
        @AuraEnabled public Boolean isPrimaryQuote{get; set;}
        /**
         * @description This is the ressmoLink property.
         */
        @AuraEnabled public String ressmoLink{get; set;}
        /**
         * @description This is the oppStageName property.
         */
        @AuraEnabled public String oppStageName{get; set;}
        /**
         * @description This is the expirationDate property.
         */
        @AuraEnabled public Date expirationDate{get; set;}
        /**
         * @description This is the bankingInfo property.
         */
        @AuraEnabled public Boolean bankingInfo{get; set;}
        /**
         * @description refresh the UI when contract eligible is updated.
         */
        @AuraEnabled public boolean refreshUI = false;
        /**
         * @description This is the quoteId property.
         */
        public Id quoteId{get; set;}
        /**
         * @description This is the ddmxObjectToSobjectAndLines property.
         */
        public map<String,sObject> ddmxObjectToSobjectAndLines {get; set;}
        /**
         * @description This is the bankingIquoteLineItems property.
         */
        public List<SBQQ__QuoteLine__c> quoteLineItems {get; set;}
         /**
         * @description This is the contract property.
         */
        @AuraEnabled public sObject contract{get; set;}
        /**
         * @description This is the storeAccountName property.
         */
        @AuraEnabled public String storeAccountName{get; set;}
        /**
         * @description This is the storeAccount property.
         */
        @AuraEnabled public sObject storeAccount{get; set;}
         /**
         * @description This is the quote property.
         */
        @AuraEnabled public sObject quote{get; set;}
        /**
        * @description store record type id
        */
        @AuraEnabled
        public String storeRecordTypeId {get; set;}
    }

    /**
    * @description Validating quotes eligibility if there are no errors on the quote returning those quote id.
    * @author Pankaj | 07-10-2024
    * @param listQuotes
    * @return Set<Id>
    **/
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static Set<Id> quotesEligibilityForRESSMO(List<SBQQ__Quote__c> listQuotes){
        Set<Id> quoteIds = new Set<Id>();
        if(listQuotes == null || listQuotes.isEmpty()){
            return quoteIds;
        }
        Set<Id> eligibleQuoteIds = new Set<Id>();
        Map<Id,SBQQ__Quote__c> quoteById = new Map<Id,SBQQ__Quote__c>();
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();

        List<RESSMOEligibilityWrapper> listOfRESSMOEligibilityWrapper = new List<RESSMOEligibilityWrapper>();
        for(SBQQ__Quote__c quote:  listQuotes){
            if(String.isNotBlank(quote.Id)){
                quoteIds.add(quote.Id);
                quoteById.put(quote.Id, quote);
            }
        }
        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectAllRessmoMappings();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);
        List<SBQQ__Quote__c> quotes = RESSMOService.getQuotesAndQuoteLinesWithFieldsFromMetaData(quoteIds,sobjectToSetOfField);
        listOfRESSMOEligibilityWrapper = populateQuoteIdVsQuoteAndSObjectsRelatedToQuote(quotes,quoteById);

        for(RESSMOEligibilityWrapper wrp: listOfRESSMOEligibilityWrapper){
            RESSMOEligibilityWrapper results = new RESSMOEligibilityWrapper();
            objectVsEligibilityMessages = RESSMOService.quoteEligibilityMessagesForRESSMO(ressmoMappings, wrp.ddmxObjectToSobjectAndLines, wrp.quoteLineItems);
            for(String objectName: objectVsEligibilityMessages.keySet()){
                if (!QUOTE_ELIGIBILITY_MESSAGE_OF_OBJECT.contains(objectName)) {
                    continue;
                }
                if(results.eligibilityMessages == null) {
                    results.eligibilityMessages = new List<String>();
                }
                results.eligibilityMessages.addAll(objectVsEligibilityMessages.get(objectName));
            }
            if(results.eligibilityMessages == null || results.eligibilityMessages.isEmpty()){
                eligibleQuoteIds.add(wrp.quoteId);
            }
        }
        return eligibleQuoteIds;
    }


    /**
    * @description This Apex method iterates over a list of SBQQ__Quote__c records (referred to as listQuote) and wraps each quote record along with its related data into a RESSMOEligibilityWrapper object.
    * The method performs the following steps for each quote in the list:
    * @author Pankaj | 07-10-2024
    * @param quotes
    * @param quoteById
    * @return List<RESSMOEligibilityWrapper>
    **/
    public static List<RESSMOEligibilityWrapper> populateQuoteIdVsQuoteAndSObjectsRelatedToQuote(List<SBQQ__Quote__c> quotes,Map<Id,SBQQ__Quote__c> quoteById){
	    List<RESSMOEligibilityWrapper> wrappers = new List<RESSMOEligibilityWrapper>();
        for (SBQQ__Quote__c quote : quotes) {
            RESSMOEligibilityWrapper wrapper = new RESSMOEligibilityWrapper();
            wrapper.quoteId = quote.Id;
            wrapper.ddmxObjectToSobjectAndLines = new map<String,sObject>();
            wrapper.quoteLineItems = new List<SBQQ__QuoteLine__c>();
            RESSMOService.populateQuoteAndSobjectsRelatedToQuote(wrapper.ddmxObjectToSobjectAndLines, wrapper.quoteLineItems, quote);
            // Directly mutating the SBQQ__Quote__c record in the map with the parameter quote
            wrapper.ddmxObjectToSobjectAndLines.put('SBQQ__Quote__c', quoteById.get(quote.Id));
            wrappers.add(wrapper);
        }
        return wrappers;
    }

    /**
    * @description Validates the SSMO for a given contract and returns the validation messages.
    * @param contractId
    * @param objectWrapper
    * @return
    **/
    public static String getSSMOValidationForContract(Id contractId, SendSSMOQuickActionController.RESSMOUIObjectWrapper objectWrapper){
        try{
            SSMOWrapper.ResultMessageWrapper result  = RESSMOService.sendNewStore(contractId, objectWrapper.storeAccount, objectWrapper.contact, objectWrapper.quote,true);
            if(!result.messages.isEmpty()){
                String messages = RESSMOService.updateSSMOValidations(contractId, result.messages, 'Contract');
                String contractValidationLogMessage = RESSMO_VALIDATION_MESSAGES_CONTRACT.replace('{contractRecId}', contractId);
                GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_SERVICE_NAME_CONTRACT,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                    .logMessage(contractValidationLogMessage).logSFRecordId(new Set<String>{contractId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                );
                return messages;
            }else{
                 return '';
            }

        }
        catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_VALIDATE_CONTRACT, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{contractId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @description  Verify the eligibility of the contract for ressmo.
    * @param contractId
    * @param isRefresh
    * @return RESSMOEligibilityWrapper
    **/
    @AuraEnabled
    public static RESSMOEligibilityWrapper contractEligibilityForRESSMO(Id contractId, Boolean isRefresh){
        RESSMOEligibilityWrapper result = new RESSMOEligibilityWrapper();
        result.eligibilityMessages = new List<String>();
        result.storeRecordTypeId = STORE_RECORD_TYPE_ID;
        Map<String, List<String>> objectVsEligibilityMessages = new Map<String, List<String>>();
        if(contractId == null){
            return result;
        }
        Contract contract = RESSMOService.getContractsWithSubscriptionsProducts(contractId);
        if(contract.Mx_Onboarding_Links__r.size() > 0 ){
            result.ressmoLink = contract.Mx_Onboarding_Links__r[0].One_Time_Mx_Link__c;
        }
        result.contract = contract;
        result = contractSSMOEligibility(contract, isRefresh, result, contractId);
        objectVsEligibilityMessages = RESSMOService.getEligibilityMessagesForContract(contract,null,null,null);

        for(String objectName: objectVsEligibilityMessages.keySet()){
            if (!CONTRACT_ELIGIBILITY_MESSAGE_OF_OBJECT.contains(objectName)) {
                continue;
            }
            if(result.eligibilityMessages == null) {
                result.eligibilityMessages = new List<String>();
            }
            result.eligibilityMessages.addAll(objectVsEligibilityMessages.get(objectName));
        }
        result = changeContractEligibility(result,contract);
        return result;
    }

    private static RESSMOEligibilityWrapper changeContractEligibility(RESSMOEligibilityWrapper result,Contract contract){
        if(result.eligibilityMessages.size() == 0 && contract.RESSMO_Eligible__c == false){
            contract.RESSMO_Eligible__c = true;
            result.refreshUI = updateContractEligibility(contract);
        }
        else if(result.eligibilityMessages.size() > 0 && contract.RESSMO_Eligible__c == true){
            contract.RESSMO_Eligible__c = false;
            result.refreshUI = updateContractEligibility(contract);
        }
        return result;
    }

    private static RESSMOEligibilityWrapper contractSSMOEligibility(Contract contract, Boolean isRefresh, RESSMOEligibilityWrapper result, Id contractId){
        List<RESSMO_UI_Input__mdt> uiInputs = RESSMOUIInputsSelector.newInstance().selectRessmoUiInputsOfContract();
        SendSSMOQuickActionController.RESSMOUIObjectWrapper objectWrapper = SendSSMOQuickActionController.initializefromContract(contractId,uiInputs);
        result.storeAccount =  objectWrapper.storeAccount;
        RESSMO_Configuration__mdt ressmoEligibilityConfiguration = RessmoConfigurationsSelector.newInstance().selectRessmoEligibilityConfiguration();
        if(contract.RESSMO_Store_Account_Id__c != null && ressmoEligibilityConfiguration.Enable_Backend_Eligibility__c && contract.Mx_Onboarding_Links__r.isEmpty() && (isFirstload(contract) || isRefresh)){
           contract.SSMO_Validation__c = getSSMOValidationForContract(contractId,objectWrapper);
           result.contract = contract;
        }
       return result;

    }
    /**
    * @description  - update contract ressmo eligibility and return true (Refresh UI)
    * @author Soumya Dash | 08-14-2024
    * @param contract
    * @return boolean
    **/
    private static boolean updateContractEligibility(Contract contract){
        fflib_ISObjectUnitOfWork uow = APPLICATION.UNITOFWORK.newInstance();
        uow.registerDirty(contract);
        uow.commitWork();
        return true;
    }

      /**
     * @description Retrieves the store account based on the provided store ID.
     * @param recordId The ID of the store to retrieve.
     * @param ressmoStoreId The ID of the store to retrieve.
     * @param calledFromContract The ID of the store to retrieve.
     * @return A ChangeStoreWrapper containing the store account information.
     */
    @AuraEnabled
    public static ChangeStoreWrapper updateRecordWithNewStoreId(Id recordId, Id ressmoStoreId, Boolean calledFromContract){
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        SObject sObjectToUpdate;
        if (calledFromContract) {
            sObjectToUpdate = new Contract(Id = recordId);
        } else {
            sObjectToUpdate = new SBQQ__Quote__c(Id = recordId);
        }
        sObjectToUpdate.put('RESSMO_Store_Account_Id__c', ressmoStoreId);
        uow.registerDirty(sObjectToUpdate);
        uow.commitWork();
        storeAccountLinkedLogCreation(sObjectToUpdate, recordId, ressmoStoreId);
        return getStoreAccount(ressmoStoreId);
    }

    /**
    * @description - store account linked to contract or quote based log creating
    * @param sObjectToUpdate
    * @param recordId
    * @param ressmoStoreId
    **/
    public static void storeAccountLinkedLogCreation(SObject sObjectToUpdate, Id recordId, Id ressmoStoreId) {
        if (sObjectToUpdate instanceof Contract) {
            String contractLinkLogMessage = RESSMO_STORE_ACCOUNT_ID_LINKED_CONTRACT;
            if (ressmoStoreId != null && recordId != null) {
                contractLinkLogMessage = RESSMO_STORE_ACCOUNT_ID_LINKED_CONTRACT.replace('{storeAccRecId}', ressmoStoreId).replace('{contractRecId}', recordId);
            }
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_LINKED_STORE_TO_CONTRACT, GENERIC_LOG_DOMAIN , GenericLogEntry.SeverityLevel.HIGH)
                .setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO).logMessage(contractLinkLogMessage)
            );
        } else if (sObjectToUpdate instanceof SBQQ__Quote__c) {
            String quoteLinkLogMessage = RESSMO_STORE_ACCOUNT_ID_LINKED_QUOTE;
            if (ressmoStoreId != null && recordId != null) {
                quoteLinkLogMessage = RESSMO_STORE_ACCOUNT_ID_LINKED_QUOTE.replace('{storeAccRecId}', ressmoStoreId).replace('{quoteRecId}', recordId);
            }
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_LINKED_STORE_TO_QUOTE, GENERIC_LOG_DOMAIN , GenericLogEntry.SeverityLevel.HIGH)
                .setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO).logMessage(quoteLinkLogMessage)
            );
        }
    }


    /**
     * @description Retrieves the store account based on the provided store ID.
     * @param storeId The ID of the store to retrieve.
     * @return A ChangeStoreWrapper containing the store account information.
     */
    public static ChangeStoreWrapper getStoreAccount(Id storeId){
        ChangeStoreWrapper result = new ChangeStoreWrapper();
        Set<Id> storeIds = new Set<Id>{storeId};
        List<Account> storeAccounts = AccountsSelector.newInstance().getStoreAccounts(storeIds);
        result.storeRecordTypeId = STORE_RECORD_TYPE_ID;
        if(!storeAccounts.isEmpty())
        {
            result.storeAccount = storeAccounts[0];
            return result;
        }else{
            return null;
        }

    }
    /**
     * @description Calls the SSMO validation and update method for the given record ID.
     * @param businessAccountId The ID of the record to validate and update.
     * @return A ChangeStoreWrapper containing the store account information.
     */
    @AuraEnabled
    public static ChangeStoreWrapper getStoresToPrepopulate(Id businessAccountId){
        ChangeStoreWrapper result = new ChangeStoreWrapper();
        List<Account> storeAccountDetails = AccountsSelector.newInstance().getStoreAccountbyBusinessAccountId(businessAccountId);
        result.storeRecordTypeId = STORE_RECORD_TYPE_ID;
        if(!storeAccountDetails.isEmpty())
        {
            result.storeAccount = storeAccountDetails[0];
        }else{
            result.storeAccount = null;
        }
        return result;
    }
    /**
     * @description Wrapper class for storing account information and record type ID.
     */
    public class ChangeStoreWrapper{

        /**
         * @description The store account information.
         */
        @AuraEnabled public sObject storeAccount {get; set;}

        /**
         * @description The record type ID of the store.
         */
        @AuraEnabled public String storeRecordTypeId {get; set;}
    }

}