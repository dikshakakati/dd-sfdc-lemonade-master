/**
 * @author Deloitte
 * @date 25/07/2022
 * @description Service implementation class for ViewEncryptedDataController related logic.
 */
public inherited sharing class ViewEncryptedDataServiceImpl implements IViewEncryptedDataService {
    private static final String DATE_FIELD_TYPE = 'DATE';
    private static final String ERROR_LOCATION_TOP_OF_PAGE = 'Top of Page';
    private static final String EXCEPTION_TYPE_DML_EXCEPTION = 'System.DmlException';
    private static final Map<String, Schema.SObjectType> GLOBAL_DESCRIBE = Schema.getGlobalDescribe();
    private static final String ID_FIELD = 'Id';
    private static final String NO_ENCRYPTED_DATA_PERMISSION_MESSAGE = System.Label.No_Encrypted_Data_Permission_Message;
    private static final String NUMBER_FIELD_TYPE = 'number';
    private static final String OBJECT_INSTANCE_MAP_EMPTY = '{}';
    private static final String OBJECT_INSTANCE_NULL = 'null';
    private static final String OBJECT_INSTANCE_LIST_OR_SET_EMTPY = '[]';
    private static final String PAYMENT_ACCOUNT_OBJECT_NAME = 'Payment_Account__c';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION = 'View_Encrypted_Banking_Information';
    private static final String WORK_PLAN_OBJECT_NAME = 'WorkPlan';
    private enum ObjectNames {
        WORKPLAN
    }
    private static final Map<String, ObjectNames> OBJECTNAMETOOBJECTNAMEENUMVALUES = new Map<String, ObjectNames>{
        WORK_PLAN_OBJECT_NAME => ObjectNames.WORKPLAN
    };
    private List<EncryptedFieldWrapper> encryptedFieldWrappers;
    private Map<String, String> objectApiNameToFieldSetName;
    private Set<Id> paymentAccountIds;
    private Map<Id, Id> paymentAccountToContactId;

    /**
     * @description Default constructor to insantiate variables.
     */
    public ViewEncryptedDataServiceImpl() {
        this.encryptedFieldWrappers = new List<EncryptedFieldWrapper>();
        this.objectApiNameToFieldSetName = new Map<String, String>();
        this.paymentAccountIds = new Set<Id>();
        this.paymentAccountToContactId = new Map<Id, Id>();
    }

    /**
     * @description It fetches encrypted details using passed viewEncryptedDataWrapper
     * which consists of businessAccountId, componentLocation, recordId and workOrderId.
     * @JIRA# LEM-2255
     * @param viewEncryptedDataWrapper
     * @return List<EncryptedFieldWrapper>
     */
    public List<EncryptedFieldWrapper> getEncryptedData(
        ViewEncryptedDataWrapper viewEncryptedDataWrapper
    ) {
        Id businessAccountId = viewEncryptedDataWrapper.businessAccountId;
        String componentLocation = viewEncryptedDataWrapper.componentLocation;
        String paymentRecordIds = viewEncryptedDataWrapper.paymentRecordIds;
        Id recordId = viewEncryptedDataWrapper.recordId;
        Id workOrderId = viewEncryptedDataWrapper.workOrderId;
        // List is required to maintain the sorting order.
        List<Id> recordIds = new List<Id>();
        if (
            !FeatureManagementService.newInstance()
                .checkPermission(VIEW_ENCRYPTED_BANKING_INFORMATION_PERMISSION)
        ) {
            // throw an exception when the end-user doesn’t have the permission to view encrypted fields
            throw new AuraHandledException(NO_ENCRYPTED_DATA_PERMISSION_MESSAGE);
        }
        for (
            Encrypted_Fields_Configuration__mdt eachEncryptedFieldsConfig : EncryptedFieldsConfigurationsSelector.newInstance()
                .selectByComponetLocationAndObjectApiName(componentLocation)
        ) {
            objectApiNameToFieldSetName.put(
                eachEncryptedFieldsConfig.Object_Api_Name__c,
                eachEncryptedFieldsConfig.FieldSet_Name__c
            );
        }
        recordIds.add(recordId);
        // get "Contact" related to the "Payment Account" to show encrypted fields on WorkPlan
        switch on OBJECTNAMETOOBJECTNAMEENUMVALUES.get(componentLocation) {
            when WORKPLAN {
                // to ensure duplicate Payment Account Ids or business Account Ids are removed when component is added on Work Plan object.
                recordIds.remove(0);
                getPaymentAccountIds(paymentRecordIds, recordId);
                // to get billing Contact related to Payment Account.
                getContactsByPaymentAccounts(paymentAccountIds);
                for (Id eachPaymentAccountId : paymentAccountToContactId.keySet()) {
                    recordIds.add(eachPaymentAccountId);
                    if (!isEmptyOrNull(paymentAccountToContactId.get(eachPaymentAccountId))) {
                        recordIds.add(paymentAccountToContactId.get(eachPaymentAccountId));
                    }
                }
                recordIds.add(businessAccountId);
                if (!isEmptyOrNull(workOrderId)) {
                    recordIds.add(workOrderId);
                }
            }
        }
        generateEncryptedFieldWrappers(componentLocation, recordIds);
        return encryptedFieldWrappers;
    }

    /**
     * @description It fires update on sObject associated with the passed recordId using the passed data.
     * @JIRA# LEM-2255
     * @param recordId
     * @param updatedEncryptedData
     */
    public void updateEncryptedData(Id recordId, String updatedEncryptedData) {
        List<SObject> sObjectsToUpdate = new List<SObject>();
        List<EncryptedFieldWrapper> encryptedFieldWrappers = (List<EncryptedFieldWrapper>) JSON.deserialize(
            updatedEncryptedData,
            List<EncryptedFieldWrapper>.class
        );
        sObject sObjectInstance = Schema.getGlobalDescribe()
            .get(String.valueOf(recordId.getSobjectType()))
            .newSObject();
        for (EncryptedFieldWrapper eachWrapper : encryptedFieldWrappers) {
            sObjectInstance.put(ID_FIELD, recordId);
            if (eachWrapper.fieldType == NUMBER_FIELD_TYPE) {
                sObjectInstance.put(
                    eachWrapper.fieldApiName,
                    Decimal.valueOf(eachWrapper.fieldValue)
                );
            } else {
                sObjectInstance.put(eachWrapper.fieldApiName, eachWrapper.fieldValue);
            }
        }
        sObjectsToUpdate.add(sObjectInstance);
        fireRecordsUpdation(sObjectsToUpdate);
    }

    /**
     * @description It trigger UOW commitWork on the passed records.
     * @JIRA# LEM-2255
     * @param sObjectListToUpdate
     */
    private void fireRecordsUpdation(List<SObject> sObjectListToUpdate) {
        if (isEmptyOrNull(sObjectListToUpdate)) {
            return;
        }
        fflib_ISObjectUnitOfWork uowRecordsUpdation = Application.UnitOfWork.newInstance();
        uowRecordsUpdation.registerDirty(sObjectListToUpdate);
        try {
            uowRecordsUpdation.commitWork();
        } catch (Exception recordsUpdationException) {
            throw new AuraHandledException(generateDMLExceptionMessage(recordsUpdationException));
        }
    }

    /**
     * @description To generate exception message from the passed exception.
     * Salesforce returns first error occurred on DML operation.
     * @JIRA# LEM-3191
     * @param exceptionInstance
     * @return String
     */
    private String generateDMLExceptionMessage(Exception exceptionInstance) {
        String exceptionMessage = exceptionInstance.getMessage();
        if (exceptionInstance.getTypeName() == EXCEPTION_TYPE_DML_EXCEPTION) {
            exceptionMessage =
                // A single record is getting processed in the transaction hence considering the zeroth record.
                getFieldApiName(exceptionInstance.getDmlFieldNames(0)) +
                SEPARATOR +
                exceptionInstance.getDmlMessage(0);
        }
        return exceptionMessage;
    }

    /**
     * @description To generate encrypted field wrapper.
     * @JIRA# LEM-2255
     * @param componentLocation
     * @param recordIds
     */
    private void generateEncryptedFieldWrappers(String componentLocation, List<Id> recordIds) {
        Schema.DescribeSObjectResult describeSObjectResult;
        Schema.FieldSet fieldSet;
        String objectApiName;
        SObject sObjectInstance;
        EncryptedFieldWrapper encryptedFieldWrapper;
        for (Id eachRecordId : recordIds) {
            if (eachRecordId == null) {
                continue;
            }
            objectApiName = String.valueOf(eachRecordId?.getSobjectType());
            describeSObjectResult = GLOBAL_DESCRIBE.get(objectApiName).getDescribe();
            fieldSet = getFieldSet(
                describeSObjectResult,
                objectApiNameToFieldSetName.get(objectApiName)
            );
            List<String> configuredFields = getFields(fieldSet);
            /**
             * Quering in for loop as recordIds size is within limit.
             * Storing zeroth index of returned list as it will return only one record
             * and also reduces the complexity.
             */
            sObjectInstance = ((List<SObject>) Security.stripInaccessible(
                    AccessType.READABLE,
                    ((IEncryptedDataSelector) Application.Selector.newInstance(
                            eachRecordId.getSobjectType()
                        ))
                        .selectEncryptedData(fieldSet, new Set<Id>{ eachRecordId })
                )
                .getRecords())[0];
            for (String eachFieldApiName : configuredFields) {
                if (sObjectInstance.getPopulatedFieldsAsMap().containsKey(eachFieldApiName)) {
                    encryptedFieldWrapper = new EncryptedFieldWrapper(
                        eachFieldApiName,
                        getFieldLabel(describeSObjectResult, eachFieldApiName),
                        getFieldType(describeSObjectResult, eachFieldApiName),
                        String.valueOf(sObjectInstance.get(eachFieldApiName)),
                        componentLocation == WORK_PLAN_OBJECT_NAME
                            ? false
                            : isEditable(describeSObjectResult, eachFieldApiName)
                    );
                    encryptedFieldWrapper.fieldHelpText = getFieldHelpText(
                        describeSObjectResult,
                        eachFieldApiName
                    );
                    encryptedFieldWrapper.fieldLength = getFieldLength(
                        describeSObjectResult,
                        eachFieldApiName
                    );
                    encryptedFieldWrappers.add(encryptedFieldWrapper);
                }
            }
        }
    }

    /**
     * @description To get field map from the passed describe SObject result.
     * @JIRA# LEM-2255
     * @param describeSObjectResult
     * @return Map<String, Schema.SObjectField>
     */
    private Map<String, Schema.SObjectField> getAllFields(
        Schema.DescribeSObjectResult describeSObjectResult
    ) {
        return describeSObjectResult.fields.getMap();
    }

    /**
     * @description To get Contact to Payment Account relations from passed Payment Account Ids.
     * @JIRA# LEM-2255
     * @param paymentAccountIds
     */
    private void getContactsByPaymentAccounts(Set<Id> paymentAccountIds) {
        if (isEmptyOrNull(paymentAccountIds)) {
            return;
        }
        for (
            Payment_Account__c eachPaymentAccount : PaymentAccountsSelector.newInstance()
                .selectById(paymentAccountIds)
        ) {
            // get Billing_Contact_Name__c from Payment_Account__c
            paymentAccountToContactId.put(
                eachPaymentAccount.Id,
                eachPaymentAccount.Billing_Contact_Name__c
            );
        }
    }

    /**
     * @description To get field api name from the passed dmlFieldNames.
     * @JIRA# LEM-3191
     * @param dmlFieldNames
     * @return String
     */
    private String getFieldApiName(List<String> dmlFieldNames) {
        String fieldApiName = '';
        if (isEmptyOrNull(dmlFieldNames)) {
            fieldApiName = ERROR_LOCATION_TOP_OF_PAGE;
        }
        for (String eachFieldName : dmlFieldNames) {
            fieldApiName += eachFieldName;
        }
        return fieldApiName;
    }

    /**
     * @description To get the content of the field-level help of the passed field
     * from the passed describe SObject result.
     * @JIRA# LEM-2255
     * @param describeSObjectResult
     * @param fieldApiName
     * @return String
     */
    private String getFieldHelpText(
        Schema.DescribeSObjectResult describeSObjectResult,
        String fieldApiName
    ) {
        String fieldHelpText = '';
        Map<String, Schema.SObjectField> fields = getAllFields(describeSObjectResult);
        if (fields.containsKey(fieldApiName)) {
            fieldHelpText = String.valueOf(
                fields.get(fieldApiName).getDescribe().getInlineHelpText()
            );
        }
        return fieldHelpText;
    }

    /**
     * @description To get the label of the passed field from the passed describe SObject result.
     * @JIRA# LEM-2255
     * @param describeSObjectResult
     * @param fieldApiName
     * @return String
     */
    private String getFieldLabel(
        Schema.DescribeSObjectResult describeSObjectResult,
        String fieldApiName
    ) {
        String fieldLabel = '';
        Map<String, Schema.SObjectField> fields = getAllFields(describeSObjectResult);
        if (fields.containsKey(fieldApiName)) {
            fieldLabel = fields.get(fieldApiName).getDescribe().getLabel();
        }
        return fieldLabel;
    }

    /**
     * @description To get the length of the passed field from the passed describe SObject result.
     * @JIRA# LEM-3191
     * @param describeSObjectResult
     * @param fieldApiName
     * @return Integer
     */
    private Integer getFieldLength(
        Schema.DescribeSObjectResult describeSObjectResult,
        String fieldApiName
    ) {
        Integer fieldLength = 0;
        Map<String, Schema.SObjectField> fields = getAllFields(describeSObjectResult);
        if (fields.containsKey(fieldApiName)) {
            fieldLength = fields.get(fieldApiName).getDescribe().getLength();
        }
        return fieldLength;
    }

    /**
     * @description To get the list of fields configured in the passed FieldSet.
     * @JIRA# LEM-2255
     * @param fieldSet
     * @return Set<String>
     */
    private List<String> getFields(Schema.FieldSet fieldSet) {
        List<String> fields = new List<String>();
        for (Schema.FieldSetMember eachFieldSetMember : fieldSet?.getFields()) {
            fields.add(eachFieldSetMember.getFieldPath());
        }
        return fields;
    }

    /**
     * @description To get the fieldSet from the passed describe SObject result.
     * @JIRA# LEM-2255
     * @param describeSObjectResult
     * @param fieldSetName
     * @return List<String>
     */
    private Schema.FieldSet getFieldSet(
        Schema.DescribeSObjectResult describeSObjectResult,
        String fieldSetName
    ) {
        return describeSObjectResult.FieldSets.getMap().get(fieldSetName);
    }

    /**
     * @description To get the type of the passed field from the passed describe SObject result.
     * @JIRA# LEM-2255
     * @param describeSObjectResult
     * @param fieldApiName
     * @return String
     */
    private String getFieldType(
        Schema.DescribeSObjectResult describeSObjectResult,
        String fieldApiName
    ) {
        String fieldType = '';
        Map<String, Schema.SObjectField> fields = getAllFields(describeSObjectResult);
        if (fields.containsKey(fieldApiName)) {
            fieldType = String.valueOf(fields.get(fieldApiName).getDescribe().getType());
        }
        return fieldType;
    }

    /**
     * @description It collects payment Account Ids from the passed paymentRecordIds.
     * @JIRA# LEM-3794
     * @param paymentRecordIds
     * @param recordId
     */
    private void getPaymentAccountIds(String paymentRecordIds, Id recordId) {
        if (String.isNotBlank(paymentRecordIds)) {
            paymentAccountIds = (Set<Id>) JSON.deserialize(
                JSON.serialize((List<String>) paymentRecordIds?.split(SEPARATOR)),
                Set<Id>.class
            );
        } else {
            paymentAccountIds.add(recordId);
        }
    }

    /**
     * @description To check whether a field is editable by the current user.
     * @JIRA# LEM-2255
     * @param describeSObjectResult
     * @param fieldApiName
     * @return Boolean
     */
    private Boolean isEditable(
        Schema.DescribeSObjectResult describeSObjectResult,
        String fieldApiName
    ) {
        Boolean isUpdateable = false;
        Map<String, Schema.SObjectField> fields = getAllFields(describeSObjectResult);
        if (fields.containsKey(fieldApiName)) {
            isUpdateable = fields.get(fieldApiName).getDescribe().isUpdateable();
        }
        return isUpdateable;
    }

    /**
     * @description To check whether the passed list or set or map is null or empty.
     * @param objectInstance - List/Set/Map
     * @return Boolean
     */
    private Boolean isEmptyOrNull(Object objectInstance) {
        return (JSON.serialize(objectInstance) == OBJECT_INSTANCE_NULL) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_LIST_OR_SET_EMTPY) ||
            JSON.serialize(objectInstance).equals(OBJECT_INSTANCE_MAP_EMPTY);
    }
}