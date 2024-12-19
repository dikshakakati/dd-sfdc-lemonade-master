/**
 * @author Deloitte
 * @date 11/10/2023
 * @description Interface of service class for Business_Vertical__c related logic.
 */
public interface IBusinessVerticalsService {
  /**
   * @description It is used to map Primary Vertical, Business Vertical Id, Menu UI Type from Business Vertical records to the
   * Sboject records passed.
   * @JIRA# LEM-11072
   * @param sObjectsToPopulateBusinessVertical
   */

  void populateBusinessVerticalDetails(
    List<SObject> sObjectsToPopulateBusinessVertical
  );

}