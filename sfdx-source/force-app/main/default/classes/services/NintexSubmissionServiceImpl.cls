/**
 * @description Service Class for Nintex UseCases
 * @author ATG/Bhargavi
 */
public with sharing class NintexSubmissionServiceImpl implements INintexSubmissionService {
    static final String AGREED_TO_SERVICES_ALL = 'All';
    static final String AGREED_TO_SERVICES_DRIVE = 'Drive';
    static final String AGREED_TO_SERVICES_MARKETPLACE = 'Marketplace';
    private static final String LOG_SERVICE = 'Nintex Submission Service';
    private static final String LOG_DOMAIN = 'Sales';

    private enum USE_CASE {
        CHANGE_OF_OWNERSHIP,
        NEW_ADDITIONAL_STORES,
        NEW_FRANCHISE,
        MARKETPLACE_AMENDMENT,
        DRIVE_AMENDMENT,
        INTEGRATED_FRANCHISE,
        DRIVE_FORM_FRANCHISE
    }

    private static Map<String, USE_CASE> useCaseMap = new Map<String, USE_CASE>{
        'Change of Ownership' => USE_CASE.CHANGE_OF_OWNERSHIP,
        'New additional stores' => USE_CASE.NEW_ADDITIONAL_STORES,
        'New Franchise - Unknown' => USE_CASE.NEW_FRANCHISE,
        'Rate Change' => USE_CASE.MARKETPLACE_AMENDMENT,
        'Drive - Amendment' => USE_CASE.DRIVE_AMENDMENT,
        'Integrated Franchise' => USE_CASE.INTEGRATED_FRANCHISE,
        'Drive Form - Franchise' => USE_CASE.DRIVE_FORM_FRANCHISE
    };

    static final String STORE_AGREEMENT = 'Store Agreement';
    static final String FRANCHISE_AGREEMENT = 'Franchise Agreement';
    static final String ACTIVE_STATUS = 'Active';
    static final String PRODUCT_FAMILY_DRIVE = 'Drive';
    static final String PRODUCT_FAMILY_MARKETPLACE = 'Marketplace';
    static final String AGREED_TO_YES = 'Yes';
    static final String AGREED_TO_NO = 'No';

    static final Set<String> PRODUCT_FAMILY_DRIVE_SET = new Set<String>{
        'Drive',
        'Drive Promotion',
        'Voice Ordering'
    };
    private static final String READINESS_CHECK_TRIGGER_SOURCE_NINTEX = 'Nintex';

    /**
     * @description This method is called from Opportunities Services
     * @param opportunities - list of Opportunities
     */
    public static void submitOpportunities(IOpportunities opportunities) {
        if (opportunities == null || opportunities.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        submitOpportunities(uow, opportunities);

        try {
            SBQQ.TriggerControl.disable();
            uow.commitWork();
            SBQQ.TriggerControl.enable();
        } catch (Exception e) {
            Logger.publish(e, LogEntry.SeverityLevel.HIGH);
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_SERVICE,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(e)
            );
        }
    }
    /**
     * @description This method is called to submit the Opportunities for processing
     * @param uow - fflib_ISObjectUnitOfWork Unit of Work
     * @param opportunities - IOpportunities
     */
    public static void submitOpportunities(
        fflib_ISObjectUnitOfWork uow,
        IOpportunities opportunities
    ) {
        if (opportunities == null || opportunities.isEmpty()) {
            return;
        }

        Map<String, IOpportunities> opportunitiesByUseCase = opportunities.getByUseCase();
        Set<String> marketplaceNintexIds = opportunities.getMarketplaceNintexIds();
        IAccounts nintexStoreAccounts = Accounts.newInstance(
            marketplaceNintexIds.isEmpty()
                ? new List<Account>()
                : AccountsSelector.newInstance()
                      .selectStoreAccountsByMarketplaceNintextIds(marketplaceNintexIds)
        );

        for (String useCase : opportunitiesByUseCase.keySet()) {
            if (opportunitiesByUseCase.get(useCase).isEmpty()) {
                continue;
            }
            SubmissionHandler handler = submissionHandlerFactory(uow, useCase);
            Boolean uowCommitted = handler.submit(
                opportunitiesByUseCase.get(useCase),
                nintexStoreAccounts
            );
            if (uowCommitted) {
                uow = Application.UNITOFWORK.newInstance();
            }
        }
    }

    /**
     * @description This method is called from Opportunities Services
     * @param uow - fflib_ISObjectUnitOfWork Unit of Work
     * @param strUseCase - Nintext UserCase
     * @return SubmissionHandler - Abstract class
     */
    private static SubmissionHandler submissionHandlerFactory(
        fflib_ISObjectUnitOfWork uow,
        String strUseCase
    ) {
        USE_CASE useCase = useCaseMap.get(strUseCase);
        if (useCase == null) {
            throw new IllegalArgumentException(
                'Unknown Use Case provided to Nintex Submission Service.  Received: ' + strUseCase
            );
        }

        switch on useCase {
            when CHANGE_OF_OWNERSHIP {
                return new ChangeOfOwnership(uow);
            }
            when NEW_ADDITIONAL_STORES {
                return new AdditionalStores(uow);
            }
            when NEW_FRANCHISE {
                return new NewFranchise(uow);
            }
            when MARKETPLACE_AMENDMENT {
                return new MarketplaceAmendment(uow);
            }
            when DRIVE_AMENDMENT {
                return new DriveAmendment(uow);
            }
            when INTEGRATED_FRANCHISE {
                return new IntegratedFranchise(uow);
            }
            when DRIVE_FORM_FRANCHISE {
                return new DriveFormFranchise(uow);
            }
            when else {
                return null;
            }
        }
    }

    /**
     * @description SubmissionHandler is an abstract class with holds all the methods.
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public abstract class SubmissionHandler {
        public fflib_ISObjectUnitOfWork uow;
        public Map<String, Opportunity> opportunitiesByMarketPlaceNintexId = new Map<String, Opportunity>();
        public Map<String, Opportunity> opportunitiesByDriveNintexId = new Map<String, Opportunity>();
        public Map<Id, Agreement__c> mapFranchiseAgreementsByBusinessAccountId = new Map<Id, Agreement__c>();

        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public SubmissionHandler(fflib_ISObjectUnitOfWork uow) {
            this.uow = uow;
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        @SuppressWarnings('PMD.EmptyStatementBlock')
        public virtual Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            return false;
        }
        /**
         * @description This method is to get the opportunities by Nintex Id.
         * @param opportunities - IOpportunities
         */
        protected void registerOpportunities(IOpportunities opportunities) {
            opportunitiesByMarketPlaceNintexId = opportunities.getByMarketPlaceNintexId();
            opportunitiesByDriveNintexId = opportunities.getByDriveNintexId();
        }
        /**
         * @description This method is to create the Franchise Agreements for the given Opportunities
         * @param opportunities - IOpportunities
         * @param agreedToServices
         */
        protected virtual void registerFranchiseAgreements(
            IOpportunities opportunities,
            String agreedToServices
        ) {
            for (Opportunity objOpportunity : (Opportunity[]) opportunities.getRecords()) {
                Agreement__c agreement = new Agreement__c(
                    Name = objOpportunity.Name.SubStringBefore('-') + ' - ' + FRANCHISE_AGREEMENT,
                    Account__c = objOpportunity.AccountId,
                    Agreed_To_Services__c = agreedToServices,
                    Contract__c = objOpportunity.ContractId,
                    Opportunity__c = objOpportunity.Id,
                    CurrencyIsoCode = objOpportunity.CurrencyIsoCode,
                    Status__c = ACTIVE_STATUS,
                    Type__c = FRANCHISE_AGREEMENT,
                    Start_Date__c = Date.valueOf(objOpportunity.Nintex_Signed_Date__c)
                );
                uow.registerNew(agreement);
                mapFranchiseAgreementsByBusinessAccountId.put(objOpportunity.AccountId, agreement);
            }
        }
        /**
         * @description This method is to create the Store Agreements for the given Opportunities
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @param driveAccounts - Boolean
         * @param isChangeOfOwnerShip - Boolean
         * @param agreedToServices - String
         */
        protected virtual void registerStoreAgreements(
            IOpportunities opportunities,
            IAccounts storeAccounts,
            Boolean driveAccounts,
            Boolean isChangeOfOwnerShip,
            String agreedToServices
        ) {
            if (driveAccounts && opportunitiesByDriveNintexId.isEmpty()) {
                return;
            }
            for (Account objAccount : (Account[]) storeAccounts.getRecords()) {
                Opportunity objOpportunity = driveAccounts
                    ? opportunitiesByDriveNintexId.get(objAccount.Drive_Nintex_Id__c)
                    : opportunitiesByMarketPlaceNintexId.get(objAccount.Marketplace_Nintex_Id__c);
                if (objOpportunity == null) {
                    continue;
                }

                Agreement__c franchiseAgreement = (mapFranchiseAgreementsByBusinessAccountId.containsKey(
                        objOpportunity.AccountId
                    ))
                    ? mapFranchiseAgreementsByBusinessAccountId.get(objOpportunity.AccountId)
                    : null;
                String agreementName = objAccount.Name.substring(
                    0,
                    objAccount.Name.length() > 60 ? 60 : objAccount.Name.length()
                );
                Date startDate = isChangeOfOwnerShip
                    ? getStartDateForStoreAgreements(objAccount)
                    : Date.valueOf(objOpportunity.Nintex_Signed_Date__c);
                Agreement__c storeAgreement = new Agreement__c(
                    Name = agreementName + ' - ' + STORE_AGREEMENT,
                    Account__c = objAccount.Id,
                    Agreed_To_Services__c = agreedToServices,
                    Contract__c = objOpportunity.ContractId,
                    CurrencyIsoCode = objOpportunity.CurrencyIsoCode,
                    Status__c = ACTIVE_STATUS,
                    Type__c = STORE_AGREEMENT,
                    Opportunity__c = objOpportunity.Id,
                    Agreement__c = franchiseAgreement.Id,
                    Start_Date__c = startDate
                );
                uow.registerNew(storeAgreement);
            }
        }
        /**
         * @description This method is to create the Store Agreements for the given Opportunities
         * @param opportunities - IOpportunities
         */
        protected virtual void registerWorkOrderReadinessCheck(IOpportunities opportunities) {
            Set<Id> setAccountIds = opportunities.getAccountIds();
            List<WorkOrder> workOrders = WorkOrdersSelector.newInstance()
                .queryNonCompleteDriveWorkOrdersByAccountIds(setAccountIds);

            WorkOrdersService.runReadinessCheckOnParentWorkOrders(
                new Map<Id, SObject>(workOrders).keySet(),
                READINESS_CHECK_TRIGGER_SOURCE_NINTEX
            );
        }
        /**
         * @description This method is to get the Start Date for the Agreements
         * @param accountObj - Account
         * @return Date
         */
        private Date getStartDateForStoreAgreements(Account accountObj) {
            Date agreementStartDate;
            if (accountObj.Change_of_Ownership_Effective_Date__c != null) {
                agreementStartDate = accountObj.Change_of_Ownership_Effective_Date__c;
            } else {
                agreementStartDate = System.today();
            }
            return agreementStartDate;
        }
    }
    /**
     * @description Inner class extending SubmissionHandler
     */
    public class AdditionalStores extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public AdditionalStores(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_MARKETPLACE);

            IAccounts nintexMarketplaceStoreAccounts = Accounts.newInstance(
                AccountsSelector.newInstance()
                    .selectStoreAccountsByMarketplaceNintextIds(
                        opportunities.getMarketplaceNintexIds()
                    )
            );
            if (
                nintexMarketplaceStoreAccounts != null && !nintexMarketplaceStoreAccounts.isEmpty()
            ) {
                Set<Id> accountIdsWithAgreements = Agreements.newInstance(
                        AgreementsSelector.newInstance()
                            .selectStoreAgreementsByAccountIds(
                                nintexMarketplaceStoreAccounts.getIds()
                            )
                    )
                    .getAccountIds();
                Set<Id> marketplaceAccountIds = new Set<Id>();
                marketplaceAccountIds = nintexMarketplaceStoreAccounts.getIds();
                marketplaceAccountIds.removeAll(accountIdsWithAgreements);
                IAccounts marketplaceStoreAccounts = Accounts.newInstance(
                    AccountsSelector.newInstance().selectById(marketplaceAccountIds)
                );
                registerStoreAgreements(
                    opportunities,
                    marketplaceStoreAccounts,
                    false,
                    false,
                    AGREED_TO_SERVICES_MARKETPLACE
                );
            }
            registerMerchantOptIn(opportunities, storeAccounts, false);
            return false;
        }
        /**
         * @description Creates a map of account Ids to Deselected Services from the Opportunity.
         * If multiple Agreements point to the same account, concatenate the deselected Services, since services are related to accounts.
         * @param accountWithOpp
         * @return Map<Id, Map<String, String>>
         */
        private Map<Id, Map<String, String>> createAccountIdToDeselectedServiceMap(
            Map<Id, Opportunity> accountWithOpp
        ) {
            Map<Id, Map<String, String>> returnMap = new Map<Id, Map<String, String>>();
            Map<Id, String> deSelectedServices = new Map<Id, String>();
            for (Id eachAccountId : accountWithOpp.keySet()) {
                Id accountId = eachAccountId;
                if (
                    String.isNotBlank(accountWithOpp.get(eachAccountId).Packages_with_Products__c)
                ) {
                    Map<String, String> deselectedServicesMap = returnMap.containsKey(accountId)
                        ? returnMap.get(accountId)
                        : new Map<String, String>();
                    MerchantPopUpPackageWrapper wrappers = (MerchantPopUpPackageWrapper) JSON.deserialize(
                        accountWithOpp.get(eachAccountId).Packages_with_Products__c,
                        MerchantPopUpPackageWrapper.class
                    );
                    // Parse the Packages_with_Products__c JSON string and add it to the map
                    for (
                        MerchantPopUpPackageWrapper.packageDetails wrap : wrappers.packageDetails
                    ) {
                        String deselectedMpServices;
                        if (wrap.packageName == AGREED_TO_SERVICES_MARKETPLACE) {
                            deselectedMpServices = deselectedServices.containsKey(accountId)
                                ? deselectedServices.get(accountId) + ';' + wrap.products
                                : wrap.products;
                        }
                        deselectedServicesMap.put(
                            wrap.packageName,
                            wrap.packageName == AGREED_TO_SERVICES_MARKETPLACE
                                ? deselectedMpServices
                                : wrap.products
                        );
                        deselectedServices.put(accountId, deselectedMpServices);
                    }
                    returnMap.put(accountId, deselectedServicesMap);
                } else {
                    returnMap.put(accountId, new Map<String, String>());
                }
            }
            return returnMap;
        }

        /**
         * @description Virtual override method to registerMerchantOptIn.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @param driveAccounts - boolean
         */
        private void registerMerchantOptIn(
            IOpportunities opportunities,
            IAccounts storeAccounts,
            Boolean driveAccounts
        ) {
            Set<Id> accountIds = storeAccounts.getIds();
            Map<Id, Opportunity> accountWithOpp = new Map<Id, Opportunity>();
            for (Account objAccount : (Account[]) storeAccounts.getRecords()) {
                Opportunity objOpportunity = driveAccounts
                    ? opportunitiesByDriveNintexId.get(objAccount.Drive_Nintex_Id__c)
                    : opportunitiesByMarketPlaceNintexId.get(objAccount.Marketplace_Nintex_Id__c);
                accountWithOpp.put(objAccount.Id, objOpportunity);
            }
            Map<Id, Map<String, String>> accountIdDeselectedServicesMap = createAccountIdToDeselectedServiceMap(
                accountWithOpp
            );
            List<Merchant_Service__c> servicesRecords = MerchantSelector.newInstance()
                .queryMerchantRecordsWithAccountIds(accountIds);
            IMerchantServices merchantServices = MerchantServices.newInstance(servicesRecords)
                .filterByProductFamilyNotInSet(PRODUCT_FAMILY_DRIVE_SET)
                .filterDeselectedServices(accountIdDeselectedServicesMap, false);
            uow.registerDirty(merchantServices.getRecords());
        }
    }
    /**
     * @description Inner class extending SubmissionHandler
     */
    public class ChangeOfOwnership extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public ChangeOfOwnership(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_MARKETPLACE);
            registerStoreAgreements(
                opportunities,
                storeAccounts,
                false,
                true,
                AGREED_TO_SERVICES_MARKETPLACE
            );
            expireStoreAgreements(opportunities);
            return false;
        }
        /**
         * @description Virtual override method to expireStoreAgreements.
         * @param opportunities - IOpportunities
         */
        private void expireStoreAgreements(IOpportunities opportunities) {
            if (opportunitiesByMarketPlaceNintexId.isEmpty()) {
                return;
            }
            for (
                Agreement__c storeAgreement : AgreementsSelector.newInstance()
                    .selectAgreementsByMarketplaceNintexIds(
                        opportunitiesByMarketPlaceNintexId.keySet()
                    )
            ) {
                if (String.isBlank(storeAgreement.Account__r.Marketplace_Nintex_Id__c)) {
                    continue;
                }
                //If COO is not blank use that, other wise use today's date.
                Date deactivationDate = storeAgreement.Account__r.Change_of_Ownership_Effective_Date__c !=
                    null
                    ? storeAgreement.Account__r.Change_of_Ownership_Effective_Date__c
                    : system.today();
                //LEM-5808 - Adding fail-safe in-case the deactivation date is less than start date.
                if (deactivationDate <= storeAgreement.Start_Date__c) {
                    storeAgreement.Start_Date__c = deactivationDate - 2;
                }
                storeAgreement.Deactivation_Date__c = deactivationDate - 1;
                if (
                    opportunitiesByMarketPlaceNintexId.get(
                            storeAgreement.Account__r.Marketplace_Nintex_Id__c
                        )
                        .ContractId == storeAgreement.Contract__c
                ) {
                    storeAgreement.Expiring_Agmt_Nintex_COO__c = true;
                }
                uow.registerDirty(storeAgreement);
            }
        }
    }
    /**
     * @description Inner class extending SubmissionHandler
     */
    public class NewFranchise extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public NewFranchise(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            Set<Id> accountIds = new Set<Id>();
            Set<Id> accountIdsWithAgreements = Agreements.newInstance(
                    AgreementsSelector.newInstance()
                        .selectStoreAgreementsByAccountIds(storeAccounts.getIds())
                )
                .getAccountIds();
            accountIds = storeAccounts.getIds();
            accountIds.removeAll(accountIdsWithAgreements);
            IAccounts accountsWithoutAgreements = Accounts.newInstance(
                AccountsSelector.newInstance().selectById(accountIds)
            );
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_MARKETPLACE);
            registerStoreAgreements(
                opportunities,
                accountsWithoutAgreements,
                false,
                false,
                AGREED_TO_SERVICES_MARKETPLACE
            );
            registerMerchantOptIn(opportunities, accountIdsWithAgreements);
            return false;
        }
        /**
         * @description Virtual override method to registerMerchantOptIn.
         * @param opportunities - IOpportunities
         * @param accountIdsWithAgreements - Set of Id's
         */
        private void registerMerchantOptIn(
            IOpportunities opportunities,
            Set<Id> accountIdsWithAgreements
        ) {
            Map<Id, Map<String, String>> accountIdDeselectedServicesMap = opportunities.getAccountIdDeselectedServicesMap();
            List<Merchant_Service__c> servicesRecords = MerchantSelector.newInstance()
                .queryMerchantRecordsWithAccountIds(accountIdsWithAgreements);
            IMerchantServices merchantServices = MerchantServices.newInstance(servicesRecords)
                .filterByProductFamilyNotInSet(PRODUCT_FAMILY_DRIVE_SET)
                .filterDeselectedServices(accountIdDeselectedServicesMap, false);
            uow.registerDirty(merchantServices.getRecords());
        }
    }

    /**
     * @description Inner class extending SubmissionHandler for MarketplaceAmendment LEM-2356
     */
    public class MarketplaceAmendment extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public MarketplaceAmendment(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_MARKETPLACE);
            registerMerchantOptIn(opportunities);
            return false;
        }
        /**
         * @description Set MX Agreed to for Drive Services.
         * @param opportunities - IOpportunities
         */
        private void registerMerchantOptIn(IOpportunities opportunities) {
            Set<Id> setAccountIds = opportunities.getAccountIds();
            Map<Id, Map<String, String>> accountIdDeselectedServicesMap = opportunities.getAccountIdDeselectedServicesMap();
            List<Merchant_Service__c> servicesRecords = MerchantSelector.newInstance()
                .queryMerchantRecordsWithFranchiseParentAccountIds(setAccountIds);
            IMerchantServices merchantServices = MerchantServices.newInstance(servicesRecords)
                .filterByProductFamilyNotInSet(PRODUCT_FAMILY_DRIVE_SET)
                .filterDeselectedServices(accountIdDeselectedServicesMap, true);
            uow.registerDirty(merchantServices.getRecords());
        }
    }

    /**
     * @description Inner class extending SubmissionHandler for DriveAmendment LEM-2671
     */
    public class DriveAmendment extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public DriveAmendment(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_DRIVE);
            registerMerchantOptIn(opportunities);
            //LEM-3088: requirements updated
            return false;
        }
        /**
         * @description Set MX Agreed to for Drive Services.
         * @param opportunities - IOpportunities
         */
        private void registerMerchantOptIn(IOpportunities opportunities) {
            Set<Id> setAccountIds = opportunities.getAccountIds();
            IMerchantServices merchantServices = MerchantServices.newInstance(
                    MerchantSelector.newInstance()
                        .queryMerchantRecordsWithFranchiseParentAccountIds(setAccountIds)
                )
                .filterByProductFamilyInSet(PRODUCT_FAMILY_DRIVE_SET)
                .setMxAgreedToProductValue(AGREED_TO_YES);

            uow.registerDirty(merchantServices.getRecords());
        }
    }

    /**
     * @description Inner class extending SubmissionHandler for IntegratedFranchise LEM-2673
     */
    public class IntegratedFranchise extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public IntegratedFranchise(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_DRIVE);
            registerWorkOrderReadinessCheck(opportunities);
            //This Creates Activation Order Products on the Franchise Parent which is the Business Account.
            return createActivationOrderProductsServices(opportunities);
        }
        /**
         * @description Set MX Agreed to for Drive Services.
         * @param opportunities - IOpportunities
         * @return Boolean uowCommitted
         */
        private Boolean createActivationOrderProductsServices(IOpportunities opportunities) {
            Map<String, Id> accountIdContractIdMap = opportunities.getAccountIdContractIdMap();
            return ActivationOrdersService.createActivationOrdersAndProductsForIntegratedFranchise(
                accountIdContractIdMap,
                uow
            );
        }
    }

    /**
     * @description Inner class extending SubmissionHandler for DriveFormFranchise LEM-2674
     */
    public class DriveFormFranchise extends SubmissionHandler {
        /**
         * @description Constructor
         * @param uow - Unit of Work
         */
        public DriveFormFranchise(fflib_ISObjectUnitOfWork uow) {
            super(uow);
        }
        /**
         * @description Virtual override method to submit.
         * @param opportunities - IOpportunities
         * @param storeAccounts - IAccounts
         * @return Boolean uowCommitted
         */
        public override Boolean submit(IOpportunities opportunities, IAccounts storeAccounts) {
            registerOpportunities(opportunities);
            registerFranchiseAgreements(opportunities, AGREED_TO_SERVICES_DRIVE);

            IAccounts nintexDriveStoreAccounts = Accounts.newInstance(
                AccountsSelector.newInstance()
                    .selectStoreAccountsByDriveNintextIds(opportunities.getDriveNintexIds())
            );
            Set<Id> accountIdsWithAgreements = Agreements.newInstance(
                    AgreementsSelector.newInstance()
                        .selectStoreAgreementsByAccountIds(nintexDriveStoreAccounts.getIds())
                )
                .getAccountIds();
            Set<Id> driveAccountIds = new Set<Id>();
            driveAccountIds = nintexDriveStoreAccounts.getIds();
            driveAccountIds.removeAll(accountIdsWithAgreements);
            IAccounts driveAccountsWithoutAgreements = Accounts.newInstance(
                AccountsSelector.newInstance().selectById(driveAccountIds)
            );
            registerMerchantOptIn(accountIdsWithAgreements);
            registerStoreAgreements(
                opportunities,
                driveAccountsWithoutAgreements,
                true,
                false,
                AGREED_TO_SERVICES_DRIVE
            );
            registerWorkOrderReadinessCheck(opportunities);
            //This Creates Activation Order Products on the Franchise Parent which is the Business Account.
            return createActivationOrderProductsServices(opportunities);
        }
        /**
         * @description Set MX Agreed to for Drive Services.
         * @param opportunities - IOpportunities
         * @return Boolean uowCommitted
         */
        private Boolean createActivationOrderProductsServices(IOpportunities opportunities) {
            Map<String, Id> accountIdContractIdMap = opportunities.getAccountIdContractIdMap();
            return ActivationOrdersService.createActivationOrdersAndProductsForIntegratedFranchise(
                accountIdContractIdMap,
                uow
            );
        }

        /**
         * @description Set MX Agreed to for Drive Services for existing store agreements. LEM-4643
         * @param setAccountIds - Set<Id>
         */
        private void registerMerchantOptIn(Set<Id> setAccountIds) {
            IMerchantServices merchantServices = MerchantServices.newInstance(
                    MerchantSelector.newInstance().queryMerchantRecordsWithAccountIds(setAccountIds)
                )
                .filterByProductFamilyInSet(PRODUCT_FAMILY_DRIVE_SET)
                .setMxAgreedToProductValue(AGREED_TO_YES);

            uow.registerDirty(merchantServices.getRecords());
        }
    }
}