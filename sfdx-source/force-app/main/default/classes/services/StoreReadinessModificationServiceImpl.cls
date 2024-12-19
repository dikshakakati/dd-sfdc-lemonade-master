/**
 * @description       :
 * @author            : Aethereus
 * @group             :
 * @last modified on  : 05-09-2024
 * @description Common Service implementation class for all objects readiness validations related logic.
**/
public with sharing class StoreReadinessModificationServiceImpl implements IStoreReadinessModificationService {
    private static final String LOG_SERVICE_READINESS_CHECK = 'Readiness Check';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String STATUS_RESOLVED = 'Resolved';
    // Class-level variables
    private Schema.SObjectType sObjectType;
    private String objectName;
    private List<Readiness_Check_Failure__c> insertReadinessValidationFailures;
    private List<Readiness_Check_Failure__c> updateReadinessValidationFailures;
    private List<Readiness_Check_Failure__c> existingFailureslist;
    private Map<String, Readiness_Check_Failure__c> existingFailuresMap;
    private Map<String, Readiness_Check_Failure__c> newFailuresMap;

    private void initializeVariables(String sObjectName) {
        this.sObjectType = Schema.getGlobalDescribe().get(sObjectName);
        this.objectName = (this.sObjectType == null) ? '' : this.sObjectType.getDescribe().getLabel();
        this.insertReadinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.updateReadinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.existingFailureslist = new List<Readiness_Check_Failure__c>();
        this.existingFailuresMap = new Map<String, Readiness_Check_Failure__c>();
        this.newFailuresMap = new Map<String, Readiness_Check_Failure__c>();
    }
    /**
     * @description  It is designed to handle the insertion and updating of readiness check failures for all object.
     * @jira LEM-13963
     * @param existingReadinessCheckFailures
     * @param newReadinessCheckFailures
     * @param sObjectName
     * @param className
     */
    public void processReadinessCheckFailures(List<Readiness_Check_Failure__c> existingReadinessCheckFailures,List<Readiness_Check_Failure__c> newReadinessCheckFailures,String sObjectName, String className){
        try{
            initializeVariables(sObjectName);
            processExistingFailures(existingReadinessCheckFailures);
            insertNewFailures(newReadinessCheckFailures);
            updateExistingFailures();
            performDML();
        }catch (Exception readinessCheckException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(LOG_SERVICE_READINESS_CHECK +' - '+ className,LOG_DOMAIN_PROVISIONING,GenericLogEntry.SeverityLevel.HIGH
                ).logException(readinessCheckException)
            );
        }
    }

    /**
     * @description concatenates the provided parameters with '*' as a separator and returns the resulting string.
     * This is used to create a unique key for each failure.
     * @jira LEM-13963
     * @param accountId
     * @param errorMessage
     * @param objectName
     * @param fieldName
     * @return String
     */
    private String mapKeyStringConcanet(String accountId, String errorMessage, String objectName, String fieldName) {
        return (accountId + '*' + errorMessage + '*' + objectName + '*' + fieldName).toLowerCase();
    }

    /**
     * @description This method processes a list of existing failures. It checks if the object name of each failure matches the object name of the current instance.
     * If it does, the failure is added to a list and a map for further processing.
     * @jira LEM-13963
     * @param existingReadinessCheckFailures
     */
    private void processExistingFailures(List<Readiness_Check_Failure__c> existingReadinessCheckFailures) {
        for (Readiness_Check_Failure__c failure : existingReadinessCheckFailures) {
            if(String.isBlank(failure.Object_Name__c) || !objectName.equalsIgnoreCase(failure.Object_Name__c)){
                continue;
            }
            existingFailureslist.add(failure);
            String existkey = mapKeyStringConcanet(failure.Account_Name__c, failure.Error_Message__c, failure.Object_Name__c,failure.Field_Name__c);
            existingFailuresMap.put(existkey,failure);
        }
    }

    /**
     * @description This method processes a list of new failures. It checks if the object name of each failure matches the object name of the current instance.
     * If it does, the failure is added to a map and, if it's not resolved, to a list for insertion.
     * @jira LEM-13963
     * @param newReadinessCheckFailures
     */
    private void insertNewFailures(List<Readiness_Check_Failure__c> newReadinessCheckFailures) {
        for (Readiness_Check_Failure__c newFailure : newReadinessCheckFailures) {
            if(String.isBlank(newFailure.Object_Name__c) || !objectName.equalsIgnoreCase(newFailure.Object_Name__c)){
                continue;
            }
            String key = mapKeyStringConcanet(newFailure.Account_Name__c, newFailure.Error_Message__c, newFailure.Object_Name__c,newFailure.Field_Name__c);
            newFailuresMap.put(key, newFailure);

            if(!existingFailuresMap.containsKey(key)){
                insertReadinessValidationFailures.add(newFailure);
            }
        }
    }


    /**
     * @description This method updates the status of the existing failures.
     * If a failure is not resolved and its object name matches the object name of the current instance,
     * and it's not present in the new failures map, its status is set to resolved and it's added to a list for updating.
     * @jira LEM-13963
     */
    private void updateExistingFailures() {
        for (Readiness_Check_Failure__c failure : existingFailureslist) {
            if(failure.Status__c != STATUS_RESOLVED && String.isNotBlank(failure.Object_Name__c) && objectName.equalsIgnoreCase(failure.Object_Name__c)){
                String keyExisting = mapKeyStringConcanet(failure.Account_Name__c, failure.Error_Message__c,failure.Object_Name__c,failure.Field_Name__c);
                if(!newFailuresMap.containsKey(keyExisting)){
                    failure.Status__c = STATUS_RESOLVED;
                    updateReadinessValidationFailures.add(failure);
                }
            }
        }
    }

    /**
     * @description This method performs DML operations (insertion and updating) on the failures.
     * It uses the Unit of Work pattern to handle these operations.
     * It registers new failures for insertion and existing failures for updating, and then commits the work.
     * @jira LEM-13963
     */
    private void performDML() {
        fflib_ISObjectUnitOfWork uowToInsertUpdateReadinessCheckFailures = Application.UNITOFWORK.newInstance();
        if (!insertReadinessValidationFailures.isEmpty()) {
            uowToInsertUpdateReadinessCheckFailures.registerNew(insertReadinessValidationFailures);
        }
        if (!updateReadinessValidationFailures.isEmpty()) {
            uowToInsertUpdateReadinessCheckFailures.registerDirty(updateReadinessValidationFailures);
        }
        if(!insertReadinessValidationFailures.isEmpty() || !updateReadinessValidationFailures.isEmpty()){
            uowToInsertUpdateReadinessCheckFailures.commitWork();
        }
    }
}