/**
 * @author Deloitte
 * @date 06/11/2024
 * @description Interface to add Selector class methods.
 */
public interface IEventsSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for get count of events by passing status and related Sobject Ids.
     * @param relatedToIds
     * @param eventStatus
     * @return Aggregate[]
     */
    Aggregate[] selectCountOfEventsByStatusAndRelatedToIds(
        Set<Id> relatedToIds,
        String eventStatus
    );

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Event>
     */
    List<Event> selectById(Set<Id> idSet);

    /**
     * @description This method querying account with Bussiness record type and Account life cycle status not equal to In Pursuit.
     * @param sObjectIds
     * @return List<Event>
     */
    List<Event> selectByWhatIdAndWhoId(Set<Id> sObjectIds);
}