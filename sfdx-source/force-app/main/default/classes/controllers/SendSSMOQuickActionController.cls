/**
 * @description       : Controller for sendSSMOQuickAction lwc
 * @author            : Soumya Dash
 * @group             : DDMxRESSMO-Aethereus
 * @last modified on  : 11-18-2024
 * @last modified by  : Soumya Dash
**/
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength, PMD.ExcessiveParameterList')
public with sharing class SendSSMOQuickActionController {
    private static final String GENERIC_LOG_DOMAIN = 'SSMO';
    private static final String LOG_SERVICE_NAME_RESSMO_GENERATED_MX_LINK_QUOTE = 'RESSMO MX link generated for quote';
    private static final String LOG_SERVICE_NAME_RESSMO_GENERATED_MX_LINK_CONTRACT = 'RESSMO MX link generated for Contract';
    private static final String QUOTE_OBJECT = 'SBQQ__Quote__c';
    private static final String CONTRACT_OBJECT = 'Contract';
    private static final String CONTACT_OBJECT = 'Contact';
    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String MX_ONBOARDING_NEW_STORE_EXPANSION = 'NSE';
    private static final String MX_ONBOARDING_SOURCE = 'RESSMO';
    private static final String REP_COLLECTING_ON_MX_BEHALF_YES = 'Yes';
    private static final String MX_LINK_STATUS_ACTIVE = 'Active';
    private static final String MX_LINK_STATUS_INACTIVE = 'Inactive';
    private static final String MX_LINK_INACTIVE_REASON_SUBMITTED = 'Submitted';
    private static final String MX_LINK_INACTIVE_REASON_DEACTIVATED = 'Deactivated';
    private static final String MX_ONBOARDING_SOURCE_ONA = 'OnA';
    private static final String ONE_TIME_MX_LINK_STATIC_CONFIG = 'One_Time_Mx_Link';
    private static final String FORMIDPARAM = '?formId=';
    private static final String DASH_SPLIT = '-';
    private static final String ACCOUNT_CONTACT_ROLE_PHOTOSHOOT = 'Photoshoot Contact';
    private static final String ACTIVATED_CENTERALLY_YES = 'Yes';
    private static final String ACR_CONTRACT_SIGNATORY = 'Contract Signatory';
    private static final String ACR_DECISION_MAKER = 'Decision Maker';
    private static final String ACR_BUSINESS_OWNER = 'Business Owner';
    private static final String ACR_BUSINESS_DIRECTOR = 'Business Director';
    private static final String COUNTRY_CANADA = 'Canada';
    static final Id STORE_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Store').getRecordTypeId();
    static final Id PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE = Schema.SObjectType.Payment_Account__c.getRecordTypeInfosByDeveloperName().get('Payments').getRecordTypeId();
    private static Boolean storeLevelAcrCreated = false;
    private static final String LOG_SERVICE_NAME_RESSMO_GENERATE_MX_LINK_ERROR = 'RESSMO Generate Mx Link Error';
    private static final String LOG_SERVICE_NAME_RESSMO_POP_PULL_DATA_ERROR = 'RESSMO Popup Pull Data Error';
    private static final String LOG_SERVICE_NAME_RESSMO_NNE_CONTRACT_LINK_PROCESSING_ERROR = 'RESSMO NSE Contract Send Link Processing Error';
    private static final String LOG_SERVICE_NAME_RESSMO_NSE_CONTRACT_LINK_ERROR = 'RESSMO NSE Contract Send Link Error';
    private static final String LOG_SERVICE_NAME_RESSMO_NNS_SEND_QUOTE_ERROR = 'RESSMO NNS Send Quote Error';
    private static final String LOG_SERVICE_NAME_RESSMO_GET_STORES_WITH_ACTIVE_XREF_ERROR = 'RESSMO Get Stores With Active Xref Error';
    private static final String LOG_SERVICE_NAME_RESSMO_POPUP_SAVE_RECORDS_ERROR = 'RESSMO Popup Data Save Error';
    private static final String LOG_SERVICE_NAME_RESSMO_POPUP_SAVE_RECORDS_FAILED = 'Failed to Update Record :';
    private static final String LOG_SERVICE_NAME_GET_STORES_DETAILS_BY_STORE_ID = 'RESSMO Get Store Details By Store Id Error';
    private static final String LOG_RESSMO_CATEGORY = '';
    private static final String LOG_RESSMO_LOG_LEVEL_ERROR = 'ERROR';
    private static final String LOG_RESSMO_LOG_LEVEL_INFO = 'INFO';
    private static final String LOG_MESSGE_RESSMO_MX_LINK_GENERATED_QUOTE = 'RESSMO Mx Link Generated for Quote Id ';
    private static final String LOG_MESSGE_RESSMO_MX_LINK_GENERATED_CONTRACT = 'RESSMO Mx Link Generated for Contract Id ';


    /**
    * @description -initialize Lwc component with data to show on UI-
    * @author Soumya Dash | 07-29-2024
    * @param recordId
    * @param openedFrom
    * @return SendToRESSMODataWrapper
    **/
    @AuraEnabled
    public static SendToRESSMODataWrapper initializeSendToSSMO(Id recordId, String openedFrom){
        List<RESSMO_UI_Input__mdt> uiInputs =  new List<RESSMO_UI_Input__mdt>();
        SendToRESSMODataWrapper initializeData = new SendToRESSMODataWrapper();

        try{
            if(openedFrom == CONTRACT_OBJECT){
                Contract contract = contractsSelector.newInstance().selectByIdWithMxActiveOnboarding(recordId);
                if(contract.Mx_Onboarding_Links__r.size() > 0 ){
                    initializeData.hasMxOnboardingLink = contract.Mx_Onboarding_Links__r[0];
                    return initializeData;
                }
                uiInputs = RESSMOUIInputsSelector.newInstance().selectRessmoUiInputsOfContract();
                initializeData.objectWrapper = initializefromContract(recordId,uiInputs);
            }
            else{
                uiInputs = RESSMOUIInputsSelector.newInstance().selectRessmoUiInputsOfQuote();
                initializeData.objectWrapper = initializefromQuote(recordId,uiInputs);
            }
            initializeData.sectiontoInputMetadata = createSectionToInputMetadataMap(uiInputs);
            initializeData.storeRecordTypeId = STORE_RECORD_TYPE_ID;
            return initializeData;
        }
        Catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_POP_PULL_DATA_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{recordId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }

    }

    /**
    * @description - create a map of section(string) to List of fields(RESSMO UI Inputs) metadata Common for botgh contract and quote
    * @author Soumya Dash | 07-30-2024
    * @param uiInputs
    * @return map<String, List<RESSMO_UI_Input__mdt>>
    **/
    private static map<String,List<RESSMO_UI_Input__mdt>> createSectionToInputMetadataMap(List<RESSMO_UI_Input__mdt> uiInputs){
        map<String,List<RESSMO_UI_Input__mdt>> sectiontoInputMetadata = new map<String,List<RESSMO_UI_Input__mdt>>();
        for(RESSMO_UI_Input__mdt input : uiInputs){
            if(sectiontoInputMetadata.containsKey(input.Section__c)){
                sectiontoInputMetadata.get(input.Section__c).add(input);
            }
            else{
                sectiontoInputMetadata.put(input.Section__c,new List<RESSMO_UI_Input__mdt>{input});
            }
        }
        return sectiontoInputMetadata;
    }

    /**
    * @description - intialize data for UI from contract
    * @author Soumya Dash | 08-01-2024
    * @param contractId
    * @param uiInputs
    * @return RESSMOUIObjectWrapper
    **/
    public static  RESSMOUIObjectWrapper initializefromContract(Id contractId,List<RESSMO_UI_Input__mdt> uiInputs){
        RESSMOUIObjectWrapper objectWrapper = new RESSMOUIObjectWrapper();

        Map<String,Set<String>> objectTosObjectField = new Map<String,Set<String>>();
        createObjectToSObjectFields(uiInputs,objectTosObjectField);
        Contract contract = ContractsSelector.newInstance().selectByIdWithRESSMOSourceMxOnboarding(contractId);
        SBQQ__Quote__c quote = new SBQQ__Quote__c(
            Id =  contract.SBQQ__Quote__c
        );

        //building wrapper
        objectWrapper.quote = quote;
        if(contract.Mx_Onboarding_Links__r.size() > 0){
            objectWrapper.mxOnboardingLinkId = contract.Mx_Onboarding_Links__r[0].Id;
            Map<String,Object> objectMap = (Map<String,Object>) JSON.deserializeUntyped(contract.Mx_Onboarding_Links__r[0].Payload__c);
            if(objectMap.containsKey('genericInput')){
            	objectWrapper.genericInput = objectMap.get('genericInput');
            }
        }
        objectWrapper.storeAccount = getStoreDetailsByBussinessIdFromContract(contract.AccountId,objectTosObjectField,contract.RESSMO_Store_Account_id__c);
        if(objectWrapper.storeAccount!=null){
            if(objectWrapper.storeAccount.Account_Payment_Account_Relations__r.size() > 0){
                map<String,sObject> sObjectData = new Map<String,sObject>{
                    'Account (Store Account)' => (sObject)objectWrapper.storeAccount,
                    'Payment_Account__c' => objectWrapper.storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r,
                    'Account (Business Account)' => new Account(Id = contract.AccountId, Legal_Business_Name__c = contract.Account.Legal_Business_Name__c)
                };

                objectWrapper.paymentAccount = objectWrapper.storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r;
                objectWrapper.isBankingInfoPopulated = RESSMOService.bankingInfoExists(sObjectData);
            }
            if(objectWrapper.storeAccount.AccountContactRelations.size() > 0){
                objectWrapper.photoshootContact = objectWrapper.storeAccount.AccountContactRelations[0].Contact;
            }
            contract.RESSMO_Store_Account_id__c =  objectWrapper.storeAccount.Id;
        }
        objectWrapper.contract = contract;

        objectWrapper.contact = getContractSignatoryFromContract(contract.SBQQ__Opportunity__c,objectTosObjectField);
        return objectWrapper;
    }

    /**
    * @description - get contract signatory from opportunity in case of contract
    * @author Soumya Dash | 08-01-2024
    * @param opportunityId
    * @param objectTosObjectField
    * @return Contact
    **/
    private static Contact getContractSignatoryFromContract(Id opportunityId,Map<String,Set<String>> objectTosObjectField){
        Opportunity opportunity = OpportunitiesSelector.newInstance().selectOpportunityContactRoleByOpportunityId(opportunityId,objectTosObjectField);
        if(opportunity.OpportunityContactRoles.size() != 0){
            return opportunity.OpportunityContactRoles[0].Contact;
        }
        return null;
    }

    /**
    * @description  - get store details along with payament account and return the store in case of contract
    * @author Soumya Dash | 08-01-2024
    * @param bussinessAccountId
    * @param objectTosObjectField
    * @param ressmoStoreId
    * @return Account
    **/
    private static Account getStoreDetailsByBussinessIdFromContract(Id bussinessAccountId,Map<String,Set<String>> objectTosObjectField, Id ressmoStoreId){
        Map<Id, Account> storeAccountDetails = new Map<Id,Account>(AccountsSelector.newInstance().selectByBusinessAccountIdAndgetStoreDetails(bussinessAccountId,objectTosObjectField));
        if(storeAccountDetails.values().isEmpty()){
            return null;
        }
        if(ressmoStoreId!=null && storeAccountDetails.containsKey(ressmoStoreId)){
            Account store  = storeAccountDetails.get(ressmoStoreId);
            if(store.Xrefs__r.size() == 0){
                return store;
            }
        }

        for(Account store : storeAccountDetails.values()){
           if(store.Xrefs__r.size() == 0){
                return store;
            }
        }
        return null;
    }



    /**
    * @description - intitialize data for UI From contract
    * @author Soumya Dash | 08-01-2024
    * @param quoteId
    * @param uiInputs
    * @return RESSMOUIObjectWrapper
    **/
    private static RESSMOUIObjectWrapper initializefromQuote(Id quoteId,List<RESSMO_UI_Input__mdt> uiInputs){
        RESSMOUIObjectWrapper objectWrapper = new RESSMOUIObjectWrapper();
        Map<String,Set<String>> objectTosObjectField = new Map<String,Set<String>>();
        createObjectToSObjectFields(uiInputs,objectTosObjectField);
            IQuotesSelector quoteSelector = QuotesSelector.newInstance();
            SBQQ__Quote__c quote = quoteSelector.selectByIdWithBusinessAccount(quoteId,objectTosObjectField);
            if(quote.RESSMO_Payload__c != '' && quote.RESSMO_Payload__c !=null ){
                objectWrapper.genericInput = JSON.deserializeUntyped(quote.RESSMO_Payload__c);
            }
            if(quote.SSMO_Expiration_Date__c == null){
                quote.SSMO_Expiration_Date__c = Date.today().addDays(14);
            }
            if(quote.Opportunity_Contact_Role__r.size() > 0){
                objectWrapper.contact = quote.Opportunity_Contact_Role__r[0].Contact;
            }
            objectWrapper.storeAccount = getStoreDetailsByBussinessId(quote.SBQQ__Account__c,objectTosObjectField,quote.RESSMO_Store_Account_Id__c);

            if(objectWrapper.storeAccount!=null){
                quote.RESSMO_Store_Account_Id__c = objectWrapper.storeAccount.Id;
                if(objectWrapper.storeAccount.Account_Payment_Account_Relations__r.size() > 0){
                    map<String,sObject> sObjectData = new Map<String,sObject>{
                    'Account (Store Account)' => (sObject)objectWrapper.storeAccount,
                    'Payment_Account__c' => objectWrapper.storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r,
                    'Account (Business Account)' => new Account(Id = quote.SBQQ__Account__c, Legal_Business_Name__c = quote.SBQQ__Account__r.Legal_Business_Name__c)
                    };

                    objectWrapper.paymentAccount = objectWrapper.storeAccount.Account_Payment_Account_Relations__r[0].Payment_Account__r;
                    objectWrapper.isBankingInfoPopulated = RESSMOService.bankingInfoExists(sObjectData);
                }
                if(objectWrapper.storeAccount.AccountContactRelations.size() > 0){
                    objectWrapper.photoshootContact = objectWrapper.storeAccount.AccountContactRelations[0].Contact;
                }
            }
            objectWrapper.quote = quote;
            return objectWrapper;
    }

     /**
    * @description - create a map of Object to its fields present on UI
    * @author Soumya Dash | 07-30-2024
    * @param ressmoUIInputs
    * @param sObjectFields
    **/
    private static void createObjectToSObjectFields(List<RESSMO_UI_Input__mdt> ressmoUIInputs, Map<String,Set<String>> sObjectFields){
        for(RESSMO_UI_Input__mdt input : ressmoUIInputs){
            if(sObjectFields.containsKey(input.Object_API_Name__c)){
                if(input.Object_API_Name__c == CONTACT_OBJECT){
                    sObjectFields.get(input.Object_API_Name__c).add(input.Object_API_Name__c + '.' + input.Field_API_name__c);
                }
                else{
                    sObjectFields.get(input.Object_API_Name__c).add(input.Field_API_name__c);
                }
            }
            else{
                if(input.Object_API_Name__c == CONTACT_OBJECT){
                    sObjectFields.put(input.Object_API_Name__c,new Set<String>{input.Object_API_Name__c + '.' +input.Field_API_name__c});
                }
                else{
                    sObjectFields.put(input.Object_API_Name__c,new Set<String>{input.Field_API_name__c});
                }
            }
        }
    }


    /**
    * @description - get store and payment account through business Id
    * @author Soumya Dash | 08-01-2024
    * @param bussinessAccountId
    * @param objectTosObjectField
    * @param ressmoStoreId
    * @return Account
    **/
    private static Account getStoreDetailsByBussinessId(Id bussinessAccountId,Map<String,Set<String>> objectTosObjectField, Id ressmoStoreId){
        Map<Id, Account> storeAccountDetails = new Map<Id,Account>(AccountsSelector.newInstance().selectByBusinessAccountIdAndgetStoreDetails(bussinessAccountId,objectTosObjectField));
        if(storeAccountDetails.values().isEmpty()){
            return null;
        }
        if(ressmoStoreId!=null && storeAccountDetails.containsKey(ressmoStoreId)){
            Account store  = storeAccountDetails.get(ressmoStoreId);
            return store;
        }
        return storeAccountDetails.values()[0];
    }

    /**
    * @description - return store when store change is confirmed in lwc
    * @author Soumya Dash | 07-30-2024
    * @param storeId
    * @param businessId
    * @param uiInputs
    * @return RESSMOUIObjectWrapper
    **/
    @AuraEnabled
    public static RESSMOUIObjectWrapper getStoreDetailsByStoreId(Id storeId,Id businessId, List<RESSMO_UI_Input__mdt> uiInputs){
        try{
            RESSMOUIObjectWrapper objectWrapper = new RESSMOUIObjectWrapper();
            Map<String,Set<String>> sObjectFields = new Map<String,Set<String>>();
            createObjectToSObjectFields(uiInputs, sObjectFields);

            IAccountsSelector accountSelector = AccountsSelector.newInstance();
            List<Account> account = accountSelector.selectByStoreAccountIdAndgetStoreDetails(storeId,businessId,sObjectFields);
            objectWrapper.storeAccount = account[0];
            if(account[0].Account_Payment_Account_Relations__r.size() != 0){
                map<String,sObject> sObjectData = new Map<String,sObject>{
                        'Account (Store Account)' => (sObject)account[0],
                        'Payment_Account__c' => account[0].Account_Payment_Account_Relations__r[0].Payment_Account__r,
                        'Account (Business Account)' => new Account(Id = account[0].Parentid, Legal_Business_Name__c = account[0].Parent.Legal_Business_Name__c)
                };
                objectWrapper.paymentAccount = account[0].Account_Payment_Account_Relations__r[0].Payment_Account__r;
                objectWrapper.isBankingInfoPopulated = RESSMOService.bankingInfoExists(sObjectData);
            }
            if(account[0].AccountContactRelations.size() != 0){
                objectWrapper.photoshootContact = account[0].AccountContactRelations[0].Contact;
            }
            return objectWrapper;
        }
        catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_GET_STORES_DETAILS_BY_STORE_ID, GENERIC_LOG_DOMAIN , GenericLogEntry.SeverityLevel.HIGH)
                .logException(ex).logSFRecordId(new Set<String>{storeId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @description  - get active xref store account ids of a business account
    * @author Soumya Dash | 09-23-2024
    * @param businessId
    * @return List<Id>
    **/
    @AuraEnabled
    public static List<Id> getStoresWithActiveXref(Id businessId){
        Map<String,Set<String>> objectTosOjectFields = new Map<String,Set<String>>{
            'Account' => new Set<String>(),
            'Contact' => new Set<String>()
        };
        Set<Id> storAccountIds =  new Set<Id>();
        try{
            List<Account> accountWithActiveXref = AccountsSelector.newInstance().selectByBusinessAccountIdAndgetStoreDetails(businessId,objectTosOjectFields);
            if(!accountWithActiveXref.isEmpty()){
                for(Account account : accountWithActiveXref){
                    if(account.Xrefs__r.size() > 0){
                        storAccountIds.add(account.Id);
                    }
                }
            }

            return new List<Id>(storAccountIds);
        }
        catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_GET_STORES_WITH_ACTIVE_XREF_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{businessId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @description - update record(Store,Quote,Business Account,COntact) from lwc
    * @author Soumya Dash | 08-02-2024
    * @param sObjectData
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    @AuraEnabled
    public static SendToRESSMODataWrapper updateRecordsFromSSMOUI(RESSMOUIObjectWrapper sObjectData){

        SendToRESSMODataWrapper dataWrapper = new SendToRESSMODataWrapper();
        RESSMOResponseWrapper ressmoResponse = new RESSMOResponseWrapper();
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();
        boolean isPhotoshootCreated = false;
        boolean isPaymentCreated = false;
        Mx_Onboarding_Link__c mxLink = new Mx_Onboarding_Link__c();

        Account storeAccount = (Account) sObjectData.storeAccount;
        Contact contact = (Contact) sObjectData.contact;
        Contract contract = (Contract) sObjectData.contract;
        SBQQ__Quote__c quote = (SBQQ__Quote__c) sObjectData.quote;

        List<String> eligibilityResult = new List<String>();

        fflib_ISObjectUnitOfWork uow = APPLICATION.UNITOFWORK.newInstance();
        uow.registerDirty(sObjectData.storeAccount);
        uow.registerDirty(sObjectData.contact);
        try{
            //payment account
            isPaymentCreated = createPaymentAccountAndPaymentAccountRelation(sObjectData, uow);

            Set<String> acrRoles = populateAcrRoles(sObjectData.storeAccount.BillingCountry );

            //photoshoot details update
            isPhotoshootCreated = handlePhotoshootContact(sObjectData,uow, acrRoles);

            //create new account contact relation for store account
            upsertStoreAccountContactRelation(sObjectData, acrRoles, uow);

            //reset ssmo login
            if(sObjectData.resetSSMOLogin){
                blankRemainingRESSMOFields(sObjectData,uow);
            }

            //do operations
            if(sObjectData.openedFrom == CONTRACT_OBJECT){
                uow.registerDirty(sObjectData.contract);
                mxLink = manageMxOnbardingLink(sObjectData,null,uow);
                uow.commitWork();
                sObjectData.mxOnboardingLinkId = mxLink.Id; //reassign mx link id to wrapper
                objectVsEligibilityMessages = RESSMOService.getEligibilityMessagesForContract(contract,storeAccount,contact,quote);
            }
            else{
                sObjectData.quote.RESSMO_Payload__c = JSON.serializePretty(sObjectData.genericInput);
                uow.registerDirty(sObjectData.quote);
                uow.commitWork();
                objectVsEligibilityMessages = RESSMOService.getEligibilityMessagesForQuote(sObjectData.quote.Id);
            }
            for(String objectName: objectVsEligibilityMessages.keySet()){
                eligibilityResult.addAll(objectVsEligibilityMessages.get(objectName));
            }

            //eliigibility handle
            if(eligibilityResult.size() != 0){
                ressmoResponse.status = 'Failed';
                ressmoResponse.messages = eligibilityResult;
            }
            else{
                ressmoResponse.status = 'Success';
            }
            if(isPaymentCreated){
                sObjectData.paymentAccount = PaymentAccountsSelector.newInstance().selectById(new Set<Id>{sObjectData.paymentAccount.Id})[0];
            }
            if(isPhotoshootCreated){
                updateAccountContactRelation(sObjectData.photoshootContact.Id,sObjectData.storeAccount.Id);
            }
            dataWrapper.ressmoResponse = ressmoResponse;
            dataWrapper.objectWrapper = sObjectData;
            return dataWrapper;
        }
        catch(Exception ex){
            //handle in catch block in lwc
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_POPUP_SAVE_RECORDS_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException( ex ).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(LOG_SERVICE_NAME_RESSMO_POPUP_SAVE_RECORDS_FAILED + ex.getMessage());
        }
    }

    /**
    * @description this method will return Account Contact Relationship roles based on the country with regards to KYC compliance
    * @author VenkateshDD | 09-26-2024
    * @param country
    * @return Set<String>
    **/
    private static Set<String> populateAcrRoles(String country){
        Set<String> acrRoles = new Set<String>{ACR_CONTRACT_SIGNATORY,ACR_DECISION_MAKER};
        if(country == COUNTRY_CANADA){
            acrRoles.add(ACR_BUSINESS_OWNER);
            acrRoles.add(ACR_BUSINESS_DIRECTOR);
        }
        return acrRoles;
    }

    /**
    * @description
    * @author Soumya Dash | 09-01-2024
    * @param sObjectData
    * @param uow
    * @param acrRoles
    * @return Boolean
    **/
    private static Boolean handlePhotoshootContact(RESSMOUIObjectWrapper sObjectData,fflib_ISObjectUnitOfWork uow, Set<String> acrRoles){
        if(sObjectData.photoshootContact == null){
            return false;
        }
        Account storeAccount = (Account) sObjectData.storeAccount;
        Id businessAccountId = sObjectData.openedFrom == CONTRACT_OBJECT ? sObjectData.contract.AccountId : sObjectData.quote.SBQQ__Account__c;
        Contact photoshootContact = (Contact) sObjectData.photoshootContact;
        Boolean isPhotoshootCreated = false;

        if(photoshootContact.Id != null){
            uow.registerDirty(photoshootContact);
            return isPhotoshootCreated;
        }

        //check duplicate contact
        List<Contact> duplicateContact = ContactsSelector.newInstance().selectContactByEmailFirstNameLastNameAccountIds(
            new Set<String>{photoshootContact.FirstName},
            new Set<String>{photoshootContact.LastName},
            new Set<String>{photoshootContact.Email},
            storeAccount.Id,
            businessAccountId
        );

        if(!duplicateContact.isEmpty()){
            Boolean acrFound = false;
            for(Contact currCon : duplicateContact){
                if(!currCon.AccountContactRelations.isEmpty()){
                    AccountContactRelation acr = currCon.AccountContactRelations[0];
                    Set<String> roles = new Set<String>(acr.Roles != null ? acr.Roles.split(';') : new List<String>());
                    roles.add('Photoshoot Contact');
                    assignAcrRoles(acr.ContactId, sObjectData.contact.Id, roles, acrRoles);
                    acr.Roles = String.join(roles, ';');
                    uow.registerDirty(acr);
                    acrFound= true;
                    sObjectData.photoshootContact = currCon; //update contact to reflect in UI
                    break;
                }
            }

            if(!acrFound){
                AccountContactRelation acr = new AccountContactRelation();
                acr.AccountId = storeAccount.Id;
                acr.ContactId = duplicateContact[0].Id;
                Set<String> roles = new Set<String>{'Photoshoot Contact'};
                assignAcrRoles(acr.ContactId, sObjectData.contact.Id, roles, acrRoles);
                acr.Roles = String.join(roles, ';');
                acr.isActive = true;
                uow.registerNew(acr);
                sObjectData.photoshootContact = duplicateContact[0]; //update contact to reflect in UI
            }
        }
        else{
            //create new contact related to the store account
            sObjectData.photoshootContact.AccountId = storeAccount.Id;
            uow.registerNew(photoshootContact);
            isPhotoshootCreated = true;
        }
        return isPhotoshootCreated;
    }

    /**
    * @description - it creates payment account and payment account relation if payment account is recieved.
    * @author Soumya Dash | 09-26-2024
    * @param sObjectData
    * @param uow
    * @return boolean
    **/
    private static boolean createPaymentAccountAndPaymentAccountRelation(RESSMOUIObjectWrapper sObjectData,fflib_ISObjectUnitOfWork uow){
        if(sObjectData.paymentAccount != null){
            sObjectData.paymentAccount.RecordTypeId = PAYMENT_ACCOUNT_PAYMENT_RECORD_TYPE;
            sObjectData.paymentAccount.Business_Account__c = sObjectData.openedFrom == CONTRACT_OBJECT ?  sObjectData.contract.AccountId : sObjectData.quote.SBQQ__Account__c;
            uow.registerNew(sObjectData.paymentAccount);

            Account_Payment_Account_Relation__c par = new Account_Payment_Account_Relation__c(
                Account__c =  sObjectData.storeAccount.Id,
                Payment_Account__c = sObjectData.paymentAccount.Id
            );
            uow.registerNew(par,Account_Payment_Account_Relation__c.Payment_Account__c,sObjectData.paymentAccount);
            return true;
        }
        else{
            return false;
        }
    }

    /**
    * @description
    * @author VenkateshDD | 09-26-2024
    * @param acrContactId
    * @param ocrContactId
    * @param roles
    * @param acrRoles
    **/
    private static void assignAcrRoles(Id acrContactId, Id ocrContactId, Set<String> roles, Set<String> acrRoles){
        if(acrContactId == ocrContactId){
            roles.addAll(acrRoles);
            storeLevelAcrCreated = true;
        }
    }

    /**
    * @description this will upsert the ACR at the store level with the given contact roles
    * @author VenkateshDD | 09-25-2024
    * @param sObjectData
    * @param roles
    * @param uow
    **/
    private static void upsertStoreAccountContactRelation(RESSMOUIObjectWrapper sObjectData, Set<String> roles, fflib_ISObjectUnitOfWork uow){
        if(storeLevelAcrCreated){
            return;
        }
        List<AccountContactRelation> acrs = AccountContactRelationsSelector.newInstance().selectByAccountIdsAndContactIds(new Set<Id>{sObjectData.storeAccount.Id}, new Set<Id>{sObjectData.contact.Id});
        if(!acrs.isEmpty()){
            AccountContactRelation acr = acrs[0];
            Set<String> existingRoles = String.isBlank(acr.Roles) ? new Set<String>() : new Set<String>(acr.Roles.split(';'));
            existingRoles.addAll(roles);
            acr.Roles = String.join(existingRoles, ';');
            uow.registerDirty(acr);
            return;
        }
        AccountContactRelation acr = new AccountContactRelation();
        acr.AccountId = sObjectData.storeAccount.Id;
        acr.ContactId = sObjectData.contact.Id;
        acr.Roles = String.join(roles, ';');
        uow.registerNew(acr);
    }

    /**
    * @description - blank out remaining RESSMO fields on quote/contract and store id on xref
    * @author Soumya Dash | 09-04-2024
    * @param sObjectData
    * @param uow
    **/
    private static void blankRemainingRESSMOFields(RESSMOUIObjectWrapper sObjectData,fflib_ISObjectUnitOfWork uow){
        if(sobjectData.openedFrom == QUOTE_OBJECT){
            Opportunity opp = new Opportunity(
                Id = sobjectData.quote.SBQQ__Opportunity2__c,
                RESSMO_Link__c = '',
                Unique_Identifier__c = ''
            );
            uow.registerDirty(opp);
        }

        //xref store id blank
        List<Account> storeWithXref = AccountsSelector.newInstance().selectAccountByIdWithXrefPaymentAccount(
            new Set<Id>{sObjectData.storeAccount.Id},
            new map<String,Set<String>>{'Account' => new Set<String>(),'Xref' => new Set<String>(),'Account_Payment_Account_Relation' => new Set<String>()}
        );
        if(!storeWithXref[0].Xrefs__r.isEmpty()){
            Xref__c xref = new Xref__c(
                Id = storeWithXref[0].Xrefs__r[0].Id,
                External_ID__c = ''
            );
            uow.registerDirty(xref);
        }
    }

    /**
    * @description  - update Account contact Relation to Photoshoot contact role when newly created
    * @author Soumya Dash | 08-08-2024
    * @param contactId
    * @param storeId
    **/
    private static void updateAccountContactRelation(Id contactId,Id storeId){
        fflib_ISObjectUnitOfWork uow = APPLICATION.UNITOFWORK.newInstance();
        AccountContactRelation acr = AccountContactRelationsSelector.newInstance().selectByAccountIdsAndContactIds(new Set<Id>{storeId},new Set<Id>{contactId})[0];
        acr.Roles = ACCOUNT_CONTACT_ROLE_PHOTOSHOOT;
        uow.registerDirty(acr);
        uow.commitWork();
    }


    /**
    * @description - send to SSMO APi From quote
    * @author Soumya Dash | 07-02-2024
    * @param quoteId
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    @AuraEnabled
    public static RESSMOResponseWrapper sendToSSMOQuoteUI(Id quoteId){


        RESSMOResponseWrapper ressmoResponse = new RESSMOResponseWrapper();

        String oldRessmoLink = '';
        try{
            //Query RESSMO Link from Opportunity
            IQuotesSelector quoteSelector = QuotesSelector.newInstance();
            SBQQ__Quote__c quote = quoteSelector.selectByIdWithBusinessAccount(quoteId,new Map<String,Set<String>>{
                QUOTE_OBJECT => new Set<String>(),
                CONTACT_OBJECT => new Set<String>()
             }
            );

            if(quote.SBQQ__Opportunity2__r.RESSMO_Link__c != null){
                oldRessmoLink = quote.SBQQ__Opportunity2__r.RESSMO_Link__c;
            }

            SSMOWrapper.ResultMessageWrapper result  = RESSMOService.sendQuote(quoteId, oldRessmoLink,false);
            ressmoResponse = prepareRESSMOResponse(result);
            if(result.status == 'Success'){
                RESSMOService.updateRESSMOSobjectRecords(quoteId, result);
                String mxLinkGeneratedLogMessage = LOG_MESSGE_RESSMO_MX_LINK_GENERATED_QUOTE + quoteId;
                GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_GENERATED_MX_LINK_QUOTE,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                    .logMessage(mxLinkGeneratedLogMessage)
                    .logSFRecordId(new Set<String>{quoteId})
                    .setCategory(LOG_RESSMO_CATEGORY)
                    .setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                );
            }
            return ressmoResponse;
        }
        catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_NNS_SEND_QUOTE_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{quoteId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
    * @description - prepare ressponse wraaper for UI
    * @author Soumya Dash | 08-08-2024
    * @param result
    * @return RESSMOResponseWrapper
    **/
    private static  RESSMOResponseWrapper prepareRESSMOResponse(SSMOWrapper.ResultMessageWrapper result){
        RESSMOResponseWrapper ressmoResponse = new RESSMOResponseWrapper();
        ressmoResponse.status = result.status;
        ressmoResponse.messages = result.messages;
        ressmoResponse.onboardingLink = result.onboardingLink;
        ressmoResponse.uuid = result.uuid;
        return ressmoResponse;
    }

    /**
    * @description - send to ssmo from contract record page
    * @author Soumya Dash | 07-29-2024
    * @param sObjectData
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    @AuraEnabled
    public static RESSMOResponseWrapper sendToSSMOContractUI(RESSMOUIObjectWrapper sObjectData){
        RESSMOResponseWrapper ressmoResponse = new RESSMOResponseWrapper();
        Account storeAccount = (Account) sObjectData.storeAccount;
        Contact contact = (Contact) sObjectData.contact;
        Contract contract = (Contract) sObjectData.contract;
        SBQQ__Quote__c quote = (SBQQ__Quote__c) sObjectData.quote;

        try{
            SSMOWrapper.ResultMessageWrapper result = RESSMOService.sendNewStore(contract.Id,storeAccount,contact,quote,false);
            ressmoResponse = prepareRESSMOResponse(result);
            if(ressmoResponse.status == 'Success'){
                try{
                    fflib_ISObjectUnitOfWork uow = APPLICATION.UNITOFWORK.newInstance();
                    contract.RESSMO_Sales_Rep_Name__c = UserInfo.getUserID();
                    uow.registerDirty(contract);
                    //create mx onboarding link record
                    manageMxOnbardingLink(sObjectData,ressmoResponse,uow);

                    //update Contact(OCR)
                    updatesObjectFromContractUI(sObjectData.contact.Id,ressmoResponse,Schema.Contact.sObjectType,uow);

                    //Update Store Account
                    updatesObjectFromContractUI(sObjectData.storeAccount.Id,ressmoResponse,Schema.Account.sObjectType,uow);
                    uow.commitWork();
                    String mxLinkGenLogMessage = LOG_MESSGE_RESSMO_MX_LINK_GENERATED_CONTRACT + contract.Id;
                    GenericLoggerService.publish(GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_GENERATED_MX_LINK_CONTRACT,GENERIC_LOG_DOMAIN,GenericLogEntry.SeverityLevel.MEDIUM)
                        .logMessage(mxLinkGenLogMessage)
                        .logSFRecordId(new Set<String>{contract.Id})
                        .setCategory(LOG_RESSMO_CATEGORY)
                        .setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
                    );
                }
                Catch(Exception ex){
                    GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_NNE_CONTRACT_LINK_PROCESSING_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                        .logException(ex).logSFRecordId(new Set<String>{contract.Id}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
                    );
                }
            }
            return ressmoResponse;
        }
        Catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_NSE_CONTRACT_LINK_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{contract.Id}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }
    }


    /**
    * @description - Insert/Update Mx-Onboarding link accordingly
    * @author Soumya Dash | 08-09-2024
    * @param sObjectData
    * @param ressmoResponse
    * @param uow
    * @return Mx_Onboarding_Link__c
    **/
    private static Mx_Onboarding_Link__c manageMxOnbardingLink(RESSMOUIObjectWrapper sObjectData, RESSMOResponseWrapper ressmoResponse,fflib_ISObjectUnitOfWork uow){
        map<String,Object> genericInputsData = (map<String,Object>)JSON.deserializeUntyped(JSON.serialize(sObjectData.genericInput));
        Map<String, Object> quoteData = (Map<String, Object>)genericInputsData.get('Quote');

        Mx_Onboarding_Link__c mxLink = new Mx_Onboarding_Link__c(
            Status__c = MX_LINK_STATUS_INACTIVE,
            Contract__c = (Id) sObjectData.contract.Id,
            Expiration_Date_Time__c = Date.valueOf((String)quoteData.get('SSMOExpirationDate')),
            Onboarding_Scenario__c = MX_ONBOARDING_NEW_STORE_EXPANSION,
            Business_Account__c = (Id) sObjectData.contract.AccountId,
            Payment_Method__c = (String) sObjectData.contract.Payment_Method__c,
            Rep_Collecting_On_Mx_Behalf__c = REP_COLLECTING_ON_MX_BEHALF_YES,
            Source__c = MX_ONBOARDING_SOURCE,
            Inactive_Reason__c = '',
            Record_Creation_Status__c = '',
            Generated_By__c = UserInfo.getUserID(),
            Payload__c = JSON.serialize(sObjectData)

        );
        if(ressmoResponse != null){
            mxLink.UUID__C = ressmoResponse.uuid;
            mxLink.One_Time_Mx_Link__c = ressmoResponse.onboardingLink;
            mxLink.Status__c = MX_LINK_STATUS_ACTIVE;
        }
        if(sObjectData.mxOnboardingLinkId != null){
            mxLink.Id = (Id) sObjectData.mxOnboardingLinkId ;
            uow.registerDirty(mxLink);
        }
        else{
            uow.registerNew(mxLink);
        }
        return mxLink;
    }


    /**
    * @description  - update sObject(Account,Contact) after ssmo successful from contract
    * @author Soumya Dash | 08-09-2024
    * @param recordId
    * @param ressmoResponse
    * @param sObjectType
    * @param uow
    **/
    private static void updatesObjectFromContractUI(Id recordId, RESSMOResponseWrapper ressmoResponse, Schema.SObjectType sObjectType, fflib_ISObjectUnitOfWork uow) {
        Set<String> sObjectsApiName = new set<String>{'Contact'};

        if (String.isNotBlank(recordId)) {
            SObject sObjectToUpdate = sObjectType.newSObject(recordId);
            String sObjectName = sObjectToUpdate.getSObjectType().getDescribe().getName();
            sObjectToUpdate.put('Unique_Identifier__c', ressmoResponse.uuid);
            if(sObjectsApiName.contains(sObjectName)){
                sObjectToUpdate.put('RESSMO_link__c', ressmoResponse.onboardingLink);
            }
            uow.registerDirty(sObjectToUpdate);
        }
    }

    /**
    * @description - generate mx link record from UI
    * @author Soumya Dash | 08-29-2024
    * @param mxLinkId
    * @return Boolean
    **/
    @AuraEnabled
    public static Boolean generateMxLinkRecord(Id mxLinkId){
        set<String> storeFieldsToBeStoredInBusiness = new Set<String>{'Order_Protocol__c','Proposed_Date_of_Activation__c','Legal_Business_Name__c','Activated_Centrally_AC__c','Brand__c'};
        try{
            fflib_ISObjectUnitOfWork uow = APPLICATION.UNITOFWORK.newInstance();
            Mx_Onboarding_Link__c mxLink = MxOnboardingLinksSelector.newInstance().selectByIdWithPayloadAndRelated(mxLinkId)[0];
            List<RESSMO_UI_Input__mdt> ressmoUIInput = RESSMOUIInputsSelector.newInstance().selectAllREESMOUIInputContract();
            Mx_Onboarding_Link__c oldMxLink = new  Mx_Onboarding_Link__c(
                Id = mxLinkId,
                Status__c = MX_LINK_STATUS_INACTIVE,
                Inactive_Reason__c = MX_LINK_INACTIVE_REASON_DEACTIVATED,
                Record_Creation_Status__c = ''
            );
            uow.registerDirty(oldMxLink);

            //Extracting data from payload
            map<String,Object> parseMap = (map<String,Object>)JSON.deserializeUntyped(mxLink.Payload__c);
            map<String,Object> contract = (map<String,Object>)parseMap.get('contract');
            map<String,Object> storeAccount = (map<String,Object>)parseMap.get('storeAccount');
            Account storeAllData = AccountsSelector.newInstance().selectById(new Set<Id>{(Id)storeAccount.get('Id')})[0];
            map<String,Object> contact = (map<String,Object>)parseMap.get('contact');
            map<String,Object> photoshootContact = (map<String,Object>)parseMap.get('photoshootContact');
            map<String,Object> genericInput = (map<String,Object>)parseMap.get('genericInput');
            Map<String,Object> photoshootDateTime = (map<String,Object>)genericInput.get('Photoshoot');

            OIMainDataWrapper oiMainDataWrapper = new OIMainDataWrapper((Id) contract.get('AccountId'),(Id)contract.get('Id'));
            List<OIFieldWrapper> oiFieldWrapperStore = new List<OIFieldWrapper>();
            List<OIFieldWrapper> oiFieldWrapperBusiness = new List<OIFieldWrapper>();

            //create contract info payload
            ContractInfoWrapper oiDataServiceContractPayload = OIDataService.fetchContractDetails((Id)contract.get('Id'), MX_ONBOARDING_NEW_STORE_EXPANSION);
            oiMainDataWrapper.payload = oiDataServiceContractPayload.payload;

            //manual entries
            oiMainDataWrapper.payload.isActivateCentrallyValue  = ACTIVATED_CENTERALLY_YES;
            oiMainDataWrapper.payload.orderProtocol = (String)storeAllData.get('Order_Protocol__c');
            oiMainDataWrapper.payload.brandName = (String)storeAllData.get('Brand__c');

            //iterater RESSMO UI inputs and create oiFieldWrapperStore and oiFieldWrapperBusiness
            processUIFields(ressmoUIInput, storeAllData, contact, photoshootContact, photoshootDateTime, storeFieldsToBeStoredInBusiness, oiFieldWrapperStore, oiFieldWrapperBusiness);

            //create storeDataWrapper property
            List<StoreDataWrapper> storeDataWrapperList = new List<StoreDataWrapper>{
                new StoreDataWrapper(1,oiFieldWrapperStore,null)
            };
            oiMainDataWrapper.businessInfoWrappers = oiFieldWrapperBusiness;
            oiMainDataWrapper.storeDataWrappers = storeDataWrapperList;
            oiMainDataWrapper.onboardingScenario = MX_ONBOARDING_NEW_STORE_EXPANSION;
            oiMainDataWrapper.isMxInputRequired = true;
            oiMainDataWrapper.repCollectingOnMxBehalf = REP_COLLECTING_ON_MX_BEHALF_YES;

            Mx_Onboarding_Link__c newMxLink = OIDataService.saveMxOnboardingLinkRecord(JSON.serialize(new List<OIMainDataWrapper>{oiMainDataWrapper}));

            newMxLink.Source__c = MX_ONBOARDING_SOURCE_ONA;
            uow.registerDirty(newMxLink);
            uow.commitWork();
            return true;
        }
        catch(Exception ex){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_GENERATE_MX_LINK_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{mxLinkId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
            throw new AuraHandledException(ex.getMessage());
        }

    }



    /**
    * @description
    * @author Pankaj | 11-05-2024
    * @param ressmoUIInput
    * @param storeAllData
    * @param contact
    * @param photoshootContact
    * @param photoshootDateTime
    * @param storeFieldsToBeStoredInBusiness
    * @param oiFieldWrapperStore
    * @param oiFieldWrapperBusiness
    **/
    private static void processUIFields(List<RESSMO_UI_Input__mdt> ressmoUIInput, Account storeAllData, Map<String, Object> contact, Map<String, Object> photoshootContact, Map<String, Object> photoshootDateTime, Set<String> storeFieldsToBeStoredInBusiness, List<OIFieldWrapper> oiFieldWrapperStore, List<OIFieldWrapper> oiFieldWrapperBusiness) {
        for (RESSMO_UI_Input__mdt eachUIField : ressmoUIInput) {
            if (eachUIField.OIAttributes__c == null) {
                continue;
            }
            String fieldApiName = eachUIField.OIAttributes__r.Field_API_Name__c;
            String fieldType = eachUIField.OIAttributes__r.Data_Type__c;
            String fieldValue;

            switch on eachUIField.Section__c {
                when 'Account' {
                    fieldValue = getFieldValueForAccount(eachUIField, storeAllData);
                    addFieldWrapper(fieldApiName, fieldValue, fieldType, storeFieldsToBeStoredInBusiness, oiFieldWrapperStore, oiFieldWrapperBusiness);
                }
                when 'Contact' {
                    fieldValue = (String) contact.get(eachUIField.Field_API_Name__c);
                    createOIFieldWrapper(fieldApiName, fieldValue, fieldType, oiFieldWrapperStore);
                }
                when 'Photoshoot' {
                    fieldValue = getFieldValueForPhotoshoot(eachUIField, photoshootDateTime, photoshootContact);
                    createOIFieldWrapper(fieldApiName, fieldValue, fieldType, oiFieldWrapperBusiness);
                }
            }
        }
    }

    /**
    * @description
    * @param eachUIField
    * @param storeAllData
    * @return String
    **/
    private static String getFieldValueForAccount(RESSMO_UI_Input__mdt eachUIField, Account storeAllData) {
        if (eachUIField.Input_Type__c == 'Date') {
            DateTime dateValue = (DateTime) storeAllData.get(eachUIField.Field_API_Name__c);
            return dateValue != null ? dateValue.format('yyyy-MM-dd') : null;
        } else {
            return (String) storeAllData.get(eachUIField.Field_API_Name__c);
        }
    }

    /**
    * @description
    * @param fieldApiName
    * @param fieldValue
    * @param fieldType
    * @param storeFieldsToBeStoredInBusiness
    * @param oiFieldWrapperStore
    * @param oiFieldWrapperBusiness
    **/
    private static void addFieldWrapper(String fieldApiName, String fieldValue, String fieldType, Set<String> storeFieldsToBeStoredInBusiness, List<OIFieldWrapper> oiFieldWrapperStore, List<OIFieldWrapper> oiFieldWrapperBusiness) {
        if (storeFieldsToBeStoredInBusiness.contains(fieldApiName)) {
            createOIFieldWrapper(fieldApiName, fieldValue, fieldType, oiFieldWrapperBusiness);
        } else {
            createOIFieldWrapper(fieldApiName, fieldValue, fieldType, oiFieldWrapperStore);
        }
    }

    /**
    * @description
    * @param eachUIField
    * @param photoshootDateTime
    * @param photoshootContact
    * @return String
    **/
    private static String getFieldValueForPhotoshoot(RESSMO_UI_Input__mdt eachUIField, Map<String, Object> photoshootDateTime, Map<String, Object> photoshootContact) {
        if (eachUIField.Type__c == 'Generic Input' && photoshootDateTime != null) {
            return (String) photoshootDateTime.get(eachUIField.Field_API_Name__c);
        } else if (photoshootContact != null) {
            return (String) photoshootContact.get(eachUIField.Field_API_Name__c);
        }
        return null;
    }

    /**
    * @description  - create OIField wrapper intsance
    * @author Soumya Dash | 08-29-2024
    * @param fieldApiName
    * @param fieldValue
    * @param fieldType
    * @param oiFieldWrapper
    **/
    private static void createOIFieldWrapper(String fieldApiName,String fieldValue,String fieldType,List<OIFieldWrapper> oiFieldWrapper){
        if(fieldValue != null && fieldValue != ''){
            OIFieldWrapper addField = new OIFieldWrapper(fieldApiName,fieldValue,fieldType);
            oiFieldWrapper.add(addField);
        }
    }

   /**
    * @description Wrapper for sendToSSMO loading
    */
    public class SendToRESSMODataWrapper{

        /**
        * @description Ressmo UI Inputs fields metadata
        */
        @AuraEnabled
        public map<String,List<RESSMO_UI_Input__mdt>> sectiontoInputMetadata {get; set;}

        /**
        * @description store record type id
        */
        @AuraEnabled
        public String storeRecordTypeId {get; set;}

        /**
        * @description gets populated when contract has an active mx onboarding link
        */
        @AuraEnabled
        public Mx_Onboarding_Link__c hasMxOnboardingLink {get; set;}


        /**
        * @description RESSMOResponseWrapper
        */
        @AuraEnabled
        public RESSMOResponseWrapper ressmoResponse {get;set;}

         /**
        * @description RESSMOUIObjectWrapper
        */
        @AuraEnabled
        public RESSMOUIObjectWrapper objectWrapper {get;set;}
   }


    /**
    * @description Wrapper for ressmoResponse
    */
    public class RESSMOResponseWrapper{

        /**
        * @description status
        */
        @AuraEnabled
        public String status {get; set;}

        /**
        * @description eligibility messages
        */
        @AuraEnabled
        public List<String> messages {get; set;}

        /**
        * @description ssmo uuid
        */
        @AuraEnabled
        public String uuid;

        /**
        * @description ssmo link
        */
        @AuraEnabled
        public String onboardingLink;
    }

   /**
    * @description object wrspper
    */
   public class RESSMOUIObjectWrapper{

        /**
        * @description contract
        */
        @AuraEnabled
        public Contract contract {get; set;}

        /**
        * @description business account
        */
        @AuraEnabled
        public Account businessAccount {get; set;}

        /**
        * @description store Account
        */
        @AuraEnabled
        public  Account storeAccount {get; set;}

        /**
        * @description contact
        */
        @AuraEnabled
        public Contact contact {get; set;}

        /**
        * @description payment account
        */
        @AuraEnabled
        public  Payment_Account__c paymentAccount {get; set;}

        /**
        * @description quote
        */
        @AuraEnabled
        public SBQQ__Quote__c quote {get; set;}

        /**
        * @description photo shoot contact
        */
        @AuraEnabled
        public Contact photoshootContact {get; set;}

        /**
        * @description mx onboarding link id
        */
        @AuraEnabled
        public String mxOnboardingLinkId {get; set;}

        /**
        * @description banking information checking
        */
        @AuraEnabled
        public Boolean isBankingInfoPopulated = false;

        /**
        * @description determines to blank ressmo related field from different objects
        */
        @AuraEnabled
        public Boolean resetSSMOLogin {get; set;}

        /**
        * @description opened from contract or quote
        */
        @AuraEnabled
        public String openedFrom {get; set;}

        /**
        * @description genericInput section wise
        */
        @AuraEnabled
        public Object genericInput {get; set;}

   }

}