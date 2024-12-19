/**
 * @author DoorDash
 * @description Interface to add Selector class methods
 */
public interface ICronTriggersSelector extends fflib_ISObjectSelector {
	 /**
     * @description This method is used for getting Sobject record by Id
     * @param idSet
     * @return List<CronTrigger>
     */
    List<CronTrigger> selectById(Set<Id> idSet);
    /**
     * @description This method is used to query running asyc jobs by job name
     * @param jobName
     * @return List<CronTrigger>
     */
    List<CronTrigger> selectCronTriggerJobByName(String jobName);
}