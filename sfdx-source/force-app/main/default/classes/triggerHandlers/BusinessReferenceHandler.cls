/**
 * @description LEM-2081 Business_Reference__c Object Trigger Handler
 * @author ATG
 * @date 2022-06-29
 */
public class BusinessReferenceHandler extends ApplicationDomainHandler {
    private static final String DEFAULT_TYPE_COO_GRAVEYARD = 'COO Graveyard';
    private static final String DRIVE_WITH_MPBZID_YES = 'Yes';
    public static final String EXTERNAL_ID_SOURCE_DRIVE_DB = 'DriveDb';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_ID_SOURCE_MDS_CATERING = 'MDS - Catering';
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION = 'EBID_INTEGRATE';
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_COO = 'EBID_INTEGRATE_COO';
    private static final String EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING = 'EBID_WH_INTEGRATE';
    public static final String STATUS_COO_SUCCESS = 'COO Success';
    public static final String STATUS_FAILURE = 'Failure';
    public static final String STATUS_READY_FOR_COO_INTEGRATION = 'Ready for COO Integration';
    public static final String STATUS_READY_FOR_INTEGRATION = 'Ready for Integration';
    public static final String STATUS_SUCCESS = 'Success';
    public static final String SANDBOX_NAMED_CREDENTIAL = Label.NamedCredentialAPIName;
    public static final String PROD_NAMED_CREDENTIAL = Label.ProdNamedCredentialAPIName;
    public static Map<Id, String> oldBGIDMap = new Map<Id, String>();
    private static final string TRIGGER_CONTEXT_BEFORE = 'Before';

    /**
     * @description Constructor Method
     * @param sObjectList - Contract Record List
     */
    public BusinessReferenceHandler(List<Business_Reference__c> sObjectList) {
        super(sObjectList);
        setContextBypass(Business_Reference__c.SObjectType, BusinessReferenceHandler.class);
    }

    /**
     * @description Called to perform processing during the before insert phase.
     */
    public override void onBeforeInsert() {
        BusinessVerticalsService.populateBusinessVerticalDetails(getRecords());
        validateUniqueness();
        for (Business_Reference__c record : (List<Business_Reference__c>) getRecords()) {
            if (String.isNotBlank(record.Business_Group_Id__c)) {
                record.is_Biz_Group_Id_Link_To_Biz_Ref_Id__c = true;
            }
        }
        BusinessReferences.newInstance(this.records)
            .updateMasteredInFigment(TRIGGER_CONTEXT_BEFORE);
    }

    /**
     * @description Called to perform processing during the after insert phase.
     */
    public override void onAfterInsert() {
        List<Business_Reference__c> readyForIntegrationBusinessReferences = filterByIntegrationStatuses(
            new Set<String>{ STATUS_READY_FOR_INTEGRATION },
            (List<Business_Reference__c>) getRecords()
        );
        Map<String, List<Business_Reference__c>> topicToBusinessReferences = filterBusinessReferencesByTopic(
            readyForIntegrationBusinessReferences
        );
        List<Business_Reference__c> readyForCOOIntegrationRecords = filterByIntegrationStatuses(
            new Set<String>{ STATUS_READY_FOR_COO_INTEGRATION },
            (List<Business_Reference__c>) getRecords()
        );
        if (!topicToBusinessReferences.isEmpty()) {
            if (topicToBusinessReferences.containsKey(EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION)) {
                BusReferenceIntegrationService.createIntegrationPlatformEvents(
                    topicToBusinessReferences.get(EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION),
                    EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION
                );
            }
            if (
                topicToBusinessReferences.containsKey(
                    EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
                )
            ) {
                BusReferenceIntegrationService.createIntegrationPlatformEvents(
                    topicToBusinessReferences.get(
                        EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
                    ),
                    EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
                );
            }
        }
        if (!readyForCOOIntegrationRecords.isEmpty()) {
            BusReferenceIntegrationService.createIntegrationPlatformEvents(
                readyForCOOIntegrationRecords,
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_COO
            );
        }
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return ContractHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new BusinessReferenceHandler(sObjectList);
        }
    }

    /**
     * @description Called to perform processing during the before update phase.
     * @param existingRecords - The map of old BusinessReferenceHandler Records
     */
    public override void onBeforeUpdate(Map<Id, SObject> existingRecords) {
        BusinessVerticalsService.populateBusinessVerticalDetails(
            new List<Business_Reference__c>(
                (List<Business_Reference__c>) getChangedRecords(
                    new Set<SObjectField>{ Business_Reference__c.Business_Vertical__c }
                )
            )
        );
        validateUniqueness();
        BusinessReferences.newInstance(busRefsWithUpdatedProvisioningErrorMessage())
            .updateIntegrationMessage();

        List<Business_Reference__c> changedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{
                Business_Reference__c.Business_Group_Id__c,
                Business_Reference__c.Integration_Status__c
            }
        );
        updateIsBizGroupIdLinkToBizRefId(changedRecords, existingRecords);
        BusinessReferences.newInstance(
                new List<Business_Reference__c>(
                    (List<Business_Reference__c>) getChangedRecords(
                        new Set<SObjectField>{ Business_Reference__c.Brand__c }
                    )
                )
            )
            .updateMasteredInFigment(TRIGGER_CONTEXT_BEFORE);
    }

    private List<Business_Reference__c> busRefsWithUpdatedProvisioningErrorMessage() {
        return new List<Business_Reference__c>(
            (List<Business_Reference__c>) getChangedRecords(
                new Set<SObjectField>{ Business_Reference__c.Provisioning_Error_Message__c }
            )
        );
    }

    /**
     * @description Called to update is_Biz_Group_Id_Link_To_Biz_Ref_Id__c field
     * @param changedRecords - The list of BusinessReferenceHandler Records
     * @param existingRecords - The map of old BusinessReferenceHandler Records
     */
    @TestVisible
    private void updateIsBizGroupIdLinkToBizRefId(
        List<Business_Reference__c> changedRecords,
        Map<Id, SObject> existingRecords
    ) {
        for (Business_Reference__c record : changedRecords) {
            Business_Reference__c oldRecord = (Business_Reference__c) existingRecords.get(
                record.Id
            );

            if (record.Business_Group_Id__c != oldRecord.Business_Group_Id__c && String.isNotBlank(record.Business_Group_Id__c)) {
                // Store the old Business Group Id and External Id in oldBGIDMap
                if(String.isNotBlank(oldRecord.Business_Group_Id__c)){
                    BusinessReferenceHandler.oldBGIDMap.put(record.Id, oldRecord.Business_Group_Id__c + '|' + record.External_Id__c);
                }

                record.is_Biz_Group_Id_Link_To_Biz_Ref_Id__c = true;
                record.Integration_Status__c = STATUS_READY_FOR_INTEGRATION;
                record.Integration_Message__c = NULL;
            }

            if (
                String.isNotBlank(record.Integration_Status__c) &&
                record.Integration_Status__c.equalsIgnoreCase(STATUS_SUCCESS) &&
                record.is_Biz_Group_Id_Link_To_Biz_Ref_Id__c
            ) {
                record.is_Biz_Group_Id_Link_To_Biz_Ref_Id__c = false;
            }
        }
    }

    /**
     * @description Called to perform processing during the after update phase.
     * @param existingRecords - The map of old BusinessReferenceHandler Records
     */
    public override void onAfterUpdate(Map<Id, SObject> existingRecords) {
        coordinateSuccessIntegration();
        coordinateReadyForIntegration();
        coordinateFailedIntegration();
        updateWorkStepWhenBusRefUpdatedForDriveOnSuccess();
        updateWorkStepWhenBusRefUpdatedForDriveOnFailure();
        BusinessReferences.newInstance(
                getBusinessReferencesWithExternalIdCreatedandSourceNotEmpty()
            )
            .updateProcessRequestFlowifAllExternalIdsCreated();
    }

    /**
     * @description to fetch all BusinessReferences with External Id Created and Source Not Empty
     * @author rishab.goyal | 03-18-2024
     * @return List<Business_Reference__c>
     **/
    @TestVisible
    private List<Business_Reference__c> getBusinessReferencesWithExternalIdCreatedandSourceNotEmpty() {
        List<Business_Reference__c> recordsWithExternalIdChanged = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{ Business_Reference__c.External_Id__c }
        );

        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>();
        for (Business_Reference__c businessReference : recordsWithExternalIdChanged) {
            if (
                businessReference.External_Id__c != null &&
                businessReference.Created_Source_Id__c != null
            ) {
                businessReferences.add(businessReference);
            }
        }
        return businessReferences;
    }

    /**
     * @description Called to Update WorkStep Status from Last Completed Step Change
     */
    private Void updateWorkStepWhenBusRefUpdatedForDriveOnSuccess() {
        List<Business_Reference__c> statusChangedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{
                Business_Reference__c.Last_Completed_Step__c,
                Business_Reference__c.Integration_Status__c
            }
        );

        Map<Id, Business_Reference__c> busReferIdToBusRefRecMap = new Map<Id, Business_Reference__c>();
        for (Business_Reference__c businessReference : statusChangedRecords) {
            if (
                businessReference.External_ID_Source__c == EXTERNAL_ID_SOURCE_DRIVE_DB &&
                businessReference.Integration_Status__c == STATUS_SUCCESS &&
                (String.isNotBlank(businessReference.Last_Completed_Step__c))
            ) {
                busReferIdToBusRefRecMap.put(businessReference.Id, businessReference);
            }
        }
        if (!busReferIdToBusRefRecMap.isEmpty()) {
            WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
                busReferIdToBusRefRecMap
            );
        }
    }

    /**
     * @description Called to Update WorkStep Status
     */
    private Void updateWorkStepWhenBusRefUpdatedForDriveOnFailure() {
        List<Business_Reference__c> statusChangedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{ Business_Reference__c.Integration_Status__c }
        );
        Map<Id, Business_Reference__c> busReferIdToBusRefRecMap = new Map<Id, Business_Reference__c>();
        for (Business_Reference__c businessReference : statusChangedRecords) {
            if (
                businessReference.External_ID_Source__c == EXTERNAL_ID_SOURCE_DRIVE_DB &&
                businessReference.Integration_Status__c == STATUS_FAILURE
            ) {
                busReferIdToBusRefRecMap.put(businessReference.Id, businessReference);
            }
        }
        if (!busReferIdToBusRefRecMap.isEmpty()) {
            WorkStepStatusForDriveService.updateWorkStepsStatusOnBusinessReferenceStatusChangeForDrive(
                busReferIdToBusRefRecMap
            );
        }
    }

    /**
     * @description Called to validate uniqueness
     */
    private void validateUniqueness() {
        List<Business_Reference__c> businessReferencesThatChanged = new List<Business_Reference__c>();
        if (this.ExistingRecords == null) {
            businessReferencesThatChanged.addAll((List<Business_Reference__c>) getRecords());
        } else {
            businessReferencesThatChanged.addAll(
                (List<Business_Reference__c>) getChangedRecords(
                    BusinessReferences.UNIQUE_IDENTIFIER_FIELDS
                )
            );
        }

        List<Business_Reference__c> businessReferencesToValidate = new List<Business_Reference__c>();
        for (Business_Reference__c busRef : businessReferencesThatChanged) {
            if (busRef.Default_Type__c != DEFAULT_TYPE_COO_GRAVEYARD) {
                businessReferencesToValidate.add(busRef);
            }
        }
        if (businessReferencesToValidate.isEmpty()) {
            return;
        }

        BusinessReferences.newInstance(businessReferencesToValidate).validateUniqueness();
    }

    /**
     * @description Called to coordinate Successful integration
     */
    private void coordinateSuccessIntegration() {
        List<Business_Reference__c> statusChangedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{ Business_Reference__c.Integration_Status__c }
        );

        List<Business_Reference__c> lastCompletedStepChangedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{ Business_Reference__c.Last_Completed_Step__c }
        );

        List<Business_Reference__c> successRecords = filterByIntegrationStatuses(
            new Set<String>{ STATUS_SUCCESS },
            statusChangedRecords
        );

        //Add All Success records, because it may have had Last Completed Step before, but is now going to Success Again.
        lastCompletedStepChangedRecords.addAll(successRecords);

        List<Business_Reference__c> cooSuccessRecords = filterByIntegrationStatuses(
            new Set<String>{ STATUS_COO_SUCCESS },
            statusChangedRecords
        );

        if (!successRecords.isEmpty()) {
            XrefIntegrationService.updateStatusToReadyForIntegration(successRecords, false);
        }

        if (!lastCompletedStepChangedRecords.isEmpty()) {
            ActivationOrdersService.activateOrderProductsOnBusinessReferenceSuccess(
                lastCompletedStepChangedRecords
            );
        }

        if (!cooSuccessRecords.isEmpty()) {
            XrefIntegrationService.updateStatusToReadyForIntegration(cooSuccessRecords, true);
            WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceCOOStatusChange(
                cooSuccessRecords
            );
        }
    }
    /**
     * @description Called to coordinate Ready for Integration integration
     */
    private void coordinateReadyForIntegration() {
        List<Business_Reference__c> statusChangedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{ Business_Reference__c.Integration_Status__c }
        );

        List<Business_Reference__c> readyForIntegrationRecords = filterByIntegrationStatuses(
            new Set<String>{ STATUS_READY_FOR_INTEGRATION },
            statusChangedRecords
        );
        Map<String, List<Business_Reference__c>> topicToBusinessReferences = filterBusinessReferencesByTopic(
            readyForIntegrationRecords
        );
        List<Business_Reference__c> readyForCOOIntegrationRecords = filterByIntegrationStatuses(
            new Set<String>{ STATUS_READY_FOR_COO_INTEGRATION },
            statusChangedRecords
        );
        if (!topicToBusinessReferences.isEmpty()) {
            if (topicToBusinessReferences.containsKey(EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION)) {
                BusReferenceIntegrationService.createIntegrationPlatformEvents(
                    topicToBusinessReferences.get(EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION),
                    EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION
                );
            }
            if (
                topicToBusinessReferences.containsKey(
                    EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
                )
            ) {
                BusReferenceIntegrationService.createIntegrationPlatformEvents(
                    topicToBusinessReferences.get(
                        EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
                    ),
                    EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING
                );
            }
        }
        if (!readyForCOOIntegrationRecords.isEmpty()) {
            BusReferenceIntegrationService.createIntegrationPlatformEvents(
                readyForCOOIntegrationRecords,
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_COO
            );
        }
        // Check for size of Map.
        if (BusinessReferenceHandler.oldBGIDMap.Size()>=0 && (!BusinessReferenceHandler.oldBGIDMap.isEmpty())) {
            unlinkBusinessGroupMappings(new List<String>(BusinessReferenceHandler.oldBGIDMap.values()));
            BusinessReferenceHandler.oldBGIDMap.clear();
        }
    }

    /**
     * @description Called to coordinate Successed/Failed integration
     */
    private void coordinateFailedIntegration() {
        List<Business_Reference__c> statusChangedRecords = (List<Business_Reference__c>) getChangedRecords(
            new Set<SObjectField>{ Business_Reference__c.Integration_Status__c }
        );
        Map<Id, Business_Reference__c> successFailureBusinessReferences = new Map<Id, Business_Reference__c>(
            filterByIntegrationStatuses(
                new Set<String>{ STATUS_SUCCESS, STATUS_FAILURE },
                statusChangedRecords
            )
        );
        if (!successFailureBusinessReferences.isEmpty()) {
            WorkStepIntegrationStatusService.updateWorkStepsStatusOnBusinessReferenceStatusChange(
                successFailureBusinessReferences
            );
        }
    }

    /**
     * @description Called to perform processing during the after
     * update phase.
     * @param statuses
     * @param statusChangedRecords
     * @return List<Business_Reference__c>
     */
    private List<Business_Reference__c> filterByIntegrationStatuses(
        Set<String> statuses,
        List<Business_Reference__c> statusChangedRecords
    ) {
        List<Business_Reference__c> results = new List<Business_Reference__c>();
        for (Business_Reference__c obj : statusChangedRecords) {
            //new Set(String){'COO Success'}.contains('Success') will return false,
            //So there is no problem with having Integration Statuses of 'COO Success' and 'Success'
            if (statuses.contains(obj.Integration_Status__c) == true) {
                results.add(obj);
            }
        }
        return results;
    }

    /**
     * @description It filters the passed Business References by
     * External Notifier Event's topic name.
     * @JIRA LEM-10182
     * @param businessReferencesToFilter
     * @return Map<String, List<Business_Reference__c>>
     */
    private Map<String, List<Business_Reference__c>> filterBusinessReferencesByTopic(
        List<Business_Reference__c> businessReferencesToFilter
    ) {
        Map<String, List<Business_Reference__c>> topicToBusinessReferences = new Map<String, List<Business_Reference__c>>();
        List<Business_Reference__c> businessReferencesToEBIDIntegrate = new List<Business_Reference__c>();
        List<Business_Reference__c> businessReferencesToEBIDWHIntegrate = new List<Business_Reference__c>();
        for (Business_Reference__c eachBusinessReference : businessReferencesToFilter) {
            if (eachBusinessReference.Drive_with_Mp_Bz_Id__c == DRIVE_WITH_MPBZID_YES) {
                businessReferencesToEBIDWHIntegrate.add(eachBusinessReference);
            } else {
                businessReferencesToEBIDIntegrate.add(eachBusinessReference);
            }
        }
        if (!businessReferencesToEBIDIntegrate.isEmpty()) {
            topicToBusinessReferences.put(
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION,
                businessReferencesToEBIDIntegrate
            );
        }
        if (!businessReferencesToEBIDWHIntegrate.isEmpty()) {
            topicToBusinessReferences.put(
                EXTERNAL_NOTIFIER_TOPIC_EBID_INTEGRATION_DRIVE_WITHHOLDING,
                businessReferencesToEBIDWHIntegrate
            );
        }
        return topicToBusinessReferences;
    }

    /**
     * @description Called to make the HTTP callout to delete the Business Group mappings
     * @param oldBGIDList - The list of old BGID values
     */
    @future(callout=true)
    public static void unlinkBusinessGroupMappings(List<String> oldBGIDList) {
        Boolean isSandbox = false;
        List<String> urlSplit = URL.getOrgDomainUrl().toExternalForm().split('--');
        if (urlSplit.size() > 1) {
        isSandbox = true;
        }
        String namedCredential = isSandbox ? SANDBOX_NAMED_CREDENTIAL : PROD_NAMED_CREDENTIAL;

        for (String oldBGID : oldBGIDList) {
            List<String> parts = oldBGID.split('\\|');
            if (parts.size() == 2) {
                String oldBGIDValue = parts[0];
                String externalIdValue = parts[1];
                String prefix = Label.UnlinkBGIDExperiencePrefix;
                String endpoint = prefix + 'api/businessGroups/' + oldBGIDValue + '/businesses/' + externalIdValue;

                HttpRequest req = new HttpRequest();
                req.setEndpoint('callout:'+ namedCredential + endpoint);
                req.setMethod('DELETE');

                Http http = new Http();
                try {
                    HttpResponse res = http.send(req);
                    String status = '';
                    String message = '';

                    if (res.getStatusCode() == 200) {
                        status = 'Success';
                        message = 'BGID - '+ oldBGIDValue +' was unlinked successfully. Current BGID linked successfully.';
                    } else {
                        status = 'Failure';
                        message = 'Unknown error';
                        if (res.getStatusCode() == 404) {
                            message = 'Not found - BGID does not exist';
                        }
                    }
                    BusinessReferences.updateIntegrationMessageLinkingBizIdandBGID(externalIdValue, message, status);
                } catch (Exception e) {
                    BusinessReferences.updateIntegrationMessageLinkingBizIdandBGID(externalIdValue, 'Exception while unlinking BGID: ' + e.getMessage(), 'Failure');
                }
            }
        }
    }

}