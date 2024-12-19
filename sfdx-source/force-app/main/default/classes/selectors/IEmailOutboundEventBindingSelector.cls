/**
 * @author Deloitte
 * @date 05/09/2024
 * @description Selector Interface to query Email outbound integration binding.
 */
public interface IEmailOutboundEventBindingSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Notifier Event Binding records
     * @return List<Email_Outbound_Events_Binding__mdt> - returns list of metadata records
     */
    List<Email_Outbound_Events_Binding__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Email_Outbound_Events_Binding__mdt
     * @return List<Schema.SObjectField>- Email_Outbound_Events_Binding__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}