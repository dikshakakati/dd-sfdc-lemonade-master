/**
 * @description Domain Class for Business Reference
 */
public with sharing class BusinessReferences extends fflib_SObjects implements IBusinessReferences {
    private static final String LOG_DOMAIN_SALES_TO_CONTRACT = 'Sales To Contract';
    private static final String LOG_DOMAIN = 'Business References';
    private static final String BUSINESS_REFERENCE_BRAND_NOT_MAPPED = 'Brand stamping failed.';
    private static final String LOG_UPDATE_SOBJECT_BASED_ON_BIZ_REF = 'Updation of fields on sObjects based on Business Reference';

    //LEM-12957, the order of these UNIQUE_IDENTIFIER_FIELDS is important. If you want to add new fields add in the bottom.
    public static final Set<SobjectField> UNIQUE_IDENTIFIER_FIELDS = new Set<SObjectField>{
        Business_Reference__c.Business_Vertical__c,
        Business_Reference__c.Brand__c,
        Business_Reference__c.CurrencyIsoCode,
        Business_Reference__c.External_Id_Source__c,
        Business_Reference__c.Default_Type__c
    };
    private static final string PRIMARY_VERTICAL_RX = 'Rx';
    private static final string SEGMENT_SMB = 'SMB';
    private static final string SUCCESS_STRING = 'Success';
    private static final string TRIGGER_CONTEXT_AFTER = 'After';
    private static final string TRIGGER_CONTEXT_BEFORE = 'Before';
    @testvisible
    private static final string INTEGRATION_TYPE = 'Business Reference Provisioning';
    private enum TRIGGER_CONTEXT {
        TRIGGER_CONTEXT_AFTER,
        TRIGGER_CONTEXT_BEFORE
    }
    private static final Map<String, TRIGGER_CONTEXT> TRIGGER_CONTEXT_MAPPING = new Map<String, TRIGGER_CONTEXT>{
        TRIGGER_CONTEXT_AFTER => TRIGGER_CONTEXT.TRIGGER_CONTEXT_AFTER,
        TRIGGER_CONTEXT_BEFORE => TRIGGER_CONTEXT.TRIGGER_CONTEXT_BEFORE
    };

    /**
     * @description This method is to return the IBusinessReference interface
     * @param recordList - Business Reference record list
     * @return IBusinessReferences - Returns IBusinessReferences Interface
     */
    public static IBusinessReferences newInstance(List<Business_Reference__c> recordList) {
        return (IBusinessReferences) Application.Domain.newInstance(recordList);
    }

    /**
     * @description default constructor for the class
     * @param sObjectList
     */
    public BusinessReferences(List<Business_Reference__c> sObjectList) {
        super(sObjectList, Schema.Business_Reference__c.SObjectType);
    }

    /**
     * @description This method is used to validate uniqueness
     */
    public void validateUniqueness() {
        Map<String, Business_Reference__c> businessReferenceKeyToBusinessReferenceMap = new Map<String, Business_Reference__c>();

        for (Business_Reference__c businessReference : (List<Business_Reference__c>) getRecords()) {
            String key = generateKey(businessReference);

            if (key == null) {
                continue;
            }

            if (businessReferenceKeyToBusinessReferenceMap.containsKey(key)) {
                if((businessReference.Id == null &&  businessReference.Is_Created_By_SSMO__c ) || (businessReference.Converted_Lead_Id__c != null)){
                    businessReference.Default_Type__c = null;
                }
                else{
                    businessReference.addError(
                        error(
                            System.Label.Business_Reference_Uniqueness_Constraint_Violation,
                            businessReference
                        )
                    );
                }
            } else {
                businessReferenceKeyToBusinessReferenceMap.put(key, businessReference);
            }
        }

        if (businessReferenceKeyToBusinessReferenceMap.isEmpty()) {
            return;
        }
        checkforExistingBusinessReferences(businessReferenceKeyToBusinessReferenceMap);

    }
    /**
     * @description This method is used to validate if any existing match for business references is found.
     * @param businessReferenceKeyToBusinessReferenceMap
     */
    public void checkforExistingBusinessReferences(Map<String, Business_Reference__c> businessReferenceKeyToBusinessReferenceMap) {
        for (
            Business_Reference__c businessReference : BusinessReferencesSelector.newInstance()
                .selectByBusinessReferenceUniqueIdentifierFields(
                    (List<Business_Reference__c>) getRecords()
                )
        ) {
            String key = generateKey(businessReference);

            if (businessReferenceKeyToBusinessReferenceMap.containsKey(key)) {
                Business_Reference__c bizRef = businessReferenceKeyToBusinessReferenceMap.get(key);
                if((bizRef.Id == null && bizRef.Is_Created_By_SSMO__c ) || (bizRef.Converted_Lead_Id__c != null)){
                    bizRef.Default_Type__c = null;
                }
                else{
                    bizRef
                    .addError(
                        error(
                            System.Label.Business_Reference_Uniqueness_Constraint_Violation,
                            businessReference
                        )
                    );
                }
            }
        }
    }
    /**
     * @description It is used to update 'Mastered In Figment' field when the Account related
     * to the associated Brand has Segment = "SMB" and Primary Vertical != "Rx".
     * @param triggerContext
     */
    public void updateMasteredInFigment(String triggerContext) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Business_Reference__c> businessReferences = new List<Business_Reference__c>();
        for (
            Business_Reference__c eachBusinessReference : (List<Business_Reference__c>) getRecords()
        ) {
            if (
                eachBusinessReference.Brand_Owner_Segment__c == SEGMENT_SMB &&
                eachBusinessReference.Brand_Owner_Vertical__c != PRIMARY_VERTICAL_RX
            ) {
                switch on TRIGGER_CONTEXT_MAPPING.get(triggerContext) {
                    when TRIGGER_CONTEXT_BEFORE {
                        eachBusinessReference.Mastered_In_Figment__c = true;
                    }
                    when TRIGGER_CONTEXT_AFTER {
                        Business_Reference__c businessReference = new Business_Reference__c();
                        businessReference.Id = eachBusinessReference.Id;
                        businessReference.Mastered_In_Figment__c = true;
                        businessReferences.add(businessReference);
                    }
                }
            } else {
                switch on TRIGGER_CONTEXT_MAPPING.get(triggerContext) {
                    when TRIGGER_CONTEXT_BEFORE {
                        eachBusinessReference.Mastered_In_Figment__c = false;
                    }
                    when TRIGGER_CONTEXT_AFTER {
                        Business_Reference__c businessReference = new Business_Reference__c();
                        businessReference.Id = eachBusinessReference.Id;
                        businessReference.Mastered_In_Figment__c = false;
                        businessReferences.add(businessReference);
                    }
                }
            }
        }
        if (businessReferences.isEmpty()) {
            return;
        }
        uow.registerDirty(businessReferences);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_SOBJECT_BASED_ON_BIZ_REF,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    private String generateKey(Business_Reference__c businessReference) {
        String retVal = '';

        for (SObjectField field : UNIQUE_IDENTIFIER_FIELDS) {
            if (String.isBlank((String) businessReference.get(field))) {
                return null;
            }

            retVal += (String) businessReference.get(field);
        }

        return retVal;
    }

    /**
     * @description This method is for implementing constructor in fflib_IDomainConstructor class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description constructor menthod implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return Brands - List of Brands
         */
        public fflib_SObjects construct(List<Object> objectList) {
            return new BusinessReferences((List<SObject>) objectList);
        }
    }

    /**
     * @description It validate and update Work Plan fields on Before Update trigger event.
     */
    public void updateIntegrationMessage() {
        for (Business_Reference__c busRef : (List<Business_Reference__c>) getRecords()) {
            if (busRef.Provisioning_Error_Message__c == SUCCESS_STRING) {
                busRef.Integration_Message__c = SUCCESS_STRING;
            } else {
                updateBusinessFriendlyErrorMessageAndCategory(busRef);
            }
        }
    }

    /**
     * @description Retrieves all business reference IDs from serialized data.
     * @param jsonString The JSON string containing the serialized data.
     * @return A set of business reference IDs.
     */
    public static Set<Id> getAllBzRefsFromSerializedData(String jsonString) {
        Set<Id> businessReferenceIds = new Set<Id>();
        JSONString = JSONString.replaceAll('\n', '');
        if (!JSONString.contains('\"bizRefs\"')) {
            return businessReferenceIds;
        }
        JSONString = JSONString.replaceAll('\n', '');
        BrandWrapper.CaseWithListOfBrandAndBizRefs caseWithListOfBrandAndBizRefs = (BrandWrapper.CaseWithListOfBrandAndBizRefs) JSON.deserialize(
            JSONString,
            BrandWrapper.CaseWithListOfBrandAndBizRefs.class
        );

        if (caseWithListOfBrandAndBizRefs == null) {
            return businessReferenceIds;
        }

        if (caseWithListOfBrandAndBizRefs.brandAndBizRefsList != null) {
            businessReferenceIds = getAllBzRefsIdsFrombrandAndBizRefsList(
                caseWithListOfBrandAndBizRefs.brandAndBizRefsList
            );
        }
        return businessReferenceIds;
    }

    /**
     * @description To get all Business Reference Ids from List of brandAndBizRefsList.
     * @author rishab.goyal | 03-28-2024
     * @param brandAndBizRefsList
     * @return Set<Id>
     **/
    private static Set<Id> getAllBzRefsIdsFrombrandAndBizRefsList(
        List<BrandWrapper.BrandAndBizRefs> brandAndBizRefsList
    ) {
        Set<Id> businessReferenceIds = new Set<Id>();
        for (BrandWrapper.BrandAndBizRefs brandAndBizRefs : brandAndBizRefsList) {
            if (brandAndBizRefs.bizRefs == null) {
                continue;
            }
            for (Business_Reference__c businessReference : brandAndBizRefs.bizRefs) {
                if (businessReference == null) {
                    continue;
                }
                businessReferenceIds.add(businessReference.Id);
            }
        }

        return businessReferenceIds;
    }

    /**
     * @description to check if all other Business Reference have External_Id__c field populated and update process request flow
     * @author rishab.goyal | 03-18-2024
     **/
    public void updateProcessRequestFlowifAllExternalIdsCreated() {
        try {
            Map<Id, Id> bzRefToSourceIds = new Map<Id, Id>();
            for (
                Business_Reference__c businessReference : (List<Business_Reference__c>) getRecords()
            ) {
                bzRefToSourceIds.put(businessReference.Id, businessReference.Created_Source_Id__c);
            }

            List<Id> processFlowIds = getProcessFlowRequestsIdsForFlowCompleted(bzRefToSourceIds);

            if (!processFlowIds.isEmpty()) {
                updateProcessFlowRequestsIfExternalIdsCreated(
                    processFlowIds,
                    bzRefToSourceIds.values()
                );
            }
        } catch (Exception e) {
            Logger.publish(LogEntry.newExceptionLog(e, LogEntry.SeverityLevel.HIGH));
            String serviceName = 'ProcessFlowRequests Automation - updateProcessFlowRequestsIfExternalIdsCreated';
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        serviceName,
                        LOG_DOMAIN_SALES_TO_CONTRACT,
                        GenericLogEntry.SeverityLevel.MEDIUM
                    )
                    .logException(e)
            );
        }
    }

    /**
     * @description get Process Flow Requests Ids for Flow Completed.
     * @author rishab.goyal | 04-09-2024
     * @param bzRefToSourceIds
     * @return List<Id>
     **/
    @testVisible
    private List<Id> getProcessFlowRequestsIdsForFlowCompleted(Map<Id, Id> bzRefToSourceIds) {
        List<Process_Flow_Request__c> processFlowRequestList = ProcessFlowRequestsSelector.newInstance()
            .selectBrandAndBusinessFlowByContractOrOpportunityIds(bzRefToSourceIds.values());
        List<Id> processFlowIds = new List<Id>();
        for (Process_Flow_Request__c pfr : processFlowRequestList) {
            if (pfr.Stage__c == 'Flow Completed') {
                processFlowIds.add(pfr.id);
            }
        }
        return processFlowIds;
    }

    /**
     * @description update Process Flow Request If External Ids Created for all Business Reference with same source
     * @author rishab.goyal | 04-09-2024
     * @param processFlowIds
     * @param sourceIds
     **/
    @future
    public static void updateProcessFlowRequestsIfExternalIdsCreated(
        List<Id> processFlowIds,
        List<Id> sourceIds
    ) {
        Map<Id, Business_Reference__c> bzRefsWithSameSource = new Map<Id, Business_Reference__c>(
            BusinessReferencesSelector.newInstance().selectBySourceIds(sourceIds)
        );

        List<Process_Flow_Request__c> processFlowRequestsToUpdate = new List<Process_Flow_Request__c>();

        for (
            Process_Flow_Request__c processFlowRequest : ProcessFlowRequestsSelector.newInstance()
                .selectBrandAndBusinessFlowByIds(new Set<Id>(processFlowIds))
        ) {
            Boolean isExternalIdCreated = true;
            if (processFlowRequest.Serialized_Object_Data__c != null) {
                isExternalIdCreated = checkIfAllExternalIdCreated(
                    bzRefsWithSameSource,
                    processFlowRequest.Serialized_Object_Data__c
                );
            }
            if (isExternalIdCreated) {
                processFlowRequest.Stage__c = 'External Ids Created';
                processFlowRequestsToUpdate.add(processFlowRequest);
            }

            fflib_ISObjectUnitOfWork uowInstance = Application.UNITOFWORK.newInstance();
            UpdateUnitOfWorkHelper uowUpdateHelper = new UpdateUnitOfWorkHelper();
            uowInstance.registerWork(uowUpdateHelper);
            uowUpdateHelper.registerUpdate(processFlowRequestsToUpdate);
            uowInstance.commitWork();
        }
    }

    /**
     * @description helper method to check If all External Id Created for BzRef with Same source
     * @author rishab.goyal | 03-28-2024
     * @param bzRefsWithSameSource
     * @param serializedObjectDataForBrandAndBusinesFlow
     * @return Boolean
     **/
    private static Boolean checkIfAllExternalIdCreated(
        Map<Id, Business_Reference__c> bzRefsWithSameSource,
        String serializedObjectDataForBrandAndBusinesFlow
    ) {
        Boolean isExternalIdCreated = true;
        Set<Id> businessReferenceIds = getAllBzRefsFromSerializedData(
            serializedObjectDataForBrandAndBusinesFlow
        );
        for (Id businessReferenceId : businessReferenceIds) {
            if (bzRefsWithSameSource.containsKey(businessReferenceId)) {
                if (bzRefsWithSameSource.get(businessReferenceId).External_Id__c == null) {
                    isExternalIdCreated = false;
                    break;
                }
            }
        }
        return isExternalIdCreated;
    }

    /**
     * @description It updates the Integration Message and Provisioning Error Category fields
     * on the passed Business Reference as per the Business Friendly Message Mapping.
     * @param busRef
     */
    private void updateBusinessFriendlyErrorMessageAndCategory(Business_Reference__c busRef) {
        Business_Friendly_Mapping__mdt businessFriendlyMessageDetails = GetBusinessFriendlyMessageService.getMessageDetails(
            busRef.Provisioning_Error_Message__c,
            INTEGRATION_TYPE
        );
        if (businessFriendlyMessageDetails == null) {
            busRef.Integration_Message__c = busRef.Provisioning_Error_Message__c;
        } else {
            busRef.Integration_Message__c = businessFriendlyMessageDetails.Business_Friendly_Message__c;
            busRef.Provisioning_Error_Category__c = businessFriendlyMessageDetails.Message_Category__c;
        }
    }

     /**
     * @description This method is used to update Integration Message and Integration Status
     * @param externalIdValue
     * @param message
     * @param status
     */
    public static void updateIntegrationMessageLinkingBizIdandBGID(String externalIdValue, String message, String status) {
        List<Business_Reference__c> businessReferences = BusinessReferencesSelector.newInstance().selectByBizId(externalIdValue);
        if (businessReferences.size() >= 0 && (!businessReferences.isEmpty())) {
            fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
            for (Business_Reference__c busRef : businessReferences) {
                busRef.Integration_Message__c = message;
                busRef.Integration_Status__c = status;
                uow.registerDirty(busRef);
            }
            uow.commitWork();
        }
    }

    /**
     * @description It is used to set Brand on Business References.
     * @param businessRefToBrandId
     */
    public static void setBrandOnBusinessReference(Map<Id, Id> businessRefToBrandId) {
        fflib_ISobjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
        for (Id eachBusinessRefId : businessRefToBrandId.keySet()) {
            unitOfWork.registerDirty(
                new Business_Reference__c(
                    Brand__c = businessRefToBrandId.get(eachBusinessRefId),
                    Id = eachBusinessRefId
                )
            );
        }
        try {
            unitOfWork.commitWork();
        } catch (Exception ex) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        BUSINESS_REFERENCE_BRAND_NOT_MAPPED,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.MEDIUM
                    )
                    .logException(ex)
            );
        }
    }
}