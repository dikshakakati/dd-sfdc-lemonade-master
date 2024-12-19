/**
 * @author Deloitte
 * @date 22/05/2022
 * @description Parent wrapper for storesOnWorkPlan lightning web component.
 */
public class StoresOnWorkPlanWrapper {
    @AuraEnabled
    public List<AccountWrapper> accountWrappers;
    @AuraEnabled
    public String currentWorkPlanType;
    @AuraEnabled
    public Boolean showSearchBar;

    /**
     * @description Parameterized constructor to assign value to the variables.
     * @param accountWrappers
     * @param currentWorkPlanType
     * @param showSearchBar
     */
    public StoresOnWorkPlanWrapper(
        List<AccountWrapper> accountWrappers,
        String currentWorkPlanType,
        Boolean showSearchBar
    ) {
        this.accountWrappers = accountWrappers;
        this.currentWorkPlanType = currentWorkPlanType;
        this.showSearchBar = showSearchBar;
    }
}