/**
* @author Deloitte
* @date 08/08/2024
* @description Inserts Staging_Bulk_Upload_Request__c records according to user input in flow & csv file uploaded
**/
public with sharing class MerchantBulkOrderRequestsController{
    private static final String COLUMN_BUSINESS_ID = 'Business ID (18 Digit ID)';
    private static final String COLUMN_COUNTRY = 'Country';
    private static final String COLUMN_REQUEST_TYPE = 'Request Type';
    private static final String COLUMN_STATE = 'State/Province';
    private static final String COLUMN_STORE_ID = 'Store ID (18 Digit ID)';
    private static final String DATA_TYPE_DATE = 'DATE';
    private static final String DATA_TYPE_REFERENCE = 'REFERENCE';
    private static final String DATA_TYPE_TIME = 'TIME';
    private static final String ERROR_FOR_MIN_ROW_COUNT_BULK_CSV_UPLOAD = System.Label.Bulk_CSV_Upload_Min_Row_Error;
    private static final String ERROR_FOR_REQUEST_TYPE_MISMATCH_BULK_CSV_UPLOAD = System.Label.Error_for_request_type_mismatch_Bulk_CSV_Upload;
    private static final String ERROR_FOR_MORE_CELL_VALUES_THAN_COLUMNS_BULK_CSV_UPLOAD = System.Label.Error_for_more_cell_values_than_columns_Bulk_CSV_Upload;
    private static final String FIELD_CUSTOM_VALIDATION_EXCEPTION = 'FIELD_CUSTOM_VALIDATION_EXCEPTION';
    private static final String FIELD_INTEGRITY_EXCEPTION = 'FIELD_INTEGRITY_EXCEPTION';
    private static final String FIELD_COUNTRY_CODE_API_NAME = 'Address__CountryCode__s';
    private static final String FIELD_STATE_CODE_API_NAME = 'Address__StateCode__s';
    private static final String INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST = 'INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST';
    private static final String LOG_DOMAIN_BULK_ORDER = 'Bulk Order';
    private static final Integer MINIMUM_ROW_COUNT = 2;
    private static final String NEW_LINE_CHARACTER = '\n';
    private static final String REQUIRED_FIELD_MISSING = 'REQUIRED_FIELD_MISSING';
    private static final String REQUEST_TYPE_RETURN = 'Return';
    private static final String RETURN_PRODUCT_BUNDLE = System.Label.Product_Bundle_For_Return;
    private static final String RETURN_LINE_CHARACTER = '\r';
    private static final String RETURN_NEW_LINE_CHARACTER = '\r\n';
    private static final String STAGING_REQUEST_API_NAME = 'Staging_Bulk_Upload_Request__c';
    private static final String STRING_COLON = ':';
    private static final String STRING_COMMA = ',';
    private static final String STRING_DOUBLE_QUOTE = '"';
    private static final String STRING_ROW_SPLIT_DELIMETER = System.Label.Bulk_Equipment_Request_Split_Delimiter;
    private static final String TYPE_TABLET = 'Tablet';
    private static final String TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String TYPE_PHOTOSHOOT = 'Photoshoot';

    private enum FIELDS_DATATYPE_REFERENCES{
        DATE_TYPE,
        REFERENCE_TYPE,
        TIME_TYPE
    }
    private static final Map<String, FIELDS_DATATYPE_REFERENCES> FIELDS_DATATYPE_REFERENCES_MAPPINGS = new Map<String, FIELDS_DATATYPE_REFERENCES>{
        DATA_TYPE_DATE => FIELDS_DATATYPE_REFERENCES.DATE_TYPE,
        DATA_TYPE_REFERENCE => FIELDS_DATATYPE_REFERENCES.REFERENCE_TYPE,
        DATA_TYPE_TIME => FIELDS_DATATYPE_REFERENCES.TIME_TYPE
    };

    private static String errorMessage = 'ERROR : ';
    private static Decimal rowCountLimit = 0;
    private static String rowCountLimitMessage = '';

    private static Set<Id> businessIds = new Set<Id>();
    private static List<String> errorMessages = new List<String>();
    private static List<Schema.PicklistEntry> countryToCountryCodes;
    private static List<Schema.PicklistEntry> stateToStateCodes;
    private static Set<Id> storeIds = new Set<Id>();

    private static Map<String, String> columnNameToFieldAPIName = new Map<String, String>();
    private static Map<String, String> columnNameToDataType = new Map<String, String>();

    /**
    * @description Processes csv uploaded by user to create Staging_Bulk_Upload_Request__c record
    * and sends any error msg back to flow
    * @jira #LEM-15978
    * @param inputRequestsFromFlow
    * @return List<String>
    */
    @InvocableMethod(label = 'Merchant Bulk Order Request')
    public static List<String> createStagingRecords(
        List<Requests> inputRequestsFromFlow
    ) {
        String csvBodyAsString;
        List<String> csvRows;
        List<String> columnHeaders = new List<String>();
        try{
            Set<Id> documentIds = new Set<Id>((List<Id>)inputRequestsFromFlow[0].contentDocumentIds);
            List<ContentVersion> csvToBeProcessed = ContentVersionsSelector.newInstance().selectByContentDocumentIds(documentIds);
            List<Staging_Bulk_Upload_Reference_Mapping__mdt> metadataReferenceRecords = StagingBulkUploadRefMappingsSelector.newInstance().getAllActiveReferenceAndRequestValues(inputRequestsFromFlow[0].referenceType, inputRequestsFromFlow[0].referenceRequestType);

            rowCountLimit = metadataReferenceRecords[0].Record_Limit__c;
            rowCountLimitMessage = metadataReferenceRecords[0].Error_Message__c;

            for(
                Staging_Bulk_Upload_Request_Mapping__mdt metadataRecord : metadataReferenceRecords[0].Staging_Bulk_Upload_Request_Mappings__r
            ) {
                columnNameToFieldAPIName.put(metadataRecord.CSV_Column_Name__c.trim(), metadataRecord.API_Name__c.trim());
                columnNameToDataType.put(metadataRecord.CSV_Column_Name__c.trim(), metadataRecord.Datatype__c.trim());
            }

            csvBodyAsString = csvToBeProcessed[0].VersionData.toString();
            csvBodyAsString = csvBodyAsString.replace(RETURN_NEW_LINE_CHARACTER, NEW_LINE_CHARACTER).replace(RETURN_LINE_CHARACTER, NEW_LINE_CHARACTER);
            csvRows = csvBodyAsString.removeEnd(NEW_LINE_CHARACTER).split(NEW_LINE_CHARACTER);

            if(
                csvRows.size() < MINIMUM_ROW_COUNT
            ) {
                errorMessage += ERROR_FOR_MIN_ROW_COUNT_BULK_CSV_UPLOAD;
                errorMessages.add(errorMessage);
                return errorMessages;
            }

            columnHeaders = csvRows[0].split(STRING_ROW_SPLIT_DELIMETER);
            getCodeValueMappingsForCountryAndState();
            readCSVAndInsertStagingRequests(inputRequestsFromFlow[0].referenceRecordId, inputRequestsFromFlow[0].referenceRequestType, inputRequestsFromFlow[0].referenceType, columnHeaders, csvRows);
        }
        catch(Exception ex){
            if(ex.getMessage().contains(FIELD_CUSTOM_VALIDATION_EXCEPTION)){
                errorMessage += ex.getMessage().substringBetween(FIELD_CUSTOM_VALIDATION_EXCEPTION, STRING_COLON).removeStart(STRING_COMMA).trim();
            }
            else if(ex.getMessage().contains(REQUIRED_FIELD_MISSING)){
                errorMessage += ex.getMessage().substringBetween(REQUIRED_FIELD_MISSING, STRING_COLON).removeStart(STRING_COMMA).trim();
            }
            else if(ex.getMessage().contains(INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST)){
                errorMessage += ex.getMessage().substringAfter(INVALID_OR_NULL_FOR_RESTRICTED_PICKLIST).removeStart(STRING_COMMA).trim();
            }
            else if(ex.getMessage().contains(FIELD_INTEGRITY_EXCEPTION)){
                errorMessage += ex.getMessage().substringAfter(FIELD_INTEGRITY_EXCEPTION).removeStart(STRING_COMMA).trim();
            }
            else{
                errorMessage += ex.getMessage();
            }
            errorMessages.add(errorMessage);
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    errorMessage, LOG_DOMAIN_BULK_ORDER, GenericLogEntry.SeverityLevel.HIGH
                ).logException(ex)
            );
        }

        return errorMessages;
    }

    /**
    * @description Processes csv and assigns appropriate values to the fields of the new Staging Request record to be inserted
    * @jira #LEM-15978
    * @param referenceRecordId
    * @param referenceRequestType
    * @param referenceType
    * @param columnHeaders
    * @param csvRows
    */
    private static void readCSVAndInsertStagingRequests(
        String referenceRecordId,
        String referenceRequestType,
        String referenceType,
        List<String> columnHeaders,
        List<String> csvRows
    ) {
        String columnValue, rowValue, columnAPIName, columnDataType;
        List<String> rowValues;
        Staging_Bulk_Upload_Request__c stagingBulkRequestRecord;
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        for(
            Integer csvRowPointer = 1; csvRowPointer < csvRows.size(); csvRowPointer++
        ) {
            rowValues = csvRows[csvRowPointer].trim().split(STRING_ROW_SPLIT_DELIMETER);
            if(
                !invalidCSVData(rowValues.size(), columnHeaders.size()).isEmpty()
            ) {
                    return;
            }
            stagingBulkRequestRecord = new Staging_Bulk_Upload_Request__c();
            stagingBulkRequestRecord.Staging_Upload_Ref__c = referenceRecordId;
            for(
                Integer cellValPointer = 0; cellValPointer < rowValues.size(); cellValPointer++
            ) {
                columnValue = assignColumnValue(columnHeaders[cellValPointer]);
                rowValue = assignRowValue(rowValues[cellValPointer]);
                if(
                    !invalidRequestTypeValueOrInvalidRowCount(rowValue, columnValue, referenceType, referenceRequestType).isEmpty()
                ) {
                    return;
                }
                if(
                    invalidRowOrColumnValue(rowValue, columnValue)
                ) {
                    continue;
                }
                rowValue = columnValue == COLUMN_COUNTRY || columnValue == COLUMN_STATE ? getCountryOrStateCode(rowValue, columnValue) : rowValue;
                assignFieldValueForStagingRequest(rowValue, columnValue, columnDataType, columnAPIName, stagingBulkRequestRecord);
            }
            assignProductBundleValueForReturnRequestType(referenceRequestType, stagingBulkRequestRecord);
            uow.registerNew(stagingBulkRequestRecord);
        }
        uow.commitWork();
    }

    /**
    * @description Assigns columnValue after trim
    * @jira #LEM-15978
    * @param rawColumnValue
    * @return String
    */
    private static String assignColumnValue(String rawColumnValue){
        return String.isNotBlank(rawColumnValue) ? rawColumnValue.replace(STRING_DOUBLE_QUOTE,'').trim() : '';
    }

    /**
    * @description Assigns rowValue after trim
    * @jira #LEM-15978
    * @param rawRowValue
    * @return String
    */
    private static String assignRowValue(String rawRowValue){
        return String.isNotBlank(rawRowValue) ? rawRowValue.replace(STRING_DOUBLE_QUOTE,'').trim() : '';
    }

    /**
    * @description Checks whether the no. of cell values in any row is greater than the no. of column headers in the csv
    * @jira #LEM-15978
    * @param totalNoOfRowValues
    * @param totalNoOfColumns
    * @return List<String>
    */
    private static List<String> invalidCSVData(Integer totalNoOfRowValues, Integer totalNoOfColumns){
        if(totalNoOfRowValues > totalNoOfColumns){
            errorMessage += ERROR_FOR_MORE_CELL_VALUES_THAN_COLUMNS_BULK_CSV_UPLOAD;
            errorMessages.add(errorMessage);
        }
        return errorMessages;
    }

    /**
    * @description Checks whether request type in csv matches the selected request type from flow or
    * whether the no. of business account ids is greater than the limit (Photoshoot) or
    * whether the no. of store account ids is greater than the limit (Tablet / Marketing-Kit)
    * @jira #LEM-15978
    * @param rowValue
    * @param columnValue
    * @param referenceType
    * @param referenceRequestType
    * @return List<String>
    */
    private static List<String> invalidRequestTypeValueOrInvalidRowCount(
        String rowValue,
        String columnValue,
        String referenceType,
        String referenceRequestType
    ) {
        if(columnValue == COLUMN_REQUEST_TYPE && rowValue != referenceRequestType){
            errorMessage += ERROR_FOR_REQUEST_TYPE_MISMATCH_BULK_CSV_UPLOAD;
            errorMessages.add(errorMessage);
            return errorMessages;
        }

        populateStoreOrBusinessIds(rowValue, columnValue, referenceType);

        if(storeIds.size() > rowCountLimit || businessIds.size() > rowCountLimit){
            errorMessage += rowCountLimitMessage;
            errorMessages.add(errorMessage);
        }
        return errorMessages;
    }

    /**
    * @description Populates Store and Business Ids set based on Type
    * @param rowValue
    * @param columnValue
    * @param referenceType
    */
    private static void populateStoreOrBusinessIds(String rowValue, String columnValue, String referenceType){
        if(columnValue == COLUMN_STORE_ID && (referenceType == TYPE_TABLET || referenceType == TYPE_MARKETING_KIT)){
            storeIds.add(rowValue);
        }
        else if(columnValue == COLUMN_BUSINESS_ID && referenceType == TYPE_PHOTOSHOOT){
            businessIds.add(rowValue);
        }
    }

    /**
    * @description Decides whether rowValue or columnValue is blank and whether column's corresponding record is present in
    * Staging Bulk Upload Request Mappings custom metadata
    * @jira #LEM-15978
    * @param rowValue
    * @param columnValue
    * @return Boolean
    */
    private static Boolean invalidRowOrColumnValue(
        String rowValue,
        String columnValue
    ) {
        return (String.isBlank(rowValue) || String.isBlank(columnValue) || !columnNameToFieldAPIName.containsKey(columnValue));
    }

    /**
    * @description Assigns values to the fields of the new Staging Request record to be inserted
    * @jira #LEM-15978
    * @param rowValue
    * @param columnValue
    * @param columnDataType
    * @param columnAPIName
    * @param stagingBulkRequestRecord
    */
    private static void assignFieldValueForStagingRequest(
        String rowValue,
        String columnValue,
        String columnDataType,
        String columnAPIName,
        Staging_Bulk_Upload_Request__c stagingBulkRequestRecord
    ) {
        Time photoshootTime;
        String[] timeSplit;
        columnAPIName = columnNameToFieldAPIName.get(columnValue);
        columnDataType = columnNameToDataType.get(columnValue);
        switch on FIELDS_DATATYPE_REFERENCES_MAPPINGS.get(columnDataType){
            when DATE_TYPE{
                stagingBulkRequestRecord.put(columnAPIName, Date.valueOf(rowValue));
            }
            when TIME_TYPE{
                timeSplit = rowValue.trim().split(STRING_COLON);
                photoshootTime = Time.newInstance(Integer.valueOf(timeSplit[0])
                                            ,Integer.valueOf(timeSplit[1])
                                            ,0
                                            ,0);
                stagingBulkRequestRecord.put(columnAPIName, photoshootTime);
            }
            when REFERENCE_TYPE{
                stagingBulkRequestRecord.put(columnAPIName, Id.valueOf(rowValue));
            }
            when else{
                stagingBulkRequestRecord.put(columnAPIName, rowValue);
            }
        }
    }

    /**
    * @description Assigns Product Bundle when Request Type is Return
    * @jira #LEM-15978
    * @param referenceRequestType
    * @param stagingBulkRequestRecord
    */
    private static void assignProductBundleValueForReturnRequestType(
        String referenceRequestType,
        Staging_Bulk_Upload_Request__c stagingBulkRequestRecord
    ) {
        if(referenceRequestType == REQUEST_TYPE_RETURN){
            stagingBulkRequestRecord.Product_Bundle__c = RETURN_PRODUCT_BUNDLE;
        }
    }

    /**
    * @description Gets the corresponding State code or Country code based on the state or country entered by the user in a csv row
    * @jira #LEM-15978
    * @param rowValue
    * @param columnValue
    * @return String
    */
    private static String getCountryOrStateCode(
        String rowValue,
        String columnValue
    ) {
        List<Schema.PicklistEntry> codeValues = new List<Schema.PicklistEntry>();
        codeValues = columnValue == COLUMN_COUNTRY ? countryToCountryCodes : stateToStateCodes;
        for(Schema.PicklistEntry currentValue : codeValues) {
            if(currentValue.getLabel().equalsIgnoreCase(rowValue)){
                return currentValue.getValue();
            }
        }
        return '';
    }

    /**
    * @description Gets the picklist values and their labels for CountryCode and StateCode
    * @jira #LEM-15978
    */
    private static void getCodeValueMappingsForCountryAndState(){
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(STAGING_REQUEST_API_NAME);
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
        Schema.DescribeFieldResult countryfieldInfo = describeResult.fields.getMap()
                                                                    .get(FIELD_COUNTRY_CODE_API_NAME)
                                                                    .getDescribe();
        Schema.DescribeFieldResult statefieldInfo = describeResult.fields.getMap()
                                                                    .get(FIELD_STATE_CODE_API_NAME)
                                                                    .getDescribe();
        countryToCountryCodes = countryfieldInfo.getPicklistValues();
        stateToStateCodes = statefieldInfo.getPicklistValues();
    }

    /**
    * @description Input type from flow.
    */
    public class Requests{
        @InvocableVariable
        public String referenceType;

        @InvocableVariable
        public String referenceRequestType;

        @InvocableVariable
        public String referenceRecordId;

        @InvocableVariable
        public List<String> contentDocumentIds;
    }
}