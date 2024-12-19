/**
 * @author Deloitte
 * @date 11/30/2022
 * @description Interface for BriefItems
 */
public interface IBriefItems extends fflib_ISObjects {
    /**
     * @description It is used to verify status of all the related Brief Items and update queue
     * assignment eligibility of the related Brief
     */
    void updateStatusOnRelatedBrief();

    /**
     * @description It is used to fetch Dates of all Brief Items and update the dates on the
     * related Brief.
     */
    void updateDateOnRelatedBrief();

    /**
     * @description It is used to update sync changes in the brief item to the subscription related
     * to the quote line the brief item was created
     */
    void syncSubscriptionFields();

    /** @description It is used to update the configuration field in the brief item to the
     * related brief
     *
     */
    void updateConfigurationOnRelatedBrief();

    /**
     * @description validates the campaign Id field on brief items
     */
    void validateCampaignIdField();
}