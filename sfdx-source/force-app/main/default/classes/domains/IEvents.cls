/**
 * @author Deloitte
 * @date 05/01/2024
 * @description Interface to add domain class methods of Event Object
 */
public interface IEvents extends fflib_ISObjects {
    /**
     * @description : It is used to Update the SDR Touch Required field on opportunity.
     * LEM-13541
     */
    void updateSDRTouchOnOpportunity();
    /**
     * @description : It is used to Update the SDR Assisted field on opportunity.
     * LEM-16065
     */
    void updateSDRAssistedFieldOnOpportunity();
    /**
     * @description It is used to update meeting set date on related Lead for Event
     * which are inserted
     */
    void updateMeetingSetOnLeadAndOpportunity();
    /**
     * @description It is used to update Last Meeting Ran date on related Lead for Event
     * which are updated
     */
    void updateLastMeetingRanOnLeadAndOpportunity();
    /**
     * @description It is used to update First and Last Qualified Activity on lead for an event
     * which are updated
     */
    void updateFirstAndLastQualifiedActivityOnLeadAndOpportunity();
    /**
     * @description It is used to update meeting set date on related Lead for Event Start Date Update
     * which are inserted
     */
    void updateMeetingSetOnLeadAndOpportunityOnEventStartDateUpdate();
}