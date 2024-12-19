/**
 * @author atg
 * @date 06/29/2022
 * @description Wrapper class to prepare JSON payload for Xref__c integration.
 */
public class XrefIntegration {
    public Id businessReference;
    public Id account;
    public Id store;
    public String externalIdSource;
    public Id createdById;
    public String createdDate;
    public String msSyncStage;
    public String oldStore;

    /**
     * @description Constructor to set wrapper class variables.
     * @param xref
     */
    public XrefIntegration(Xref__c xref ) {
        this.businessReference = String.valueOf(xref.Business_Reference__c);
        this.account = String.valueOf(xref.Salesforce_Account_Name__c);
        this.store = String.valueOf(xref.Id);
        this.externalIdSource = xref.External_Id_Source__c;
        this.createdById = String.valueOf(xref.CreatedById);
        this.createdDate = String.valueofGmt(xref.CreatedDate);
        this.msSyncStage = xref.MS_Sync_Stage__c;
        this.oldStore = xref.Inactive_Xref__r.External_ID__c;
    }
}