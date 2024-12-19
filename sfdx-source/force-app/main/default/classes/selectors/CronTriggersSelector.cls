/**
 * @author DoorDash
 * @date 06/20/2023
 * @description Selector Class for CronTrigger Object
 */
public inherited sharing class CronTriggersSelector extends fflib_SObjectSelector implements ICronTriggersSelector {
	/**
     * @description default constructor for the CronTrigger Selector class
     * @return ICronTriggersSelector
     */
    public static ICronTriggersSelector newInstance() {
        return (ICronTriggersSelector) Application.Selector.newInstance(CronTrigger.SObjectType);
    }
     /**
     * @description This method is for getting the fields on account object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{ CronTrigger.Id };
    }
	/**
     * @description This method is used for getting Object type
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CronTrigger.SObjectType;
    }
     /**
     * @description This method is used for getting Sobject record by Id
     * @param idSet
     * @return List<CronTrigger>
     */
    public List<CronTrigger> selectById(Set<Id> idSet) {
        return (List<CronTrigger>) selectSObjectsById(idSet);
    }
     /**
     * @description This method is used to query running async jobs by job name
     * @param jobName
     * @return List<CronTrigger>
     */
    public List<CronTrigger> selectCronTriggerJobByName(String jobName) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition('CronJobDetail.Name LIKE :jobName');
        return (List<CronTrigger>) Database.query(query.toSOQL());
    }
}