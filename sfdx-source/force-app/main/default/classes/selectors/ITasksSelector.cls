/**
 * @author Deloitte
 * @date 07/07/2023
 * @description Interface for TasksSelector class methods.
 */
public interface ITasksSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used to query Tasks having WhatId by the passed Ids.
     * @param taskIds
     * @return List<Task>
     */
    List<Task> selectTasksWithWhatIdByIds(Set<Id> taskIds);
}