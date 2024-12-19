/**
 * @author Deloitte
 * @date 29/04/2022
 * @description Interface to add Selector class methods.
 */
public interface IStoresListViewConfigurationsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is for getting the fields on Stores_List_View_Configuration__mdt.
     * @return List<Schema.SObjectField> - Stores_List_View_Configuration__mdt fields
     */
    List<Schema.SObjectField> getSObjectFieldList();

    /**
     * @description It is for getting all field values on basis of Work Plan type
     * and Account record type for Stores_List_View_Configuration__mdt.
     * @param type - Type of WorkPlan
     * @param accountRecordType - Account record type
     * @return List<Stores_List_View_Configuration__mdt> - List of metadata records with values
     */
    List<Stores_List_View_Configuration__mdt> selectByWorkPlanTypeAndAccountRecordType(
        String type,
        String accountRecordType
    );
}