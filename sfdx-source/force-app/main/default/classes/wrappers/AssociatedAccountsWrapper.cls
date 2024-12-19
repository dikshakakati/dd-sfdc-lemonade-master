/**
 * @author Deloitte
 * @date 17/08/2023
 * @description AssociatedAccountsWrapper for storesOnContract
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class AssociatedAccountsWrapper {
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    public String groupId { get; set; }
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    public String accounts { get; set; }
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    public Id contractId { get; set; }
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    public Boolean isProcessingExistingStores { get; set; }
    /**
     * @description getter/setter for AssociatedAccountsWrapper variable
     */
    public SelectedAndDeselectedEntitlements selectedAndDeselectedEntitlements { get; set; }

    /**
     * @description Constructor
     * @param groupId
     * @param accounts
     * @param contractId
     * @param isProcessingExistingStores
     * @param selectedAndDeselectedEntitlements
     */
    public AssociatedAccountsWrapper(
        String groupId,
        String accounts,
        Id contractId,
        Boolean isProcessingExistingStores,
        SelectedAndDeselectedEntitlements selectedAndDeselectedEntitlements
    ) {
        this.groupId = groupId;
        this.accounts = accounts;
        this.contractId = contractId;
        this.isProcessingExistingStores = isProcessingExistingStores;
        this.selectedAndDeselectedEntitlements = selectedAndDeselectedEntitlements;
    }

    /**
     * @description Wrapper class to show data in correct format
     */
    public class SelectedAndDeselectedEntitlements {
        /**
         * @description getter/setter for selectedAndDeselectedEntitlements variable
         */
        @AuraEnabled
        public List<SelectedPackage> selected { get; set; }
        /**
         * @description getter/setter for selectedAndDeselectedEntitlements variable
         */
        @AuraEnabled
        public List<DeselectedPackage> deselected { get; set; }

        /**
         * @description Constructor
         * @param selected
         * @param deselected
         */
        public SelectedAndDeselectedEntitlements(
            List<SelectedPackage> selected,
            List<DeselectedPackage> deselected
        ) {
            this.selected = selected;
            this.deselected = deselected;
        }
    }
    /**
     * @description SelectedPackage for storesOnContract
     * @param packageId
     * @param packageName
     * @param productSubId
     */
    public class SelectedPackage {
        public String packageId;
        public String packageName;
        public List<ProductSubId> productSubId;
        /**
         * @description Constructor
         * @param packageId
         * @param packageName
         * @param productSubId
         */
        public SelectedPackage(
            String packageId,
            String packageName,
            List<ProductSubId> productSubId
        ) {
            this.packageId = packageId;
            this.packageName = packageName;
            this.productSubId = productSubId;
        }
    }
    /**
     * @description ProductSubId for storesOnContract
     * @param productId
     * @param productName
     */
    public class ProductSubId {
        public String productId;
        public String productName;
        /**
         * @description Constructor
         * @param productId
         * @param productName
         */
        public ProductSubId(String productId, String productName) {
            this.productId = productId;
            this.productName = productName;
        }
    }
    /**
     * @description DeselectedPackage for storesOnContract
     * @param selectedPackageId
     * @param productDeselected
     */

    public class DeselectedPackage {
        public String selectedPackageId;
        public List<String> productDeselected;
        /**
         * @description Constructor
         * @param selectedPackageId
         * @param productDeselected
         */
        public DeselectedPackage(String selectedPackageId, List<String> productDeselected) {
            this.selectedPackageId = selectedPackageId;
            this.productDeselected = productDeselected;
        }
    }
}