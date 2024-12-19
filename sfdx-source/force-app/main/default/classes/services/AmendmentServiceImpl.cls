/**
 * @author Aetherus
 * @date 30/05/2024
 * @description Service implementation class for AmendmentService related logic.
 */
@SuppressWarnings('PMD.CyclomaticComplexity,PMD.StdCyclomaticComplexity,PMD.NcssMethodCount')
public inherited sharing class AmendmentServiceImpl implements IAmendmentService {
    private static final String ADDRESSED_NOT_VERIFIED = 'Please ensure that Address and Data Verification Status fields on the Account is Verified';
    private static final String PREFERRED_LANGUAGE = 'Please update the Preferred Language field on the associated Business Account before proceeding with quote creation.';
    private static final String LEGAL_ENTITY_MESSAGE = 'Please populate Country on Business Account before proceeding with quote creation. This will automatically populate DoorDash Legal Entity';
    private static final String SMB_PRIMARY_VERTICAL_VALIDATION = 'You must select Primary Vertical as Rx on the Account before creating a quote.';
    private static final String SMB_LEGAL_BUSINESS_NAME = 'Legal Business Name on Account must be populated in order to create a quote against the opportunity.';
    private static final String SMB_BRAND_VALIDATION = 'Please ensure Opportunity Brand Relationship is present on the Opportunity before proceeding with quote creation.';
    private static final String SMB_OCR_VALIDATION = 'Please ensure one Primary Contact and one Contact Role with Contract Signatory must be associated with this opportunity. You may have two separate contacts in order to meet this requirement (one Primary Contact and one Contract Signatory), or a single contact that serves as both (Primary Contact and Contract Signatory)';
    private static final String BUSINESS_RECORDTYPE = 'Business';
    private static final String BYPASS_VALIDATIONS = 'Bypass_Quote_Validation_Rules';
    private static final String VALIDATED_STATUS = 'Verified';
    private static final String SMB_SEGMENT = 'SMB';
    private static final String SMB_PRIMARY_VERTICAL = 'Rx';
    private static final String CHANNELPARTNER_RECORDTYPE = 'Channel_Partner';
    private static final String SOURCEMAPPINGTYPE = 'Copy from Source';
    private static final String STATICMAPPINGTYPE = 'Fixed Value';
    private static final String CLASSNAME = 'AmendmentServiceImpl';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final String OBJECT_TYPE_QUOTE = 'SBQQ__Quote__c';
    private static final String OBJECT_TYPE_QUOTELINEGROUP = 'SBQQ__QuoteLineGroup__c';
    private static final String OBJECT_TYPE_QUOTELINE = 'SBQQ__QuoteLine__c';
    private static final String OBJECT_TYPE_SUBSCRIPTIONS = 'SBQQ__Subscription__c';
    private static final String OBJECT_TYPE_OPPORTUNITY = 'Opportunity';
    private static final String OBJECT_TYPE_WORKORDER = 'WorkOrder';
    private static final String CONTRACT_SOURCE = 'Contract';
    private static final String CONTRACT_SPLIT_CATEGORY_A_AND_P = 'A&P';

    private static final date DATE_TODAY = Date.today();
    private static final Boolean BOOLEAN_FALSE = false;
    private static final Boolean BOOLEAN_TRUE = true;

    private static final String LOG_AMEND_CUSTOM_QUOTE = 'Amendment Service Implementation';
    private static final String LOG_AMEND_QUOTE_CREATION = 'Amendment Quote Creation';
    private static final String SUCCESSFUL_MESSAGE = 'Quote created successfully';
    private static final String UNSUCCESSFUL_MESSAGE =
        'There was problem while creating the quote. Therefore' +
        ' it is not successful. Kindly try after sometime.';
    private static final String UNSUCCESSFUL_MESSAGE_OPPORTUNITY_WORKORDER =
        'There was problem while creating the Opportunity and Work Order. Therefore' +
        ' it is not successful. Kindly try after sometime.';
    private static final String NO_ACTIVE_SUBSCRIPTIONS = 'No active subscriptions found for the given contract ID.';
    private static final String UNSUCCESSFUL_MESSAGE_NULL_SUBTYPE_ACCOUNTID = 'Opportunity Sub Type and Account ID cannot be null.';
    private static final String ERROR_MESSAGE =
        'There was exception while creating the quote. Kindly' +
        ' check with you administator for more details';
    private static final String UNSUCCESSFUL_OPPORTUNITY = 'There was problem while getting the Oppportunity. ';
    private static final String UNSUCCESSFUL_CONTRACT = 'There was problem while getting the Contract. ';
    private static final String UNSUCCESSFUL_QUOTE = 'There was problem while creating the Quote. ';
    private static final String UNSUCCESSFUL_QUOTELINEGROUPANDQUOTELINE = 'There was problem while creating the Quote Line Group or Quote Lines. ';
    private static final String UNSUCCESSFUL_OPPORTUNITY_STAGES = System.Label.Errormsg_newquote_cannotbe_created_foropp;
    private static final String UNSUCCESSFUL_QUOTE_STATUS = System.Label.Errormsg_new_quote_cannot_be_created;
    private static final String UNSUCCESSFUL_CONTRACT_PRICING = System.Label.Contract_PricingVariationType_ErrorMessage;
    private static final String CONTRACT_PRICINGVARIATIONTYPE_UNEXPLAINABLE = 'Unexplainable';
    private static final String BYPASS_QUOTE_VALIDATION_RULES = 'Bypass_Quote_Validation_Rules';
    private static final String COMMOPS_USER = 'CommOps_User';

    //Map of Field Mapping by Object
    private static Map<String, Set<String>> amendmentFieldMapbyObject;

    private static List<Custom_Amendment_Field_Mapping__mdt> customAmendmentFieldMappings;
    private static List<SBQQ__Subscription__c> subscriptionList;
    private static Map<Id, Id> oldQuoteLinetoRequiredByMap;
    private static List<SBQQ__Quote__c> quoteList;

    /**
     * @description Method to create an amendment from an opportunity
     * @param opportunityId
     * @param contractId
     * @return amendmentQuoteId
     */
    @AuraEnabled
    public static String createAmendmentFromOpportunity(String opportunityId, String contractId) {
        String amendmentQuoteId = null;
        String userMessage;
        String primaryQuoteId;

        Savepoint sp;
        try {
            if (String.isEmpty(opportunityId) || String.isEmpty(contractId)) {
                return prepareResponse(amendmentQuoteId, UNSUCCESSFUL_MESSAGE, BOOLEAN_FALSE);
            }
            //Get the Opportunity
            Opportunity opportunity = getOpportunity(opportunityId);
            if (opportunity == null) {
                return prepareResponse(
                    amendmentQuoteId,
                    UNSUCCESSFUL_OPPORTUNITY + ' Id = ' + opportunityId,
                    BOOLEAN_FALSE
                );
            }

            //Get Primary Quote Id
            if (opportunity != null && opportunity.SBQQ__PrimaryQuote__c != null) {
                primaryQuoteId = opportunity.SBQQ__PrimaryQuote__c;
            }

            if (
                opportunity.Account.Segment__c == SMB_SEGMENT &&
                !FeatureManagement.checkPermission(BYPASS_VALIDATIONS)
            ) {
                if ((opportunity.CloseDate < Date.today())) {
                    return prepareResponse(
                        null,
                        System.Label.OpportunityCloseDateValidation,
                        BOOLEAN_FALSE
                    );
                }
                if (
                    (opportunity.Account.Data_Verification_Status__c != VALIDATED_STATUS ||
                    opportunity.Account.Address_Verification_Status__c != VALIDATED_STATUS)
                ) {
                    return prepareResponse(null, ADDRESSED_NOT_VERIFIED, BOOLEAN_FALSE);
                }
                if (opportunity.Account.Preferred_Language__c == null) {
                    return prepareResponse(null, PREFERRED_LANGUAGE, BOOLEAN_FALSE);
                }

                if (
                    (opportunity.Account.RecordType.DeveloperName == BUSINESS_RECORDTYPE ||
                    opportunity.Account.RecordType.DeveloperName == CHANNELPARTNER_RECORDTYPE) &&
                    opportunity.Account.DoorDash_Legal_Entity__c == null
                ) {
                    return prepareResponse(null, LEGAL_ENTITY_MESSAGE, BOOLEAN_FALSE);
                }
                if (opportunity.Account.Primary_Vertical__c != SMB_PRIMARY_VERTICAL) {
                    return prepareResponse(null, SMB_PRIMARY_VERTICAL_VALIDATION, BOOLEAN_FALSE);
                }
                if (
                    opportunity.Account.Legal_Business_Name__c == null &&
                    (opportunity.Account.RecordType.DeveloperName == BUSINESS_RECORDTYPE)
                ) {
                    return prepareResponse(null, SMB_LEGAL_BUSINESS_NAME, BOOLEAN_FALSE);
                }
                if (hasBrandRecords(opportunity.Id)) {
                    return prepareResponse(null, SMB_BRAND_VALIDATION, BOOLEAN_FALSE);
                }
                if (!checkOCRValid(opportunity.Id)) {
                    return prepareResponse(null, SMB_OCR_VALIDATION, BOOLEAN_FALSE);
                }
            }

            //Check Opportunity Stage before Creating Quote from Opportunity and Contract
            if (
                opportunity.StageName == System.Label.Opportunity_Stage_Closed_Won ||
                opportunity.StageName == System.Label.Opportunity_Stage_Closed_Lost ||
                opportunity.StageName == System.Label.Opportunity_Stage_Contracting
            ) {
                return prepareResponse(
                    amendmentQuoteId,
                    UNSUCCESSFUL_OPPORTUNITY_STAGES,
                    BOOLEAN_FALSE
                );
            }

            if (primaryQuoteId != null) {
                //Get the Primary Quote
                SBQQ__Quote__c primaryQuote = getPrimaryQuote(primaryQuoteId);
                //Check Primary Quote Status before Creating Quote from Opportunity and Contract
                if (
                    primaryQuote.SBQQ__Status__c == System.Label.Quote_Status_Out_for_Signature ||
                    primaryQuote.SBQQ__Status__c == System.Label.Quote_Contract_Signed
                ) {
                    return prepareResponse(
                        amendmentQuoteId,
                        UNSUCCESSFUL_QUOTE_STATUS,
                        BOOLEAN_FALSE
                    );
                }
            }

            //Get Contract Details
            Set<Id> contractIds = new Set<Id>{ contractId };
            Contract contract = ContractsSelector.newInstance().selectById(contractIds)[0];
            if (contract == null) {
                return prepareResponse(
                    amendmentQuoteId,
                    UNSUCCESSFUL_CONTRACT + ' Id = ' + contractId,
                    BOOLEAN_FALSE
                );
            }

            if (
                contract.Pricing_Variation_Type__c == CONTRACT_PRICINGVARIATIONTYPE_UNEXPLAINABLE &&
                !FeatureManagement.checkPermission(COMMOPS_USER) &&
                !FeatureManagement.checkPermission(BYPASS_QUOTE_VALIDATION_RULES)
            ) {
                return prepareResponse(
                    amendmentQuoteId,
                    UNSUCCESSFUL_CONTRACT_PRICING,
                    BOOLEAN_FALSE
                );
            }

            AmendmentService amendmentService = new AmendmentService();
            amendmentService.prepareMapforCustomAmendmentFields();

            // Create a savepoint in order for the operation to start
            sp = Database.setSavepoint();

            //Create the Quote from Opportunity and Contract
            SBQQ__Quote__c quote = amendmentService.createAmendmentQuote(opportunity, contract);
            if (quote == null || quote.Id == null) {
                return prepareResponse(amendmentQuoteId, UNSUCCESSFUL_QUOTE, BOOLEAN_FALSE);
            }
            amendmentQuoteId = quote.Id;

            //Check if Quoteline are successful else rollback
            Boolean isSuccessful = amendmentService.insertAmendedQuoteLines(quote, contract);
            if (!isSuccessful) {
                Database.rollback(sp);
                amendmentQuoteId = null;
                return prepareResponse(
                    amendmentQuoteId,
                    UNSUCCESSFUL_QUOTELINEGROUPANDQUOTELINE,
                    BOOLEAN_FALSE
                );
            }

            Database.releaseSavepoint(sp);
            //Successful user message
            userMessage = prepareResponse(amendmentQuoteId, SUCCESSFUL_MESSAGE, BOOLEAN_TRUE);
            //Update the Opportunity in Async
            boolean isDifferentSubtype = checkIfOpportunitySubTypeIsDifferentForAdsandPromo(
                opportunity,
                quote.Is_this_for_Ads_Promos__c
            );
            updateOpportunityWithAmendedContract(opportunity.Id, contractId, isDifferentSubtype);
        } catch (DmlException dmlException) {
            logErrors(dmlException, '');
            string validationErrorMessage = ERROR_MESSAGE;
            for (Integer counter = 0; counter < dmlException.getNumDml(); counter++) {
                if (
                    dmlException.getDmlType(counter) == StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION
                ) {
                    validationErrorMessage = dmlException.getDmlMessage(counter);
                    break;
                }
            }
            Database.rollback(sp);
            userMessage = prepareResponse(null, validationErrorMessage, BOOLEAN_FALSE);
        } catch (Exception ex) {
            logErrors(ex, '');
            Database.rollback(sp);
            userMessage = prepareResponse(null, ERROR_MESSAGE, BOOLEAN_FALSE);
        }
        return userMessage;
    }
    /**
     * @description  Get Opportunity By Id
     * @param opportunity
     * @param isAdsOrPromo
     * @return Opportunity
     */
    private static Boolean checkIfOpportunitySubTypeIsDifferentForAdsandPromo(
        Opportunity opportunity,
        String isAdsOrPromo
    ) {
        if (opportunity == null) {
            return BOOLEAN_FALSE;
        }
        if (isAdsOrPromo == 'Yes' && opportunity.Opportunity_Sub_Type__c != 'Ads & Promos') {
            return BOOLEAN_TRUE;
        }
        return BOOLEAN_FALSE;
    }
    /**
     * @description It is used to verify whether the Opportunity has associated brand relation records.
     * @JIRA# LEM-19350
     * @param oppId
     * @return Boolean
     */
    private static Boolean hasBrandRecords(Id oppId) {
        List<Opportunity_Brand_Relationship__c> brands = OpportunityBrandRelationshipsSelector.newInstance()
            .selectByOpportunity(new Set<Id>{ oppId });
        return brands.size() == 0;
    }

    /**
     * @description It is used to verify whether the Opportunity has Contract Signatory OCR records.
     * @JIRA# LEM-19350
     * @param oppId
     * @return Boolean
     */
    private static Boolean checkOCRValid(Id oppId) {
        Boolean isValidOCR = false;
        for (
            OpportunityContactRole ocr : OpportunityContactRoleSelector.newInstance()
                .selectByOpportunity(new Set<Id>{ oppId })
        ) {
            if (ocr.Role == 'Contract Signatory') {
                isValidOCR = true;
            }
        }
        return isValidOCR;
    }
    /**
     * @description  Get Opportunity By Id
     * @param opportunityId
     * @return Opportunity
     */
    private static Opportunity getOpportunity(String opportunityId) {
        Set<Id> opportunityIds = new Set<Id>{ opportunityId };
        List<Opportunity> opportunityList = OpportunitiesSelector.newInstance()
            .selectById(opportunityIds);
        return (opportunityList.isEmpty()) ? null : opportunityList[0];
    }

    /**
     * @description  Get Quote By Id
     * @param primaryQuoteId
     * @return Quote
     */
    private static SBQQ__Quote__c getPrimaryQuote(String primaryQuoteId) {
        Set<Id> primaryQuoteIds = new Set<Id>{ primaryQuoteId };
        List<SBQQ__Quote__c> primaryQuoteList = QuotesSelector.newInstance()
            .selectById(primaryQuoteIds);
        return (primaryQuoteList.isEmpty()) ? null : primaryQuoteList[0];
    }

    /**
     * @description  Create a new quote based on the provided contract ID
     * @param opportunity
     * @param contract
     * @return Id
     */
    public SBQQ__Quote__c createAmendmentQuote(Opportunity opportunity, Contract contract) {
        SBQQ__Quote__c quote;

        Set<Id> quoteId = new Set<Id>{ contract.SBQQ__Order__r.SBQQ__Quote__r.Id };
        Set<String> targetFieldAPIs = new Set<String>();

        List<Custom_Amendment_Field_Mapping__mdt> mappings = CustomAmendmentFieldMappingSelector.newInstance()
            .selectMappingsBySourceObjectAndTargetObject(CONTRACT_SOURCE, OBJECT_TYPE_QUOTE);
        for (Custom_Amendment_Field_Mapping__mdt mapping : mappings) {
            targetFieldAPIs.add(mapping.Field_API_Name__c);
        }
        quoteList = QuotesSelector.newInstance()
            .selectOriginalQuotewithDynamicFields(quoteId, targetFieldAPIs);

        quote = new SBQQ__Quote__c(
            SBQQ__Opportunity2__c = opportunity.Id,
            SBQQ__PrimaryContact__c = opportunity.ContactId,
            SBQQ__MasterEvergreenContract__c = contract.Id,
            SBQQ__Account__c = opportunity.AccountId,
            SBQQ__StartDate__c = DATE_TODAY,
            SBQQ__Primary__c = BOOLEAN_TRUE,
            Payment_Method__c = contract.Payment_Method__c,
            Is_this_for_Ads_Promos__c = (contract.Is_This_Ads_Or_Promo__c == BOOLEAN_TRUE
                ? 'Yes'
                : 'No'),
            Unique_Identifier__c = opportunity.Unique_Identifier__c
        );

        if (
            contract.Account.Segment__c == ACCOUNT_SEGMENT_SMB &&
            contract.Contract_Split_Category__c == CONTRACT_SPLIT_CATEGORY_A_AND_P
        ) {
            quote.SBQQ__MasterEvergreenContract__c = null;
            quote.SBQQ__MasterContract__c = contract.Id;
        }

        if (!targetFieldAPIs.isEmpty() && !quoteList.isEmpty()) {
            for (SBQQ__Quote__c quoteRecord : quoteList) {
                for (String field : targetFieldAPIs) {
                    quote.put(field, quoteRecord.get(field));
                }
            }
        }
        //It will be updated to primary as true from the platform events fired for integration use cases.
        if (opportunity.Unique_Identifier__c != null) {
            quote.SBQQ__Primary__c = BOOLEAN_FALSE;
            quote.CurrencyIsoCode = opportunity.CurrencyIsoCode;
            quote.SBQQ__PriceBook__c = opportunity.Pricebook2Id;
            quote.SBQQ__PricebookId__c = opportunity.Pricebook2Id;
        }
        Map<String, Schema.SObjectField> fieldsFromQuote = SBQQ__Quote__c.sObjectType.getDescribe()
            .fields.getMap();
        //Apply Quote Mapping
        applyFieldMappings(quote, quote, OBJECT_TYPE_QUOTE, fieldsFromQuote);
        //Insert Quote
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(quote);
        commitUnitOfWork(uow);
        return quote;
    } /**
     * @description  We create Quoteline Groups and Quoteline in this method
     * @param quote
     * @param contract
     * @return If the process is successful
     */
    public Boolean insertAmendedQuoteLines(SBQQ__Quote__c quote, Contract contract) {
        Boolean isSuccessful = BOOLEAN_FALSE;
        //Get Subcriptions
        Set<Id> contractIds = new Set<Id>{ contract.Id };
        Set<String> subscriptionsFields = amendmentFieldMapbyObject.get(OBJECT_TYPE_SUBSCRIPTIONS);
        subscriptionList = SubscriptionSelector.newInstance()
            .selectActiveSubscriptionsByContractIdwithDynamicFields(
                contractIds,
                subscriptionsFields
            );

        //Subscription Candidate
        if (subscriptionList == null || subscriptionList.isEmpty()) {
            return isSuccessful;
        }

        oldQuoteLinetoRequiredByMap = new Map<Id, Id>();
        for (SBQQ__Subscription__c subscription : subscriptionList) {
            if (subscription.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c != null) {
                oldQuoteLinetoRequiredByMap.put(
                    subscription.SBQQ__QuoteLine__c,
                    subscription.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c
                );
            }
        }
        //Create Quotelines
        createAmendedQuoteLines(quote.Id);
        updateAmendedQuoteForProcessingGroups(quote);
        return isSuccessful = BOOLEAN_TRUE;
    }

    /**
     * @description : To prepare map  of Custom Metadata
     **/
    public void prepareMapforCustomAmendmentFields() {
        //Populate Map for Custom Ammendment Custom Metadata
        customAmendmentFieldMappings = CustomAmendmentFieldMappingSelector.newInstance()
            .selectAllCustomAmendmentFieldsMapping();

        if (customAmendmentFieldMappings == null || customAmendmentFieldMappings.isEmpty()) {
            return;
        }
        amendmentFieldMapbyObject = new Map<String, Set<String>>();

        for (
            Custom_Amendment_Field_Mapping__mdt amendedCustomMetadata : customAmendmentFieldMappings
        ) {
            if (amendmentFieldMapbyObject.containsKey(amendedCustomMetadata.Source_Object__c)) {
                amendmentFieldMapbyObject.get(amendedCustomMetadata.Source_Object__c)
                    .add(amendedCustomMetadata.Source_Field__c);
            } else {
                Set<String> customAmendmentFieldList = new Set<String>();
                customAmendmentFieldList.add(amendedCustomMetadata.Source_Field__c);
                amendmentFieldMapbyObject.put(
                    amendedCustomMetadata.Source_Object__c,
                    customAmendmentFieldList
                );
            }
        }
    }

    private void updateAmendedQuoteForProcessingGroups(SBQQ__Quote__c quote) {
        if (quote == null) {
            return;
        }
        //To Update Quote Blank commit to fire the Group Logic
        fflib_ISObjectUnitOfWork uowquote = Application.UNITOFWORK.newInstance();
        uowquote.registerDirty(quote);
        commitUnitOfWork(uowquote);
    }

    /**
     * @description  Create quote lines based on subscriptions and field mappings
     * @param amendedQuoteId ammended Quote Id
     */
    public void createAmendedQuoteLines(String amendedQuoteId) {
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        if (subscriptionList == null || subscriptionList.isEmpty()) {
            return;
        }
        Map<String, Schema.SObjectField> fieldsFromQuoteline = SBQQ__QuoteLine__c.sObjectType.getDescribe()
            .fields.getMap();

        for (SBQQ__Subscription__c subscription : subscriptionList) {
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = amendedQuoteId;
            quoteLine.SBQQ__UpgradedSubscription__c = subscription.Id;

            applyFieldMappings(subscription, quoteLine, OBJECT_TYPE_QUOTELINE, fieldsFromQuoteline);
            if (quoteLine.SBQQ__SubscriptionTerm__c == null) {
                quoteLine.SBQQ__SubscriptionTerm__c = 1; //Set to Defualt
            }
            quoteLineList.add(quoteLine);
        }
        if (!quoteLineList.isEmpty()) {
            fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
            uow.registerNew(quoteLineList);
            commitUnitOfWork(uow);
            //To Updated Quotelines By Required By
            updateQuoteLinesWithRequiredByFlag(quoteLineList);
        }
    }

    //To Update Quotelines with required  By Flag details
    private void updateQuoteLinesWithRequiredByFlag(List<SBQQ__QuoteLine__c> quoteLineList) {
        if (quoteLineList == null || quoteLineList.isEmpty()) {
            return;
        }
        Map<Id, Id> oldQuoteLineToNewQuoteLineMap = new Map<Id, Id>();
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            oldQuoteLineToNewQuoteLineMap.put(quoteLine.SBQQ__OriginalQuoteLineId__c, quoteLine.Id);
        }
        for (SBQQ__QuoteLine__c quoteLine : quoteLineList) {
            if (oldQuoteLinetoRequiredByMap.containsKey(quoteLine.SBQQ__OriginalQuoteLineId__c)) {
                quoteLine.SBQQ__RequiredBy__c = oldQuoteLineToNewQuoteLineMap.get(
                    oldQuoteLinetoRequiredByMap.get(quoteLine.SBQQ__OriginalQuoteLineId__c)
                );
            }
        }
        //Update Quotlines
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerDirty(quoteLineList);
        commitUnitOfWork(uow);
    }

    // Apply field mappings from source object to target object
    private void applyFieldMappings(
        SObject source,
        SObject target,
        String targetObjectType,
        Map<String, Schema.SObjectField> fieldsFromSObject
    ) {
        for (Custom_Amendment_Field_Mapping__mdt mapping : customAmendmentFieldMappings) {
            if (mapping.sObject_Type__c == targetObjectType) {
                if (
                    mapping.Type_of_Mapping__c == SOURCEMAPPINGTYPE &&
                    !String.isBlank(mapping.Source_Field__c)
                ) {
                    //Map Values
                    TransformationValues transformedValues = getTranformedValuesBasedonRelationship(
                        mapping,
                        source
                    );
                    transformFieldToActualDataTypeValues(
                        target,
                        transformedValues.objectFieldMap,
                        fieldsFromSObject,
                        transformedValues.fieldName,
                        mapping.Field_API_Name__c
                    );
                } else if (
                    mapping.Type_of_Mapping__c == STATICMAPPINGTYPE &&
                    !String.isBlank(mapping.Static_Value__c)
                ) {
                    transformStaticFieldToActualDataTypeValues(
                        source,
                        target,
                        fieldsFromSObject,
                        mapping
                    );
                }
            }
        }
    }

    private TransformationValues getTranformedValuesBasedonRelationship(
        Custom_Amendment_Field_Mapping__mdt mapping,
        SObject source
    ) {
        TransformationValues transformedValues = new TransformationValues();
        if (mapping.Source_Field__c.contains('__r.')) {
            String relationshipObject = mapping.Source_Field__c.substringBefore('.');
            transformedValues.objectFieldMap = ((sObject) source.getPopulatedFieldsAsMap()
                    .get(relationshipObject)) != null
                ? ((sObject) source.getPopulatedFieldsAsMap().get(relationshipObject))
                      .getPopulatedFieldsAsMap()
                : source.getPopulatedFieldsAsMap();
            transformedValues.fieldName = mapping.Source_Field__c.substringAfter('.');
        } else {
            transformedValues.objectFieldMap = source.getPopulatedFieldsAsMap();
            transformedValues.fieldName = mapping.Source_Field__c;
        }
        return transformedValues;
    }

    private void transformFieldToActualDataTypeValues(
        SObject target,
        Map<String, Object> objectFieldMap,
        Map<String, Schema.SObjectField> fieldsFromSObject,
        String fieldName,
        String fieldApiName
    ) {
        //NOPMD
        if (!fieldsFromSObject.containsKey(fieldName)) {
            return;
        }
        Schema.DisplayType fieldType = fieldsFromSObject.get(fieldName).getDescribe().getType();
        Object fieldValue = objectFieldMap.get(fieldName);
        if (fieldValue == null) {
            return;
        }
        if (fieldType == Schema.DisplayType.DATETIME) {
            target.put(fieldApiName, DATETIME.valueOf(fieldValue));
        } else if (fieldType == Schema.DisplayType.DATE) {
            target.put(fieldApiName, Date.valueOf(fieldValue));
        } else if (
            fieldType == Schema.DisplayType.CURRENCY ||
            fieldType == Schema.DisplayType.PERCENT ||
            fieldType == Schema.DisplayType.DOUBLE
        ) {
            target.put(fieldApiName, fieldValue);
        } else if (fieldType == Schema.DisplayType.INTEGER) {
            target.put(fieldApiName, Integer.valueOf(fieldValue));
        } else if (fieldType == Schema.DisplayType.BOOLEAN) {
            target.put(fieldApiName, BOOLEAN.valueOf(fieldValue));
        } else {
            target.put(fieldApiName, fieldValue);
        }
    }

    private void transformStaticFieldToActualDataTypeValues(
        SObject source,
        SObject target,
        Map<String, Schema.SObjectField> fieldsFromSObject,
        Custom_Amendment_Field_Mapping__mdt mapping
    ) {
        Schema.DisplayType fieldType = fieldsFromSObject.get(mapping.Field_API_Name__c)
            .getDescribe()
            .getType();
        Object fieldValue = mapping.Static_Value__c;
        if (fieldValue == null) {
            return;
        }

        if (fieldType == Schema.DisplayType.DATETIME) {
            target.put(mapping.Field_API_Name__c, DATETIME.valueOf(fieldValue));
        } else if (fieldType == Schema.DisplayType.DATE) {
            target.put(mapping.Field_API_Name__c, Date.valueOf(fieldValue));
        } else if (
            fieldType == Schema.DisplayType.CURRENCY ||
            fieldType == Schema.DisplayType.PERCENT ||
            fieldType == Schema.DisplayType.DOUBLE
        ) {
            target.put(mapping.Field_API_Name__c, fieldValue);
        } else if (fieldType == Schema.DisplayType.INTEGER) {
            target.put(mapping.Field_API_Name__c, Integer.valueOf(fieldValue));
        } else if (fieldType == Schema.DisplayType.BOOLEAN) {
            target.put(mapping.Field_API_Name__c, BOOLEAN.valueOf(fieldValue));
        } else {
            target.put(mapping.Field_API_Name__c, fieldValue);
        }
    }

    /**
     * @description  Update the opportunity with the contract ID
     * @param opportunityId ammended Quot It
     * @param contractId list of subscriptions
     * @param isDifferentSubtype Boolean value indicating Different SubType
     */
    @Future
    public static void updateOpportunityWithAmendedContract(
        String opportunityId,
        String contractId,
        boolean isDifferentSubtype
    ) {
        try {
            if (String.isEmpty(opportunityId) || String.isEmpty(contractId)) {
                return;
            }
            Opportunity opportunity = new Opportunity();
            opportunity.Id = opportunityId;
            if (opportunity == null || opportunity.Id == null) {
                return;
            }
            opportunity.ContractId = contractId;
            //Incase of Ads and Promo
            if (isDifferentSubtype) {
                opportunity.Opportunity_Sub_Type__c = 'Ads & Promos';
                opportunity.Deal_Type__c = 'Full-Serve';
            }
            fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
            uow.registerDirty(opportunity);
            commitUnitOfWork(uow);
        } catch (Exception ex) {
            logErrors(ex, 'updateOpportunityWithAmendedContract');
        }
    }

    /**
     * @description  create opportunity and work order for Rate Change
     * @param opportunitySubType
     * @param accountId
     * @param contractId
     * @return Map<String, String>
     */

    @AuraEnabled
    public static Map<String, String> createOpportunityAndWorkOrder(
        String opportunitySubType,
        Id accountId,
        Id contractId
    ) {
        Map<String, String> mapOfOpportunityAndWorkorder = new Map<String, String>();
        Set<Id> contractIds = new Set<Id>{ contractId };
        Savepoint sp = Database.setSavepoint();
        AmendmentService amendmentService = new AmendmentService();
        amendmentService.prepareMapforCustomAmendmentFields();

        Opportunity newOpportunity = new Opportunity();
        WorkOrder newWorkOrder = new WorkOrder();
        Set<String> subscriptionsFields = amendmentFieldMapbyObject.get(OBJECT_TYPE_SUBSCRIPTIONS);
        subscriptionList = SubscriptionSelector.newInstance()
            .selectActiveSubscriptionsByContractIdwithDynamicFields(
                contractIds,
                subscriptionsFields
            );

        if (subscriptionList == null || subscriptionList.isEmpty()) {
            Database.rollback(sp);
            accountId = null;
            String userMessage = prepareResponse(accountId, NO_ACTIVE_SUBSCRIPTIONS, BOOLEAN_FALSE);
            mapOfOpportunityAndWorkorder.put('error', userMessage);
            return mapOfOpportunityAndWorkorder;
        }
        try {
            newOpportunity = createChangeRateOpportunity(opportunitySubType, accountId);
            newWorkOrder = createChangeRateWorkOrder(
                newOpportunity.Id,
                accountId,
                opportunitySubType
            );
        } catch (Exception ex) {
            logErrors(ex, 'createOpportunityAndWorkOrder');
            Database.rollback(sp);
            String userMessage = prepareResponse(
                accountId,
                UNSUCCESSFUL_MESSAGE_OPPORTUNITY_WORKORDER,
                BOOLEAN_FALSE
            );
            mapOfOpportunityAndWorkorder.put('error', userMessage);
            return mapOfOpportunityAndWorkorder;
        }
        return sendLinkofOpportunityandWorkOrder(newOpportunity, newWorkOrder);
    }
    /**
     * @description  create opportunity and work order for Rate Change
     * @param opportunitySubType
     * @param accountId
     * @return Map<String, String>
     */
    private static Opportunity createChangeRateOpportunity(
        String opportunitySubType,
        Id accountId
    ) {
        Integer numberOfDays = Date.daysInMonth(Date.today().year(), Date.today().month());
        Date lastDayOfMonth = Date.newInstance(
            Date.today().year(),
            Date.today().month(),
            numberOfDays
        );

        AmendmentServiceImpl amendmentServiceImpl = new AmendmentServiceImpl();
        Map<String, Schema.SObjectField> fieldsFromOpportunity = Opportunity.sObjectType.getDescribe()
            .fields.getMap();

        Opportunity newOpportunity = new Opportunity();
        newOpportunity.CloseDate = lastDayOfMonth;
        newOpportunity.Opportunity_Sub_Type__c = opportunitySubType;
        newOpportunity.AccountId = accountId;
        amendmentServiceImpl.applyFieldMappings(
            newOpportunity,
            newOpportunity,
            OBJECT_TYPE_OPPORTUNITY,
            fieldsFromOpportunity
        );

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(newOpportunity);
        commitUnitOfWork(uow);
        return newOpportunity;
    }

    private static WorkOrder createChangeRateWorkOrder(
        Id opportunityId,
        Id accountId,
        String opportunitySubType
    ) {
        AmendmentServiceImpl amendmentServiceImpl = new AmendmentServiceImpl();
        Map<String, Schema.SObjectField> fieldsFromWorkOrder = WorkOrder.sObjectType.getDescribe()
            .fields.getMap();

        WorkOrder newWorkOrder = new WorkOrder();
        newWorkOrder.Opportunity__c = opportunityId;
        newWorkOrder.AccountId = accountId;
        newWorkOrder.Proposed_Date_of_Activation__c = Date.today().addDays(8);
        newWorkOrder.Proposed_Date_of_Tablet__c = Date.today().addDays(10);
        amendmentServiceImpl.applyFieldMappings(
            newWorkOrder,
            newWorkOrder,
            OBJECT_TYPE_WORKORDER,
            fieldsFromWorkOrder
        );

        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        uow.registerNew(newWorkOrder);
        commitUnitOfWork(uow);
        return newWorkOrder;
    }

    private static Map<String, String> sendLinkofOpportunityandWorkOrder(
        Opportunity newOpportunity,
        WorkOrder newWorkOrder
    ) {
        Map<String, String> result = new Map<String, String>();
        result.put('opportunityId', newOpportunity.Id);
        result.put('workOrderId', newWorkOrder.Id);
        return result;
    }

    // Commit unit of work
    private static void commitUnitOfWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception unitOfWorkException) {
            throw unitOfWorkException;
        }
    }

    private static String prepareResponse(String quoteId, String message, Boolean isSuccessful) {
        AmendmentResponseWrapper response = new AmendmentResponseWrapper();
        response.quoteId = quoteId;
        response.message = message;
        response.isSuccessful = isSuccessful;
        return JSON.serialize(response);
    }

    private static void logErrors(Exception ex, String methodName) {
        Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        GenericLoggerService.publish(
            GenericLoggerService.createGenericLog(
                    LOG_AMEND_CUSTOM_QUOTE +
                        ' ' +
                        CLASSNAME +
                        (methodName != '' && methodName != null ? '.' + methodName : ''),
                    LOG_AMEND_QUOTE_CREATION,
                    GenericLogEntry.SeverityLevel.HIGH
                )
                .logException(ex)
        );
    }

    /**
     * @description  To Prepare the Wrapper for LWC response
     */
    public class AmendmentResponseWrapper {
        @AuraEnabled
        public String quoteId;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public BOOLEAN isSuccessful;
    }

    /**
     * @description  To Prepare the Wrapper for Transforming values
     */
    public class TransformationValues {
        public String fieldName = '';
        public Map<String, Object> objectFieldMap;
    }
}