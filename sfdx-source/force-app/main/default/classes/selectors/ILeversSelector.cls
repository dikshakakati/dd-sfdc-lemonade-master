/**
 * @author Deloitte
 * @date 04/09/2024
 * @description Interface to add Lever Selector class methods
 */
public interface ILeversSelector extends fflib_ISObjectSelector {
    /**
     * @description It is used for getting Levers by passed Ids.
     * @param leverIds
     * @return List<Lever__c>
     */
    List<Lever__c> selectById(Set<Id> leverIds);

    /**
     * @description It is used for getting Levers by passed cloned Lever Ids.
     * @param clonedLeverIds
     * @return List<Lever__c>
     */
    List<Lever__c> selectByClonedLeverId(Set<Id> clonedLeverIds);

    /**
     * @description It is used for getting Levers by passed Account Plan Ids.
     * @param accountPlanIds
     * @return List<Lever__c>
     */
    List<Lever__c> selectOpenLeversByAccountPlanId(Set<Id> accountPlanIds);

    /**
     * @description It is used for getting Levers by account Ids.
     * @param accountIds
     * @return List<Lever__c>
     */
    List<Lever__c> selectByAccountIds(Set<Id> accountIds);
}