/**
 * @author atg
 * @date 06/30/2022
 * @description Wrapper class to prepare JSON payload for Business_Reference__c integration.
 */
public class BusinessReferenceIntegration {
    public Id externalBusinessId;
    public String externalIdSource;
    public Id createdById;
    public String createdDate;
    public String msSyncStage;
    public String lastCompletedStep;

    /**
     * @description Constructor to set wrapper class variables.
     * @param businessReference
     */
    public BusinessReferenceIntegration(Business_Reference__c businessReference ) {
        this.externalBusinessId = String.valueOf(businessReference.Id);
        this.externalIdSource = businessReference.External_Id_Source__c;
        this.createdById = String.valueOf(businessReference.CreatedById);
        this.createdDate = String.valueofGmt(businessReference.CreatedDate);
        this.msSyncStage = businessReference.MS_Sync_Stage__c;
        this.lastCompletedStep = businessReference.Last_Completed_Step__c;
    }
}