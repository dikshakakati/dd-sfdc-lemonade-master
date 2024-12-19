/**
 * @description The BrandWrapper class represents a wrapper class for handling brand, related biz refs data.
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public class BrandWrapper {
    /**
     * @description String brandname.
     */
    public String brandName{get; set;}
    /**
    * @description String priceRange.
     */
    public String priceRange{get; set;}
    /**
     * @description String brandId.
     */
    public String brandId{get; set;}
    /**
     * @description String brandType.
     */
    public String brandType{get; set;}
    /**
     * @description String createBrandAssociations.
     */
    public Boolean createBrandAssociations{get; set;}
    /**
     * @description String brandAssociationId.
     */
    public String brandAssociationId{get; set;}
    /**
     * @description String opportunityId.
     */
    // public String opportunityId{get; set;}

     /**
     * @description String recordId.
     */
    public String recordId{get; set;}

    /**
     * @description String createdSource.
     */
    public String createdSource{get; set;}
    /**
     * @description String accountId.
     */
    public String accountId{get; set;}
    /**
     * @description String currencyOfAccount.
     */
    public String currencyOfAccount{get; set;}
    /**
     * @description String bizRefList.
     */
    public List<BizRef> bizRefList{get; set;}

    /**
     * @description The BizRef class represents a business reference.
     */
    public class BizRef {
        /**
        * @description String businessName.
        */
        public String businessName{get; set;}
         /**
        * @description String businessVerticalId.
        */
        public String businessVerticalId{get; set;}
         /**
        * @description String business group id.
        */
        public String businessGroupId{get; set;}
        /**
        * @description String Selling country code.
        */
        public String sellingCountryCode{get; set;}
    }

    /**
     * @description The CaseWithListOfBrandAndBizRefs class represents a case with a list of brand and business references.
     */
    public class CaseWithListOfBrandAndBizRefs{
         /**
        * @description Case caseRecord.
        */
        @AuraEnabled
        public Case caseRecord{get; set;}
         /**
        * @description List<BrandAndBizRefs> brandAndBizRefsList.
        */
        @AuraEnabled
        public List<BrandAndBizRefs> brandAndBizRefsList{get; set;}

        /**
         * @description Constructs a new CaseWithListOfBrandAndBizRefs object.
         */
        public CaseWithListOfBrandAndBizRefs() {
            brandAndBizRefsList = new List<BrandAndBizRefs>();
        }
    }

    /**
     * @description The BrandAndBizRefs class represents a brand with a list of business references.
     */
    public class BrandAndBizRefs {
        /**
         * @description Brand__c.
         */
        @AuraEnabled
        public Brand__c brand{get; set;}
        /**
         * @description List<Business_Reference__c>.
         */
        @AuraEnabled
        public List<Business_Reference__c> bizRefs{get; set;}

        /**
         * @description Constructs a new BrandAndBizRefs object.
         * @param brand The brand object.
         * @param bizRefs The list of business references.
         */
        public BrandAndBizRefs(Brand__c brand, List<Business_Reference__c> bizRefs) {
            this.brand = brand;
            this.bizRefs = bizRefs;
        }
    }

    /**
     * @description Returns a list of brands to insert.
     * @param brandAndBizRefsList The list of BrandAndBizRefs objects.
     * @param sObjectName The name of the sObject.
     * @return A list of Brand__c objects.
     */
    public static List<Brand__c> getAllBrandsToInsert(List<BrandAndBizRefs> brandAndBizRefsList, String sObjectName) {
        List<Brand__c> brands = new List<Brand__c>();
        for(BrandAndBizRefs b : brandAndBizRefsList) {
            if(b.brand.Id == null){
                b.brand.Source__c = sObjectName;
                brands.add(b.brand);
            }
            else{
                b.brand.Source__c = null;
            }
        }
        return brands;
    }

    /**
     * @description Returns a list of business references to insert.
     * @param brandAndBizRefsList The list of BrandAndBizRefs objects.
     * @return A list of Business_Reference__c objects.
     */
    public static List<Business_Reference__c> getAllBizRefsToInsert(List<BrandAndBizRefs> brandAndBizRefsList) {
        List<Business_Reference__c> bizRefs = new List<Business_Reference__c>();
        for(BrandAndBizRefs b : brandAndBizRefsList) {
            for(Business_Reference__c br : b.bizRefs) {
                br.Brand__c = b.brand.Id;
                bizRefs.add(br);
            }
        }
        return bizRefs;
    }


    /**
     * @description Returns a set of brand association IDs.
     * @param brandWrapperList The list of BrandWrapper objects.
     * @return A set of brand association IDs.
     */
    public static Set<Id> getAllBrandIds(List<BrandAndBizRefs> brandWrapperList) {
        Set<Id> brandSet = new Set<Id>();
        for(BrandAndBizRefs wrapper : brandWrapperList) {
                if(wrapper.brand.Id != null){
                    brandSet.add(wrapper.brand.Id);
                }
            }
        return brandSet;
    }

    /**
     * @description Returns a set of brand association IDs.
     * @param brandWrapperList The list of BrandWrapper objects.
     * @return A set of brand association IDs.
     */
    public static Set<Id> getAllBrandAssociationIds(List<BrandWrapper> brandWrapperList) {
        Set<Id> brandAsscSet = new Set<Id>();
        for(BrandWrapper b : brandWrapperList) {
            if(b.brandAssociationId != null && !b.createBrandAssociations){
                brandAsscSet.add(b.brandAssociationId);
            }
        }
        return brandAsscSet;
    }

    /**
     * @description Returns the URLs of business references.
     * @param brandAndBizRefsList The list of BrandAndBizRefs objects.
     * @return The URLs of business references.
     */
    public static String getUrlsOfBizRefs(List<BrandAndBizRefs> brandAndBizRefsList){
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
         String urls = '';
         for(BrandAndBizRefs b : brandAndBizRefsList) {
            for(Business_Reference__c br : b.bizRefs) {
                if(br.Id != null){
                    urls += baseUrl + '/' + br.Id + '\n';
                }
            }
        }
        return urls;
    }

}