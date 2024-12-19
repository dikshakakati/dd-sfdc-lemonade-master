/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Interface to add Selector class methods.
 */
public interface ITaskRelationsSelector extends fflib_ISObjectSelector{
	/**
     * @description  It is used to get TaskRelations by Task Ids.
     * @param taskIds
     * @return List<TaskRelation>
     */
    
    List<TaskRelation> selectByTaskIds(Set<Id> taskIds);
}