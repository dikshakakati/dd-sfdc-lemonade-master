/**
 * @author Deloitte
 * @date 07/03/2024
 * @description OIFormPayloadWrapper for OIUserForm lightning web component.
 */
public class OIFormPayloadWrapper {
    @AuraEnabled
    public String accountName;
    @AuraEnabled
    public Id accountId;
    @AuraEnabled
    public String billingCountry;
    @AuraEnabled
    public String billingState;
    @AuraEnabled
    public String brandName;
    @AuraEnabled
    public Id contractId;
    @AuraEnabled
    public String orderProtocol;
    @AuraEnabled
    public String packageName;
    @AuraEnabled
    public String paymentMethod;
    @AuraEnabled
    public String primaryVertical;
    @AuraEnabled
    public Boolean isSelfDelivery;
    @AuraEnabled
    public Boolean hasAlcoholPackage;
    @AuraEnabled
    public String isActivateCentrallyValue;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param contractId
     */
    public OIFormPayloadWrapper(Id contractId) {
        this.accountName = '';
        this.billingCountry = '';
        this.billingState = '';
        this.brandName = '';
        this.contractId = contractId;
        this.orderProtocol = '';
        this.packageName = '';
        this.paymentMethod = '';
        this.primaryVertical = '';
        this.isSelfDelivery = false;
    }
}