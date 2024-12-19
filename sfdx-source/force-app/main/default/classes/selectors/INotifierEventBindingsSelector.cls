/**
 * @author Deloitte
 * @date 06/13/2022
 * @description Interface to add Selector class methods
 */
public interface INotifierEventBindingsSelector extends fflib_ISObjectSelector {
    /**
     * @description Method fetches all Notifier Event Binding records
     * @return List<Notifier_Event_Binding__mdt> - returns list of metadata records
     */
    List<Notifier_Event_Binding__mdt> getAllValues();

    /**
     * @description This method is for getting the fields on Notifier_Event_Binding__mdt
     * @return List<Schema.SObjectField>- Notifier_Event_Binding__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();
}