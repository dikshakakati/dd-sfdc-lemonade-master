/**
 * @author Deloitte
 * @date 05/07/2023
 * @description Interface to add domain class methods
 */
public interface ILeads extends fflib_ISObjects {
    /**
     * @description It is used to reset attributes on Leads related to address.
     */
    void resetAddressAttributes();

    /**
     * @description It is used to process Leads on conversion.
     */
    void processLeadsOnConversion();

    /**
     * @description It is used to set certain field values before Lead conversion.
     */
    void setDefaultValuesBeforeConversion();

    /**
     * @description It is used to update Last Inbound Date/Time for Lead.
     */
    void updateLastInboundDateTime();
    /**
     * @description It is to update the inbound ingestion logs to completed status on lead creation.
     */
    void updateInboundIngestionLogsToCompletedStatusOnSSMOLeadCreation();
    /**
     * @description It is used to update the last status change date when there is an update on status.
     */
    void updateLastStatusChangeDate();
}