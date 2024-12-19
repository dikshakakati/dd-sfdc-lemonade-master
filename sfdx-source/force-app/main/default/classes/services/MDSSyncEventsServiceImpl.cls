/**
 * @author Doordash
 * @date   02/27/2024
 * @description This is the service implementation class for MDS Events Sync related logic
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.StdCyclomaticComplexity')
public inherited sharing class MDSSyncEventsServiceImpl implements IMDSSyncEventsService{
    private static final String PROCESSED_STATUS = 'Processed';
    private static final String FAILED_STATUS = 'Failed';
    private static final String NO_XREF_FOUND = 'No Xref found for this store in DDMx';
    private static final String TIMESTAMP_FIELD = 'Timestamp__c';
    private static final String SIMPLE_UPDATE = 'Simple';
    private static final String COMPLEX_UPDATE = 'Complex';
    private static final String NO_SYNC_NEEDED = 'As part of this update we dont have any fields that needs to be synced in DDMx';
    private static final String ACCOUNT_OBJECT_API_NAME = 'Account';
    private static final String BUSINESS_ID_JSON_TAG_NAME = 'business_id';
    private static final String ACCOUNT_API_NAME = 'Account';
    private static final String XREF_API_NAME = 'Xref__c';
    private Map<String, String> xrefLastMdsUpdatedMap;
    private Map<String, String> accountLastMdsUpdatedMap;
    private Account accountRecord;
    private xref__c xrefRecord;
    private String batchId;
    private DateTime thisEventRecievedDateTime;
    private StoreUpdateIntegrationWrapper storeUpdate;
    fflib_ISObjectUnitOfWork storeSyncUnitOfWork;
    private boolean isXrefUpdated = false;
    private boolean isAccountUpdated = false;
    private static final String STRING_TYPE = 'String';
    private static final String INTEGER_TYPE = 'Integer';
    private static final String BOOLEAN_TYPE = 'Boolean';
    private static final String DECIMAL_TYPE = 'Decimal';
    private static final String DOUBLE_TYPE = 'Double';
    private static final String LOG_SERVICE_MDS_STORE_SYNC = 'MDS Store Sync';
    private static final String LOG_DOMAIN_NAME = 'Provisioning';

    private enum DataTypes {
        STRING_TYPE,
        DOUBLE_TYPE,
        INTEGER_TYPE,
        BOOLEAN_TYPE,
        DECIMAL_TYPE
    }

    private enum ObjectNames {
        XREF_API_NAME,
        ACCOUNT_API_NAME
    }

    private static final Map<String, ObjectNames> OBJECT_NAME_MAPPINGS = new Map<String, ObjectNames>{
        XREF_API_NAME => ObjectNames.XREF_API_NAME,
        ACCOUNT_API_NAME => ObjectNames.ACCOUNT_API_NAME
    };

    private static final Map<String, DataTypes> DATA_TYPE_MAPPINGS = new Map<String, DataTypes>{
        STRING_TYPE => DataTypes.STRING_TYPE,
        DOUBLE_TYPE => DataTypes.DOUBLE_TYPE,
        INTEGER_TYPE => DataTypes.INTEGER_TYPE,
        BOOLEAN_TYPE => DataTypes.BOOLEAN_TYPE,
        DECIMAL_TYPE => DataTypes.DECIMAL_TYPE
    };

    private static final Map<String, String> ATTRIBUTE_REPLACEMENT_MAP = new Map<String, String>{
        'Sub_Market__c' => 'Sub_Market_Name',
        'Sub_Market_ID__c' => 'Sub_Market_ID'
    };

    /**
     * @description Process MDS Updates method
     * @param integrationRequestIdsToProcess
     */
    public void processMDSUpdates(Set<Id> integrationRequestIdsToProcess) {
        for (Integration_Request__c ir: IntegrationRequestsSelector.newInstance().selectById(integrationRequestIdsToProcess)){
            if(ir.Sfdc_Status__c <> PROCESSED_STATUS) {
                processMDSUpdates(ir);
            }
        }
    }

    private void processMDSUpdates(Integration_Request__c integrationRequest){
        batchId = integrationRequest.Batch_Id__c;
        String payload = integrationRequest.payload__c;
        for(String attrKey: ATTRIBUTE_REPLACEMENT_MAP.keyset()) {
            payload = payload.replaceAll(attrKey, ATTRIBUTE_REPLACEMENT_MAP.get(attrKey));
        }
        storeUpdate = StoreUpdateIntegrationWrapper.parse(payload);
        storeSyncUnitOfWork = Application.UNITOFWORK.newInstance();
        List<Xref__c> xrefs = getXrefByStoreAndBusinessId();
        if(xrefs.isEmpty()){
            updateIntegrationRequestRecord(integrationRequest.Id, PROCESSED_STATUS, NO_XREF_FOUND);
        } else{
            processDDMxRecordsUpdates(integrationRequest, xrefs);
        }
        commitUnitOfWork(storeSyncUnitOfWork);
    }

    private void updateIntegrationRequestRecord(Id integrationRequestId, String status, string message){
        Integration_Request__c intRequest = new Integration_Request__c(
            Id = integrationRequestId,
            Sfdc_Status__c = status,
            Error_Message__c = message
        );
        storeSyncUnitOfWork.registerDirty(intRequest);
        if(String.isNotblank(message)){
            message = message+'-'+batchId;
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_MDS_STORE_SYNC,LOG_DOMAIN_NAME,GenericLogEntry.SeverityLevel.MEDIUM
                ).logMessage(message)
            );
        }
    }

    private List<Xref__c> getXrefByStoreAndBusinessId(){
        String storeId = storeUpdate.Updated_store.id.value;
        Map<String,String> fieldsUpdatedwithOldValues = StoreUpdateIntegrationWrapper.fieldsUpdatedwithOldValues(storeUpdate);

        String businessId = fieldsUpdatedwithOldValues.containskey(BUSINESS_ID_JSON_TAG_NAME) ?
                            fieldsUpdatedwithOldValues.get(BUSINESS_ID_JSON_TAG_NAME) :
                            storeUpdate.Updated_store.business_id.value;

        List<Xref__c> xrefs = XrefsSelector.newInstance().selectByStoreIdAndBusinessId(storeId, businessId);
        return xrefs;
    }

    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception unitOfWorkException) {
            //set the Integration request Id in error message so that we can search by Id in Scalayr
            String errorMessage = unitOfWorkException.getMessage();
            errorMessage = errorMessage+'-'+batchId;
            unitOfWorkException.setMessage(errorMessage);

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_MDS_STORE_SYNC,LOG_DOMAIN_NAME,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
        }
    }

    private MDSSyncServiceWrapper processAccountRecordComplexUpdates(MDS_Sync_Mapping__mdt mdsSyncMapping) {
        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        string thisFieldLastUpdatedString = null;
        complexServiceInput.accountRecord = accountRecord;
        complexServiceInput.xrefRecord = xrefRecord;
        thisFieldLastUpdatedString = accountLastMdsUpdatedMap.containsKey(mdsSyncMapping.DDMx_Field_to_Update__c) ?
                                    accountLastMdsUpdatedMap.get(mdsSyncMapping.DDMx_Field_to_Update__c) : null;
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = thisFieldLastUpdatedString;
        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        if(String.isNotBlank(complexServiceReturn.thisFieldLastMdsUpdatedDateTime)) {
            isAccountUpdated = true;
            accountLastMdsUpdatedMap.put(mdsSyncMapping.DDMx_Field_to_Update__c, complexServiceReturn.thisFieldLastMdsUpdatedDateTime);
        }
        accountRecord = complexServiceReturn.accountRecord;
        return complexServiceReturn;
    }

    private MDSSyncServiceWrapper processXrefRecordComplexUpdates(MDS_Sync_Mapping__mdt mdsSyncMapping) {
        MDSSyncServiceWrapper complexServiceInput = new MDSSyncServiceWrapper();
        string thisFieldLastUpdatedString = null;
        complexServiceInput.xrefRecord = xrefRecord;
        thisFieldLastUpdatedString = xrefLastMdsUpdatedMap.containsKey(mdsSyncMapping.DDMx_Field_to_Update__c) ?
                                                xrefLastMdsUpdatedMap.get(mdsSyncMapping.DDMx_Field_to_Update__c) : null;
        complexServiceInput.thisFieldLastMdsUpdatedDateTime = thisFieldLastUpdatedString;
        MDSSyncServiceWrapper complexServiceReturn = ComplexMdsAttributesProcessService.processAttribute(complexServiceInput, mdsSyncMapping, thisEventRecievedDateTime, storeUpdate);
        if(String.isNotBlank(complexServiceReturn.thisFieldLastMdsUpdatedDateTime)) {
            isXrefUpdated = true;
            xrefLastMdsUpdatedMap.put(mdsSyncMapping.DDMx_Field_to_Update__c, complexServiceReturn.thisFieldLastMdsUpdatedDateTime);
        }
        xrefRecord = complexServiceReturn.xrefRecord;
        return complexServiceReturn;
    }

    private void updateAccountRecord() {
        if(isAccountUpdated){
            accountRecord.MDS_Last_Synced__c = String.valueOf(JSON.serialize(accountLastMdsUpdatedMap));
            accountRecord.Latest_MDS_Updated_Date_Time__c = thisEventRecievedDateTime;
            storeSyncUnitOfWork.registerDirty(accountRecord);
        }
    }

    private void updateXrefRecord() {
        if(isXrefUpdated){
            xrefRecord.MDS_Last_Synced__c = String.valueOf(JSON.serialize(xrefLastMdsUpdatedMap));
            xrefRecord.Latest_MDS_Updated_Date_Time__c = thisEventRecievedDateTime;
            storeSyncUnitOfWork.registerDirty(xrefRecord);
        }
    }

    private void processDDMxRecordsUpdates(Integration_Request__c integrationRequest, List<Xref__c> xrefs){
        xrefRecord = xrefs[0];
        accountRecord = new Account(Id = xrefs[0].Salesforce_Account_Name__c,
                                    Order_Protocol__c = xrefs[0].Salesforce_Account_Name__r.Order_Protocol__c);

        xrefLastMdsUpdatedMap = string.isNotBlank(xrefs[0].MDS_Last_Synced__c) ?
                                                    (Map<String, String>) JSON.deserialize(xrefs[0].MDS_Last_Synced__c, Map<String, String>.class) :
                                                    new Map<String, String>();
        accountLastMdsUpdatedMap = string.isNotBlank(xrefs[0].Salesforce_Account_Name__r.MDS_Last_Synced__c) ?
                                                        (Map<String, String>) JSON.deserialize(xrefs[0].Salesforce_Account_Name__r.MDS_Last_Synced__c, Map<String, String>.class) :
                                                        new Map<String, String>();

        thisEventRecievedDateTime = integrationRequest.Store_Update_Event_Received_Date_Time__c;

        Map<String,String> fieldsUpdatedwithNewValues = StoreUpdateIntegrationWrapper.fieldsUpdatedwithNewValues(storeUpdate);
        String errorMessage;
        Map<String, MDS_Sync_Mapping__mdt> mdsSyncMappings = new Map<String, MDS_Sync_Mapping__mdt>();
        for(MDS_Sync_Mapping__mdt mapping: MDSSyncMappingsSelector.newInstance().getActiveMDSSyncMappings()){
                mdsSyncMappings.put(mapping.DeveloperName, mapping);
        }

        for(String jsonAttr: fieldsUpdatedwithNewValues.keyset()){
            MDS_Sync_Mapping__mdt mdsSyncMapping = mdsSyncMappings.containsKey(jsonAttr) ? mdsSyncMappings.get(jsonAttr) : null;
            if(mdsSyncMapping == null){
                continue;
            }
            if(mdsSyncMapping.DDMx_Update_Type__c == COMPLEX_UPDATE) {
                MDSSyncServiceWrapper complexServiceReturn;
                switch on OBJECT_NAME_MAPPINGS.get(mdsSyncMapping.DDMx_Object_Name__c){
                    when ACCOUNT_API_NAME {
                        complexServiceReturn = processAccountRecordComplexUpdates(mdsSyncMapping);
                    } when XREF_API_NAME {
                        complexServiceReturn = processXrefRecordComplexUpdates(mdsSyncMapping);
                    } when else {
                        complexServiceReturn = new MDSSyncServiceWrapper();
                    }
                }
                errorMessage = complexServiceReturn.errorMessage != null && String.isNotBlank(errorMessage) ? errorMessage+' - '+complexServiceReturn.errorMessage : complexServiceReturn.errorMessage;
            } else if(mdsSyncMapping.DDMx_Update_Type__c == SIMPLE_UPDATE) {
                updateRecords(mdsSyncMapping, fieldsUpdatedwithNewValues.get(jsonAttr));
            }
        }

        updateXrefRecord();
        updateAccountRecord();

        String irStatus = String.isBlank(errorMessage) ? PROCESSED_STATUS : FAILED_STATUS;
        updateIntegrationRequestRecord(integrationRequest.Id, irStatus, errorMessage);
    }

    private boolean isNotEligibleForUpdate(Map<String, String> lastMdsUpdatedMap, MDS_Sync_Mapping__mdt mdsSyncMapping) {
        return lastMdsUpdatedMap.containsKey(mdsSyncMapping.DDMx_Field_to_Update__c) && thisEventRecievedDateTime < DateTime.valueOf(lastMdsUpdatedMap.get(mdsSyncMapping.DDMx_Field_to_Update__c));
    }

    private void updateRecords(MDS_Sync_Mapping__mdt mdsSyncMapping, String newValue){
        //set the respective object record and its last MDS updated map
        SObject objRecord;
        Map<String, String> lastMdsUpdatedMap = new Map<String, String>();
        if(mdsSyncMapping.DDMx_Object_Name__c == ACCOUNT_API_NAME){
            objRecord = accountRecord;
            lastMdsUpdatedMap.putAll(accountLastMdsUpdatedMap);
        } else if(mdsSyncMapping.DDMx_Object_Name__c == XREF_API_NAME){
            objRecord = xrefRecord;
            lastMdsUpdatedMap.putAll(xrefLastMdsUpdatedMap);
        }
        //determine if we have to proceed with update or not
        if(isNotEligibleForUpdate(lastMdsUpdatedMap, mdsSyncMapping)){
            return;
        }
        //set the field value
        if(String.isBlank(newValue)){
            objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, null);
        } else{
            switch on DATA_TYPE_MAPPINGS.get(mdsSyncMapping.Target_Field_Data_Type__c){
                when STRING_TYPE {
                    objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, String.valueOf(newValue));
                } when INTEGER_TYPE {
                    objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, Integer.valueOf(newValue));
                } when BOOLEAN_TYPE {
                    objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, Boolean.valueOf(newValue));
                } when DECIMAL_TYPE {
                    objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, Decimal.valueOf(newValue));
                } when DOUBLE_TYPE {
                    objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, Double.valueOf(newValue));
                } when else {
                    objRecord.put(mdsSyncMapping.DDMx_Field_to_Update__c, String.valueOf(newValue));
                }
        	}
        }

        if(mdsSyncMapping.DDMx_Object_Name__c == ACCOUNT_API_NAME){
            accountRecord = (Account) objRecord;
            accountLastMdsUpdatedMap.put(mdsSyncMapping.DDMx_Field_to_Update__c, String.valueOf(thisEventRecievedDateTime));
            isAccountUpdated = true;
        } else if(mdsSyncMapping.DDMx_Object_Name__c == XREF_API_NAME){
            xrefRecord = (Xref__c) objRecord;
            xrefLastMdsUpdatedMap.put(mdsSyncMapping.DDMx_Field_to_Update__c, String.valueOf(thisEventRecievedDateTime));
            isXrefUpdated = true;
        }
    }
}