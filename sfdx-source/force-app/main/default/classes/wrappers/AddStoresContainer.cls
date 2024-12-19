/**
 * @author Deloitte
 * @date 12/01/2022
 * @description Parent wrapper for addStores lightning web component.
 */
public class AddStoresContainer {
    @AuraEnabled
    public List<Id> lastReturnedParentIds;
    @AuraEnabled
    public Id lastReturnedStoreAccountId;
    @AuraEnabled
    public List<Id> parentIds;
    @AuraEnabled
    public WorkOrder parentWorkOrder;
    @AuraEnabled
    public String searchKey;
    @AuraEnabled
    public List<AccountWrapper> storeAccountWrappers;

    /**
     * @description Parameterized constructor to assign value to the variables.
     * @param parentIds
     * @param storeAccountWrappers
     */
    public AddStoresContainer(List<Id> parentIds, List<AccountWrapper> storeAccountWrappers) {
        this.lastReturnedParentIds = new List<Id>();
        this.parentIds = parentIds;
        this.storeAccountWrappers = storeAccountWrappers;
    }
}