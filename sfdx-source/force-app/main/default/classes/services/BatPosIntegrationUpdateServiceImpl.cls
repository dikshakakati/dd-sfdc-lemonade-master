/**
 * @author DoorDash
 * @date 03/09/2023
 * @description This class will process bat requested status updates on worksteps and workplans.
 */
public inherited sharing class BatPosIntegrationUpdateServiceImpl implements IBatPosIntegrationUpdateService{
    private static final String EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST = 'PROCESS_UPDATE_POS_INTEGRATION_REQUEST';
    private static final String NEW_IR_REQUEST = 'CREATE';
    private static Map<String, Map<String, Bat_To_WorkSteps_Status_Mapping__mdt>> batSettingForWs;
    private static Map<String, Bat_To_WorkSteps_Status_Mapping__mdt> batSettingForWp;
    private static final String STATUS_PROCESSED = 'Processed';
    private static final String BAT_STATUS_INTEGRATION_ACTIVATED = 'INTEGRATION_ACTIVATED';
    private static final String LOG_SERVICE_POS_INTEGRATION = 'POS Integration Service';
    private static final String LOG_DOMAIN_PROVISIONING = 'Provisioning';

    private List<IGenericLogEntry> genericLogList = new List<IGenericLogEntry>();
    fflib_ISObjectUnitOfWork uow;
    /**
    @description Constructor to instantiate an instance of this class. It initializes batSettingForWs, batSettingForWp, and uow.
    */
    public BatPosIntegrationUpdateServiceImpl(){
        batSettingForWs = new Map<String, Map<String, Bat_To_WorkSteps_Status_Mapping__mdt>>();
        batSettingForWp = new Map<String, Bat_To_WorkSteps_Status_Mapping__mdt>();
        uow = Application.UnitOfWork.newInstance();
    }
    /**
    @description This method handles a list of Notifier__e events.
    @param events A List of Notifier__e events.
    */
    public void handleNotifierEvents(List<Notifier__e> events){
        Set<Id> intRequestIds = new Set<Id>();
        Set<Id> recordIdsFromPayload;
        for (Notifier__e eachEvent : events) {
            recordIdsFromPayload = (Set<Id>) JSON.deserialize(eachEvent.Payload__c, Set<Id>.class);
            if (recordIdsFromPayload == null) {
                continue;
            }
            if (EVENT_TOPIC_PROCESS_UPDATE_POS_INTEGRATION_REQUEST.equals(eachEvent.Topic__c)) {
                intRequestIds.addAll(recordIdsFromPayload);
            }
        }
        processIntegrationRequests(intRequestIds);
    }
    /**
    * @description This method processes a set of Integration_request__c ids.
    * @param intRequestIds A Set of Integration_request__c ids.
    */
    public void processIntegrationRequests(Set<Id> intRequestIds){
        try{
            List<Integration_request__c> irRequests =  IntegrationRequestsSelector.newInstance().selectById(intRequestIds);
            Map<String, WorkPlan> onboardingIdToWorkPlan = getWorkPlansAndSteps(IrRequests);
            getBatMetaData();
            for(Integration_Request__c eachIr: IrRequests){
                if(onboardingIdToWorkPlan.containsKey(eachIr.Onboarding_Id__c)){
                    mapIntegrationRequestToWsAndWp(eachIr, onboardingIdToWorkPlan.get(eachIr.Onboarding_Id__c));
                }
            }
            uow.commitWork();

            GenericLoggerService.publish(genericLogList);
            genericLogList.clear();
        } catch (Exception processIrException) {
            Logger.publish(
                LogEntry.newExceptionLog(processIrException, LogEntry.SeverityLevel.HIGH)
            );
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_SERVICE_POS_INTEGRATION,
                    LOG_DOMAIN_PROVISIONING,
                    GenericLogEntry.SeverityLevel.HIGH
                ).logException(processIrException)
            );
        }
    }
    /**
    * @description This method maps an integration request to a workplan and a workstep.
    * @param ir An Integration_Request__c object.
    * @param wp A WorkPlan object.
    */
    @testVisible
    private void mapIntegrationRequestToWsAndWp(Integration_Request__c ir, WorkPlan wp){

        for(WorkStep eachWorkStep: wp.WorkSteps){
            Bat_To_WorkSteps_Status_Mapping__mdt setting = getSettingForUpdateWs(ir, eachWorkStep);
            Boolean updateWs = setting != null ? true : false;
            if(updateWs){
                updateWorkStep(eachWorkStep, setting);
            }
        }
        Bat_To_WorkSteps_Status_Mapping__mdt setting = getSettingForUpdateWp(ir, wp);
        Boolean updateWp = setting != null ? true : false;
        if(updateWp){
            updateWorkPlan(wp, setting, ir);
        }
        updateIntegrationRequest(ir);
    }
    /**
     * @description This method returns a Bat_To_WorkSteps_Status_Mapping__mdt object that matches the target status of the
     * Integration_Request__c object and the WorkPlan object.
     * @param ir An Integration_Request__c object.
     * @param wp A WorkPlan object.
     * @return A Bat_To_WorkSteps_Status_Mapping__mdt object.
     */
    @testVisible
    private Bat_To_WorkSteps_Status_Mapping__mdt getSettingForUpdateWp(Integration_Request__c ir, WorkPlan wp){
        if(String.isNotBlank(Ir.Target_Status__c) && batSettingForWp.containsKey(Ir.Target_Status__c)){
            return batSettingForWp.get(Ir.Target_Status__c);
        }
        return null;
    }
    /**
     * @description This method returns a Bat_To_WorkSteps_Status_Mapping__mdt object that matches the target status
     * and exclusion code of the Integration_Request__c object and the WorkStep object.
     * @param ir An Integration_Request__c object.
     * @param eachWorkStep A WorkStep object.
     * @return A Bat_To_WorkSteps_Status_Mapping__mdt object.
     */
    @testVisible
    private Bat_To_WorkSteps_Status_Mapping__mdt getSettingForUpdateWs(Integration_Request__c ir, WorkStep eachWorkStep){
        String statusAndExclusionCode = string.format('{0}@{1}', new string[]{ir.Target_Status__c, ir.Exclusion_Code__c});
        // checks for is Integration Request status exists in default map.
        if(String.isNotBlank(Ir.Target_Status__c) && batSettingForWs.containsKey(statusAndExclusionCode)){
            Map<String, Bat_To_WorkSteps_Status_Mapping__mdt> settingByWorkStep = batSettingForWs.get(statusAndExclusionCode);
            return settingByWorkStep.containsKey(eachWorkStep.Type__c) ? settingByWorkStep.get(eachWorkStep.Type__c) : null;
        }
        return null;
    }
    /**
     * @description This method updates the sfdc_status__c field of an Integration_Request__c object to "Processed" and registers the object as dirty.
     * @param ir An Integration_Request__c object.
     */
    @testVisible
    private void updateIntegrationRequest(Integration_Request__c ir){
        ir.sfdc_status__c = STATUS_PROCESSED;
        uow.registerDirty(ir);
    }
    /**
     * @description This method updates the Status__c and Notes__c fields of a WorkPlan object based on a Bat_To_WorkSteps_Status_Mapping__mdt
     * object and an Integration_Request__c object.
     * @param workPlan A WorkPlan object.
     * @param setting A Bat_To_WorkSteps_Status_Mapping__mdt object.
     * @param ir An Integration_Request__c object.
     */
    @testVisible
    private void updateWorkPlan(WorkPlan workPlan, Bat_To_WorkSteps_Status_Mapping__mdt setting, Integration_Request__c ir){
        workPlan.Status__c = setting.Work_Plan_Status__c;
        if(BAT_STATUS_INTEGRATION_ACTIVATED.equals(ir.Target_Status__c)){
            workPlan.Notes__c = ir.Notes__c;
        }
        uow.registerDirty(workPlan);
    }
    /**
     * @description This method updates the Status, Status_Reason__c, and Status_Reason_Details__c fields of a WorkStep object
     * based on a Bat_To_WorkSteps_Status_Mapping__mdt object.
     * @param workStep A WorkStep object.
     * @param setting A Bat_To_WorkSteps_Status_Mapping__mdt object.
     */
    @testVisible
    private void updateWorkStep(WorkStep workStep, Bat_To_WorkSteps_Status_Mapping__mdt setting){
        workStep.Status = setting.Work_Step_Status__c;
        workStep.Status__c = setting.Work_Step_Status__c;
        workStep.Status_Reason__c = setting.Status_Reason__c;
        workStep.Status_Reason_Details__c = setting.Status_Reason__c;

        genericLogList.add(
            GenericLoggerService.createGenericLog(
                LOG_SERVICE_POS_INTEGRATION,
                LOG_DOMAIN_PROVISIONING,
                GenericLogEntry.SeverityLevel.HIGH
            ).logMessage(
                workStep.Status__c +' '+ workStep.Status_Reason__c
                    +' '+workStep.Status_Reason_Details__c
            )
        );
        uow.registerDirty(workStep);
    }
    /**
     * @description Retrieves the metadata for the Bat_To_WorkSteps_Status_Mapping__mdt custom metadata type and populates the batSettingForWs
     * and batSettingForWp maps with the appropriate values.
     */
    @testVisible
    private void getBatMetaData(){
        for(Bat_To_WorkSteps_Status_Mapping__mdt eachMdt: BatToWorkStepsStatusMappingSelector.newInstance().getAllValues()){
            String statusAndExclusionCode = string.format('{0}@{1}', new string[]{eachMdt.Bat_Status__c, eachMdt.Exclusion_Code__c});

            if(batSettingForWs.containsKey(statusAndExclusionCode)){
                Map<String, Bat_To_WorkSteps_Status_Mapping__mdt> settingMap = batSettingForWs.get(statusAndExclusionCode);
                    settingMap.put( eachMdt.Work_Step_Type__c, eachMdt );
            } else {
                batSettingForWs.put( statusAndExclusionCode,
                    new Map<String, Bat_To_WorkSteps_Status_Mapping__mdt>{eachMdt.Work_Step_Type__c => eachMdt}
                );
            }
            if(String.isNotBlank(eachMdt.Work_Plan_Status__c)){
                batSettingForWp.put(eachMdt.Bat_Status__c, eachMdt);
            }
        }
    }
    /**
     * @description Retrieves the WorkPlan records associated with the provided Integration Request records, and returns them in a map
     * keyed by the Onboarding_Id__c field of the Integration Request records.
     * @param irRequests a list of Integration_request__c records for which to retrieve associated WorkPlan records
     * @return a map of WorkPlan records keyed by the Onboarding_Id__c field of the Integration Request records
     */
    @testVisible
    private Map<String, WorkPlan> getWorkPlansAndSteps(List<Integration_request__c> irRequests){
        Set<String> onboardingIds = new Set<String>();
        Map<String, WorkPlan> onboardingIdToWorkPlan = new Map<String, WorkPlan>();
        Set<Id> newIntRequestIds = new Set<Id>();
        for(Integration_request__c eachIr: IrRequests){
            onboardingIds.add(eachIr.Onboarding_Id__c);
        }
        for(Integration_request__c eachIr: IntegrationRequestsSelector.newInstance()
            .selectByOnboardingId(onboardingIds,  new Set<String>{STATUS_PROCESSED})){
            if(NEW_IR_REQUEST.equals(eachIr.Action__c)){
                newIntRequestIds.add(eachIr.Id);
            }
        }
        for(WorkPlan eachWp: WorkPlansSelector.newInstance().selectWorkPlansByIntegrationRequestId(newIntRequestIds)){
            onboardingIdToWorkPlan.put(eachWp.Integration_Request__r.Onboarding_Id__c, eachWp);
        }
        return onboardingIdToWorkPlan;
    }
}