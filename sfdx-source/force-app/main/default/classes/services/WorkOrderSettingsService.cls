/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Service class for disabling or bypassing Work Order related
 * functionalities based on Type and Sub-Type values.
 */
public inherited sharing class WorkOrderSettingsService {
    /**
     * @description It checks whether the Decision Maker population is applicable on the
     * passed Work Order.
     * @JIRA# LEM-4195
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isDecisionMakerApplicableOnWorkOrder(WorkOrder workOrder) {
        return service().isDecisionMakerApplicableOnWorkOrder(workOrder);
    }

    /**
     * @description It checks whether the passed Work Order Type value
     * is eligible for matching parent Work Order by Type.
     * @JIRA# LEM-4281
     * @param workOrderType
     * @return Boolean
     */
    public static Boolean isMatchByTypeDisabled(String workOrderType) {
        return service().isMatchByTypeDisabled(workOrderType);
    }

    /**
     * @description It checks whether the provisioning status notification is enabled for the
     * passed child Work Order.
     * @JIRA# LEM-3920
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isProvisioningStatusNotificationEnabledOnChildWorkOrder(
        WorkOrder workOrder
    ) {
        return service().isProvisioningStatusNotificationEnabledOnChildWorkOrder(workOrder);
    }

    /**
     * @description It checks whether the provisioning status notification is enabled for the
     * passed parent Work Order.
     * @JIRA# LEM-3094
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isProvisioningStatusNotificationEnabledOnParentWorkOrder(
        WorkOrder workOrder
    ) {
        return service().isProvisioningStatusNotificationEnabledOnParentWorkOrder(workOrder);
    }

    /**
     * @description It checks whether the passed Work Order Type and Sub Type key value
     * is eligible for matching parent Work Order by PDOA.
     * @JIRA# LEM-3384
     * @param workOrderTypeSubTypeKey
     * @return Boolean
     */
    public static Boolean isPDOAMatchingEnabled(String workOrderTypeSubTypeKey) {
        return service().isPDOAMatchingEnabled(workOrderTypeSubTypeKey);
    }

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check.
     * @JIRA# LEM-15489
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isReadinessCheckEligibilityByParentBypassed(WorkOrder workOrder) {
        return service().isReadinessCheckEligibilityByParentBypassed(workOrder);
    }

    /**
     * @description It checks whether passed Work Order is eligible for readiness check
     * when stores are not expected.
     * @JIRA# LEM-3094
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isReadinessCheckEligibilityByStoreBypassed(WorkOrder workOrder) {
        return service().isReadinessCheckEligibilityByStoreBypassed(workOrder);
    }

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check
     * on creation.
     * @JIRA# LEM-17052
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isReadinessCheckEligibleOnParentWorkOrderCreation(WorkOrder workOrder) {
        return service().isReadinessCheckEligibleOnParentWorkOrderCreation(workOrder);
    }

    /**
     * @description It checks whether the passed Work Order is eligible for automatic
     * creation of Work Plans.
     * @JIRA# LEM-3474
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isWorkPlansAutoCreationEnabled(WorkOrder workOrder) {
        return service().isWorkPlansAutoCreationEnabled(workOrder);
    }

    /**
     * @description It checks whether passed Work Order is eligible for Work Plan creation
     * when stores are not expected.
     * @JIRA# LEM-3094
     * @param workOrder
     * @return Boolean
     */
    public static Boolean isWorkPlansEligibilityByStoreBypassed(WorkOrder workOrder) {
        return service().isWorkPlansEligibilityByStoreBypassed(workOrder);
    }

    /**
     * @description It creates instance of WorkOrderSettingsServiceImpl class.
     * @return IWorkOrderSettingsService
     */
    private static IWorkOrderSettingsService service() {
        return (IWorkOrderSettingsService) Application.SERVICE.newInstance(
            IWorkOrderSettingsService.class
        );
    }
}