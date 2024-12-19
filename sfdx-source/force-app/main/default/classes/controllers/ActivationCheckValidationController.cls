/**
 * @description       : LEM-13304 - Controller class for Activation Checklist validation button.
 * @author            : Meghana Nidavani
 * @group             :
 * @last modified on  : 04-04-2024
 * @last modified by  : Meghana Nidavani
 **/
public with sharing class ActivationCheckValidationController {
    private static final String ERROR_KEY = 'error';
    private static final String MESSAGE_KEY = 'message';
    private static final String STATUS_KEY = 'status';
    private static final String SUCCESS_KEY = 'warning';
    private static final String WORK_STEP_NAME_ACTIVATIONS_CHECKLIST = 'Activations Checklist';
    private static final String WORK_STEP_NAME_ACTIVATIONS_OUTREACH = 'Activations Outreach';
    private static final Set<String> WORK_STEP_NAMES = new Set<String>{
        WORK_STEP_NAME_ACTIVATIONS_CHECKLIST,
        WORK_STEP_NAME_ACTIVATIONS_OUTREACH
    };

    /**
     * @description It checks whether the Work Plan has child Activation Checklist Work Steps.
     * @JIRA# LEM-13304
     * @param workPlanID
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    public static boolean hasActivationsCheckListForSelectedWorkPlan(Id workPlanID) {
        List<WorkStep> childWorkSteps = getChildActivationChecklistWorkStepsForWorkPlan(workPlanID);
        return childWorkSteps != null && !childWorkSteps.isEmpty();
    }

    /**
     * @description It collects the child Activation Checklist Work Steps for passed Work Plan Id.
     * @JIRA# LEM-13304
     * @param workPlanID
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> getChildActivationChecklistWorkSteps(Id workPlanID) {
        Map<String, Object> requestRespone = new Map<String, Object>();
        try {
            List<WorkStep> childWorkSteps = getChildActivationChecklistWorkStepsForWorkPlan(
                workPlanID
            );
            Set<Id> activationChecklistWorkSteps = new Set<Id>();
            for (WorkStep workStep : childWorkSteps) {
                activationChecklistWorkSteps.add(workStep.id);
            }
            if (!activationChecklistWorkSteps.isEmpty()) {
                WorkStepsService.collectChildActivationChecklistWorkStepsForOutboundIntegration(
                    activationChecklistWorkSteps
                );
                requestRespone.put(STATUS_KEY, SUCCESS_KEY);
                requestRespone.put(
                    MESSAGE_KEY,
                    System.Label.Activation_Checklist_Validation_In_progress
                );
            } else {
                requestRespone.put(STATUS_KEY, SUCCESS_KEY);
                requestRespone.put(
                    MESSAGE_KEY,
                    System.Label.Activation_Checklist_No_WorkStep_Found
                );
            }
            return requestRespone;
        } catch (Exception ex) {
            requestRespone.put(STATUS_KEY, ERROR_KEY);
            requestRespone.put(MESSAGE_KEY, ex.getMessage());
            return requestRespone;
        }
    }

    /**
     * @description It queries child Activation Checklist Work Steps based on passed parent Work Plan Id.
     * @JIRA# LEM-13304
     * @param workPlanID
     * @return Map<String, Object>
     */
    private static List<WorkStep> getChildActivationChecklistWorkStepsForWorkPlan(Id workPlanID) {
        return WorkStepsSelector.newInstance()
            .selectChildWorkStepsByWorkPlan(workPlanID, WORK_STEP_NAME_ACTIVATIONS_CHECKLIST);
    }

    /**
     * @description It is used to get dependee Work Step details using the passed Work Plan Id.
     * @param workPlanId
     * @return Boolean
     */
    @AuraEnabled(cacheable=true)
    public static Boolean hasOpenDependentWorkPlan(Id workPlanId) {
        SObjectField fieldToFilter = WorkStepDependency__c.Dependent_Work_Plan_Id__c;
        Integer openDependentWorkPlanCount = 0;
        for (
            WorkStepDependency__c eachWorkStepDependency : WorkStepDependenciesSelector.newInstance()
                .selectDependeeWorkStepsByDependentSobjectIds(
                    new Set<Id>{ workPlanId },
                    fieldToFilter
                )
        ) {
            if (WORK_STEP_NAMES.contains(eachWorkStepDependency.Dependee_Work_Step__r.Name)) {
                continue;
            }
            openDependentWorkPlanCount += 1;
        }
        return openDependentWorkPlanCount > 0;
    }
}