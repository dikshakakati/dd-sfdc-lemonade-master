/**
 * @author Deloitte
 * @date 05/16/2024
 * @description Interface of service class for SSMO Lead Creation related logic.
 */
public interface ISSMOLeadCreationService {
    /**
     * @description It is used to update lead record on the basis of parsed payload.
     * @JIRA# LEM-14823
     * @param inputPayload
     * @param leadToUpdate
     * @return Lead
     */
    Lead updateLead(SSMOFalloutWrapper inputPayload, Lead leadToUpdate);

    /**
     * @description @description It is used to insert lead with Basic fields on basis of payload.
     * @JIRA# LEM-14823
     * @param payLoad
     * @param leadToInsert
     * @param queueId
     * @return Lead
     */
    Lead insertLead(SSMOFalloutWrapper payLoad, Lead leadToInsert, Id queueId);

    /**
     * @description It is used to create new task on lead when the lead is in open status.
     * @param leadsToBeUpdatedOnFallout
     * @param existingLeads
     */
    void createTaskOnLeadAfterFallout(
        List<Lead> leadsToBeUpdatedOnFallout,
        Map<Id, Lead> existingLeads
    );

    /**
     * @description It is used to populate lead with Additional fields on basis of payload.
     * @param leadsToBeUpdatedOnFallout
     */
    void updateFieldsOnLeadAfterFallout(List<Lead> leadsToBeUpdatedOnFallout);

    /**
     * @description It is to update the inbound ingestion logs to completed status on lead updation when in closed status.
     * @param leadsToBeUpdatedOnFallout
     * @param existingLeads
     */
    void updateInboundIngestionLogsToCompletedStatusOnSSMOLeadUpdationWhenInClosedStatus(
        List<Lead> leadsToBeUpdatedOnFallout,
        Map<Id, Lead> existingLeads
    );
}