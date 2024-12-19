/**
 * @author Deloitte
 * @date   05/16/2024
 * @description This is the service class for Lead creation from SSMO Payload
 */
public inherited sharing class SSMOLeadCreationService implements ISSMOLeadCreationService {
    /**
     * @description default constructor for the class
     * @return ISSMOLeadCreationService - interface of SSMOLeadCreationService
     */
    public static ISSMOLeadCreationService service() {
        return (ISSMOLeadCreationService) Application.Service.newInstance(
            ISSMOLeadCreationService.class
        );
    }

    /**
     * @description It is used to update lead record on the basis of parsed payload.
     * @JIRA# LEM-14823
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    public static Lead updateLead(SSMOFalloutWrapper inputPayload, Lead leadToUpdate) {
        return service().updateLead(inputPayload, leadToUpdate);
    }

    /**
     * @description @description It is used to insert lead with Basic fields on basis of payload.
     * @JIRA# LEM-14823
     * @param payLoad
     * @param leadToInsert
     * @param queueId
     * @return Lead
     */
    public static Lead insertLead(SSMOFalloutWrapper payLoad, Lead leadToInsert, Id queueId) {
        return service().insertLead(payLoad, leadToInsert, queueId);
    }

    /**
     * @description It is used to create new task on lead when the lead is in open status.
     * @param leadsToBeUpdatedOnFallout
     * @param existingLeads
     */
    public static void createTaskOnLeadAfterFallout(
        List<Lead> leadsToBeUpdatedOnFallout,
        Map<Id, Lead> existingLeads
    ) {
        service().createTaskOnLeadAfterFallout(leadsToBeUpdatedOnFallout, existingLeads);
    }

    /**
     * @description It is to update the inbound ingestion logs to completed status on lead updation when in closed status.
     * @param leadsToBeUpdatedOnFallout
     * @param existingLeads
     */
    public static void updateInboundIngestionLogsToCompletedStatusOnSSMOLeadUpdationWhenInClosedStatus(
        List<Lead> leadsToBeUpdatedOnFallout,
        Map<Id, Lead> existingLeads
    ) {
        service()
            .updateInboundIngestionLogsToCompletedStatusOnSSMOLeadUpdationWhenInClosedStatus(
                leadsToBeUpdatedOnFallout,
                existingLeads
            );
    }

    /**
     * @description It is used to populate lead with Additional fields on basis of payload.
     * @param leadsToBeUpdatedOnFallout
     */
    public static void updateFieldsOnLeadAfterFallout(List<Lead> leadsToBeUpdatedOnFallout) {
        service().updateFieldsOnLeadAfterFallout(leadsToBeUpdatedOnFallout);
    }
}