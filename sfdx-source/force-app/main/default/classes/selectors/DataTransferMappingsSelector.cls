/**
 * @author DoorDash
 * @date 08-Aug-2023
 * @description Selector class for the Data_Transfer_Mapping__mdt custom metadata
**/
public inherited sharing class DataTransferMappingsSelector extends fflib_SObjectSelector implements IDataTransferMappingsSelector {
    /**
     * @description Default constructor for the class.
     * @return IDataTransferMappingsSelector - Returns interface of DataTransferMappingsSelector
     */
    public static IDataTransferMappingsSelector newInstance() {
        return (IDataTransferMappingsSelector) Application.Selector.newInstance(Data_Transfer_Mapping__mdt.SObjectType);
    }

    /**
     * @description It is used for getting object type.
     * @return SObjectType - Returns object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Data_Transfer_Mapping__mdt.SObjectType;
    }

    /**
     * @description It is for getting the fields of Data_Transfer_Mapping__mdt.
     * @return List<Schema.SObjectField> - Data_Transfer_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Data_Transfer_Mapping__mdt.MasterLabel,
            Data_Transfer_Mapping__mdt.Field_API_Name__c,
            Data_Transfer_Mapping__mdt.Is_Required__c,
            Data_Transfer_Mapping__mdt.Field_Data_Type__c,
            Data_Transfer_Mapping__mdt.Field_Label__c,
            Data_Transfer_Mapping__mdt.Object_API_Name__c,
            Data_Transfer_Mapping__mdt.Active__c
        };
    }

    /**
     * @description Returns a List of Data_Transfer_Mapping__mdt
     * @return List<Data_Transfer_Mapping__mdt>
     */
    public List<Data_Transfer_Mapping__mdt> getAllValues() {
        fflib_QueryFactory query = newQueryFactory();
		query.addOrdering('Field_Label__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Data_Transfer_Mapping__mdt>) Database.query(query.toSOQL());
    }

    /**
     * @description Returns a List of "Active" Data_Transfer_Mapping__mdt
     * @return List<Data_Transfer_Mapping__mdt>
     */
    public List<Data_Transfer_Mapping__mdt> getAllActiveValues() {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition ('Active__c = true');
		query.addOrdering('Field_Label__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Data_Transfer_Mapping__mdt>) Database.query(query.toSOQL());
    }
}