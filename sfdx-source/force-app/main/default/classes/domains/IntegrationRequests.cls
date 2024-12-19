/**
 * @author DoorDash
 * @date 03/08/2023
 * @description Domain Class for IntegrationRequests Object
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public inherited sharing class IntegrationRequests extends fflib_SObjects implements IIntegrationRequests {
    private static final String ACCOUNT_RECORD_TYPE_BUSINESS = 'Business';
    private static final String SFDC_ORG_FIGMENT = 'Figment';
    private static final String SFDC_ORG_LEMONADE = 'Lemonade';
    private static final String INTEGRATION_TYPE_POS = 'POS Requests';
    private static final String INTEGRATION_TYPE_COO_SAME_STORE = 'COO Same Store';
    private static final String INTEGRATION_TYPE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String INTEGRATION_TYPE_TABLET_CASE_SYNC = 'Tablet Case Sync';
    private static final String SFDC_STATUS_FAILED = 'Failed';
    private static final String MESSAGE_STORE_NOT_FOUND = 'Store not found';
    fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
    private static final String PRODUCT_STATUS_APPROVED = 'approved';
    private static final String PRODUCT_STATUS_READY = 'ready';
    private static final String ACTION_CREATE = 'CREATE';
    private static final String PRODUCT_STATUS_CREATED = 'created';
    private static final String SFDC_STATUS_PROCESSED = 'Processed';
    private static final Set<String> PRODUCT_STATUS_TO_MARKED_PROCESSED = new Set<String>{
        PRODUCT_STATUS_APPROVED
    };
    private static final String STATUS_FAILED = 'Failed';
    private static final String INTEGRATION_REQUEST_CLASS = 'IntegrationRequests';
    private static final String METHOD_NAME = 'validateAndPrePopulateFields';

    private enum IntegrationTypes {
        COO_SAME_STORE,
        PLACE_IT_FOR_ME,
        POS
    }
    private static final Map<String, IntegrationTypes> INTEGRATION_TYPES = new Map<String, IntegrationTypes>{
        INTEGRATION_TYPE_COO_SAME_STORE => IntegrationTypes.COO_SAME_STORE,
        INTEGRATION_TYPE_PLACE_IT_FOR_ME => IntegrationTypes.PLACE_IT_FOR_ME,
        INTEGRATION_TYPE_POS => IntegrationTypes.POS
    };

    /**
     * @description This method is used to return the IIntegrationRequests interface
     * @param recordList - IntegrationRequests record list
     * @return IIntegrationRequests - Returns IIntegrationRequests Interface
     */
    public static IIntegrationRequests newInstance(List<Integration_request__c> recordList) {
        return (IIntegrationRequests) Application.Domain.newInstance(recordList);
    }
    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }
    /**
     * @description Default constructor for the class
     * @param sObjectList
     */
    public IntegrationRequests(List<Integration_request__c> sObjectList) {
        super(sObjectList, Schema.Integration_request__c.SObjectType);
    }
    /**
     * @description Validates the existing store and transfers the Integration_Request__c records to Figment.
     * Pre-populates the required fields in the Integration_Request__c records.
     */
    public void validateAndPrePopulateFields() {
        validateExistingStoreAndTransferToFigment();
        prePopulateIntReqFields();
    }
    /**
     * @description Pre-populates the Integration_Request__c fields based on specific conditions.
     * Sets the Sfdc_Status__c field to "Processed" when the Integration_Type__c is "COO Same Store"
     * and the Product_Status__c is in the list of statuses to mark as processed.
     */
    public void prePopulateIntReqFields() {
        for (Integration_request__c eachIr : (List<Integration_request__c>) getRecords()) {
            if (
                INTEGRATION_TYPE_COO_SAME_STORE.equals(eachIr.Integration_Type__c) &&
                PRODUCT_STATUS_TO_MARKED_PROCESSED.contains(eachIr.Product_Status__c)
            ) {
                eachIr.Sfdc_Status__c = SFDC_STATUS_PROCESSED;
            }
            if (
                eachIr.Parent_Integration_Request__c == null &&
                eachIr.Integration_Type__c != INTEGRATION_TYPE_TABLET_CASE_SYNC
            ) {
                eachIr.Stage__c = eachIr.Product_Status__c;
                eachIr.Stage_Status__c = eachIr.Sfdc_Status__c;
            }
        }
    }
    /**
     * @description Validates the existing store and transfers the Integration_Request__c records to Figment.
     * Updates the Account__c field with the corresponding Salesforce Account Name based on the store Id.
     * Sets the SFDC_Org__c field to Figment for Integration_Type__c equals "POS".
     * Sets the Sfdc_Status__c and Error_Message__c fields when the store is not found or the onboarding Id is not empty.
     */
    @SuppressWarnings('PMD.CyclomaticComplexity')
    public void validateExistingStoreAndTransferToFigment() {
        Set<String> assignToFigmentTypes = new Set<String>{
            INTEGRATION_TYPE_COO_SAME_STORE,
            INTEGRATION_TYPE_POS
        };
        Set<String> businessAndStoreIds = new Set<String>();
        Map<String, Xref__c> xrefByExternalIds = new Map<String, Xref__c>();
        Set<String> onboardingIds = new Set<String>();
        Map<String, Integration_request__c> onboardingIdtoIr = new Map<String, Integration_request__c>();
        for (Integration_request__c eachIr : (List<Integration_request__c>) getRecords()) {
            businessAndStoreIds.add(eachIr.Store_Id__c);
            if (String.isNotBlank(eachIr.onBoarding_Id__c)) {
                onboardingIds.add(eachIr.onBoarding_Id__c);
            }
            if (eachIr.Integration_Type__c == INTEGRATION_TYPE_PLACE_IT_FOR_ME) {
                businessAndStoreIds.add(eachIr.Business_Id__c);
                businessAndStoreIds.remove(eachIr.Store_Id__c);
                onboardingIds.remove(eachIr.onBoarding_Id__c);
            }
        }
        if (!onboardingIds.isEmpty()) {
            onboardingIdtoIr = getIntReqsByOnboardingId(onboardingIds);
        }
        xrefByExternalIds = getXrefByBusinessAndStoreIds(businessAndStoreIds);
        List<Integration_request__c> processPosIntReq = new List<Integration_request__c>();
        for (Integration_request__c eachIr : (List<Integration_request__c>) getRecords()) {
            if (
                String.isNotEmpty(eachIr.Onboarding_Id__c) &&
                onboardingIdtoIr.containsKey(eachIr.Onboarding_Id__c)
            ) {
                eachIr.Parent_Integration_Request__c = onboardingIdtoIr.get(eachIr.Onboarding_Id__c)
                    .Id;
            }
            if (xrefByExternalIds.containsKey(eachIr.Store_Id__c)) {
                eachIr.Account__c = xrefByExternalIds.get(eachIr.Store_Id__c)
                    .Salesforce_Account_Name__c;
            } else if (assignToFigmentTypes.contains(eachIr.Integration_Type__c)) {
                eachIr.SFDC_Org__c = SFDC_ORG_FIGMENT;
                continue;
            }
            switch on INTEGRATION_TYPES.get(eachIr.Integration_Type__c) {
                when PLACE_IT_FOR_ME {
                    if (xrefByExternalIds.containsKey(eachIr.Business_Id__c)) {
                        eachIr.Account__c = xrefByExternalIds.get(eachIr.Business_Id__c)
                            .Salesforce_Account_Name__c;
                    }
                }
                when COO_SAME_STORE {
                    processCooIntRequests(eachIr);
                }
                when POS {
                    processPosIntReq.add(eachIr);
                }
            }
        }
        processPosIntRequests(processPosIntReq);
    }

    /**
     * @description prepopulate intgratoin requests.
     * @param intReq Integration_request__c to prepolate default on before trigger context
     */
    private void processCooIntRequests(Integration_request__c intReq) {
        if (String.isBlank(intReq.Batch_Id__c)) {
            intReq.Batch_Id__c = intReq.Onboarding_Id__c;
        }
    }
    /**
     * @description validate and prepopulate pos integration requests fields.
     * @param posIntReq List<Integration_request__c>
     **/
    private void processPosIntRequests(List<Integration_request__c> posIntReq) {
        if (posIntReq.isEmpty()) {
            return;
        }
        Set<String> providerTypes = getPosProviderTypes();
        for (Integration_request__c eachInt : posIntReq) {
            if (
                !providerTypes.contains(eachInt.Integration_Provider__c) &&
                !(SFDC_ORG_FIGMENT.equals(eachInt.Sfdc_org__c))
            ) {
                eachInt.sfdc_status__c = STATUS_FAILED;
                eachInt.Error_Message__c = 'Provider type not exists in salesforce';
            }
        }
    }
    /**
     * @description query the integration request records to get the intreq By ParentOnBoardingId.
     * @param onboardingIds onboardingIds related to the int req
     * @return  Map<String, Integration_request__c>
     */
    private Map<String, Integration_request__c> getIntReqsByOnboardingId(
        Set<String> onboardingIds
    ) {
        Map<String, Integration_request__c> onboardingIdtoIr = new Map<String, Integration_request__c>();
        for (
            Integration_request__c eachIr : IntegrationRequestsSelector.newInstance()
                .selectParentByOnboardingId(onboardingIds)
        ) {
            if (eligilbleParent(eachIr)) {
                onboardingIdtoIr.put(eachIr.Onboarding_Id__c, eachIr);
            }
        }
        return onboardingIdtoIr;
    }
    /**
     * @description query the xref records to get the account Ids by store Ids and business Ids.
     * @param businessAndStoreIds Store Ids and Business Ids related to the int req
     * @return  Map<String, Xref__c>
     */
    private Map<String, Xref__c> getXrefByBusinessAndStoreIds(Set<String> businessAndStoreIds) {
        Map<String, Xref__c> xrefByExternalIds = new Map<String, Xref__c>();
        for (
            Xref__c eachXref : XrefsSelector.newInstance()
                .selectXrefsByBusinessReferenceExternalIdOrStoreIds(businessAndStoreIds)
        ) {
            xrefByExternalIds.put(eachXref.External_ID__c, eachXref);
            if (eachXref.Business_Reference__r.External_Id__c != null) {
                xrefByExternalIds.put(eachXref.Business_Reference__r.External_Id__c, eachXref);
            }
        }
        return xrefByExternalIds;
    }
    /**
     * @description before assigned int request as parent to another int request check if it is eligible parent.
     * @param intRequest integration request
     * @return Boolean
     */
    private Boolean eligilbleParent(Integration_Request__c intRequest) {
        return (INTEGRATION_TYPE_POS.equals(intRequest.Integration_Type__c) &&
            ACTION_CREATE.equals(intRequest.Action__c)) ||
            INTEGRATION_TYPE_COO_SAME_STORE.equals(intRequest.Integration_Type__c)
            ? true
            : false;
    }
    /**
     * @description Filters the Integration Requests by the specified Product Status.
     * @param productStatus The Product Status to filter by.
     * @return An instance of IIntegrationRequests containing the filtered Integration Requests.
     */
    public virtual IIntegrationRequests filterByProductStatus(String productStatus) {
        return (IIntegrationRequests) new IntegrationRequests(
            getRecordsByFieldValue(Integration_Request__c.Product_Status__c, productStatus)
        );
    }
    /**
     * @description Filters the Integration Requests by the specified Salesforce (SFDC) Status.
     * @param status The SFDC Status to filter by.
     * @return An instance of IIntegrationRequests containing the filtered Integration Requests.
     */
    public virtual IIntegrationRequests filterBySfdcStatus(String status) {
        return (IIntegrationRequests) new IntegrationRequests(
            getRecordsByFieldValue(Integration_Request__c.Sfdc_status__c, status)
        );
    }
    /**
     * @description Retrieves the set of store Ids from the Integration_Request__c records.
     * @return The set of store Ids.
     */
    public virtual Set<String> getStoreIds() {
        return convertObjectToString(getFieldValues(Integration_Request__c.Store_Id__c));
    }
    /**
     * @description Retrieves the set of business Ids from the Integration_Request__c records.
     * @return The set of business Ids.
     */
    public virtual Set<String> getBusinessIds() {
        return convertObjectToString(getFieldValues(Integration_Request__c.business_Id__c));
    }
    /**
     * @description Converts a set of Objects to a set of Strings.
     * @param storeIds The set of Objects to be converted.
     * @return The set of Strings after conversion.
     */
    private Set<String> convertObjectToString(Set<Object> storeIds) {
        Set<String> stringStoreIds = new Set<String>();
        for (Object storeId : storeIds) {
            stringStoreIds.add((String) storeId);
        }
        return stringStoreIds;
    }
    /**
     * @description Filters the batch IDs of Integration_Request__c records that are not in the specified product status.
     * @param productStatus  A Set of product status values to filter.
     * @return Set<String> A Set of batch IDs of Integration_Request__c records not in the specified product status.
     */
    public virtual Set<String> filterBatchIdsIrNotInProductStatus(Set<String> productStatus) {
        Set<String> batchIds = new Set<String>();
        Set<String> onBoardingIds = new Set<String>();
        for (Integration_Request__c eachIr : (List<Integration_request__c>) getRecords()) {
            if (productStatus.contains(eachIr.Product_Status__c)) {
                onBoardingIds.add(eachIr.Onboarding_Id__c);
            }
        }
        for (Integration_Request__c eachIr : (List<Integration_request__c>) getRecords()) {
            if (!onBoardingIds.contains(eachIr.Onboarding_Id__c)) {
                batchIds.add(eachIr.batch_Id__c);
            }
        }
        return batchIds;
    }
    /**
     * @description This method is used for getting pos integration provider types from account field.
     * @return Set<String> provider types
     */
    public static Set<String> getPosProviderTypes() {
        Schema.DescribeFieldResult fieldResult = Schema.SObjectType.Account.fields.getMap()
            .get('POS_Integration_Type__c')
            .getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        Set<String> providerTypes = new Set<String>();
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            providerTypes.add(picklistEntry.getValue());
        }
        return providerTypes;
    }

    /**
     * @description Create a Log__c record
     * @param integrationRequestList List of Integration_request__c records
     */
    public static void createLog(List<Integration_request__c> integrationRequestList) {
        if (integrationRequestList == null || integrationRequestList.isEmpty()) {
            return;
        }

        List<String> integrationRequestInfo = new List<String>();
        for (Integration_Request__c integrationRequest : integrationRequestList) {
            integrationRequestInfo.add(
                'Id: ' +
                integrationRequest.Id +
                ', onBoarding_Id__c: ' +
                integrationRequest.onBoarding_Id__c +
                ', Stage: ' +
                integrationRequest.Stage__c +
                ', CreatedDate' +
                integrationRequest.CreatedDate +
                ', Sfdc_Status__c' +
                integrationRequest.Sfdc_Status__c +
                ', Parent_Integration_Request__c' +
                integrationRequest.Parent_Integration_Request__c
            );
        }
        if (integrationRequestInfo != null && !integrationRequestInfo.isEmpty()) {
            String integrationRequestString = String.join(integrationRequestInfo, '; ');
            String message = 'Integration Requests Before Creation: ' + integrationRequestString;
            Logger.publish(LogEntry.newLog(INTEGRATION_REQUEST_CLASS, METHOD_NAME, message));
        }
    }

    /*
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;
    /**
     * @description This class is used for implementing fflib_IDomainConstructor Interface
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description Constructor method implementation from fflib_IDomainConstructor class
         * @param objectList
         * @return IntegrationRequests - List of IntegrationRequests
         */
        public fflib_SObjects construct(List<Object> objectList) {
            if (IntegrationRequests.constructorMock != null) {
                return (fflib_SObjects) IntegrationRequests.constructorMock.construct(objectList);
            }
            return new IntegrationRequests((List<SObject>) objectList);
        }
    }
}