/**
 * @author Deloitte
 * @date 04/30/2024
 * @description It is used for sending information needed for Creation of Mx Order from Guided Flow.
 */
public with sharing class CloneAccountPlanFlowInputs {
    @InvocableVariable
    public Id runningUserId;
    @InvocableVariable
    public Account_Plan__c accountPlanRecord;
}