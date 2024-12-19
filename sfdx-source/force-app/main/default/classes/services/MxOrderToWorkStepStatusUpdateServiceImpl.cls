/**
 * @author Deloitte
 * @date 05/06/2024
 * @description Service Implementation class for Status Update for Mx Order and WorkStep.
 */
public inherited sharing class MxOrderToWorkStepStatusUpdateServiceImpl implements IMxOrderToWorkStepStatusUpdateService {
    private static final String ESCALTED = 'Escalated';
    private static final String MAPPING_TYPE_TABLET = 'Tablet';
    private static final String MAPPING_TYPE_RETURN = 'Return';
    private static final String MAPPING_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String MAPPING_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String PROCESS_TYPE_WORKSTEP_STATUS_UPDATE = 'Mx Order Status to WorkStep Status';
    private static final String STATUS_REASON_OTHER = 'Other';
    private static final String SHIPPED = 'Shipped';
    private static final String WORK_STEP_TYPE_DELIVER_TABLET = 'Deliver Tablet';
    private static final String WORK_STEP_TYPE_DELIVER_RETURN_LABEL = 'Deliver Return Label';
    private static final String WORK_STEP_TYPE_DELIVER_PHOTOSHOOT = 'Vendor Photoshoot';
    private static final String ORDER_STATUS_RETURN_TO_SENDER = 'Return to Sender';
    private static final String WORKSTEP_STATUS_REASON_RETURNED_TO_SENDER = 'Returned to Sender';
    //Deliver Marketing Kit
    private static final String WORK_STEP_TYPE_DELIVER_MARKETING_KIT = 'Deliver Marketing Kit';
    private enum WORK_STEP_TYPE {
        WORK_STEP_TYPE_DELIVER_TABLET,
        WORK_STEP_TYPE_DELIVER_RETURN_LABEL,
        WORK_STEP_TYPE_DELIVER_PHOTOSHOOT,
        WORK_STEP_TYPE_DELIVER_MARKETING_KIT
    }
    private static Map<String, WORK_STEP_TYPE> workStepTypeMap = new Map<String, WORK_STEP_TYPE>{
        WORK_STEP_TYPE_DELIVER_TABLET => WORK_STEP_TYPE.WORK_STEP_TYPE_DELIVER_TABLET,
        WORK_STEP_TYPE_DELIVER_RETURN_LABEL => WORK_STEP_TYPE.WORK_STEP_TYPE_DELIVER_RETURN_LABEL,
        WORK_STEP_TYPE_DELIVER_PHOTOSHOOT => WORK_STEP_TYPE.WORK_STEP_TYPE_DELIVER_PHOTOSHOOT,
        WORK_STEP_TYPE_DELIVER_MARKETING_KIT => WORK_STEP_TYPE.WORK_STEP_TYPE_DELIVER_MARKETING_KIT
    };
    private enum CROSS_OBJECTS {
        MAPPING_TYPE_TABLET,
        MAPPING_TYPE_RETURN,
        MAPPING_TYPE_PHOTOSHOOT,
        MAPPING_TYPE_MARKETING_KIT
    }
    private static Map<String, CROSS_OBJECTS> crossObjectMappings = new Map<String, CROSS_OBJECTS>{
        MAPPING_TYPE_TABLET => CROSS_OBJECTS.MAPPING_TYPE_TABLET,
        MAPPING_TYPE_RETURN => CROSS_OBJECTS.MAPPING_TYPE_RETURN,
        MAPPING_TYPE_PHOTOSHOOT => CROSS_OBJECTS.MAPPING_TYPE_PHOTOSHOOT,
        MAPPING_TYPE_MARKETING_KIT => CROSS_OBJECTS.MAPPING_TYPE_MARKETING_KIT
    };

    /**
     * @description It is used for updating the WorkStep status.
     * @JIRA# LEM-13508 && LEM-14542
     * @param mxOrders
     */
    public void updateWorkStepStatus(List<MX_Order__c> mxOrders) {
        Map<Id, WorkStep> mxOrderIdToWorkStep = getMxOrderIdToWorkStep(mxOrders);
        Map<String, String> mxOrderStatusToWorkStepStatusTablet = new Map<String, String>();
        Map<String, String> mxOrderStatusToWorkStepStatusReturn = new Map<String, String>();
        Map<String, String> mxOrderStatusToWorkStepStatusPhotoshoot = new Map<String, String>();
        Map<String, String> mxOrderStatusToWorkStepStatusMarketingKit = new Map<String, String>();
        WorkStep workStep;
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (
            Cross_Object_Status_Mapping__mdt eachMapping : CrossObjectStatusMappingsSelector.newInstance()
                .selectActiveStatusMappingsByProcessName(PROCESS_TYPE_WORKSTEP_STATUS_UPDATE)
        ) {
            switch on crossObjectMappings.get(eachMapping.Type__c) {
                when MAPPING_TYPE_TABLET {
                    mxOrderStatusToWorkStepStatusTablet.put(
                        eachMapping.Source_Status__c,
                        eachMapping.Target_Status__c
                    );
                }
                when MAPPING_TYPE_RETURN {
                    mxOrderStatusToWorkStepStatusReturn.put(
                        eachMapping.Source_Status__c,
                        eachMapping.Target_Status__c
                    );
                }
                when MAPPING_TYPE_PHOTOSHOOT {
                    mxOrderStatusToWorkStepStatusPhotoshoot.put(
                        eachMapping.Source_Status__c,
                        eachMapping.Target_Status__c
                    );
                }
                when MAPPING_TYPE_MARKETING_KIT {
                    mxOrderStatusToWorkStepStatusMarketingKit.put(
                        eachMapping.Source_Status__c,
                        eachMapping.Target_Status__c
                    );
                }
            }
        }
        for (MX_Order__c eachMxOrder : mxOrders) {
            workStep = mxOrderIdToWorkStep.get(eachMxOrder.Id);
            if (workStep == null) {
                continue;
            }
            switch on workStepTypeMap.get(workStep.Type__c) {
                when WORK_STEP_TYPE_DELIVER_MARKETING_KIT {
                    setWorkStepStatusAndStatusReasonDeatils(
                        mxOrderStatusToWorkStepStatusMarketingKit,
                        eachMxOrder,
                        workStep,
                        uow
                    );
                }
                when WORK_STEP_TYPE_DELIVER_TABLET {
                    setWorkStepStatusAndStatusReasonDeatils(
                        mxOrderStatusToWorkStepStatusTablet,
                        eachMxOrder,
                        workStep,
                        uow
                    );
                }
                when WORK_STEP_TYPE_DELIVER_RETURN_LABEL {
                    setWorkStepStatusAndStatusReasonDeatils(
                        mxOrderStatusToWorkStepStatusReturn,
                        eachMxOrder,
                        workStep,
                        uow
                    );
                }
                when WORK_STEP_TYPE_DELIVER_PHOTOSHOOT {
                    setWorkStepStatusAndStatusReasonDeatils(
                        mxOrderStatusToWorkStepStatusPhotoshoot,
                        eachMxOrder,
                        workStep,
                        uow
                    );
                }
            }
        }
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used for setting the WorkStep status.
     * @param mxOrderStatusToWorkStepStatus
     * @param mxOrder
     * @param workStep
     * @param uow
     */
    private void setWorkStepStatusAndStatusReasonDeatils(
        Map<String, String> mxOrderStatusToWorkStepStatus,
        MX_Order__c mxOrder,
        WorkStep workStep,
        fflib_ISObjectUnitOfWork uow
    ) {
        if (mxOrderStatusToWorkStepStatus.containsKey(mxOrder.Status__c)) {
            workStep.Status__c = mxOrderStatusToWorkStepStatus.get(mxOrder.Status__c);
        }
        if (workStep.Status__c == ESCALTED) {
            workStep.Status_Reason__c = STATUS_REASON_OTHER;
        }
        updateWorkStepStatusReason(workStep, mxOrder);
        if (String.isNotBlank(mxOrder.Shipment_Status_Description__c)) {
            workStep.Status_Reason_Details__c = mxOrder.Shipment_Status_Description__c;
        } else if (String.isNotBlank(mxOrder.Order_Status_Description__c)) {
            workStep.Status_Reason_Details__c = mxOrder.Order_Status_Description__c;
        }
        uow.registerDirty(workStep);
    }

    /**
     * @description It is used for setting the WorkStep status.
     * @param workStep
     * @param mxOrder
     */
    private void updateWorkStepStatusReason(workStep workStep, MX_Order__c mxOrder){
        if (workStep.Status__c == ESCALTED) {
            workStep.Status_Reason__c = STATUS_REASON_OTHER;
        }
        if(mxOrder.Status__c != null && mxOrder.Status__c.equalsIgnoreCase(ORDER_STATUS_RETURN_TO_SENDER)){
            workStep.Status_Reason__c = WORKSTEP_STATUS_REASON_RETURNED_TO_SENDER;
        }
    }
    /**
     * @description It is used for getting the MxOrderIdToWorkStep map.
     * @param mxOrders
     * @return Map<Id, WorkStep>
     */
    private Map<Id, WorkStep> getMxOrderIdToWorkStep(List<MX_Order__c> mxOrders) {
        Map<Id, Id> workStepIdTomxOrderId = new Map<Id, Id>();
        Map<Id, WorkStep> mxOrderIdToWorkStep = new Map<Id, WorkStep>();
        for (MX_Order__c eachMxOrder : mxOrders) {
            workStepIdTomxOrderId.put(eachMxOrder.Work_Step__c, eachMxOrder.Id);
        }
        for (
            WorkStep eachWorkStep : WorkStepsSelector.newInstance()
                .selectById(workStepIdTomxOrderId.keySet())
        ) {
            mxOrderIdToWorkStep.put(workStepIdTomxOrderId.get(eachWorkStep.Id), eachWorkStep);
        }
        return mxOrderIdToWorkStep;
    }
}