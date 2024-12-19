/**
 * @author Deloitte
 * @date 11/10/2023
 * @description Service class for Business_Vertical__c related logic.
 */
public class BusinessVerticalsService {
  /**
   * @description It is used to map Primary Vertical, Business Vertical Id, Menu UI Type from Business Vertical records to the
   * Sboject records passed.
   * @JIRA# LEM-11072
   * @param sObjectsToPopulateBusinessVertical
   */

  public static void populateBusinessVerticalDetails(
    List<SObject> sObjectsToPopulateBusinessVertical
  ) {
     service()
      .populateBusinessVerticalDetails(sObjectsToPopulateBusinessVertical);
  }

  private static IBusinessVerticalsService service() {
    return (IBusinessVerticalsService) Application.Service.newInstance(
      IBusinessVerticalsService.class
    );
  }

}