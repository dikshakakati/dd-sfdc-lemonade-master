/**
 * @author Deloitte
 * @date 10/09/2023
 * @description Interface for RateChangeRequestSelector class methods.
 */
public interface IRateChangeRequestSelector extends fflib_ISObjectSelector {
    /**
     * @description This method fetches the RateChangeRequests along with all the related Subscription Rate Change records.
     * @param rcrIds
     * @return List<Rate_Change_Request__c>
     */
    List<Rate_Change_Request__c> selectRateChangeRequestById(Set<Id> rcrIds);

    /**
     * @description This method fetches the RateChangeRequests with activation status as new and effective date in past.
     * @return List<Rate_Change_Request__c>
     */
    Database.QueryLocator selectRateChangeRequestByPastEffectiveDate();

    /**
     * @description This method is used for getting Rate_Change_Request__c records
     * with today as effective date for batch
     * @return List<Rate_Change_Request__c>
     */
    Database.QueryLocator selectByEffectiveDateToday();
}