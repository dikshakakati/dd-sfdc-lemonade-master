/**
 * @author Deloitte
 * @date 2024-04-26
 * @description Interface to add domain class methods of EmailMessage Object
 */
public interface IEmailMessages extends fflib_ISObjects {
    /**
     * @description update Email Count on EmailMessage Insert
     */
    void updateEmailCountWhenEmailMessageInserted();

    /**
     * @description Set Last Email Revceived Data fields on Opportunity and Lead.
     */
    void setLastEmailReceivedDate();

    /**
     * @description It is used to update Parent Work Plan Related
     * to email when EmailMessages are Inserted
     * @JIRA LEM-21243
     */
    void updateWorkPlanWhenEmailMessageInserted();
}