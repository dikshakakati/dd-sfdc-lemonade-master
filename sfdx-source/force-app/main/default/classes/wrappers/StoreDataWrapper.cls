/**
 * @author Deloitte
 * @date 06/03/2024
 * @description StoreDataWrapper for OIUserForm lightning web component.
 */
public class StoreDataWrapper {
    @AuraEnabled
    public Integer storeNumber;
    @AuraEnabled
    public List<OIFieldWrapper> oiFieldWrappers;
    @AuraEnabled
    public Id parentStoreId;
    @AuraEnabled
    public String isStoreForNoRepScenario;


    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param storeNumber
     * @param oiFieldWrappers
     * @param parentStoreId
     */
    public StoreDataWrapper(Integer storeNumber, List<OIFieldWrapper> oiFieldWrappers,Id parentStoreId) {
        this.storeNumber = storeNumber;
        this.oiFieldWrappers = oiFieldWrappers;
        this.parentStoreId = parentStoreId;
    }
}