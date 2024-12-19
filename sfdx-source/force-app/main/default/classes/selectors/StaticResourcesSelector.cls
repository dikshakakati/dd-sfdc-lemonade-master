/**
 * @author Deloitte
 * @date 04/27/2024
 * @description Selector Class for StaticResource Object
 */
public inherited sharing class StaticResourcesSelector extends fflib_SObjectSelector implements IStaticResourcesSelector {
    /**
     * @description default constructor for the StaticResources Selector class
     * @return IStaticResourcesSelector - interface of IStaticResourcesSelector
     */
    public static IStaticResourcesSelector newInstance() {
        return (IStaticResourcesSelector) Application.Selector.newInstance(
            StaticResource.SObjectType
        );
    }

    /**
     * @description It is used for getting the fields on StaticResource object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> staticResourceFields = new List<Schema.SObjectField>{
            StaticResource.Id,
            StaticResource.Body,
            StaticResource.Name
        };
        return staticResourceFields;
    }

    /**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return StaticResource.SObjectType;
    }

    /**
     * @description It is used for getting Static Resource by passed fileName.
     * @param fileName
     * @return List<StaticResource>
     */
    public List<StaticResource> selectByName(String fileName) {
        fflib_QueryFactory query = newQueryFactory().setCondition('Name = :fileName');
        return (List<StaticResource>) Database.query(query.toSOQL());
    }
}