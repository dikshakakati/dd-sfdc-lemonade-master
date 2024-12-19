/**
 * @author Doordash
 * @date 03/12/2024
 * @description Service implementation class for Complex MDS Sync related logic.
 */
public inherited sharing class ComplexMdsAttributesProcessServiceImpl implements IComplexMdsAttributesProcessService{
    private static final String IS_ACTIVE_ATTRIBUTE = 'is_active';
    private static final String ADDRESS_ID_ATTRIBUTE = 'address_id';
    private static final String BUSINESS_ID_ATTRIBUTE = 'business_id';
    private static final String ORDER_PROTOCOL_ATTRIBUTE = 'order_protocol';
    private static final String NAME_ATTRIBUTE = 'name';
    private static final String INACTIVE_STATUS = 'Inactive';

    private static final String XREF_ACTIVATION_STATUS_ACTIVE  = 'Active';
    private static final String XREF_ACTIVATION_STATUS_INACTIVE  = 'Inactive';

    private static final String OP_POINT_OF_SALE = 'POINT_OF_SALE';
    private static final String ADDRESS_IN_COVERAGE = 'In Coverage';
    private static final String UNDEFINED_ORDER_PROTOCOL = 'OP received from MDS is not defined';
    private static final String BIZREF_NOT_FOUND = 'Business Reference not found in DDMx';
    private static final String UNVERIFIED_STATUS = 'Unverified';
    private static final String VERIFIED_STATUS = 'Verified';
    private static final String REJECTED_STATUS = 'Rejected';

    private static final String CORPORATE_DEFAULT_TYPE = 'Corporate';
    private static final String FRANCHISE_DEFAULT_TYPE = 'Franchise';
    private static final String COO_GRAVEYARD_DEFAULT_TYPE = 'COO Graveyard';
    private static final String STORE_NAME_LABEL_PREFIX =System.Label.ExcludedStoreNamePrefix;

    private enum AttributeNames {
        IS_ACTIVE_ATTRIBUTE,
        NAME_ATTRIBUTE,
        ADDRESS_ID_ATTRIBUTE,
        BUSINESS_ID_ATTRIBUTE,
        ORDER_PROTOCOL_ATTRIBUTE
    }
    private static final Map<String, AttributeNames> ATTRIBUTE_NAME_MAPPINGS = new Map<String, AttributeNames>{
        IS_ACTIVE_ATTRIBUTE => AttributeNames.IS_ACTIVE_ATTRIBUTE,
        NAME_ATTRIBUTE => AttributeNames.NAME_ATTRIBUTE,
        ADDRESS_ID_ATTRIBUTE => AttributeNames.ADDRESS_ID_ATTRIBUTE,
        BUSINESS_ID_ATTRIBUTE => AttributeNames.BUSINESS_ID_ATTRIBUTE,
        ORDER_PROTOCOL_ATTRIBUTE => AttributeNames.ORDER_PROTOCOL_ATTRIBUTE
    };
    /**
     * @description to update the account record fields that needs to processed via store sync event
     * @param serviceInput object record on which we will have to update a field value
     * @param mdsSyncMapping metadata record for refering the store update Json tag details
     * @param thisEventRecievedDateTime this is the store event recieved date time
     * @param storeUpdate this is the formatted JSON of the store event
     * @return MDSSyncServiceWrapper
     */
    public MDSSyncServiceWrapper processAttribute(
        MDSSyncServiceWrapper serviceInput,
        MDS_Sync_Mapping__mdt mdsSyncMapping,
        DateTime thisEventRecievedDateTime,
        StoreUpdateIntegrationWrapper storeUpdate) {
            switch on ATTRIBUTE_NAME_MAPPINGS.get(mdsSyncMapping.DeveloperName){
                when IS_ACTIVE_ATTRIBUTE {
                    return processIsActiveUpdates(serviceInput, thisEventRecievedDateTime, storeUpdate);
                }
                when NAME_ATTRIBUTE {
                    return processStoreNameUpdates(serviceInput, thisEventRecievedDateTime, storeUpdate);
                }
                when ADDRESS_ID_ATTRIBUTE {
                    return processAddressIdUpdates(serviceInput, thisEventRecievedDateTime, storeUpdate);
                } when BUSINESS_ID_ATTRIBUTE {
                    return processBusinessIdUpdates(serviceInput, thisEventRecievedDateTime, storeUpdate);
                } when ORDER_PROTOCOL_ATTRIBUTE {
                    return processOrderProtocolUpdates(serviceInput, thisEventRecievedDateTime, storeUpdate);
                } when else {
                    return serviceInput;
                }
            }
    }
    private MDSSyncServiceWrapper processBusinessIdUpdates(
        MDSSyncServiceWrapper serviceInput,
        DateTime thisEventRecievedDateTime,
        StoreUpdateIntegrationWrapper storeUpdate
    ) {
        if(isValidForProcessing(thisEventRecievedDateTime, serviceInput.thisFieldLastMdsUpdatedDateTime)) {
            String businessId = storeUpdate.updated_store.business_id.value;
            Xref__c xrefRecord = serviceInput.xrefRecord;
            String defaultType = String.isBlank(xrefRecord.Salesforce_Account_Name__r.Franchise_Parent__c) ? CORPORATE_DEFAULT_TYPE : FRANCHISE_DEFAULT_TYPE;
            Set<String> defaultTypes = new Set<String>{defaultType, COO_GRAVEYARD_DEFAULT_TYPE};
            List<Business_Reference__c> bizRefs = BusinessReferencesSelector.newInstance().selectBusRefByExternalIdAndDefaultType(new Set<String>{businessId}, defaultTypes);
            if(bizRefs.isEmpty()){
                serviceInput.errorMessage = BIZREF_NOT_FOUND;
            } else {
                xrefRecord.Business_Reference__c = bizRefs[0].Id;
                serviceInput.xrefRecord = xrefRecord;
                serviceInput.thisFieldLastMdsUpdatedDateTime = String.valueOf(thisEventRecievedDateTime);
            }
        }
        return serviceInput;
    }

    @SuppressWarnings('PMD.CyclomaticComplexity')
    private MDSSyncServiceWrapper processOrderProtocolUpdates(
        MDSSyncServiceWrapper serviceInput,
        DateTime thisEventRecievedDateTime,
        StoreUpdateIntegrationWrapper storeUpdate
    ) {
        if(isValidForProcessing(thisEventRecievedDateTime, serviceInput.thisFieldLastMdsUpdatedDateTime)) {
            Account accountRecord = serviceInput.accountRecord;

            Map<String,String> fieldsUpdatedwithOldValues = StoreUpdateIntegrationWrapper.fieldsUpdatedwithOldValues(storeUpdate);
            string oldOrderProtocol = fieldsUpdatedwithOldValues.get(ORDER_PROTOCOL_ATTRIBUTE);
            string newOrderProtocol = storeUpdate.updated_store.order_protocol.value;

            string orderProtocolOnAccount ;
            for(Order_Protocol_Mapping__mdt op: OrderProtocolMappingsSelector.newInstance().getActiveOrderProtocolMappings()){
                if(newOrderProtocol == op.MasterLabel && String.isBlank(op.Old_Value__c)){
                    orderProtocolOnAccount = op.Result__c;
                    break;
                }else if(newOrderProtocol == op.MasterLabel &&
                            (String.isNotBlank(op.Old_Value__c) && op.Old_Value__c == oldOrderProtocol) &&
                            (String.isNotBlank(op.Ignore_Values__c) && accountRecord.Order_Protocol__c.contains(op.Ignore_Values__c))) {
                        orderProtocolOnAccount = accountRecord.Order_Protocol__c;
                        break;
                } else if(newOrderProtocol == op.MasterLabel &&
                            (String.isNotBlank(op.Old_Value__c) && op.Old_Value__c == oldOrderProtocol) &&
                            String.isBlank(op.Contains__c)) {
                        orderProtocolOnAccount = op.Result__c;
                        break;
                } else if(newOrderProtocol == op.MasterLabel &&
                            (String.isNotBlank(op.Old_Value__c) && op.Old_Value__c == oldOrderProtocol) &&
                            (String.isNotBlank(op.Contains__c) && accountRecord.Order_Protocol__c.contains(op.Contains__c))) {
                        orderProtocolOnAccount = op.Result__c;
                        break;
                }
            }
            if(newOrderProtocol == OP_POINT_OF_SALE && StoreUpdate.point_of_sale != null) {
                accountRecord.POS_Integration_ID__c = StoreUpdate.point_of_sale.location_id;
                accountRecord.POS_Integration_Type__c = StoreUpdate.point_of_sale.provider_type;
            }

            if(string.isNotBlank(orderProtocolOnAccount)){
                accountRecord.Order_Protocol__c = orderProtocolOnAccount;
                serviceInput.accountRecord = accountRecord;
                serviceInput.thisFieldLastMdsUpdatedDateTime = String.valueOf(thisEventRecievedDateTime);
            } else {
                serviceInput.errorMessage = UNDEFINED_ORDER_PROTOCOL;
            }
        }
        return serviceInput;
    }
    private MDSSyncServiceWrapper processIsActiveUpdates(
        MDSSyncServiceWrapper serviceInput,
        DateTime thisEventRecievedDateTime,
        StoreUpdateIntegrationWrapper storeUpdate
     ) {
        if(isValidForProcessing(thisEventRecievedDateTime, serviceInput.thisFieldLastMdsUpdatedDateTime)){
            Xref__c xrefRecord = serviceInput.xrefRecord;
            Boolean xrefStatus = storeUpdate.updated_store.Is_active.value;
            xrefRecord.Xref_Status__c = xrefStatus ? XREF_ACTIVATION_STATUS_ACTIVE : XREF_ACTIVATION_STATUS_INACTIVE;
            xrefRecord.Date_of_Status_Change__c = thisEventRecievedDateTime;
            serviceInput.xrefRecord = xrefRecord;
            serviceInput.thisFieldLastMdsUpdatedDateTime = String.valueOf(thisEventRecievedDateTime);
        }
        return serviceInput;

    }
    private boolean isValidForProcessing(DateTime thisEventRecievedDateTime, String thisFieldLastMdsUpdatedDateTime){
        return String.isBlank(thisFieldLastMdsUpdatedDateTime) || (String.isNotBlank(thisFieldLastMdsUpdatedDateTime) && thisEventRecievedDateTime > DateTime.valueof(thisFieldLastMdsUpdatedDateTime));
    }
    private MDSSyncServiceWrapper processAddressIdUpdates(
        MDSSyncServiceWrapper serviceInput,
        DateTime thisEventRecievedDateTime,
        StoreUpdateIntegrationWrapper storeUpdate
    ) {
        if(isValidForProcessing(thisEventRecievedDateTime, serviceInput.thisFieldLastMdsUpdatedDateTime)) {
            //proceed with account update
            Account accountRecord = serviceInput.accountRecord;
            Account addressAccount = (Account) storeUpdate.AddressValidationResponse.addressResponse;
            if(addressAccount.Address_Verification_Status__c == VERIFIED_STATUS){
                accountRecord = getVerifiedAddressAccount(accountRecord, addressAccount, storeUpdate);
            } else if(addressAccount.Address_Verification_Status__c == REJECTED_STATUS) {
                accountRecord = getRejectedAccount(accountRecord, addressAccount);
            }
            serviceInput.accountRecord = accountRecord;
            serviceInput.thisFieldLastMdsUpdatedDateTime = String.valueOf(thisEventRecievedDateTime);
        }
        return serviceInput;
    }

    private Account getVerifiedAddressAccount(Account accountRecord, Account addressAccount, StoreUpdateIntegrationWrapper storeUpdate) {
        accountRecord.Address_ID__c = addressAccount.Address_ID__c;
        accountRecord.BillingStreet = addressAccount.BillingStreet;
        accountRecord.BillingPostalCode = addressAccount.BillingPostalCode;
        accountRecord.BillingCity = addressAccount.BillingCity;
        accountRecord.BillingLatitude = addressAccount.BillingLatitude;
        accountRecord.BillingLongitude = addressAccount.BillingLongitude;
        accountRecord.Address_Verification_Status__c = addressAccount.Address_Verification_Status__c;
        accountRecord.Rejected_Reason__c = addressAccount.Rejected_Reason__c;
        accountRecord.Address_Verification_Date__c = addressAccount.Address_Verification_Date__c;
        accountRecord.BillingStateCode = addressAccount.BillingStateCode;
        accountRecord.BillingCountryCode = addressAccount.BillingCountryCode;
        accountRecord.Coverage__c = addressAccount.Coverage__c;
        accountRecord.Last_Coverage_Check_Time__c = addressAccount.Last_Coverage_Check_Time__c;
        accountRecord.Coverage_Start_Date__c = addressAccount.Coverage_Start_Date__c;
        accountRecord.Alcohol_Eligibility__c = addressAccount.Alcohol_Eligibility__c;
        accountRecord.Starting_Point__c = addressAccount.Starting_Point__c;
        accountRecord.Starting_Point_ID__c = addressAccount.Starting_Point_ID__c;
        if(accountRecord.Coverage__c == ADDRESS_IN_COVERAGE) {
            accountRecord.SubMarket__c = getSubMarketId(storeUpdate, addressAccount.BillingStateCode);
        } else {
            accountRecord.SubMarket__c = null;
        }
        return accountRecord;
    }

    private Account getRejectedAccount(Account accountRecord, Account addressAccount) {
        accountRecord.Rejected_Reason__c = addressAccount.Rejected_Reason__c;
        accountRecord.Address_Verification_Date__c = addressAccount.Address_Verification_Date__c;
        accountRecord.Address_Verification_Status__c = addressAccount.Address_Verification_Status__c;
        return accountRecord;
    }

    private Id getSubMarketId(StoreUpdateIntegrationWrapper storeUpdate, String billingStateCode) {
        string subMarketId = StoreUpdate.AddressValidationResponse.submarketRequest.Sub_Market_ID;
        string subMarketName = StoreUpdate.AddressValidationResponse.submarketRequest.Sub_Market_Name;
        List<Submarket__c> submarkets = SubmarketsSelector.newInstance().getSubmarketsByIdAndName(subMarketId, subMarketName);
        Id sfdcSubMktId;
        if(submarkets.isEmpty()) {
            fflib_ISObjectUnitOfWork subMarketUow = Application.UNITOFWORK.newInstance();
            Submarket__c subMkt = new Submarket__c();
            subMkt.Name = subMarketName+', '+billingStateCode;
            subMkt.Submarket_ID__c = subMarketId;
            subMkt.Status__c = UNVERIFIED_STATUS;
            subMarketUow.registerNew(subMkt);
            subMarketUow.commitWork();
            sfdcSubMktId = subMkt.Id;
        } else {
            sfdcSubMktId = submarkets[0].Id;
        }
        return sfdcSubMktId;
    }

    private MDSSyncServiceWrapper processStoreNameUpdates(
        MDSSyncServiceWrapper serviceInput,
        DateTime thisEventRecievedDateTime,
        StoreUpdateIntegrationWrapper storeUpdate
    ) {
        Xref__c xrefRecord = serviceInput.xrefRecord;
        if(isValidForProcessing(thisEventRecievedDateTime, serviceInput.thisFieldLastMdsUpdatedDateTime)
         && checkIfXrefIsActive(xrefRecord)) {
            List<String> storeNamePrefixes = STORE_NAME_LABEL_PREFIX.split(';');

            Account accountRecord = serviceInput.accountRecord;

            Map<String,String> fieldsUpdatedwithNewValues = StoreUpdateIntegrationWrapper.fieldsUpdatedwithNewValues(storeUpdate);
            string accountName = fieldsUpdatedwithNewValues.get(NAME_ATTRIBUTE);
            Boolean isPrefixFound = false;

            for(string excludedName :storeNamePrefixes){
                    if(accountName.contains(excludedName)){
                        isPrefixFound = true;
                        break;
                    }
            }
            if(!isPrefixFound){
                accountRecord.Name = accountName;
                serviceInput.accountRecord = accountRecord;
                serviceInput.thisFieldLastMdsUpdatedDateTime = String.valueOf(thisEventRecievedDateTime);
            }
        }
        return serviceInput;
    }

    private boolean checkIfXrefIsActive(Xref__c xrefRecord){
        return (xrefRecord != null && xrefRecord.Xref_Status__c == INACTIVE_STATUS)
            ? false
            : true;
    }
}