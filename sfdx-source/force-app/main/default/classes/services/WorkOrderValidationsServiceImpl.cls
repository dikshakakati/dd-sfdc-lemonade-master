/**
 * @author Deloitte
 * @date 07/12/2022
 * @description Service implementation class for WorkOrder's
 * store readiness validations related logic.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public inherited sharing class WorkOrderValidationsServiceImpl implements IWorkOrderValidationsService, IHandleStoreReadinessValidations {
    private enum MethodTypes {
        ACTIVATECENTRALLY,
        ACTIVATECENTRALLYFORMARKETPLACEANDCOO,
        BUSINESSID,
        CONTRACTFORMARKETPLACE,
        GOOGLESHEETURL,
        MENUTOBECOMPLETEDBY,
        NULLVALUES,
        NUMBEROFSTORES,
        OPPORTUNITYSTAGE,
        ORDERPROTOCOL,
        PDOAONMARKETPLACEANDCOO,
        PROPOSEDDATEOFACTIVATION,
        PROPOSEDDATEOFMENU,
        PROPOSEDDATEOFTABLET,
        PROPOSEDDATEOFTABLETINPAST,
        MPBZIDFORDRIVEWITHHOLDING
    }
    private static final Map<String, MethodTypes> METHODNAMETOMETHODTYPES = new Map<String, MethodTypes>{
        'validateActivateCentrally' => MethodTypes.ACTIVATECENTRALLY,
        'validateActivateCentrallyOnMarketplaceAndCOO' => MethodTypes.ACTIVATECENTRALLYFORMARKETPLACEANDCOO,
        'validateContractOnMarketplace' => MethodTypes.CONTRACTFORMARKETPLACE,
        'validateGoogleSheetURL' => MethodTypes.GOOGLESHEETURL,
        'validateMenuToBeCompletedBy' => MethodTypes.MENUTOBECOMPLETEDBY,
        'validateNullFieldValues' => MethodTypes.NULLVALUES,
        'validateNumberOfStores' => MethodTypes.NUMBEROFSTORES,
        'validateOpportunityStage' => MethodTypes.OPPORTUNITYSTAGE,
        'validateOrderProtocol' => MethodTypes.ORDERPROTOCOL,
        'validatePDOA' => MethodTypes.PROPOSEDDATEOFACTIVATION,
        'validatePDOAOnWeekend' => MethodTypes.PROPOSEDDATEOFACTIVATION,
        'validateProposedDateOfMenu' => MethodTypes.PROPOSEDDATEOFMENU,
        'validateProposedDateOfTablet' => MethodTypes.PROPOSEDDATEOFTABLET,
        'validateProposedDateOfTabletInPast' => MethodTypes.PROPOSEDDATEOFTABLETINPAST,
        'validatePDOAOnMarketplaceAndCOO' => MethodTypes.PDOAONMARKETPLACEANDCOO,
        'validateMPBZIdOnDriveWithholding' => MethodTypes.MPBZIDFORDRIVEWITHHOLDING,
        'validateBusinessId' => MethodTypes.BUSINESSID
    };
    private static final String ACTIVATE_CENTRALLY_NO = 'No';
    private static final String AUTO_ACTIVATIONS_SUB_TYPE = 'Auto-Activations';
    private static final String OPPORTUNITY_STAGE_CLOSED_WON = 'Closed Won';
    private static final String PDOA_DAYS_IN_FUTURE_LIMIT_STATIC_CONFIG = 'PDOA_DAYS_IN_FUTURE_LIMIT';
    private static final String WORKORDER_ACTIVATED_CENTRALLY_NO = 'No';
    private static final String WORKORDER_DELAY_TABLET_SHIPMENT_YES = 'Yes';
    private static final String WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER = 'Account Owner';
    private static final String WORKORDER_SUB_TYPE_WITHHOLDING = 'Withholding';
    private static final String WORKORDER_TYPE_COO = 'COO';
    private static final String WORKORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String LOG_SERVICE_WORK_ORDER = 'Work Order Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String PROVISIONING_PROCESS_AUTOMATIC = 'Automatic';
    private static final String SEGMENT_SMB = 'SMB';
    private List<WorkOrder> childWorkOrders;
    private Map<Id, WorkOrder> parentWorkOrders;
    private List<Readiness_Check_Failure__c> readinessValidationFailures;
    private Map<String, Map<String, Set<String>>> readinessValidationToTypeToSubTypes;
    private List<Readiness_Check_Failure__c> existingReadinessValidationFailuresRecords; //* @jira LEM-13963
    private String readinessObjectName; //* @jira LEM-13963
    private static final String CLASS_NAME = 'WorkOrderValidationsServiceImpl'; //* @jira LEM-13963

    /**
     * @description Default Constructor to initialize class variables
     */
    public WorkOrderValidationsServiceImpl() {
        this.childWorkOrders = new List<WorkOrder>();
        this.parentWorkOrders = new Map<Id, WorkOrder>();
        this.readinessValidationFailures = new List<Readiness_Check_Failure__c>();
        this.readinessValidationToTypeToSubTypes = new Map<String, Map<String, Set<String>>>();
        this.existingReadinessValidationFailuresRecords = new List<Readiness_Check_Failure__c>(); //* @jira LEM-13963
    }

    /**
     * @description It performs readiness validations on the passed WorkOrders
     * according to the rules configured in the custom metadata.
     * @JIRA# LEM-1684 @jira LEM-13963
     * @param childWorkOrders
     * @param parentWorkOrders
     * @param storeReadinessValidations - custom metadata records
     * @param existingReadinessCheckFailures
     * @param objectName
     */
    public void validate(
        List<WorkOrder> childWorkOrders,
        List<WorkOrder> parentWorkOrders,
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations,
        List<Readiness_Check_Failure__c> existingReadinessCheckFailures,
        String objectName
    ) {
        this.childWorkOrders.addAll(childWorkOrders);
        this.parentWorkOrders = new Map<Id, WorkOrder>(parentWorkOrders);
        this.readinessValidationToTypeToSubTypes = ReadinessValidationRulesService.collectReadinessValidationRuleMappings(
            storeReadinessValidations
        );
        this.existingReadinessValidationFailuresRecords.addAll(existingReadinessCheckFailures); //* @jira LEM-13963
        this.readinessObjectName = objectName; //* @jira LEM-13963
        runValidations(storeReadinessValidations);
        publishReadinessCheckFailures();
    }

    /**
     * @description It checks whether the passed field value is null on the passed sObjectInstance.
     * @JIRA# LEM-2644
     * @param sObjectInstance
     * @param fieldName
     * @return Boolean
     */
    private Boolean isFieldValueNull(SObject sObjectInstance, String fieldName) {
        return sObjectInstance.get(fieldName) == null;
    }

    /**
     * @description It validates that a valid Google Sheet URL is populated by checking
     * if the URL contains 'https://docs.google.com/spreadsheets/'.
     * @JIRA# LEM-11502
     * @param googleSheetURL
     * @return Boolean
     */
    private Boolean isGoogleSheetURLInvalid(String googleSheetURL) {
        return !googleSheetURL.contains(System.Label.Google_Sheet_URL);
    }

    /**
     * @description It validates that the passed Work Order ineligible to validate Google Sheet URL
     * by checking the following conditions:
     * 1. Work Order Sub-Type is Auto-Activations OR
     * 2. Work Order is Withholding with Auto-Activations OR
     * 3. Work Order is created by Process Automation User
     * @JIRA# LEM-11502
     * @param workOrder
     * @return Boolean
     */
    private Boolean isWorkOrderIneligibleToValidateGoogleSheetURL(WorkOrder workOrder) {
        return ((workOrder.Sub_Type__c == AUTO_ACTIVATIONS_SUB_TYPE ||
        (workOrder.Sub_Type__c == WORKORDER_SUB_TYPE_WITHHOLDING &&
        workOrder.Withholding_with_Auto_Activations__c)) ||
        workOrder.CreatedBy.Name.startsWithIgnoreCase(
            System.Label.Automated_Process_User_Full_Name
        ));
    }

    /**
     * @description It run store readiness validations on parent Work Orders.
     * @JIRA# LEM-1684
     * @param storeReadinessValidations - custom metadata records
     */
    private void runValidations(
        List<Store_Readiness_Validation_Rule__mdt> storeReadinessValidations
    ) {
        for (
            Store_Readiness_Validation_Rule__mdt eachStoreReadinessValidationRule : storeReadinessValidations
        ) {
            switch on
                METHODNAMETOMETHODTYPES.get(
                    eachStoreReadinessValidationRule.Service_Method_Name__c
                ) {
                when ACTIVATECENTRALLYFORMARKETPLACEANDCOO {
                    validateActivateCentrallyOnMarketplaceAndCOO(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when ACTIVATECENTRALLY {
                    validateActivateCentrally(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when CONTRACTFORMARKETPLACE {
                    validateContractOnMarketplace(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values(),
                        childWorkOrders
                    );
                }
                when GOOGLESHEETURL {
                    validateGoogleSheetURL(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when MENUTOBECOMPLETEDBY {
                    validateMenuToBeCompletedBy(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when NULLVALUES {
                    validateNullFieldValues(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when OPPORTUNITYSTAGE {
                    validateOpportunityStage(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when ORDERPROTOCOL {
                    validateOrderProtocol(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when PDOAONMARKETPLACEANDCOO {
                    validatePDOAOnMarketplaceAndCOO(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when PROPOSEDDATEOFACTIVATION {
                    validateProposedDateOfActivation(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when PROPOSEDDATEOFMENU {
                    validateProposedDateOfMenu(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when PROPOSEDDATEOFTABLET {
                    validateProposedDateOfTablet(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when PROPOSEDDATEOFTABLETINPAST {
                    validateProposedDateOfTabletInPast(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when MPBZIDFORDRIVEWITHHOLDING {
                    validateMPBZIdOnDriveWithholding(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values()
                    );
                }
                when BUSINESSID {
                    validateBusinessId(eachStoreReadinessValidationRule, parentWorkOrders.values());
                }
                when NUMBEROFSTORES {
                    validateNumberOfStores(
                        eachStoreReadinessValidationRule,
                        parentWorkOrders.values(),
                        childWorkOrders
                    );
                }
            }
        }
    }

    /**
     * @description It creates 'Readiness Check Failures' records based on the passed Work Order
     * and Store Readiness Validation Rule.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrder
     */
    private void logReadinessCheckFailure(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        WorkOrder workOrder
    ) {
        readinessValidationFailures.add(
            new Readiness_Check_Failure__c(
                Account_Name__c = workOrder.AccountId,
                Child_Work_Order__c = workOrder.Id,
                Error_Message__c = storeReadinessValidationRule.Error_Message__c,
                Field_Name__c = storeReadinessValidationRule.Field_Label__c,
                Object_Name__c = storeReadinessValidationRule.Object_Label__c,
                Parent_Work_Order__c = workOrder.ParentWorkOrderId == null
                    ? workOrder.Id
                    : workOrder.ParentWorkOrderId
            )
        );
    }

    /**
     * @description It commits 'Readiness Check Failures' records in the database.
     * @JIRA# LEM-1684 // @jira LEM-13963
     */
    private void publishReadinessCheckFailures() {
        StoreReadinessModificationService.processReadinessCheckFailures(
            existingReadinessValidationFailuresRecords,
            readinessValidationFailures,
            readinessObjectName,
            CLASS_NAME
        );
    }

    /**
     * @description It validates that 'Activate Centrally' should be 'No'
     * when 'Menu to be completed by' is 'Account Owner'.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateActivateCentrally(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                eachWorkOrder.Menu_to_be_Completed_By__c ==
                WORKORDER_MENU_TO_BE_COMPLETED_BY_ACCOUNT_OWNER &&
                eachWorkOrder.Activated_Centrally_AC__c != WORKORDER_ACTIVATED_CENTRALLY_NO
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Actual Number Of Stores' should not be
     * greater than 'Number of Stores on Quote'.
     * @JIRA# LEM-18591
     * @param storeReadinessValidationRule
     * @param parentWorkOrders
     * @param childWorkOrders
     */
    private void validateNumberOfStores(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> parentWorkOrders,
        List<WorkOrder> childWorkOrders
    ) {
        Set<Id> storeAccountIds = new Set<Id>();
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            if (eachWorkOrder.AccountId != null) {
                storeAccountIds.add(eachWorkOrder.AccountId);
            }
        }
        for (WorkOrder eachWorkOrder : parentWorkOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                !storeAccountIds.isEmpty() &&
                (storeAccountIds.size() > eachWorkOrder.Number_of_Stores_on_Quote__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Activate Centrally' is required
     * when WorkOrder Type is 'Marketplace' or 'COO'.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateActivateCentrallyOnMarketplaceAndCOO(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that Contract is populated
     * when Workorder type is 'Marketplace'.
     * @JIRA# LEM-7999
     * @param storeReadinessValidationRule
     * @param workOrders
     * @param childWorkOrders
     */
    private void validateContractOnMarketplace(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders,
        List<WorkOrder> childWorkOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                eachWorkOrder.Type__c == WORKORDER_TYPE_MARKETPLACE &&
                isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
        for (WorkOrder eachWorkOrder : childWorkOrders) {
            if (ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                eachWorkOrder.Type__c == WORKORDER_TYPE_MARKETPLACE &&
                isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that a valid Google Sheet URL is populated
     * on the passed Work Orders.
     * @JIRA# LEM-11502
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateGoogleSheetURL(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                !isWorkOrderIneligibleToValidateGoogleSheetURL(eachWorkOrder) &&
                (isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c) ||
                isGoogleSheetURLInvalid(
                    eachWorkOrder.get(storeReadinessValidationRule.Field_Name__c).toString()
                ))
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Menu to be completed by' is required
     * when WorkOrder Type is 'Marketplace'.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateMenuToBeCompletedBy(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation to check whether the field configured
     * in the passed custom metadata is null on the passed Work Orders.
     * @JIRA# LEM-2858
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateNullFieldValues(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that Opportunity Stage is 'Closed/Won'
     * when Work Order type is 'Marketplace'/'Storefront'/'Drive'/'COO' or
     * 'Post-Sales' with sub-type as 'Rate Change'.
     * @JIRA# LEM-10031
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateOpportunityStage(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                String.isNotBlank(eachWorkOrder.Opportunity__c) &&
                eachWorkOrder.Opportunity__r.StageName != OPPORTUNITY_STAGE_CLOSED_WON
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that Order protocol is populated
     * when Work Order type is 'Marketplace' or 'COO'.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateOrderProtocol(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Proposed Date of Activation' is required
     * when WorkOrder Type is 'Marketplace' or 'COO'.
     * @JIRA# LEM-2644
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validatePDOAOnMarketplaceAndCOO(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) && isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Proposed Date of Activation' does not occur in the past and
     * not less than configured days in the future.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateProposedDateOfActivation(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                !ReadinessValidationRulesService.isBypassedBySegmentType(
                    storeReadinessValidationRule.DeveloperName,
                    eachWorkOrder
                )
            ){
            storeReadinessValidationRuleToValidate = ReadinessValidationRulesService.getProposedDateOfActivationFailedReadinessCheck(
                readinessValidationToTypeToSubTypes,
                storeReadinessValidationRule,
                eachWorkOrder
            );
            if (storeReadinessValidationRuleToValidate != null) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }
    }

    /**
     * @description It validates that 'Proposed Date of Menu' does not occur in the past.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateProposedDateOfMenu(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (eachWorkOrder.Proposed_Date_of_Menu__c < System.today()) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Proposed Date of Tablet' is populated
     * when HasTabletWorkPlan__c is enabled.
     * @JIRA# LEM-1684
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateProposedDateOfTablet(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                eachWorkOrder.Has_Any_Store_Tablet_Shipment_Delayed__c &&
                isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It validates that 'Proposed Date of Tablet' does not occur in the past.
     * @JIRA# LEM-2625
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateProposedDateOfTabletInPast(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                eachWorkOrder.Proposed_Date_of_Tablet__c != null &&
                eachWorkOrder.Proposed_Date_of_Tablet__c < System.today()
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to perform validation on MP_Bz_Id__c check whether the field configured
     * in the passed custom metadata is null on Contract or Opportunity associated to the passed Work Orders.
     * @JIRA# LEM-16290
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateMPBZIdOnDriveWithholding(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRuleToValidate;
        for (WorkOrder eachWorkOrder : workOrders) {
            storeReadinessValidationRuleToValidate = ReadinessValidationRulesService.getMpBzIdNullReadinessCheck(
                readinessValidationToTypeToSubTypes,
                storeReadinessValidationRule,
                eachWorkOrder
            );

            if (storeReadinessValidationRuleToValidate != null) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }
    /**
     * @description It validates that 'Business Id' must match with External Id populated
     * on business reference when WorkOrder Type is 'Marketplace' or 'COO'.
     * @JIRA# LEM-15213
     * @param storeReadinessValidationRule
     * @param workOrders
     */
    private void validateBusinessId(
        Store_Readiness_Validation_Rule__mdt storeReadinessValidationRule,
        List<WorkOrder> workOrders
    ) {
        Set<String> businessIdsToQuery = new Set<String>();
        List<WorkOrder> workOrdersToValidate = new List<WorkOrder>();
        Set<String> businessReferenceExternalIdsToValidate = new Set<String>();
        for (WorkOrder eachWorkOrder : workOrders) {
            if (
                ReadinessValidationRulesService.hasTypeSubTypeMatchingWithWorkOrder(
                    readinessValidationToTypeToSubTypes,
                    storeReadinessValidationRule,
                    eachWorkOrder
                ) &&
                !isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c) &&
                isWorkOrderSegmentSMB(eachWorkOrder.Segment__c) &&
                eachWorkOrder.Business_to_Store_Assignment__c == PROVISIONING_PROCESS_AUTOMATIC
            ) {
                businessIdsToQuery.add(eachWorkOrder.Business_Id__c);
                workOrdersToValidate.add(eachWorkOrder);
            }
        }
        for (
            Business_Reference__c eachBusinessReference : BusinessReferencesSelector.newInstance()
                .selectMDSBusinessReferencesWithSuccessIntegrationStatusByBusinessIds(
                    businessIdsToQuery
                )
        ) {
            businessReferenceExternalIdsToValidate.add(eachBusinessReference.External_Id__c);
        }

        for (WorkOrder eachWorkOrder : workOrdersToValidate) {
            if (
                !isFieldValueNull(eachWorkOrder, storeReadinessValidationRule.Field_Name__c) &&
                !businessReferenceExternalIdsToValidate.contains(eachWorkOrder.Business_Id__c)
            ) {
                logReadinessCheckFailure(storeReadinessValidationRule, eachWorkOrder);
            }
        }
    }

    /**
     * @description It is used to validate whether the passed Segment value is 'SMB'.
     * @JIRA# LEM-15213
     * @param segmentValue
     * @return Boolean
     */
    private Boolean isWorkOrderSegmentSMB(String segmentValue) {
        return segmentValue == SEGMENT_SMB;
    }
}