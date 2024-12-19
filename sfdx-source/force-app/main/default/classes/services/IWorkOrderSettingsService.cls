/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Interface of service class for disabling or bypassing Work Order related
 * functionalities based on Type and Sub-Type values.
 */
public interface IWorkOrderSettingsService {
    /**
     * @description It checks whether the Decision Maker population is applicable on the
     * passed Work Order.
     * @param workOrder
     * @return Boolean
     */
    Boolean isDecisionMakerApplicableOnWorkOrder(WorkOrder workOrder);

    /**
     * @description It checks whether the passed Work Order Type value
     * is eligible for matching parent Work Order by Type.
     * @param workOrderType
     * @return Boolean
     */
    Boolean isMatchByTypeDisabled(String workOrderType);

    /**
     * @description It checks whether the provisioning status notification is enabled for the
     * passed child Work Order.
     * @param workOrder
     * @return Boolean
     */
    Boolean isProvisioningStatusNotificationEnabledOnChildWorkOrder(WorkOrder workOrder);

    /**
     * @description It checks whether the Provisioning Status notification is enabled for the
     * passed parent Work Order.
     * @param workOrder
     * @return Boolean
     */
    Boolean isProvisioningStatusNotificationEnabledOnParentWorkOrder(WorkOrder workOrder);

    /**
     * @description It checks whether the passed Work Order Type and Sub Type key value
     * is eligible for matching parent Work Order by PDOA.
     * @param workOrderTypeSubTypeKey
     * @return Boolean
     */
    Boolean isPDOAMatchingEnabled(String workOrderTypeSubTypeKey);

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check.
     * @JIRA# LEM-15489
     * @param workOrder
     * @return Boolean
     */
    Boolean isReadinessCheckEligibilityByParentBypassed(WorkOrder workOrder);

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check
     * on creation.
     * @JIRA# LEM-17052
     * @param workOrder
     * @return Boolean
     */
    Boolean isReadinessCheckEligibleOnParentWorkOrderCreation(WorkOrder workOrder);

    /**
     * @description It checks whether passed Work Order is eligible for readiness check
     * when stores are not expected.
     * @param workOrder
     * @return Boolean
     */
    Boolean isReadinessCheckEligibilityByStoreBypassed(WorkOrder workOrder);

    /**
     * @description It checks whether the passed Work Order is eligible for automatic
     * creation of Work Plans.
     * @param workOrder
     * @return Boolean
     */
    Boolean isWorkPlansAutoCreationEnabled(WorkOrder workOrder);

    /**
     * @description It checks whether passed Work Order is eligible for Work Plan creation
     * when stores are not expected.
     * @param workOrder
     * @return Boolean
     */
    Boolean isWorkPlansEligibilityByStoreBypassed(WorkOrder workOrder);
}