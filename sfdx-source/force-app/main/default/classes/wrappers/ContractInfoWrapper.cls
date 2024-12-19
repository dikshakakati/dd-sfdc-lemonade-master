/**
 * @author Deloitte
 * @date 06/10/2024
 * @description ContractInfoWrapper for oIBaseComponent lightning web component.
 */
public class ContractInfoWrapper {
    @AuraEnabled
    public String associatedBrands;
    @AuraEnabled
    public Id businessAccountId;
    @AuraEnabled
    public Account businessAccountInstance;
    @AuraEnabled
    public Boolean isDrive;
    @AuraEnabled
    public Boolean isEmail;
    @AuraEnabled
    public Boolean isMarketplace;
    @AuraEnabled
    public Boolean isMxOrRepForm;
    @AuraEnabled
    public Boolean isPOS;
    @AuraEnabled
    public Boolean isSelfDelivery;
    @AuraEnabled
    public Boolean isStorefront;
    @AuraEnabled
    public Boolean isTablet;
    @AuraEnabled
    public OIFormPayloadWrapper payload;
    @AuraEnabled
    public String productsOnContract;
    @AuraEnabled
    public Boolean hasTopMXTagAccount;
    @AuraEnabled
    public Boolean hasAlcoholPackage;
    @AuraEnabled
    public String billingCountry;
    @AuraEnabled
    public String billingState;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String zipCode;
    public Set<String> newProductsAddedSet;

    /**
     * @description default constructor to set wrapper class variables.
     */
    public ContractInfoWrapper() {
        this.isDrive = false;
        this.isEmail = false;
        this.isMarketplace = false;
        this.isMxOrRepForm = false;
        this.isPOS = false;
        this.isSelfDelivery = false;
        this.isStorefront = false;
        this.isTablet = false;
        this.hasTopMXTagAccount = false;
    }
}