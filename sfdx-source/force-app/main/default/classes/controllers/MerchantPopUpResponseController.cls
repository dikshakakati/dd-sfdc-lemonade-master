/**
 * @author Deloitte
 * @date 22/07/2022
 * @description Controller class for merchantPopUpResponse lightning web component.
 */
public with sharing class MerchantPopUpResponseController {
    private static final String ENCRYPTION_ALGORITHM = Merchant_Response_Encryption__c.getOrgDefaults()
        .Encryption_Algorithm__c;
    private static final String ENCRYPTION_KEY = Merchant_Response_Encryption__c.getOrgDefaults()
        .Encryption_Key__c;
    private static final Integer LIMIT_VALUE = 1;

    /**
     * @description It query records from Nintex_URL_Mapping__mdt
     * @return Map<String, String>
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> fetchUrls() {
        Map<String, String> allUrlMappings = new Map<String, String>();
        for (
            Nintex_URL_Mapping__mdt eachUrlMapping : NintexUrlMappingSelector.newInstance()
                .getAllValues()
        ) {
            allUrlMappings.put(eachUrlMapping.DeveloperName, eachUrlMapping.URL__c);
        }
        return allUrlMappings;
    }

    /**
     * @description This method used to list fields names from the passed fieldset of the passed object.
     * @param objectApiName
     * @param fieldSetName
     * @return List<String>
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getFields(String objectApiName, String fieldSetName) {
        List<String> fields = new List<String>();
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if (!globalDescribe.containsKey(objectApiName)) {
            return fields;
        }
        Schema.SObjectType sObjectTypeObject = globalDescribe.get(objectApiName);
        Schema.FieldSet fieldSetObject = sObjectTypeObject.getDescribe()
            .FieldSets.getMap()
            .get(fieldSetName);
        if (fieldSetObject == null) {
            return fields;
        }
        for (Schema.FieldSetMember eachFieldSetMember : fieldSetObject.getFields()) {
            fields.add(eachFieldSetMember.getFieldPath());
        }
        return fields;
    }

    /**
     * @description This method used to fetch Franchise Accounts related to the selected Corporate Merchant Account and franchise must have a franchise agreement with the Contract.
     * @param corporateAccountId
     * @param externalIdSource
     * @param contractId
     * @return List<Account_Relationship__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getFranchiseAccounts(
        String corporateAccountId,
        String externalIdSource,
        String contractId
    ) {
        return AccountsSelector.newInstance()
            .selectStoreAccountsByParentIds(
                new Set<String>{ corporateAccountId },
                externalIdSource,
                contractId
            );
    }

    /**
     * @description This method used to fetch Corporate child Accounts related to the selected Corporate Merchant Account.
     * @param corporateAccountId
     * @return List<Account>
     */
    @AuraEnabled(cacheable=true)
    public static List<Account> getCorporateAccounts(String corporateAccountId) {
        return AccountsSelector.newInstance()
            .selectAllChildCorporateAccountsWithParent(new Set<String>{ corporateAccountId });
    }

    /**
     * @description This method used to create 'Negotiating' Opportunities for all the Accounts associated
     * with the Contract Corporate Account under the relation 'Franchise'.
     * @param selectedFranchiseAccountIds
     * @param currenctContractId
     * @param franchiseUseCase
     * @param daysToAdd
     */
    @AuraEnabled
    public static void createOpportunities(
        List<String> selectedFranchiseAccountIds,
        String currenctContractId,
        String franchiseUseCase,
        String daysToAdd
    ) {
        if (!selectedFranchiseAccountIds.isEmpty()) {
            OpportunitiesService.createOpportunitiesOnFranchiseAccounts(
                selectedFranchiseAccountIds,
                currenctContractId,
                franchiseUseCase,
                daysToAdd
            );
        }
    }

    /**
     * @description This method used to check if the Contract has any CoD Subscriptions.
     * @param contractId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean getSubscriptionsWithCoDProduct(String contractId) {
        if (
            !SubscriptionSelector.newInstance()
                .selectByContractAndCoDProduct(new Set<String>{ contractId })
                .isEmpty()
        ) {
            return true;
        }
        return false;
    }

    /**
     * @description This method is used to fetch all Contract Brand Associations for the current
     * Contract.
     * @param contractId
     * @return List<Contract_Brand_Associations>
     */
    @AuraEnabled
    public static List<Contract_Brand_Association__c> getContractBrandAssociations(
        String contractId
    ) {
        return ContractBrandAssociationsSelector.newInstance()
            .selectByContracts(new Set<String>{ contractId });
    }

    /**
     * @description This method used to check if the Contract has any Alcohol Subscriptions.
     * @param contractId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean hasAlcoholProductsSubscription(String contractId) {
        if (
            !SubscriptionSelector.newInstance()
                .selectCorporateSubscriptionsByContractIdsAndAlcoholProducts(
                    new Set<String>{ contractId }
                )
                .isEmpty()
        ) {
            return true;
        }
        return false;
    }

    /**
     * @description This method used to check if the Contract has any Drive Subscriptions.
     * @param contractId
     * @return List<SBQQ__Subscription__c>
     */
    @AuraEnabled
    public static List<SBQQ__Subscription__c> getDriveSubscriptions(String contractId) {
        return SubscriptionSelector.newInstance()
            .selectByContractAndDriveProduct(new Set<String>{ contractId });
    }

    /**
     * @description This method used to check if the Contract has any Subscriptions with following products( Delivery, Pickup, DashPass).
     * @param contractId
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getSubscriptionsForOptionalProductSelection(String contractId) {
        Set<String> products = new Set<String>();
        for (
            SBQQ__Subscription__c subscription : SubscriptionSelector.newInstance()
                .selectByContractAndProducts(new Set<String>{ contractId })
        ) {
            products.add(subscription.SBQQ__ProductName__c);
        }
        List<String> productList = new List<String>(products);
        return productList;
    }

    /**
     * @description This method used to check if the Contract has any Subscriptions with following packagess(Storefront).
     * @param contractId
     * @return List<String>
     */
    @AuraEnabled
    public static List<String> getSubscriptionsForOptionalPackageSelection(String contractId) {
        Set<String> packages = new Set<String>();
        for (
            SBQQ__Subscription__c subscription : SubscriptionSelector.newInstance()
                .selectByContractAndPackages(new Set<String>{ contractId })
        ) {
            packages.add(subscription.Package__c);
        }
        List<String> packageList = new List<String>(packages);
        return packageList;
    }

    /**
     * @description It is used to encrypt Salesforce Id to generate secure Nintex url.
     * @param merchantPopUpResponseId
     * @return String
     */
    @AuraEnabled
    public static String getEncryptedId(Id merchantPopUpResponseId) {
        return EncodingUtil.convertToHex(
            crypto.generateMac(
                ENCRYPTION_ALGORITHM,
                Blob.valueOf(merchantPopUpResponseId),
                Blob.valueOf(ENCRYPTION_KEY)
            )
        );
    }
    /**
     * @description It is used to encrypt Salesforce Id to generate secure Nintex url.
     * @param paymentAccountIds
     * @return String
     */
    @InvocableMethod(label='getEncryptedId')
    public static List<String> getEncryptedId(List<Id> paymentAccountIds) {
        Id paymentId = paymentAccountIds[0];
        List<String> encryptedRecordIds = new List<String>();
        String encryptedRecordId = EncodingUtil.convertToHex(
            crypto.generateMac(
                ENCRYPTION_ALGORITHM,
                Blob.valueOf(paymentId),
                Blob.valueOf(ENCRYPTION_KEY)
            )
        );
        encryptedRecordIds.add(encryptedRecordId);
        return encryptedRecordIds;
    }

    /**
     * @description It is used to get Nintex_COO_Store_No_Match_Exception_Log queue member emails in a string.
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getEmailsOfQueueMembers() {
        String queueName = 'Nintex_COO_Store_No_Match_Exception_Log';
        String emails = '';
        Set<Id> userIds = new Set<Id>();
        for (
            GroupMember groupMemberRecord : GroupMembersSelector.newInstance()
                .selectGroupMembersByQueueName(queueName)
        ) {
            userIds.add(groupMemberRecord.UserOrGroupId);
        }
        if (userIds.size() > 0) {
            for (User userRecord : UsersSelector.newInstance().selectUsersById(userIds)) {
                emails = emails + ';' + userRecord.Email;
            }
        }
        return emails;
    }

    /**
     * @description It is used to get the Active Franchise Agreements on the Contract.
     * @param contractIds
     * @return List<Agreement__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Agreement__c> getActiveFranchiseAgreementOnContract(List<Id> contractIds) {
        return AgreementsSelector.newInstance()
            .selectActiveFranchiseAgreementsByContractIds(new Set<Id>(contractIds), LIMIT_VALUE);
    }
    /**
     * @description This method used to fetch Business Vertical for Marketplace Merchant Pop-up.
     * @return List<Business_Vertical__c>
     */
    @AuraEnabled(cacheable=true)
    public static List<Business_Vertical__c> getBusinessVerticals() {
        return BusinessVerticalsSelector.newInstance().selectBusinessVerticalRecords();
    }

    /**
     * @description This method used to fetch Menu UI Type related to the selected Business Vertical.
     * @param businessVerticalId
     * @return String
     */
    @AuraEnabled(cacheable=true)
    public static String getMenuUITypeByBusinessVerticals(Id businessVerticalId) {
        return BusinessVerticalsSelector.newInstance()
            .selectMenuUITypeByBusinessVerticalIds(businessVerticalId)
            .Menu_UI_Type__c;
    }
}