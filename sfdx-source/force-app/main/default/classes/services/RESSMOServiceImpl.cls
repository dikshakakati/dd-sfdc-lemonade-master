/**
 * @description       : Implementation class for RESSMOService
 * @author            : VenkateshDD
 * @group             : RESSMO DDMx - Aethereus
 * @last modified on  : 12-10-2024
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity,PMD.ExcessiveClassLength,PMD.NcssTypeCount')
public with sharing class RESSMOServiceImpl implements IRESSMOService{


    private static final String UNITED_STATES_COUNTRY = 'United States';
    private static final String CANDADA_COUNTRY = 'Canada';
    private static final String AUSTRALIA_COUNTRY = 'Australia';
    private static final String NEW_ZEALAND_COUNTRY = 'New Zealand';
    @TestVisible
    private static final String BUSINESS_ACCOUNT_OBJECT = 'Account (Business Account)';
    @TestVisible
    private static final String OPPORTUNITY_OBJECT = 'Opportunity';
    @TestVisible
    private static final String OWNER_OBJECT = 'SBQQ__Quote__c SalesRep';
    @TestVisible
    private static final String CONTACT_OBJECT = 'Contact';
    @TestVisible
    private static final String QUOTE_OBJECT = 'SBQQ__Quote__c';
    @TestVisible
    private static final String QUOTE_LINE_OBJECT = 'SBQQ__QuoteLine__c';
    @TestVisible
    private static final String BUSINESS_REFERENCE_OBJECT = 'Business Reference';
    @TestVisible
    private static final String STORE_ACCOUNT_OBJECT = 'Account (Store Account)';
    @TestVisible
    private static final String PAYMENT_ACCOUNT_OBJECT = 'Payment_Account__c';
    @TestVisible
    private static final String XREF_OBJECT = 'XRef__c';
    private static final String GENERIC_LOG_DOMAIN = 'SSMO';
    private static final String SERVICE_NAME_RESSMO_SEND_TO_SSMO = 'RESSMO Callout Send to SSMO';
    private static final String SERVICE_NAME_RESSMO_MANAGE_RESSMO_LINK = 'RESSMO Callout Manage RESSMO Link';
	private static final String HTTP_POST = 'POST';
    private static final String SSMO_WRAPPER_STATUS_SUCCESS = 'Success';
    private static final String SSMO_WRAPPER_STATUS_FAILED = 'Failed';
    private static final String NAMED_CREDENTIAL = 'RESSMOSendToSSMO';

    private static final String ACCOUNT_OBJECT = 'Account';
    private static final String CONTRACT_OPPORTUNITY_RELATIONSHIP = 'SBQQ__Opportunity__r';
    private static final String CONTRACT_SUBSCRIPTIONS_RELATIONSHIP = 'SBQQ__Subscriptions__r';
    private static final String SUBSCRIPTION_OBJECT = 'SBQQ__Subscription__c';
    private static final String CONTRACT_OBJECT = 'Contract';
    private static final String CONTRACT_SALES_REP = 'Contract SalesRep';
    private static final String CONTRACT_SALES_REP_RELATIONSHIP = 'Owner';
    private static final String BILLING_ADDRESS = 'BillingAddress';
    private static final String NUMBER_OF_STORES = 'Number_of_Stores__c';
    private static final String MX_ONBOARDING_PAYLOAD_GENERICINPUT =  'genericInput';
    private static final String MX_ONBOARDING_PAYLOAD_QUOTE = 'Quote';
    private static final String MX_ONBOARDING_PAYLOAD_NUMBEROFSTORES = 'NumberOfStores';
    private static final String LOG_SERVICE_NAME_RESSMO_NNS_SEND_QUOTE_LINK_PROCESSING_ERROR = 'RESSMO NNS Send Quote Link Processing Error';
    private static final String LOG_SERVICE_NAME_RESSMO_NSE_SEND_CONTRACT_ERROR = 'RESSMO NSE Send Contract Error';
    private static final String LOG_MESSAGE_RESSMO_NSE_SEND_CONTRACT_ERROR_CONTRACT_ID ='RESSMO NNE Send Contract Processing Error - Contract Id {contractRecId}';
    private static final String LOG_SERVICE_NAME_RESSMO_NNS_SEND_QUOTE_ERROR = 'RESSMO NNS Send Quote Error';
    private static final String LOG_RESSMO_CATEGORY = '';
    private static final String LOG_RESSMO_LOG_LEVEL_ERROR = 'ERROR';
    private static final String LOG_RESSMO_LOG_LEVEL_INFO = 'INFO';
    private static final String PRICING_VARIATION_TYPE_UNEXPLAINABLE = 'Unexplainable';
    private static final String QUOTE_CONTRACTING_FLOW_REDLINING = 'Redlining';
    private static final String PICKLIST_VALUE_YES = 'Yes';

    @TestVisible
    private static final String ALTERNATIVE_STORE_NAME_FIELD = 'Alternative_Store_Name__c';
    @TestVisible
    private static final String ACCOUNT_NAME_API_PROPERTY = 'AccountName';
    @TestVisible
    private static final String STORE_ACCOUNT_JSON_OBJECT = 'StoreAccount';



    @TestVisible
    private static final Map<String, String> PARENT_RELATIONSHIP = new Map<String, String>{
        BUSINESS_ACCOUNT_OBJECT => 'SBQQ__Account__r',
        OPPORTUNITY_OBJECT => 'SBQQ__Opportunity2__r',
        OWNER_OBJECT => 'SBQQ__SalesRep__r',
        CONTACT_OBJECT => 'Contact',
        BUSINESS_REFERENCE_OBJECT => 'Business_Reference__r',
        PAYMENT_ACCOUNT_OBJECT => 'Payment_Account__r'
    };

    @TestVisible
    private static final List<String> VALID_ORDER_PROTOCOLS = System.Label.RESSMO_Eligibility_Valid_Order_Protocols.split(';');
    @TestVisible
    private static final List<String> REQUIRED_RESSMO_PRODUCTCODES = System.Label.RESSMO_Eligibility_RequiredProductCodes.split(';');
    @TestVisible
    private static final List<String> VALID_COUNTRIES = System.Label.RESSMO_Eligibility_Valid_Countries.split(';');
    @TestVisible
    private static final String PRIMARY_VERTICAL_RX = 'Rx';
    @TestVisible
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';

    public static final String QUOTELINE_JSON_OBJECT = 'QuoteLine';
    @TestVisible
    private static final List<String> VALID_OPPORTUNITIES = System.Label.RESSMO_Eligibility_Valid_Opportunites.split(';');

    /**
    * @description Method to avoid repetitive null checks and get field value from Sobject map
    * @author VenkateshDD | 07-10-2024
    * @param objName
    * @param fieldName
    * @param ddmxObjectToSobject
    * @return Object
    **/
    public static Object getFieldValueFromSobject(String objName, String fieldName, Map<String, sObject> ddmxObjectToSobject){
        SObject obj = ddmxObjectToSobject.get(objName);
        if(obj != null){
            return obj.get(fieldName);
        }
        return null;
    }

    /**
    * @description This will check If the Quote Line Field is Blank or not based on the Mapping Field Name from the Custom Metadata Type
    * @author VenkateshDD | 07-09-2024
    * @param quoteLines
    * @param ressmoMap
    * @return Boolean
    **/
    public static Boolean isQuoteLineFieldBlank(List<SBQQ__QuoteLine__c> quoteLines, RESSMO_Mapping__mdt ressmoMap){
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            if(quoteLine.get(ressmoMap.Field_Name__c) == null){
                return true;
            }
        }
        return false;
    }

    /**
    * @description Check If all the Required Fields based out of metaData in sObject and  Quote Lines
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLines
    **/
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
    public static void verifyRequiredFields(Map<String,List<String>> objectVsEligibilityMessages, List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines){

        Boolean considerStoreAccountAndRelatedRequiredFields = ddmxObjectToSobject.containsKey(STORE_ACCOUNT_OBJECT);

        for(RESSMO_Mapping__mdt ressmoMap : ressmoMappings){
            Boolean validateRelatedToStore = considerStoreAccountAndRelatedRequiredFields || !System.Label.RESSMO_Eligibility_StoreRelatedSObjects.contains(ressmoMap.Object_Name__c);
            if(ressmoMap.Is_Required__c && validateRelatedToStore){
                if(ressmoMap.Object_Name__c != QUOTE_LINE_OBJECT ){
                    sObject obj = ddmxObjectToSobject.get(ressmoMap.Object_Name__c);
                    if( obj==null || obj.get(ressmoMap.Field_Name__c) == null ){
                        createObjectVsEligibilityMessage(objectVsEligibilityMessages, ressmoMap.Object_Name__c, System.Label.RESSMO_Eligibility_Error_RequiredFieldsMissing + ' ' +ressmoMap.Label);
                    }
                }else if(RESSMOService.isQuoteLineFieldBlank(quoteLines, ressmoMap)){
                    createObjectVsEligibilityMessage(objectVsEligibilityMessages, ressmoMap.Object_Name__c, System.Label.RESSMO_Eligibility_Error_RequiredFieldsMissing + ' ' +ressmoMap.Label);
                }
            }
        }
    }

    /**
    * @description checks and adds If all the Quote Lines are Eligible or  based on the Product Check and If Required quote lines are present
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param quoteLines
    * @param validationMessages
    **/
    public static void verifyQuoteLinesEligibility(Map<String,List<String>> objectVsEligibilityMessages, List<SBQQ__QuoteLine__c> quoteLines, List<String> validationMessages){
        Set<String> quoteLineProductCodes = new Set<String>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            quoteLineProductCodes.add(quoteLine.SBQQ__Product__r.ProductCode);
            if(!quoteLine.SBQQ__Product__r.SSMO_Eligible__c){
                createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_LINE_OBJECT, System.Label.RESSMO_Eligibility_Error_InEligibleProducts +' '+ quoteLine.SBQQ__Product__r.Name);
            }
        }
        for(String pc : REQUIRED_RESSMO_PRODUCTCODES){
            if(!quoteLineProductCodes.contains(pc)){
                createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_LINE_OBJECT, System.Label.RESSMO_Eligibility_Error_RequiredProductCode);
                break;
            }
        }

    }


    /**
    * @description Validates the Eligibility Rules of the Business Account
    * @author VenkateshDD | 07-09-2024
    * @param objectVsEligibilityMessages
    * @param bizAcc
    **/
    public static Void businessAccountValidations(Map<String,List<String>> objectVsEligibilityMessages,SObject bizAcc){
        if( (bizAcc.get('BillingCountry') == null ||
            !VALID_COUNTRIES.contains( (String)bizAcc.get('BillingCountry') ))
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, BUSINESS_ACCOUNT_OBJECT, System.Label.RESSMO_Eligibility_Error_Countries+ ' '+String.join(new List<String>(VALID_COUNTRIES), ' or '));
        }

        if( ( bizAcc.get('Segment__c') == null ||
             (String)bizAcc.get('Segment__c') != ACCOUNT_SEGMENT_SMB)
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, BUSINESS_ACCOUNT_OBJECT, System.Label.RESSMO_Eligibility_Error_SMBSegment);
        }

        if( ( bizAcc.get('Primary_Vertical__c') == null ||
             (String)bizAcc.get('Primary_Vertical__c') != PRIMARY_VERTICAL_RX)
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, BUSINESS_ACCOUNT_OBJECT, System.Label.RESSMO_Eligibility_Error_PrimaryVertical);
        }
    }

    /**
    * @description Returns All the quote Level Eligibility Failures for RESSMO
    * @author VenkateshDD | 07-09-2024
    * @param ressmoMappings
    * @param ddmxObjectToSobject
    * @param quoteLines
    * @return List<String>
    **/
    public static Map<String,List<String>>  quoteEligibilityMessagesForRESSMO(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines){
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();
        List<String> validationMessages = new List<String>();
        if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            String.isBlank((String)ddmxObjectToSobject.get(QUOTE_OBJECT).get('RESSMO_Store_Account_Id__c'))
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT, System.Label.RESSMO_Store_Not_Selected_Message );
            return objectVsEligibilityMessages;
        }

        if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            !(Boolean)ddmxObjectToSobject.get(QUOTE_OBJECT).get('UTA_Check__c')
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT, System.Label.RESSMO_Eligibility_Error_UTACheck);
        }

        if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            !(Boolean)ddmxObjectToSobject.get(QUOTE_OBJECT).get('SBQQ__Primary__c')
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT, System.Label.RESSMO_Eligibility_Error_NotPrimaryQuote);
        }
        if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            !(ddmxObjectToSobject.get(QUOTE_OBJECT).get('SBQQ__Status__c') !=null && ddmxObjectToSobject.get(QUOTE_OBJECT).get('SBQQ__Status__c').equals('Approved'))
            ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT, System.Label.RESSMO_Eligibility_Error_QuoteNotApproved);
        }

        if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            !String.isBlank((String)ddmxObjectToSobject.get(QUOTE_OBJECT).get('SSMO_Validation__c'))  &&
            ddmxObjectToSobject.get(QUOTE_OBJECT).get('SSMO_Validation__c') != 'Success')
          {
             createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT,(String)ddmxObjectToSobject.get(QUOTE_OBJECT).get('SSMO_Validation__c'));
          }

         if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            ddmxObjectToSobject.get(QUOTE_OBJECT).get('Store_Specific_Variations__c') == PICKLIST_VALUE_YES)
          {
             createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT,System.Label.RESSMO_Store_Specific_Validation );
          }

        if( ddmxObjectToSobject.get(QUOTE_OBJECT) != null &&
            !String.isBlank((String)ddmxObjectToSobject.get(QUOTE_OBJECT).get('Contracting_Flow__c'))  &&
            ddmxObjectToSobject.get(QUOTE_OBJECT).get('Contracting_Flow__c') == QUOTE_CONTRACTING_FLOW_REDLINING)
          {
             createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT,System.Label.RESSMO_Contracting_Flow_Validation );
          }

        opportunityLevelEligibilityMessagesForRESSMO(ddmxObjectToSobject, objectVsEligibilityMessages);
        verifyRequiredFields(objectVsEligibilityMessages, ressmoMappings, ddmxObjectToSobject, quoteLines);
        verifyQuoteLinesEligibility(objectVsEligibilityMessages, quoteLines, validationMessages);
        SObject bizAcc = ddmxObjectToSobject.get(BUSINESS_ACCOUNT_OBJECT);
        if(bizAcc != null){
            businessAccountValidations(objectVsEligibilityMessages,bizAcc);
        }
        return objectVsEligibilityMessages;
    }

    /**
    * @description This will validate opportunity level validation and add against quote
    * @author VenkateshDD | 11-07-2024
    * @param ddmxObjectToSobject
    * @param objectVsEligibilityMessages
    **/
    @TestVisible
    private static void opportunityLevelEligibilityMessagesForRESSMO(Map<String, sObject> ddmxObjectToSobject, Map<String,List<String>> objectVsEligibilityMessages){
        if( ddmxObjectToSobject.get(OPPORTUNITY_OBJECT) != null && (String.isBlank((String)ddmxObjectToSobject.get(OPPORTUNITY_OBJECT).get('Opportunity_Sub_Type__c'))
            || !VALID_OPPORTUNITIES.contains((String)ddmxObjectToSobject.get(OPPORTUNITY_OBJECT).get('Opportunity_Sub_Type__c')))
        ){
           createObjectVsEligibilityMessage(objectVsEligibilityMessages, QUOTE_OBJECT,System.Label.RESSMO_Eligiblity_Net_New_Partner + ' '+String.join(new List<String>(VALID_OPPORTUNITIES), ' or '));
        }
    }

    /**
    * @description Store Account Level Eligibility Rules
    * @author VenkateshDD | 07-09-2024
    * @param ddmxObjectToSobject
    * @return Map<String,List<String>>
    **/
    public static Map<String,List<String>> storeEligibilityMessagesForRESSMO(Map<String, sObject> ddmxObjectToSobject){
        Map<String,List<String>>  objectVsEligibilityMessages = new Map<String,List<String>>();

        SObject storeAccount = ddmxObjectToSobject.get(STORE_ACCOUNT_OBJECT);

        if(storeAccount == null){
            return objectVsEligibilityMessages;
        }

        if( storeAccount.get('Order_Protocol__c') != null &&
            !VALID_ORDER_PROTOCOLS.contains( (String)storeAccount.get('Order_Protocol__c') )
            ){
            String errorProtocal = System.Label.RESSMO_Eligibility_Error_Order_Protocol.replace( '{currentOP}', (String)storeAccount.get('Order_Protocol__c')).replace( '{validOPs}', String.join(new List<String>(VALID_ORDER_PROTOCOLS), ' or '));
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, STORE_ACCOUNT_OBJECT, errorProtocal);
        }

        if( storeAccount.get('Order_Protocol__c') == 'POS' &&
            (storeAccount.get('POS_Integration_Type__c') == null || storeAccount.get('POS_Integration_Type__c') == '') ){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, STORE_ACCOUNT_OBJECT, System.Label.RESSMO_Eligibility_Error_POSIntegrationRequired);
        }

        if( storeAccount.get('Order_Protocol__c') == 'POS' &&
          	(storeAccount.get('Hours_of_Operation__c') != null ||
              (storeAccount.get('Menu_URL__c') != '' && storeAccount.get('Menu_URL__c') != null))){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, STORE_ACCOUNT_OBJECT, System.Label.RESSMO_Eligibility_Error_MenuURL_StoreHoursNotRequired);
        }
        return objectVsEligibilityMessages;
    }

    /**
    * @description get's eligibility messages for the quote and store together
    * @author
    * @param quoteId
    * @return Map<String,List<String>>
    **/
    public static Map<String,List<String>> getEligibilityMessagesForQuote(Id quoteId){
        Map<String,List<String>> objectVsEligibilityMessages = new Map<String,List<String>>();
        Map<String,List<String>> storeObjectVsEligibilityMessages = new Map<String,List<String>>();

        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectAllRessmoMappings();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);

        SBQQ__Quote__c quote = RESSMOService.getQuoteWithQuoteLinesWithFieldsFromMetaData(sobjectToSetOfField, quoteId);

        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        RESSMOService.populateQuoteAndSobjectsRelatedToQuote(ddmxObjectToSobject, quoteLineItems, quote);

        Account storeAccount = RESSMOService.getAccountWithXrefsDecisionMakerPaymentAccount(sobjectToSetOfField, quote.RESSMO_Store_Account_Id__c);
        RESSMOService.populateStoreAccountSobjectsRelatedToStore(ddmxObjectToSobject, storeAccount);

        objectVsEligibilityMessages = RESSMOService.quoteEligibilityMessagesForRESSMO(ressmoMappings, ddmxObjectToSobject, quoteLineItems);
        storeObjectVsEligibilityMessages = RESSMOService.storeEligibilityMessagesForRESSMO(ddmxObjectToSobject);
        for(String objName:  storeObjectVsEligibilityMessages.keySet()){
            if (!objectVsEligibilityMessages.containsKey(objName)) {
                objectVsEligibilityMessages.put(objName, new List<String>());
            }
            objectVsEligibilityMessages.get(objName).addAll(storeObjectVsEligibilityMessages.get(objName));
        }
		return objectVsEligibilityMessages;
    }

    /**
    * @description Based on the country it will check the mandatory banking information exists or not
    * @author VenkateshDD | 07-09-2024
    * @param ddmxObjectToSobject
    * @return Boolean
    **/
    public static Boolean bankingInfoExists(Map<String, sObject> ddmxObjectToSobject){
        try {
            SObject paymentAccount = ddmxObjectToSobject.get(PAYMENT_ACCOUNT_OBJECT);
            if( paymentAccount == null || paymentAccount.get('Bank_Account_Number__c') == null){
                return false;
            }
            else{
                String accCountry = (String)ddmxObjectToSobject.get(STORE_ACCOUNT_OBJECT).get('BillingCountry');
                if( ddmxObjectToSobject.get(STORE_ACCOUNT_OBJECT).get('Legal_Business_Name__c') != null &&
                    (accCountry == UNITED_STATES_COUNTRY
                    || accCountry == CANDADA_COUNTRY
                    || accCountry == AUSTRALIA_COUNTRY)){
                    return paymentAccount.get('RoutingNumber__c') != null;
                }
                if( accCountry == NEW_ZEALAND_COUNTRY){
                    return true;
                }
            }
            return false;
        } catch (Exception e) {
            return false;
        }
    }

    /**
    * @description
    * @param quoteId
    * @param ressmoMappings
    * @param isValidateOnly
    * @return String
    **/
    public static String prepareRequestJSON(Id quoteId, List<RESSMO_Mapping__mdt> ressmoMappings, Boolean isValidateOnly){
		Map<String, Set<String>> sobjectToSetOfField = RessmoService.getMapOfSobjectAndSetOfField(ressmoMappings);
		SBQQ__Quote__c quote = RESSMOService.getQuoteWithQuoteLinesWithFieldsFromMetaData(sobjectToSetOfField, quoteId);
		Account storeAccount = RESSMOService.getAccountWithXrefsDecisionMakerPaymentAccount(sobjectToSetOfField, quote.RESSMO_Store_Account_Id__c);
		return RESSMOService.generateJSON(quote, storeAccount, ressmoMappings,isValidateOnly);
    }

    /**
     * @description : Generates a JSON string based on the provided quote, store account, and ressmo mappings.
     *
     * @param quote The SBQQ__Quote__c object representing the quote.
     * @param storeAccount The Account object representing the store account.
     * @param ressmoMappings The list of RESSMO_Mapping__mdt objects representing the ressmo mappings.
     * @param isValidateOnly
     * @return A JSON string generated based on the provided inputs.
     */
    public static String generateJSON(SBQQ__Quote__c quote, Account storeAccount, List<RESSMO_Mapping__mdt> ressmoMappings, Boolean isValidateOnly){
        List<SBQQ__QuoteLine__c> quoteLineItems = new List<SBQQ__QuoteLine__c>();
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();

        RESSMOService.populateQuoteAndSobjectsRelatedToQuote(ddmxObjectToSobject, quoteLineItems, quote);
        RESSMOService.populateStoreAccountSobjectsRelatedToStore(ddmxObjectToSobject, storeAccount);

        return RESSMOService.writeJSON(ressmoMappings, ddmxObjectToSobject, quoteLineItems, isValidateOnly);
    }

    /**
     * @description : Populates the given map with related objects to the quote and sObjects related to the quote.
     *
     * @param ddmxObjectToSobject - The map to populate with related objects.
     * @param quoteLineItems - The list of quote line items.
     * @param quote - The quote object.
     */
    public static void populateQuoteAndSobjectsRelatedToQuote(Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLineItems, SBQQ__Quote__c quote){
        quoteLineItems.addAll( quote.SBQQ__LineItems__r );
        SObject opportunity = quote.SBQQ__Opportunity2__c != null ? quote.getSObject('SBQQ__Opportunity2__r') : null ;
        SObject userOwner = quote.SBQQ__SalesRep__c != null ? quote.getSObject('SBQQ__SalesRep__r') : null;
        SObject bizAccount = quote.SBQQ__Account__c != null ? quote.getSObject('SBQQ__Account__r') : null ;

        SObject ocr = quote.Opportunity_Contact_Role__r != null && quote.Opportunity_Contact_Role__r.size()>0 ?
                            quote.Opportunity_Contact_Role__r[0] : null;
        SObject contact = ocr != null ? ocr.getSObject('Contact') : null;

        ddmxObjectToSobject.put(OWNER_OBJECT, userOwner);
        ddmxObjectToSobject.put(BUSINESS_ACCOUNT_OBJECT, bizAccount);
        ddmxObjectToSobject.put(OPPORTUNITY_OBJECT, opportunity);
        ddmxObjectToSobject.put(QUOTE_OBJECT, quote);
        ddmxObjectToSobject.put(CONTACT_OBJECT, contact);
    }

    /**
     * @description : Populates the given map with related sObjects for a store account.
     *
     * @param ddmxObjectToSobject The map to populate with related sObjects.
     * @param storeAccount The store account for which to retrieve related sObjects.
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public static void populateStoreAccountSobjectsRelatedToStore(Map<String, sObject> ddmxObjectToSobject, Account storeAccount){

        List<Xref__c> xrefs = storeAccount != null ? storeAccount.XRefs__r : null;
        SObject businessReference = xrefs != null && xrefs.size() > 0 && xrefs[0].Business_Reference__c != null ? xrefs[0].getSObject('Business_Reference__r') : null;
        List<Account_Payment_Account_Relation__c> accPayAccRel = storeAccount != null ? storeAccount.Account_Payment_Account_Relations__r : null;
        SObject payAcc = accPayAccRel != null && accPayAccRel.size() > 0 ? accPayAccRel[0].getSObject('Payment_Account__r') : null;

        ddmxObjectToSobject.put(BUSINESS_REFERENCE_OBJECT, businessReference);
        ddmxObjectToSobject.put(STORE_ACCOUNT_OBJECT, (SObject)storeAccount);
        ddmxObjectToSobject.put(PAYMENT_ACCOUNT_OBJECT, payAcc);
        ddmxObjectToSobject.put(XREF_OBJECT, xrefs != null && xrefs.size() > 0 ? (SObject)xrefs[0] : null);
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
     * @param isValidateOnly
     * @return The generated JSON string.
     */
    public static String writeJSON(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject, List<SBQQ__QuoteLine__c> quoteLines, Boolean isValidateOnly){
        JSONGenerator reqGenerator = JSON.createGenerator(true);
        reqGenerator.writeStartObject();

        reqGenerator.writeBooleanField('isQuoteSSMOEligible',isValidateOnly);

        Map<String, List<RESSMO_Mapping__mdt>> jsonObjectToRessmoMapping = getJsonObjectNameToListOfRessmoMapping(ressmoMappings);

        writeJSONExceptForQuoteLines(reqGenerator, jsonObjectToRessmoMapping, ddmxObjectToSobject);

        Map<Id, Set<Id>> quoteLinePackageToProductOptions = quoteLinePackageToProductOptionsMap(quoteLines);

        Map<Id, SBQQ__QuoteLine__c> quoteLineIdToLineItem = new Map<Id, SBQQ__QuoteLine__c>(quoteLines);

        reqGenerator.writeFieldName(QUOTELINE_JSON_OBJECT);
        reqGenerator.writeStartArray();
        for(Id quoteLineId : quoteLinePackageToProductOptions.keySet()){
            reqGenerator.writeStartObject();
            SBQQ__QuoteLine__c pkg = quoteLineIdToLineItem.get(quoteLineId);
            writeJSONForQuoteLine(reqGenerator, jsonObjectToRessmoMapping.get(QUOTELINE_JSON_OBJECT), pkg);
            reqGenerator.writeFieldName('Product_Options');
            reqGenerator.writeStartArray();
            for(Id quoteLineIdInPackage : quoteLinePackageToProductOptions.get(quoteLineId)){
                reqGenerator.writeStartObject();
                SBQQ__QuoteLine__c quoteLine = quoteLineIdToLineItem.get(quoteLineIdInPackage);
                writeJSONForQuoteLine(reqGenerator, jsonObjectToRessmoMapping.get(QUOTELINE_JSON_OBJECT), quoteLine);
                reqGenerator.writeEndObject();
            }
            reqGenerator.writeEndArray();
            reqGenerator.writeEndObject();
        }

        reqGenerator.writeEndArray();

        reqGenerator.writeEndObject();
        String requestJSON = reqGenerator.getAsString();
        return requestJSON;
    }

    /**
     * @description : Writes JSON data for all objects except for Quote Lines.
     *
     * @param reqGenerator The JSONGenerator object used to generate the JSON data.
     * @param jsonObjectToRessmoMapping A map containing the mapping between JSON objects and RESSMO mappings.
     * @param ddmxObjectToSobject A map containing the mapping between DDMX objects and sObjects.
     */
    public static void writeJSONExceptForQuoteLines(JSONGenerator reqGenerator, Map<String, List<RESSMO_Mapping__mdt>> jsonObjectToRessmoMapping, Map<String, sObject> ddmxObjectToSobject){
        Boolean validBanking = bankingInfoExists(ddmxObjectToSobject);
        for(String jsonObjectName : jsonObjectToRessmoMapping.keyset()){
            if(jsonObjectName == QUOTELINE_JSON_OBJECT){
                continue;
            }
            reqGenerator.writeFieldName(jsonObjectName);
            reqGenerator.writeStartObject();
            for(RESSMO_Mapping__mdt ressmoMap : jsonObjectToRessmoMapping.get(jsonObjectName)){
                if(!ressmoMap.Is_Banking__c || validBanking){
                    Object fieldValue = getFieldValue(ressmoMap, ddmxObjectToSobject);
                    createJSONProperty(reqGenerator, ressmoMap, fieldValue);
                }
            }
            reqGenerator.writeEndObject();
        }
    }

    /**
    * @description Get field value also handles the exceptional case for the Account Name
    * @author VenkateshDD | 12-06-2024
    * @param ressmoMap
    * @param ddmxObjectToSobject
    * @return Object
    **/
    @TestVisible
    private static Object getFieldValue(RESSMO_Mapping__mdt ressmoMap, Map<String, sObject> ddmxObjectToSobject){
        if( ressmoMap.API_Property__c == ACCOUNT_NAME_API_PROPERTY &&
            ressmoMap.JSON_Object__c	== STORE_ACCOUNT_JSON_OBJECT &&
            ressmoMap.Object_Name__c == STORE_ACCOUNT_OBJECT &&
            ddmxObjectToSobject.get(STORE_ACCOUNT_OBJECT) != null &&
            ddmxObjectToSobject.get(STORE_ACCOUNT_OBJECT).get(ALTERNATIVE_STORE_NAME_FIELD) != null){
            ressmoMap.Field_Name__c = ALTERNATIVE_STORE_NAME_FIELD;
        }
        Object fieldValue = ddmxObjectToSobject.get(ressmoMap.Object_Name__c) != null ? ddmxObjectToSobject.get(ressmoMap.Object_Name__c).get(ressmoMap.Field_Name__c) : null;
        return fieldValue;
    }

    /**
     * @description : Writes JSON for a quote line based on the provided mappings.
     *
     * @param reqGenerator The JSONGenerator object used to generate the JSON.
     * @param ressmoMappings The list of RESSMO_Mapping__mdt records containing the mappings.
     * @param quoteLine The SBQQ__QuoteLine__c object representing the quote line.
     */
    public static void writeJSONForQuoteLine(JSONGenerator reqGenerator, List<RESSMO_Mapping__mdt> ressmoMappings, SBQQ__QuoteLine__c quoteLine){
        for(RESSMO_Mapping__mdt ressmoMap : ressmoMappings){
            //Object fieldValue = quoteLine.get(ressmoMap.Field_Name__c);
            Object fieldValue = getFieldValue(quoteLine, ressmoMap.Field_Name__c);
            if(ressmoMap.Products__c == null || ressmoMap.Products__c.contains(quoteLine.SBQQ__Product__r.ProductCode)){
                createJSONProperty(reqGenerator, ressmoMap, fieldValue);
            }
        }
    }


    /**
     * @description : Creates a JSON property based on the field mapping and field value.
     *
     * @param reqGenerator The JSONGenerator object used to generate the JSON.
     * @param fieldMapping The field mapping metadata record.
     * @param fieldValue The value of the field.
     */
    private static void createJSONProperty(JSONGenerator reqGenerator, RESSMO_Mapping__mdt fieldMapping, Object fieldValue){
        if(fieldMapping.Data_Type__c == 'Text'){
            reqGenerator.writeStringField(fieldMapping.API_Property__c, fieldValue != null?String.valueOf(fieldValue):'');
        }else if(fieldMapping.Data_Type__c == 'Boolean'){
            reqGenerator.writeBooleanField(fieldMapping.API_Property__c, fieldValue != null?Boolean.valueOf(fieldValue):false);
        }if(fieldMapping.Data_Type__c == 'Date'){
            if(fieldValue != null){
                Date dateVal = (Date) fieldValue;
                DateTime dateField = DateTime.newInstance(dateVal.year(), dateVal.month(), dateVal.day());
                reqGenerator.writeStringField(fieldMapping.API_Property__c, dateField.format('yyyy-MM-dd'));
            }else{
                reqGenerator.writeStringField(fieldMapping.API_Property__c, '');
            }
        }
    }

    /**
     * @description : This method creates a mapping between a package and its associated product options
     * based on a list of quote lines.
     *
     * @param quoteLines The list of quote lines to process.
     * @return A map where the key is the package ID and the value is a set of product option IDs.
     */
    public static Map<Id, Set<Id>> quoteLinePackageToProductOptionsMap(List<SBQQ__QuoteLine__c> quoteLines){
        Map<Id, Set<Id>> quoteLinePackageToProductOptions = new Map<Id, Set<Id>>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLines){
            if(quoteLine.SBQQ__RequiredBy__c != null){
                if(quoteLinePackageToProductOptions.containsKey(quoteLine.SBQQ__RequiredBy__c)){
                    quoteLinePackageToProductOptions.get(quoteLine.SBQQ__RequiredBy__c).add(quoteLine.Id);
                }else{
                    quoteLinePackageToProductOptions.put(quoteLine.SBQQ__RequiredBy__c, new Set<Id>{quoteLine.Id});
                }
            }
            else if(!quoteLinePackageToProductOptions.containsKey(quoteLine.Id)){
                quoteLinePackageToProductOptions.put(quoteLine.Id, new Set<Id>{});
            }
        }
        return quoteLinePackageToProductOptions;
    }

    /**
     * @description : Retrieves the value of a field from an SObject based on the given field path.
     *
     * @param rootObject The root SObject from which to retrieve the field value.
     * @param fieldPath The path of the field to retrieve, using dot notation for nested fields.
     * @return The value of the field, or null if the field or root object is null, or if the field path is empty.
     */
    @TestVisible
    private static Object getFieldValue(SObject rootObject, String fieldPath) {

        if (rootObject == null || String.isEmpty(fieldPath)) {
            return null;
        }

        if(!fieldPath.contains('.')) {
            return rootObject.get(fieldPath);
        }

        List<String> parts = fieldPath.split('\\.');
        SObject currentObject = rootObject;

        for (Integer i = 0; i < parts.size() - 1; i++) {

            String part = parts[i];
            if (currentObject == null) {
                return null;
            }
            currentObject = (SObject)currentObject.getSObject(part);

        }

        if (currentObject != null) {
            return currentObject.get(parts[parts.size() - 1]);
        }

        return null;
    }

    /**
     * @description : Returns a map of JSON object names to a list of RESSMO mappings.
     *
     * @param ressmoMappings A list of RESSMO mappings.
     * @return A map where the key is the JSON object name and the value is a list of RESSMO mappings.
     */
    @TestVisible
    private static Map<String, List<RESSMO_Mapping__mdt>> getJsonObjectNameToListOfRessmoMapping(List<RESSMO_Mapping__mdt> ressmoMappings){
        Map<String, List<RESSMO_Mapping__mdt>> result = new Map<String, List<RESSMO_Mapping__mdt>>();
        for(RESSMO_Mapping__mdt ressmoMap : ressmoMappings){
            if(ressmoMap.Add_to_Request__c){
                if(result.containsKey(ressmoMap.JSON_Object__c)){
                    result.get(ressmoMap.JSON_Object__c).add(ressmoMap);
                }
                else{
                    result.put(ressmoMap.JSON_Object__c, new List<RESSMO_Mapping__mdt>{ressmoMap});
                }
            }
        }
        return result;
    }

    /**
     * @description : Retrieves an Account record with cross-references to the Decision Maker and Payment Account.
     *
     * @param sobjectToSetOfField A map containing the object names as keys and a set of field names as values.
     * @param accountId The ID of the Account record to retrieve.
     * @return The Account record with cross-references to the Decision Maker and Payment Account.
     */
    public static Account getAccountWithXrefsDecisionMakerPaymentAccount(Map<String, Set<String>> sobjectToSetOfField, Id accountId){
        List<Account> accounts = AccountsSelector.newInstance().selectAccountByIdWithXrefPaymentAccount(new Set<Id>{accountId}, RESSMOService.getAllAccountsandRelatedObjectFields(sobjectToSetOfField));
        return (accounts != null && !accounts.isEmpty()) ? accounts[0] : null;
    }

    /**
     * @description : Retrieves all accounts and their related object fields.
     *
     * @param sobjectToSetOfField - A map containing the object names as keys and a set of field names as values.
     * @return A map where the key is the object name and the value is a set of field names.
     */
    public static Map<String, Set<String>> getAllAccountsandRelatedObjectFields(Map<String, Set<String>> sobjectToSetOfField) {
        Set<String> accountFields = sobjectToSetOfField.get(STORE_ACCOUNT_OBJECT) != null ? sobjectToSetOfField.get(STORE_ACCOUNT_OBJECT) : new Set<String>();
        Set<String> xrefFields = sobjectToSetOfField.get(XREF_OBJECT) != null ? sobjectToSetOfField.get(XREF_OBJECT) : new Set<String>();
        xrefFields.addAll(prependStringToSet(sobjectToSetOfField.get(BUSINESS_REFERENCE_OBJECT), PARENT_RELATIONSHIP.get(BUSINESS_REFERENCE_OBJECT)));
        Set<String> paymentAccountFields = sobjectToSetOfField.get(PAYMENT_ACCOUNT_OBJECT) != null ? prependStringToSet(sobjectToSetOfField.get(PAYMENT_ACCOUNT_OBJECT), PARENT_RELATIONSHIP.get(PAYMENT_ACCOUNT_OBJECT)) : new Set<String>();
        Map<String, Set<String>> objectNameToSetOfFields = new Map<String, Set<String>>{
            'Account' => accountFields,
            'Xref' => xrefFields,
            'Account_Payment_Account_Relation' => paymentAccountFields
        };

        return objectNameToSetOfFields;
    }

    /**
     * @description : Returns a map of SObject names to a set of field names based on the given list of RESSMO_Mapping__mdt records.
     *
     * @param ressmoMappings A list of RESSMO_Mapping__mdt records.
     * @return A map where the key is the SObject name and the value is a set of field names associated with that SObject.
     */
    public static Map<String, Set<String>> getMapOfSobjectAndSetOfField(List<RESSMO_Mapping__mdt> ressmoMappings){
        Map<String, Set<String>> sobjectToSetOfField = new Map<String, Set<String>>();

        for(RESSMO_Mapping__mdt ressmoMap : ressmoMappings){
            if(sobjectToSetOfField.containsKey(ressmoMap.Object_Name__c)){
                sobjectToSetOfField.get(ressmoMap.Object_Name__c).add(ressmoMap.Field_Name__c);
            }
            else{
                sobjectToSetOfField.put(ressmoMap.Object_Name__c, new Set<String>{ressmoMap.Field_Name__c});
            }
        }
        return sobjectToSetOfField;
    }

    /**
     * @description : Retrieves a single quote record with its related quote lines and opportunity contact role records,
     * based on the specified fields from the metadata.
     *
     * @param sobjectToSetOfField A map containing the object name as the key and a set of field names as the value.
     * @param quoteId The ID of the quote record to retrieve.
     * @return The quote record with its related quote lines and opportunity contact role records.
     */
    public static SBQQ__Quote__c getQuoteWithQuoteLinesWithFieldsFromMetaData(
        Map<String, Set<String>> sobjectToSetOfField,
        Id quoteId
    ) {
        return RESSMOService.getQuotesAndQuoteLinesWithFieldsFromMetaData(
            new Set<Id>{ quoteId },
            sobjectToSetOfField
        )[0];
    }

    /**
     * @description : Retrieves a multiple quote record with its related quote lines and opportunity contact role records,
     * based on the specified fields from the metadata.
     *
     * @param quoteIds The IDs of the quote record to retrieve.
     * @param sobjectToSetOfField A map containing the object name as the key and a set of field names as the value.
     * @return The quote record with its related quote lines and opportunity contact role records.
     */
    public static List<SBQQ__Quote__c> getQuotesAndQuoteLinesWithFieldsFromMetaData(
        set<Id> quoteIds,
        Map<String, Set<String>> sobjectToSetOfField
    ) {
        return QuotesSelector.newInstance()
                    .selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields(
                        quoteIds,
                        RESSMOService.getQuoteFieldsFromMapping(sobjectToSetOfField));
    }

    /**
     * @description : Returns a map of quote fields and their related fields based on the given sobjectToSetOfField mapping.
     *
     * @param sobjectToSetOfField - A map containing sObject names as keys and sets of field names as values.
     * @return A map of quote fields and their related fields.
     */
    public static Map<String, Set<String>> getQuoteFieldsFromMapping(Map<String, Set<String>> sobjectToSetOfField){
        Set<String> quoteFields = sobjectToSetOfField.get(QUOTE_OBJECT) != null ? sobjectToSetOfField.get(QUOTE_OBJECT) : new Set<String>();
        quoteFields.addAll(prependStringToSet(sobjectToSetOfField.get(OWNER_OBJECT), PARENT_RELATIONSHIP.get(OWNER_OBJECT)));
        Set<String> bizAccFields = sobjectToSetOfField.get(BUSINESS_ACCOUNT_OBJECT) != null ? sobjectToSetOfField.get(BUSINESS_ACCOUNT_OBJECT) : new Set<String>();
        quoteFields.addAll(prependStringToSet(bizAccFields, PARENT_RELATIONSHIP.get(BUSINESS_ACCOUNT_OBJECT)));
        Set<String> oppFields = sobjectToSetOfField.get(OPPORTUNITY_OBJECT) != null ? sobjectToSetOfField.get(OPPORTUNITY_OBJECT) : new Set<String>();
        quoteFields.addAll(prependStringToSet(oppFields, PARENT_RELATIONSHIP.get(OPPORTUNITY_OBJECT)));

        Set<String> contactFields = sobjectToSetOfField.get(CONTACT_OBJECT) != null ? sobjectToSetOfField.get(CONTACT_OBJECT) : new Set<String>();

        Map<String, Set<String>> quoteAndRelatedField = new Map<String, Set<String>>{
            QUOTE_LINE_OBJECT => sobjectToSetOfField.get(QUOTE_LINE_OBJECT) != null ? sobjectToSetOfField.get(QUOTE_LINE_OBJECT) : new Set<String>(),
            QUOTE_OBJECT => quoteFields,
            CONTACT_OBJECT => prependStringToSet(contactFields, PARENT_RELATIONSHIP.get(CONTACT_OBJECT))
        };

        return quoteAndRelatedField;
    }

    /**
     * @description : Prepend a given prefix to each element in a Set of Strings.
     *
     * @param inputSet The Set of Strings to be modified.
     * @param prefix The prefix to be prepended to each element.
     * @return The modified Set of Strings with the prefix prepended to each element.
     */
    @TestVisible
    private static Set<String> prependStringToSet(Set<String> inputSet, String prefix) {
        // Initialize the output Set
        Set<String> outputSet = new Set<String>();
        // Check if the inputSet is not null and has elements
        if (inputSet != null && !inputSet.isEmpty()) {
            // Iterate through each element in the inputSet
            for (String element : inputSet) {
                // Prepend the prefix to each element
                String modifiedElement = prefix +'.'+ element;
                // Add the modified element to the outputSet
                outputSet.add(modifiedElement);
            }
        }
        // Return the processed outputSet
        return outputSet;
    }

    /**
    * @description SSMO API call to send the data.
    * @param requestBody
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    public static SSMOWrapper.ResultMessageWrapper ssmoAPICall(String requestBody) {
        SSMOWrapper.ResultMessageWrapper ssmoResultWrapper  = new SSMOWrapper.ResultMessageWrapper();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+ NAMED_CREDENTIAL);
        req.setMethod(HTTP_POST);
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res;
        String responseString = '';

        if(System.Label.RESSMO_Response=='NA'){
            res = http.send(req);
            responseString = res.getBody();
        }else{
            responseString = System.Label.RESSMO_Response;
        }
        RESSMOResponseWrapper restAPIResponse = RESSMOResponseWrapper.parse(responseString);
        Integer statusCode = System.Label.RESSMO_Response_Code!='NA'? Integer.valueOf(System.Label.RESSMO_Response_Code) : res.getStatusCode();
        ssmoResultWrapper =  createSSMOWrap(restAPIResponse,statusCode);

        if(statusCode != 200){
            ssmoResultWrapper.messages = new List<String>{responseString};
            String requestBodyWithMaskingField= maskingRequestBodyFields(requestBody);
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(SERVICE_NAME_RESSMO_SEND_TO_SSMO, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logCallout( requestBodyWithMaskingField, requestBodyWithMaskingField, responseString , req.getEndpoint())
                .setCategory(LOG_RESSMO_CATEGORY)
                .setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
            );
        }

        handleSSMOValidation(restAPIResponse, ssmoResultWrapper, statusCode);
        return ssmoResultWrapper;
    }

    /**
    * @description
    * @jira LEM-16434
    * @param requestBody
    * @return string
    **/
    public static string maskingRequestBodyFields(String requestBody){
        String requestBodyToMask = requestBody;
        // Define the strings to identify the keys whose values need to be masked
        String accountString = '\"Bank_Account_Number__c\" : \"';
        String routingString = '\"RoutingNumber__c\" : \"';
        String instituteString = '\"Institution_Number__c\" : \"';
        String taxIDString = '\"TaxId__c\" : \"';
        Set<String> dataToMask = new Set<String>{accountString, routingString, instituteString, taxIDString};
        Map<String, Integer> attributeToIndex = new Map<String, Integer>();
        for (String attribute : dataToMask) {
            Integer index = requestBodyToMask.indexOf(attribute);
            if (index != -1) {
                attributeToIndex.put(attribute, index + attribute.length());
            }
        }
        for (String attribute : attributeToIndex.keySet()) {
            Integer index = attributeToIndex.get(attribute);
            if (index != null) {
                Integer endIndex = requestBodyToMask.indexOf('\"', index);
                if (endIndex != -1) {
                    String toReplace = requestBodyToMask.substring(index, endIndex);
                    String masked = toReplace.replaceAll('.', '*');
                    requestBodyToMask = requestBodyToMask.substring(0, index) + masked + requestBodyToMask.substring(endIndex);
                }
            }
        }
        return requestBodyToMask;
    }

    /**
     * @description Processing the API response to send back to the UI involves ensuring that the data is formatted correctly before returning it.
     * @param restAPIResponse
     * @param statusCode
     * @return SSMOWrapper.ResultMessageWrapper
     **/
    public static SSMOWrapper.ResultMessageWrapper createSSMOWrap(RESSMOResponseWrapper restAPIResponse,integer statusCode) {
        SSMOWrapper.ResultMessageWrapper ssmoWrap = new SSMOWrapper.ResultMessageWrapper();
        if(statusCode == 200){
            ssmoWrap.status = SSMO_WRAPPER_STATUS_SUCCESS;
            if(restAPIResponse.message!=null){
                ssmoWrap.messages = new List<String>{restAPIResponse.message};
			}
            //Handle banking
            handleBankingFailure(restAPIResponse, ssmoWrap);
        }else{
            ssmoWrap.status = SSMO_WRAPPER_STATUS_FAILED;
            if(restAPIResponse.error_message!=null){
                ssmoWrap.messages = new List<String>{restAPIResponse.error_message};
            }
        }

        ssmoWrap.uuid = restAPIResponse.uuid;
        ssmoWrap.onboardingLink = restAPIResponse.onboardingLink;
        return ssmoWrap;
    }

    private static void handleSSMOValidation(RESSMOResponseWrapper restAPIResponse, SSMOWrapper.ResultMessageWrapper ssmoWrap, integer statusCode) {

        if(statusCode == 200){
            ssmoWrap.status = SSMO_WRAPPER_STATUS_SUCCESS;
        if (restAPIResponse.success == True){
            ssmoWrap.messages = new List<String>{'Success'};
                }else{
               ssmoWrap.messages = restAPIResponse.messages;
            }
        }else{
            ssmoWrap.status = SSMO_WRAPPER_STATUS_FAILED;
                    ssmoWrap.messages = restAPIResponse.messages;
                }
    }
    /**
    * @description Handling the banking information from the RESSMO API call response.
    * @author Pankaj | 07-12-2024
    * @param restAPIResponse
    * @param ssmoWrap
    **/
    private static void handleBankingFailure(RESSMOResponseWrapper restAPIResponse, SSMOWrapper.ResultMessageWrapper ssmoWrap) {
        if (restAPIResponse.banking != null && !restAPIResponse.banking.success) {
            ssmoWrap.messages = new List<String>{restAPIResponse.message};
            ssmoWrap.status = SSMO_WRAPPER_STATUS_SUCCESS; // This line seems redundant as the status is already set to SUCCESS in the caller method
        }
    }

     /**
     * @description Calling the API to send the quote and related information to SSMO.
     * @param quoteId
     * @param ressmoLink
     * @param isValidateOnly
     * @return SSMOWrapper.ResultMessageWrapper
     **/
     public static SSMOWrapper.ResultMessageWrapper sendQuote(Id quoteId, String ressmoLink,Boolean isValidateOnly) {
        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        List<RESSMO_Mapping__mdt> ressmoMappingMdt  =  new List<RESSMO_Mapping__mdt>();
        try {
            if(String.isNotBlank(ressmoLink)){
            	ressmoMappingMdt = RessmoMappingsSelector.newInstance().selectAddToUpdateRessmoMappings();
            }else{
                ressmoMappingMdt = RessmoMappingsSelector.newInstance().selectAllRessmoMappings();
            }
            String requestBody = RESSMOService.prepareRequestJSON(quoteId, ressmoMappingMdt, isValidateOnly);
            result = ssmoAPICall(requestBody);

        } catch (Exception ex) {
            result.status = SSMO_WRAPPER_STATUS_FAILED;
            result.messages.clear();
            result.messages.add(ex.getMessage());
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_NNS_SEND_QUOTE_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{quoteId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
        }
        return result;
    }


    /**
    * @description
    * @author Pankaj | 07-15-2024
    * @param quoteId
    * @param result
    **/
    public static void updateRESSMOSobjectRecords(Id quoteId , SSMOWrapper.ResultMessageWrapper result){
        if (result == null || String.isBlank(result.uuid)) {
        	return;
        }
		try {
            SBQQ__Quote__c quote = QuotesSelector.newInstance().selectByIdWithAccountOpportunityContacts(quoteId);
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            updateSobject(quote.Id, result, SBQQ__Quote__c.SObjectType, uow);
            updateSobject(quote.RESSMO_Store_Account_Id__c, result, Account.SObjectType, uow);
            updateSobject(quote.SBQQ__Opportunity2__c, result, Opportunity.SObjectType, uow);
            if (quote.Opportunity_Contact_Role__r != null && !quote.Opportunity_Contact_Role__r.isEmpty()) {
                for (OpportunityContactRole ocr : quote.Opportunity_Contact_Role__r) {
                    updateSobject(ocr.ContactId, result, Contact.SObjectType, uow);
                }
            }
			uow.commitWork();

        } catch (Exception ex) {
            GenericLoggerService.publish(GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_NNS_SEND_QUOTE_LINK_PROCESSING_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{quoteId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
        }

    }

    /**
     * @description Updates the SSMO validations for a record.
     * @param recordId The ID of the record to update.
     * @param messages The list of validation messages.
     * @param sObjectType The schema SObjectType of the record.
     * @return The concatenated validation messages.
     */
    public static String updateSSMOValidations(Id recordId, List<String> messages, Schema.SObjectType sObjectType){
        if (String.isNotBlank(recordId)) {
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            SObject sObjectToUpdate = sObjectType.newSObject(recordId);
        String allMessages = '';
        if (!messages.isEmpty()) {
            allMessages = String.join(messages, ', ');
        }
        sObjectToUpdate.put('SSMO_Validation__c', allMessages);
        uow.registerDirty(sObjectToUpdate);
        uow.commitWork();
         return allMessages;
       }
        return '';
    }
	/**
    * @description Sobject record updating with UUID value
    * @author Pankaj | 07-16-2024
    * @param recordId
    * @param resultWrp
    * @param sObjectType
    * @param uow
    **/
    private static void updateSobject(Id recordId, SSMOWrapper.ResultMessageWrapper resultWrp, Schema.SObjectType sObjectType, fflib_ISObjectUnitOfWork uow) {
        if (String.isNotBlank(recordId)) {
            SObject sObjectToUpdate = sObjectType.newSObject(recordId);
            sObjectToUpdate.put('Unique_Identifier__c', resultWrp.uuid);

            String sObjectName = sObjectToUpdate.getSObjectType().getDescribe().getName();
            Set<String> sObjectsApiName = new set<String>{'Contact','Opportunity'};
            if(sObjectsApiName.contains(sObjectName)){
                sObjectToUpdate.put('RESSMO_link__c', resultWrp.onboardingLink);
            }
            if(sObjectName.equalsIgnoreCase('SBQQ__Quote__c')){
                sObjectToUpdate.put('SBQQ__Status__c', 'Out for Signature');
            }
            uow.registerDirty(sObjectToUpdate);
        }
    }


    /**
    * @description
    * @author SamikshaDD | 07-12-2024
    * @param requestBody
    * @return SSMOWrapper.ResultMessageWrapper
    **/
    public static SSMOWrapper.ResultMessageWrapper ssmoManageRESSMOLinkAPICall(String requestBody) {
        SSMOWrapper.ResultMessageWrapper ssmoResultWrapper  = new SSMOWrapper.ResultMessageWrapper();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:'+ NAMED_CREDENTIAL);
        req.setMethod(HTTP_POST);
        req.setBody(requestBody);
        Http http = new Http();
        HTTPResponse res;
        String responseString = '';

        if(System.Label.RESSMO_Void_Response =='NA'){
            res = http.send(req);
            responseString = res.getBody();
        }else{
            responseString = System.Label.RESSMO_Void_Response ;
        }
        RESSMOResponseWrapper restAPIResponse = RESSMOResponseWrapper.parse(responseString);
        Integer statusCode = System.Label.RESSMO_Void_Response_Code !='NA'? Integer.valueOf(System.Label.RESSMO_Void_Response_Code) : res.getStatusCode();
        ssmoResultWrapper =  createSSMOWrap(restAPIResponse,statusCode);

        if(statusCode != 200){
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(SERVICE_NAME_RESSMO_MANAGE_RESSMO_LINK, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logCallout( requestBody, req.getBody(), responseString , req.getEndpoint())
                .setCategory(LOG_RESSMO_CATEGORY)
                .setLogLevel(LOG_RESSMO_LOG_LEVEL_INFO)
            );
        }
        return ssmoResultWrapper;
    }

    /**
    * @description get contract and associated subscriptions and products.
    * @JIRA# LEM-17378
    * @param contractId
    * @return Contract
    **/
    public static Contract getContractsWithSubscriptionsProducts(Id contractId){
        return ContractsSelector.newInstance().selectContractsWithActiveSubscriptionsProducts(new set<Id>{contractId})[0];
    }


    /**
    * @description  Validating eligibility for contract subscription products
    * @param contract
    * @param storeAccount
    * @param contractSignatory
    * @param quote
    * @return Map<string, List<String>>
    **/
    public static Map<string,List<String>> getEligibilityMessagesForContract(Contract contract, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote) {
        Map<String, List<String>> objectVsEligibilityMessages= new Map<String, List<String>>();
        Map<String, List<String>> storeObjectVsEligibilityMessages = new Map<String, List<String>>();
        Map<String, sObject> sObjectMap = new Map<String, sObject>();
        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectRessmoMappingsOfContract();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);
        List<Contract> contracts = ContractsSelector.newInstance().selectContractsandRelatedRecords(new set<Id>{contract.Id}, getAllContractRelatedObjectFields(sobjectToSetOfField));
        Contract contractObj = contracts !=null && contracts.size() > 0 ? contracts[0] : new Contract();
        SObject bizAcc = (contractObj != null && contractObj.Account != null) ? contractObj.Account : new Account();
        if(storeAccount != null){
            sObjectMap.put(STORE_ACCOUNT_OBJECT, storeAccount);
        }
        subscriptionsValidation(objectVsEligibilityMessages, contractObj);
        contractValidation(objectVsEligibilityMessages, contractObj);
        if(bizAcc !=null){
            businessAccountValidations(objectVsEligibilityMessages, bizAcc);
            removeElibilityMessageFromMap(objectVsEligibilityMessages, BUSINESS_ACCOUNT_OBJECT, System.Label.RESSMO_Eligibility_Error_Countries+ ' '+String.join(new List<String>(VALID_COUNTRIES), ' or '));
        }
        storeObjectVsEligibilityMessages = RESSMOService.storeEligibilityMessagesForRESSMO(sObjectMap);
        for(String objName : storeObjectVsEligibilityMessages.keySet()){
            if (!objectVsEligibilityMessages.containsKey(objName)) {
                objectVsEligibilityMessages.put(objName, new List<String>());
            }
            objectVsEligibilityMessages.get(objName).addAll(storeObjectVsEligibilityMessages.get(objName));
        }
        return objectVsEligibilityMessages;
    }

    /**
    * @description Generic method to remove an eligibility message from the map.
    * @param objectVsEligibilityMessages
    * @param key
    * @param message
    **/
    public static void removeElibilityMessageFromMap(Map<String, List<String>> objectVsEligibilityMessages, String key, String message) {
        if (objectVsEligibilityMessages != null && key != null && message != null && objectVsEligibilityMessages.containsKey(key)) {
            List<String> eligibilityMsg = objectVsEligibilityMessages.get(key);
            if (eligibilityMsg != null && eligibilityMsg.contains(message)) {
                eligibilityMsg.remove(eligibilityMsg.indexOf(message));
                objectVsEligibilityMessages.put(key, eligibilityMsg);
            }
        }
    }

    /**
    * @description Validating subscription Product.
    * @author Pankaj | 07-18-2024
    * @param objectVsEligibilityMessages
    * @param contract
    **/
    private static void subscriptionsValidation(Map<String, List<String>> objectVsEligibilityMessages, Contract contract) {
        Set<String> ssmoIneligibleProducts = new Set<String>();
        Set<String> subscriptionProductCodes = new Set<String>();
        if (contract == null || contract.SBQQ__Subscriptions__r == null) {
            return;
        }
        for (SBQQ__Subscription__c subscription : contract.SBQQ__Subscriptions__r) {
            if (subscription.SBQQ__Product__r == null) {
                continue;
            }
            if (!subscription.SBQQ__Product__r.SSMO_Eligible__c) {
                ssmoIneligibleProducts.add(subscription.SBQQ__Product__r.Name);
            }
            if (subscription.SBQQ__Product__r.ProductCode != null) {
                subscriptionProductCodes.add(subscription.SBQQ__Product__r.ProductCode);
            }
        }
        if (!ssmoIneligibleProducts.isEmpty()) {
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, SUBSCRIPTION_OBJECT, System.Label.RESSMO_Eligibility_Error_InEligibleProducts + ' ' + String.join(new List<String>(ssmoIneligibleProducts), ', '));
        }
        for(String pc : REQUIRED_RESSMO_PRODUCTCODES){
            if(!subscriptionProductCodes.contains(pc)){
                createObjectVsEligibilityMessage(objectVsEligibilityMessages, SUBSCRIPTION_OBJECT, System.Label.RESSMO_Eligibility_Error_RequiredProductCode);
                break;
            }
        }
    }

    /**
    * @description
    * @author Pankaj | 08-23-2024
    * @param objectVsEligibilityMessages
    * @param contract
    **/
    private static void contractValidation(Map<String, List<String>> objectVsEligibilityMessages, Contract contract){
        List<Contract> listContract =  ContractsSelector.newInstance().selectByParentAccountId(new Set<Id>{contract.AccountId});
        if(listContract !=null && listContract.size() > 1){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, CONTRACT_OBJECT, System.Label.RESSMO_Eligibility_Error_Multiple_Contract);
        }
        if(String.isBlank(contract.RESSMO_Store_Account_Id__c))
        {
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, CONTRACT_OBJECT, System.Label.RESSMO_Store_Not_Selected_Message);
        }
        if(!String.isblank(contract.SSMO_Validation__c) && contract.SSMO_Validation__c != 'Success'){
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, CONTRACT_OBJECT, contract.SSMO_Validation__c);
        }
        if(contract.Pricing_Variation_Type__c == PRICING_VARIATION_TYPE_UNEXPLAINABLE)
        {
            createObjectVsEligibilityMessage(objectVsEligibilityMessages, CONTRACT_OBJECT, System.Label.RESSMO_Contract_Pricing_Variation_Validation );
        }
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
        SSMOWrapper.ResultMessageWrapper result = new SSMOWrapper.ResultMessageWrapper();
        try {
            string payload = RESSMOService.generateRESSMOPayloadForNewStore(contractId, storeAccount, contractSignatory, quote, isValidateOnly);
            result = RESSMOService.ssmoAPICall(payload);
        } catch (Exception ex) {
            result.status = SSMO_WRAPPER_STATUS_FAILED;
            result.messages.clear();
            result.messages.add(ex.getMessage());
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_NAME_RESSMO_NSE_SEND_CONTRACT_ERROR, GENERIC_LOG_DOMAIN, GenericLogEntry.SeverityLevel.HIGH )
                .logException(ex).logSFRecordId(new Set<String>{contractId}).setCategory(LOG_RESSMO_CATEGORY).setLogLevel(LOG_RESSMO_LOG_LEVEL_ERROR)
            );
        }
        return result;
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
    public static String generateRESSMOPayloadForNewStore(Id contractId, Account storeAccount, Contact contractSignatory, SBQQ__Quote__c quote, boolean isValidateOnly){
        Set<String> businessVertical = new Set<String>();
        List<Xref__c> xref;
        String jsonPayload = '';
        Map<String, sObject> ddmxObjectToSobject = new Map<String, sObject>();
        List<RESSMO_Mapping__mdt> ressmoMappings = RessmoMappingsSelector.newInstance().selectRessmoMappingsOfContract();
        Map<String, Set<String>> sobjectToSetOfField = RESSMOService.getMapOfSobjectAndSetOfField(ressmoMappings);
        List<Contract> contracts = ContractsSelector.newInstance().selectContractsandRelatedRecords(new set<Id>{contractId}, getAllContractRelatedObjectFields(sobjectToSetOfField));
        Account businessAccount = contracts!=null && contracts[0].Account !=null ?  contracts[0].Account : null;
        Opportunity opty = contracts!=null && contracts[0].SBQQ__Opportunity__c !=null ?  contracts[0].SBQQ__Opportunity__r : null;
        User contractSalesRep = contracts!=null && contracts[0].Owner !=null ?  contracts[0].Owner : null;
        List<SBQQ__Subscription__c> subscriptions = contracts!=null && contracts[0].SBQQ__Subscriptions__r !=null ?  contracts[0].SBQQ__Subscriptions__r : new List<SBQQ__Subscription__c>();
        businessVertical.addAll(System.label.RestaurantMenuUIType.split(','));
        xref = XrefsSelector.newInstance().selectByBusinessAccountId(new set<String>{businessAccount.Id},businessVertical, new set<String>{businessAccount.CurrencyIsoCode});
        Business_Reference__c busRef = (xref!=null && xref.size()>0 && xref[0].Business_Reference__c !=null) ? xref[0].Business_Reference__r: null;
        //fetching Account,Contact,Xref,AccountPayment
        Account storeObjAccount = RESSMOService.getAccountWithXrefsDecisionMakerPaymentAccount(sobjectToSetOfField, storeAccount.Id);
        RESSMOService.populateStoreAccountSobjectsRelatedToStore(ddmxObjectToSobject, storeObjAccount);
        Contract contract = contracts !=null ? contracts[0]: null;


        ddmxObjectToSobject.put(BUSINESS_ACCOUNT_OBJECT, businessAccount);
        ddmxObjectToSobject.put(OPPORTUNITY_OBJECT, opty);
        ddmxObjectToSobject.put(QUOTE_OBJECT, quote);
        ddmxObjectToSobject.put(CONTRACT_SALES_REP, contractSalesRep);
        ddmxObjectToSobject.put(CONTRACT_OBJECT, contracts[0]);
        ddmxObjectToSobject.put(BUSINESS_REFERENCE_OBJECT, busRef);
        ddmxObjectToSobject.put(CONTACT_OBJECT, contractSignatory);

        jsonPayload = writeJSONforContract(ressmoMappings,ddmxObjectToSobject, subscriptions, isValidateOnly);
        jsonPayload = updateContractJsonPayload(contract, jsonPayload);
        return jsonPayload;
    }

    /**
    * @description updating the Contract Payload number of
    * @param contract
    * @param jsonPayload
    * @return String
    **/
    public static String updateContractJsonPayload(Contract contract, String jsonPayload) {
        if (contract == null || contract.Mx_Onboarding_Links__r == null ||  contract.Mx_Onboarding_Links__r.size() <= 0) {
            return jsonPayload;
        }
        String numberOfStores;
        Map<String, Object> objectMap = (Map<String, Object>) JSON.deserializeUntyped(contract.Mx_Onboarding_Links__r[0].Payload__c);
        if (objectMap.containsKey(MX_ONBOARDING_PAYLOAD_GENERICINPUT)) {
            Map<String, Object> genericInputMap = (Map<String, Object>) objectMap.get(MX_ONBOARDING_PAYLOAD_GENERICINPUT);
            if (genericInputMap.containsKey(MX_ONBOARDING_PAYLOAD_QUOTE)) {
                Map<String, Object> quoteMap = (Map<String, Object>) genericInputMap.get(MX_ONBOARDING_PAYLOAD_QUOTE);
                numberOfStores = getNumberOfStores(quoteMap);
            }
        }
        if(String.isNotBlank(numberOfStores)){
            String regex = '"' + NUMBER_OF_STORES + '"\\s*:\\s*"(\\d*|)"';
            jsonPayload = jsonPayload.replaceAll(regex, '"' + NUMBER_OF_STORES + '" : "' + numberOfStores + '"');
        }
        return jsonPayload;
    }

    /**
    * @description
    * @param quoteMap
    * @return String
    **/
    public static String getNumberOfStores(Map<String, Object> quoteMap) {
        if (quoteMap.containsKey(MX_ONBOARDING_PAYLOAD_NUMBEROFSTORES)) {
            Object numberOfStoresObj = quoteMap.get(MX_ONBOARDING_PAYLOAD_NUMBEROFSTORES);
            if (numberOfStoresObj instanceof String) {
                return (String) numberOfStoresObj;
            } else if (numberOfStoresObj instanceof Integer) {
                return String.valueOf((Integer) numberOfStoresObj);
            }
        }
        return null;
    }

	/**
	* @description
	* @jira LEM-17697
	* @param ressmoMappings
	* @param ddmxObjectToSobject
	* @param subscriptions
    * @param isValidateOnly
	* @return String
	**/
	private static String writeJSONforContract(List<RESSMO_Mapping__mdt> ressmoMappings, Map<String, sObject> ddmxObjectToSobject,List<SBQQ__Subscription__c> subscriptions, Boolean isValidateOnly){
        JSONGenerator reqGenerator = JSON.createGenerator(true);
        reqGenerator.writeStartObject();
        Map<String, List<RESSMO_Mapping__mdt>> jsonObjectToRessmoMapping = getJsonObjectNameToListOfRessmoMapping(ressmoMappings);
        reqGenerator.writeBooleanField('isQuoteSSMOEligible', isValidateOnly);
        for(String jsonObjectName : jsonObjectToRessmoMapping.keyset()){
            if(jsonObjectName == QUOTELINE_JSON_OBJECT){
                continue;
            }
            Boolean validBanking = bankingInfoExists(ddmxObjectToSobject);
            reqGenerator.writeFieldName(jsonObjectName);
            reqGenerator.writeStartObject();
            for(RESSMO_Mapping__mdt ressmoMap : jsonObjectToRessmoMapping.get(jsonObjectName)){
                if(ressmoMap.JSON_Object__c == jsonObjectName){
                    if(!ressmoMap.Is_Banking__c || validBanking){
                        Object fieldValue = getFieldValue(ressmoMap, ddmxObjectToSobject);
                        createJSONProperty(reqGenerator, ressmoMap, fieldValue);
                    }
                }
            }
            reqGenerator.writeEndObject();
        }

        Map<Id, Set<Id>> subsPackageToProductOptions = subsPackageToProductOptionsMap(subscriptions);
        Map<Id, SBQQ__Subscription__c > subsIdToSubscriptions = new Map<Id, SBQQ__Subscription__c>(subscriptions);
        reqGenerator.writeFieldName(QUOTELINE_JSON_OBJECT);
        reqGenerator.writeStartArray();
        for(Id subsId : subsPackageToProductOptions.keySet()){
            reqGenerator.writeStartObject();
            SBQQ__Subscription__c pkg = subsIdToSubscriptions.get(subsId);
            writeJSONForSubs(reqGenerator, jsonObjectToRessmoMapping.get(QUOTELINE_JSON_OBJECT), pkg);
            reqGenerator.writeFieldName('Product_Options');
            reqGenerator.writeStartArray();
            for(Id subsIdInPackage : subsPackageToProductOptions.get(subsId)){
                reqGenerator.writeStartObject();
                SBQQ__Subscription__c sub = subsIdToSubscriptions.get(subsIdInPackage);
                writeJSONForSubs(reqGenerator, jsonObjectToRessmoMapping.get(QUOTELINE_JSON_OBJECT), sub);
                reqGenerator.writeEndObject();
            }
            reqGenerator.writeEndArray();
            reqGenerator.writeEndObject();
        }
        reqGenerator.writeEndArray();
        reqGenerator.writeEndObject();
        String requestJSON = reqGenerator.getAsString();
        return requestJSON;
    }

    /**
    * @description
    * @jira LEM-17697
    * @param sobjectToSetOfField
    * @return Map<String, Set<String>>
    **/
    @TestVisible
    private static  Map<String, Set<String>> getAllContractRelatedObjectFields(Map<String, Set<String>> sobjectToSetOfField){
		Set<String> accountFields = sobjectToSetOfField.get(BUSINESS_ACCOUNT_OBJECT) != null ? prependStringToSet( sobjectToSetOfField.get(BUSINESS_ACCOUNT_OBJECT), ACCOUNT_OBJECT ) : new Set<String>();
        Set<String> oppportunityFields = sobjectToSetOfField.get(OPPORTUNITY_OBJECT) != null ? prependStringToSet( sobjectToSetOfField.get(OPPORTUNITY_OBJECT), CONTRACT_OPPORTUNITY_RELATIONSHIP) : new Set<String>();
        Set<String> subsFields = sobjectToSetOfField.get(SUBSCRIPTION_OBJECT) != null ? sobjectToSetOfField.get(SUBSCRIPTION_OBJECT) : new Set<String>();
        Set<String> ownerFields = sobjectToSetOfField.get(CONTRACT_SALES_REP) != null ? prependStringToSet( sobjectToSetOfField.get(CONTRACT_SALES_REP), CONTRACT_SALES_REP_RELATIONSHIP) : new Set<String>();
        Set<String> contractFields = sobjectToSetOfField.get(CONTRACT_OBJECT) != null ? sobjectToSetOfField.get(CONTRACT_OBJECT) : new Set<String>();

        Map<String, Set<String>> objectNameToSetOfFields = new Map<String, Set<String>>{
            'Account' => accountFields,
            CONTRACT_OPPORTUNITY_RELATIONSHIP => oppportunityFields,
            'Contract' => contractFields,
            CONTRACT_SALES_REP_RELATIONSHIP => ownerFields,
            SUBSCRIPTION_OBJECT => subsFields
        };
        return objectNameToSetOfFields;
    }

    /**
    * @description
    * @jira LEM-17697
    * @param subscriptions
    * @return Map<Id, Set<Id>>
    **/
    private static Map<Id, Set<Id>> subsPackageToProductOptionsMap(List<SBQQ__Subscription__c> subscriptions){
        Map<Id, Set<Id>> subsPackageToProductOptions = new Map<Id, Set<Id>>();
        for(SBQQ__Subscription__c subs : subscriptions){
            if( subs.SBQQ__RequiredById__c != null ){
                if(subsPackageToProductOptions.containsKey(subs.SBQQ__RequiredById__c)){
                    subsPackageToProductOptions.get(subs.SBQQ__RequiredById__c).add(subs.Id);
                }else{
                    subsPackageToProductOptions.put(subs.SBQQ__RequiredById__c, new Set<Id>{subs.Id});
                }
            }
            else if(!subsPackageToProductOptions.containsKey(subs.Id)){
                subsPackageToProductOptions.put(subs.Id, new Set<Id>{});
            }
        }
        return subsPackageToProductOptions;
    }

     /**
    * @description
    * @jira LEM-17697
    * @param reqGenerator
    * @param ressmoMappings
    * @param subscription
    **/
    private static void writeJSONForSubs(JSONGenerator reqGenerator, List<RESSMO_Mapping__mdt> ressmoMappings, SBQQ__Subscription__c  subscription){
        for(RESSMO_Mapping__mdt ressmoMap : ressmoMappings){
            //Object fieldValue = quoteLine.get(ressmoMap.Field_Name__c);
            Object fieldValue = getFieldValue(subscription, ressmoMap.Field_Name__c);
            if(ressmoMap.Products__c == null || ressmoMap.Products__c.contains(subscription.SBQQ__Product__r.ProductCode)){
                createJSONProperty(reqGenerator, ressmoMap, fieldValue);
            }
        }
    }

    /**
    * @description
    * @jira LEM-17378
    * @param objectVsEligibilityMessages
    * @param objectName
    * @param eligibilityMessages
    **/
    public static void createObjectVsEligibilityMessage(Map<String, List<String>> objectVsEligibilityMessages, String objectName, String eligibilityMessages) {
        if (!objectVsEligibilityMessages.containsKey(objectName)) {
            objectVsEligibilityMessages.put(objectName, new List<String>());
        }
        objectVsEligibilityMessages.get(objectName).add(eligibilityMessages);
    }

}