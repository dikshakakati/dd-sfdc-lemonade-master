/**
 * @description Domain Class for Opportunity Object
 * @author Deloitte
 */
@SuppressWarnings(
    'PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ExcessiveClassLength, PMD.NcssTypeCount'
)
public inherited sharing class Opportunities extends fflib_SObjects implements IOpportunities {
    private static final String ACCOUNT_SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String ACCOUNT_SEGMENT_MID_MARKET = 'Mid-Market';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    private static final List<String> ELIGIBLE_ACCOUNT_SEGMENTS = new List<String>{
        ACCOUNT_SEGMENT_ENTERPRISE,
        ACCOUNT_SEGMENT_MID_MARKET
    };
    private static final String AGGREGATE_BUSINESSACCOUNTNAME_FIELD_ALIAS = 'businessAccountName';
    private static final String AGGREGATE_BRANDASSOCIATION_COUNT_ALIAS = 'brandAssociationsCount';
    private static final String AGGREGATE_BRANDNAME_FIELD_ALIAS = 'brandAssociationName';
    static final String ALLOW_OPPORTUNITY_REPARENTING = 'Allow_Non_Owner_Opportunity_Reparenting';
    static final String BOOLEAN_TRUE = 'true';
    private static final Id BUSINESS_RECORD_TYPE_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Business')
        .getRecordTypeId();
    private static final String COMMA = ',';
    private static final String DISCOVERY = 'Discovery';
    private static final String FORWARDSLASH_R = '\r';
    private static final String FORWARDSLASH_N = '\n';
    private static final String FORWARDSLASH_R_N = '\r\n';
    private static final String CONTACT_SOBJECT_TYPE = 'Contact';
    private static final String LOG_FIELD_MAPPING_ERROR = 'Lead to Store Account conversion field mapping is empty.';
    static final String BYPASS_OPPORTUNITY_VALIDATION_RULES = 'Bypass_Opportunity_Validation_Rules';
    static final String CLOSED_LOST = 'Closed Lost';
    static final String CLOSEDWON_STAGE = 'Closed Won';
    static final String COLON_WITH_UNTRIMMED_SPACE = ': ';
    static final Set<String> CONTRACT_CORRECTION = new Set<String>{
        'Contract Correction',
        'Contract Correction - Amendment'
    };
    static final String CONTRACT_SIGNATORY_ROLE = 'Contract Signatory';
    static final String CONTRACT_SPLIT_CATEGORY_CORE = 'Core';
    static final String CONTRACTING_STAGE = 'Contracting';
    static final String DEAL_TYPE = 'Self-Serve';
    static final String DECISION_MAKER_ROLE = 'Decision Maker';
    static final String EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION = 'EVENT_TOPIC_OPPORTUNITY_TEAM_MEMBER_CREATION';
    static final String EXISTING_TYPE = 'Existing';
    private static final String FRANCHISE = 'Franchisee';
    static final String HYPHEN_WITH_UNTRIMMED_SPACE = ' - ';
    static final String HYPHEN_WITH_RIGHT_TRIM = ' -';
    static final String HYPHEN_WITH_LEFT_TRIM = '- ';
    static final String LACK_OF_ACTIVITY = 'Lack of Activity';
    static final String LOG_DOMAIN = 'Opportunities';
    static final String LOG_STAMP_DECK_RANK_AND_MEDAL_RANK_ON_CLOSED = 'Stamp deck rank and medal rank values on Closed Opportunities';
    private static final String LOG_UPDATE_SOBJECT_BASED_ON_OPPORTUNITY = 'Updation of fields on sObjects based on Opportunities';
    static final String LOST_ADDITIONAL_REASON = 'This opportunity has been systematically moved from Stalled to Closed Lost due to inactivity.';
    static final String NEGOTIATING_STAGE = 'Negotiating';
    static final String NEW_TYPE = 'New';
    static final String SUB_TYPE_NET_NEW_PARTNER = 'Net New Partner';
    static final String PITCHING_STAGE = 'Pitching';
    static final String PROSPECTING_STAGE = 'Prospecting';
    static final String QUARTER_ONE = 'Q1';
    static final String QUARTER_TWO = 'Q2';
    static final String QUARTER_THREE = 'Q3';
    static final String QUARTER_FOUR = 'Q4';
    static final String QUARTER = 'Q';
    static final String SOURCE_NINTEX = 'Nintex';
    static final String SOURCE_PRODUCT = 'Product';
    static final String STALLED_STAGE_NAME = 'Stalled';
    static final String SUB_TYPE = 'Ads & Promos';
    static final String VSP_RECOMMENDATION = 'VSP Recommendation';
    static final String MARKETPLACE = 'Marketplace';
    static final String OPPORTUNITY_SOBJECT = 'Opportunity';
    static final String DEAL_TYPE_STANDARD = 'Standard';
    private static final String HYPHEN = '-';
    private static final String VSP = '-VSP:';
    private static final Integer OPPORTUNITY_NAME_LENGTH = 120;
    private static final Set<String> SOURCES_TO_SKIP_VALIDATION = new Set<String>{
        SOURCE_NINTEX,
        SOURCE_PRODUCT
    };
    fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();
    private static final String EVENT_STATUS_HELD = 'Event Held';
    private static final String SUB_TYPE_NEW_STORE_EXPANSION = 'New Store Expansion';
    private static final String GENERIC_WORK_ORDER_CREATION = 'WORK_ORDER_GENERATION';
    private static final String SUB_TYPE_UPGRADE = 'Upgrade';
    private static final String SOURCE_MX_PORTAL = 'Mx Portal';

    /**
     * @description This method is to return the IOpportunities interface
     * @param List<Opportunity> - list of Opportunities
     * @param recordList - Opportunities record list
     * @return IOpportunities - Returns IOpportunities Interface
     */
    public static IOpportunities newInstance(List<Opportunity> recordList) {
        return (IOpportunities) Application.Domain.newInstance(recordList);
    }
    /**
     * @description default constructor for the class
     * @param sObjectList
     * @param Schema.Opportunity.SObjectType
     */
    public Opportunities(List<Opportunity> sObjectList) {
        super(sObjectList, Schema.Opportunity.SObjectType);
    }

    /**
     * @description Getter to return map of Opportunities grouped by Opportunity Id
     * @return Map of Opportunities grouped by Id
     */
    public Map<Id, Opportunity> getById() {
        return new Map<Id, Opportunity>((Opportunity[]) getRecords());
    }

    /**
     * @description Getter to return map of Opportunities grouped by Marketplace Nintex Id
     * @return Map of Opportunities grouped by MarketPlace Nintex Id
     */
    public Map<String, Opportunity> getByMarketPlaceNintexId() {
        Map<String, Opportunity> mapRecords = new Map<String, Opportunity>();
        for (
            Opportunity obj : (Opportunity[]) getRecordsWithNotBlankFieldValues(
                Opportunity.Marketplace_Nintex_Id__c
            )
        ) {
            if (
                String.isNotBlank(obj.Nintex_Use_Case__c) &&
                obj.ContractId != null &&
                obj.Nintex_Signed_Date__c != null
            ) {
                mapRecords.put(obj.Marketplace_Nintex_Id__c, obj);
            }
        }
        return mapRecords;
    }
    /**
     * @description Getter to return map of Opportunities grouped by Drive Nintex Id
     * @return Map of Opportunities grouped by Drive Nintex Id
     */
    public Map<String, Opportunity> getByDriveNintexId() {
        Map<String, Opportunity> mapRecords = new Map<String, Opportunity>();
        for (
            Opportunity obj : (Opportunity[]) getRecordsWithNotBlankFieldValues(
                Opportunity.Drive_Nintex_Id__c
            )
        ) {
            if (
                String.isNotBlank(obj.Nintex_Use_Case__c) &&
                obj.ContractId != null &&
                obj.Nintex_Signed_Date__c != null
            ) {
                mapRecords.put(obj.Drive_Nintex_Id__c, obj);
            }
        }
        return mapRecords;
    }
    /**
     * @description Getter to return map of Opportunities grouped by Nintex Use Case
     * @return Map of Opportunities grouped by Nintex Use Case
     */
    public Map<String, IOpportunities> getByUseCase() {
        Map<String, Opportunity> mapRecords = new Map<String, Opportunity>();
        Map<String, IOpportunities> mapDomains = new Map<String, IOpportunities>();
        for (Opportunity obj : (Opportunity[]) getRecords()) {
            if (!mapRecords.containsKey(obj.Nintex_Use_Case__c)) {
                mapRecords.put(obj.Nintex_Use_Case__c, obj);
            }
        }
        for (String useCase : mapRecords.keySet()) {
            mapDomains.put(
                useCase,
                new Opportunities(new List<Opportunity>{ mapRecords.get(useCase) })
            );
        }
        return mapDomains;
    }

    /**
     * @description Getter to return set of Opportunities contract ids
     * @return Set of contract ids
     */
    public Set<Id> getContractIds() {
        Set<Id> results = new Set<Id>();
        for (Opportunity obj : (Opportunity[]) getRecords()) {
            results.add(obj.ContractId);
        }
        results.remove(null);
        return results;
    }

    /**
     * @description Getter to return set of Opportunities contract ids
     * @return Set of contract ids
     */
    public Set<Id> getAccountIds() {
        Set<Id> results = new Set<Id>();
        for (Opportunity obj : (Opportunity[]) getRecords()) {
            results.add(obj.AccountId);
        }
        results.remove(null);
        return results;
    }

    /**
     * @description Getter to return Map of Opportunities Account Id to Contract Id
     * @return Map<String, Id>
     */
    public Map<String, Id> getAccountIdContractIdMap() {
        Map<String, Id> results = new Map<String, Id>();
        for (
            Opportunity obj : (Opportunity[]) getRecordsWithAllNotBlankFieldValues(
                new Set<Schema.SObjectField>{ Opportunity.AccountId, Opportunity.ContractId }
            )
        ) {
            //Need unique Id if the same account is passed for 2 different Opportunities
            String uniqueAccountValue =
                String.valueof(obj.AccountId) +
                '-' +
                String.valueof(obj.Id);
            results.put(uniqueAccountValue, obj.ContractId);
        }
        return results;
    }

    /**
     * @description Wrapper class to hold package details along with products.
     * This class represents a wrapper to hold package details along with products.
     */
    public class PackageWithProductWrapper {
        /**
         * @description The name of the package.
         * This field represents the name of the package.
         */
        public String packageName { get; set; }
        /**
         * @description The list of products associated with the package.
         * This field represents the list of products associated with the package.
         */
        public List<String> products { get; set; }

        /**
         * @description Constructor to initialize the PackageWithProductWrapper with package name and products.
         * @param packageName The name of the package.
         * @param products The list of products associated with the package.
         * @pmd.description This constructor initializes the PackageWithProductWrapper with the provided package name and products list.
         */
        public PackageWithProductWrapper(String packageName, List<String> products) {
            this.packageName = packageName;
            this.products = products;
        }
    }

    /**
     * @description Getter to return Map of Opportunities Account Id to Deselected MarketPlace Services
     * @JIRA# LEM-13995
     * @return Map<Id, Map<String, String>>
     */
    public Map<Id, Map<String, String>> getAccountIdDeselectedServicesMap() {
        Map<Id, Map<String, String>> returnMap = new Map<Id, Map<String, String>>();
        for (
            Opportunity obj : (Opportunity[]) getRecordsWithAllNotBlankFieldValues(
                new Set<Schema.SObjectField>{
                    Opportunity.AccountId,
                    Opportunity.Packages_with_Products__c
                }
            )
        ) {
            Id accountId = obj.AccountId;
            if (String.isNotBlank(obj.Packages_with_Products__c)) {
                Map<String, String> deselectedServicesMap = new Map<String, String>();
                MerchantPopUpPackageWrapper wrappers = (MerchantPopUpPackageWrapper) JSON.deserialize(
                    obj.Packages_with_Products__c,
                    MerchantPopUpPackageWrapper.class
                );
                // Parse the Packages_with_Products__c JSON string and add it to the map
                for (MerchantPopUpPackageWrapper.packageDetails wrap : wrappers.packageDetails) {
                    String deselectedMpServices;
                    Map<Id, String> deSelectedServices = new Map<Id, String>();
                    if (wrap.packageName == MARKETPLACE) {
                        deselectedMpServices = deselectedServices.containsKey(obj.AccountId)
                            ? deselectedServices.get(accountId)
                            : '';
                        deselectedMpServices += ',' + wrap.products;
                        deselectedServices.put(accountId, deselectedMpServices);
                    }
                    deselectedServicesMap.put(
                        wrap.packageName,
                        wrap.packageName == MARKETPLACE ? deselectedMpServices : wrap.products
                    );
                }
                returnMap.put(accountId, deselectedServicesMap);
            } else {
                returnMap.put(accountId, new Map<String, String>());
            }
        }

        return returnMap;
    }

    /**
     * @description Getter to return set of Opportunities nintex ids
     * @return Set of nintex ids
     */
    public Set<String> getDriveNintexIds() {
        Set<String> results = new Set<String>();
        for (Opportunity obj : (Opportunity[]) getRecords()) {
            results.add(obj.Drive_Nintex_Id__c);
        }
        results.remove(null);
        return results;
    }
    /**
     * @description Getter to return set of Opportunities nintex ids
     * @return Set of nintex ids
     */
    public Set<String> getMarketplaceNintexIds() {
        Set<String> results = new Set<String>();
        for (Opportunity obj : (Opportunity[]) getRecords()) {
            results.add(obj.Marketplace_Nintex_Id__c);
        }
        results.remove(null);
        return results;
    }

    /**
     * @description Assigning Opportunity Name on Name Change or Opportunity Insert
     */
    public void assignNameOnInsertOrNameUpdate() {
        List<Opportunity> changedOpportunities = new List<Opportunity>(getOpportunities());
        if (changedOpportunities.isEmpty()) {
            return;
        }
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectByOpportunity(changedOpportunities)
        );
        for (Opportunity eachOpportunity : changedOpportunities) {
            if (eachOpportunity.Source__c == VSP_RECOMMENDATION) {
                continue;
            }
            String userInput = '';
            //Null check added to eliminate Test Class failures where Opportunities are initialized without a Name
            if (eachOpportunity.Name != null) {
                if (String.isNotBlank(eachOpportunity.LeadSource)) {
                    eachOpportunity.Name = eachOpportunity.Name.removeEnd('-');
                }
                userInput =
                    COLON_WITH_UNTRIMMED_SPACE +
                    eachOpportunity.Name.substring(
                        0,
                        eachOpportunity.Name.length() > 40 ? 40 : eachOpportunity.Name.length()
                    );
            }

            if (eachOpportunity.AccountId != null) {
                formulateName(
                    eachOpportunity,
                    accountIdToAccountMap.get(eachOpportunity.AccountId),
                    50
                );
                eachOpportunity.Name += userInput;
            }
        }
    }

    /**
     * @description Update VSP Opportunity Name When Sub Type/Name updated
     * @param existingOpportunities
     */
    public void vspOpportunityNameUpdate(Map<Id, Opportunity> existingOpportunities) {
        List<Opportunity> changedOpportunities = new List<Opportunity>(getOpportunities());
        if (existingOpportunities.isEmpty()) {
            return;
        }
        Set<Id> vspOpportunityIds = new Set<Id>();
        Map<Id, String> opportunityIdToSolutionName = new Map<Id, String>();
        for (Opportunity eachOpportunity : changedOpportunities) {
            if (
                eachOpportunity.Source__c == VSP_RECOMMENDATION &&
                ((eachOpportunity.Opportunity_Sub_Type__c !=
                existingOpportunities.get(eachOpportunity.Id).Opportunity_Sub_Type__c) ||
                eachOpportunity.Name != existingOpportunities.get(eachOpportunity.Id).Name)
            ) {
                vspOpportunityIds.add(eachOpportunity.Id);
            }
        }
        Map<Id, Account> accountIdToAccount = new Map<Id, Account>(
            AccountsSelector.newInstance().selectByOpportunity(changedOpportunities)
        );
        if (vspOpportunityIds.size() > 0) {
            updateOpportunityName(
                vspOpportunityIds,
                opportunityIdToSolutionName,
                changedOpportunities,
                existingOpportunities,
                accountIdToAccount
            );
        }
    }

    /**
     * @description Update VSP Opportunity Name
     * @param vspOpportunityIds
     * @param opportunityIdToSolutionName
     * @param changedOpportunities
     * @param existingOpportunities
     * @param accountIdToAccount
     */
    private void updateOpportunityName(
        Set<Id> vspOpportunityIds,
        Map<Id, String> opportunityIdToSolutionName,
        List<Opportunity> changedOpportunities,
        Map<Id, Opportunity> existingOpportunities,
        Map<Id, Account> accountIdToAccount
    ) {
        for (
            Product_Insights__c eachProductInsight : ProductInsightsSelector.newInstance()
                .selectProductInsightsByOpportunityIds(vspOpportunityIds)
        ) {
            if (opportunityIdToSolutionName.containsKey(eachProductInsight.Opportunity__c)) {
                opportunityIdToSolutionName.put(
                    eachProductInsight.Opportunity__c,
                    opportunityIdToSolutionName.get(eachProductInsight.Opportunity__c) +
                    '-' +
                    eachProductInsight.Product__r.name
                );
            } else {
                opportunityIdToSolutionName.put(
                    eachProductInsight.Opportunity__c,
                    eachProductInsight.Product__r.name
                );
            }
        }
        for (Opportunity eachOpportunity : changedOpportunities) {
            if (
                eachOpportunity.Source__c == VSP_RECOMMENDATION &&
                opportunityIdToSolutionName.containsKey(eachOpportunity.Id) &&
                eachOpportunity.AccountId != null &&
                (((existingOpportunities.get(eachOpportunity.Id)).Name) !=
                (accountIdToAccount.get(eachOpportunity.AccountId)).Name)
            ) {
                if (
                    (eachOpportunity.Opportunity_Sub_Type__c !=
                    (existingOpportunities.get(eachOpportunity.Id)).Opportunity_Sub_Type__c) &&
                    eachOpportunity.Name == (existingOpportunities.get(eachOpportunity.Id)).Name
                ) {
                    formulateName(
                        eachOpportunity,
                        accountIdToAccount.get(eachOpportunity.AccountId),
                        40
                    );
                    eachOpportunity.Name += VSP;
                    eachOpportunity.Name += (existingOpportunities.get(eachOpportunity.Id).Name)
                        .substring(
                            (existingOpportunities.get(eachOpportunity.Id).Name).indexOf(':') + 1,
                            (existingOpportunities.get(eachOpportunity.Id).Name).length()
                        );
                } else {
                    string updatedOpportunityNameFromUI = eachOpportunity.Name;
                    formulateName(
                        eachOpportunity,
                        accountIdToAccount.get(eachOpportunity.AccountId),
                        40
                    );
                    eachOpportunity.Name += VSP + updatedOpportunityNameFromUI;
                }
            }
        }
    }

    /**
     * @description Assigning Opportunity Name on Component Update
     * @param existingOpportunities
     */
    public void assignNameOnNamingComponentsUpdates(Map<Id, Opportunity> existingOpportunities) {
        List<Opportunity> changedOpportunityList = new List<Opportunity>(getOpportunities());
        if (changedOpportunityList.isEmpty()) {
            return;
        }
        //Invoking Accounts Selector to query Parent accounts of all opportunities being inserted
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectByOpportunity(changedOpportunityList)
        );
        for (Opportunity eachOpportunity : changedOpportunityList) {
            if (eachOpportunity.Source__c == VSP_RECOMMENDATION) {
                continue;
            }
            Opportunity oldOpportunity = existingOpportunities.get(eachOpportunity.Id);
            String opportunityNameSubstring = quarterAndFiscalYearEvaluation(
                oldOpportunity.CloseDate
            );
            opportunityNameSubstring += oldOpportunity.Opportunity_Sub_Type__c != null
                ? HYPHEN_WITH_UNTRIMMED_SPACE +
                  oldOpportunity.Opportunity_Sub_Type__c +
                  COLON_WITH_UNTRIMMED_SPACE
                : '';
            Integer characterIndex = eachOpportunity.Name.indexOf(opportunityNameSubstring);
            String userInput = characterIndex > -1
                ? eachOpportunity.Name.substring(characterIndex + opportunityNameSubstring.length())
                : '';
            if (eachOpportunity.AccountId != null) {
                formulateName(
                    eachOpportunity,
                    accountIdToAccountMap.get(eachOpportunity.AccountId),
                    50
                );
                eachOpportunity.Name += COLON_WITH_UNTRIMMED_SPACE + userInput;
            }
        }
    }

    /**
     * @description Performs a validation on changes reflecting on Opportunity Name.
     * A manual edit to the opportunity is only permitted to bypass users on Update.
     * @param existingOpportunities
     */
    public void validateOpportunityNameChange(Map<Id, Opportunity> existingOpportunities) {
        if (existingOpportunities == null || existingOpportunities.isEmpty()) {
            return;
        }
        Boolean hasCurrentUserBypassOpportunityValidationRulesPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);
        Boolean hasNameChangedOnClosedOpportunity = false;
        Opportunity oldOpportunity;
        for (Opportunity eachOpportunity : getOpportunities()) {
            oldOpportunity = existingOpportunities.get(eachOpportunity.Id);
            hasNameChangedOnClosedOpportunity =
                eachOpportunity.IsClosed && (oldOpportunity.Name != eachOpportunity.Name);
            if (
                hasCurrentUserBypassOpportunityValidationRulesPermission ||
                eachOpportunity.Is_Updated_By_System__c
            ) {
                continue;
            }
            if (hasNameChangedOnClosedOpportunity) {
                eachOpportunity.addError(
                    error(System.Label.Opportunity_Name_Change_Error, eachOpportunity)
                );
            }
            eachOpportunity.Is_Updated_By_System__c = false;
        }
    }

    /**
     * @description Prepares the name of the Opportunity with Parent Account, CloseDate
     *              and Sub Type
     * @param opportunityRecord
     * @param parentAccount
     * @param length
     */
    public void formulateName(
        Opportunity opportunityRecord,
        Account parentAccount,
        Integer length
    ) {
        opportunityRecord.Name =
            parentAccount.Name.substring(
                0,
                parentAccount.Name.length() > length ? length : parentAccount.Name.length()
            ) + quarterAndFiscalYearEvaluation(opportunityRecord.CloseDate);
        opportunityRecord.Name += opportunityRecord.Opportunity_Sub_Type__c != null
            ? HYPHEN_WITH_UNTRIMMED_SPACE + opportunityRecord.Opportunity_Sub_Type__c
            : '';
    }
    /**
     * @description When the opportunity stage is updated from some previous value to Stalled,
     *              the Probability and Forecast Category from the previous stage are carried forward to the Stalled stage.
     *              This overrides the default Probability and Forecast Category configured on the Stalled stage.
     * @param oldOpportunityRecords
     * @param changedRecords
     */
    public void restoreForecastAndProbabilityOnStageChangeToStalled(
        Map<Id, SObject> oldOpportunityRecords,
        List<Opportunity> changedRecords
    ) {
        for (
            Opportunity opportunityRec : (List<Opportunity>) getRecordsByFieldValue(
                Opportunity.StageName,
                STALLED_STAGE_NAME
            )
        ) {
            Opportunity oldRecord = (Opportunity) oldOpportunityRecords.get(opportunityRec.Id);
            opportunityRec.Probability = oldRecord.Probability;
            opportunityRec.ForecastCategoryName = oldRecord.ForecastCategoryName;
        }
    }

    /**
     * @description This method is used to validate the User permissions while reparenting an opportunity without a quote.
     * @param opportunitiesToBeReparented
     * @param opportunitiesWithQuote
     */
    public void opportunityReparentingValidation(
        List<Opportunity> opportunitiesToBeReparented,
        Set<Id> opportunitiesWithQuote
    ) {
        Id currentUserId = UserInfo.getUserId();

        Boolean isCurrentUserAllowedReparenting = FeatureManagementService.newInstance()
            .checkPermission(ALLOW_OPPORTUNITY_REPARENTING);
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);
        for (Opportunity eachOpportunity : opportunitiesToBeReparented) {
            Boolean isOwnerOrOwnerManagerOfOpportunity =
                eachOpportunity.OwnerId == currentUserId ||
                eachOpportunity.Owner.ManagerId == currentUserId;
            if (
                opportunitiesWithQuote != null &&
                opportunitiesWithQuote.contains(eachOpportunity.Id)
            ) {
                eachOpportunity.addError(System.Label.Reparenting_Quote_Validation);
            }
            if (
                !isOwnerOrOwnerManagerOfOpportunity &&
                !isCurrentUserAllowedReparenting &&
                !isCurrentUserHaveByPassPermission
            ) {
                eachOpportunity.addError(System.Label.Reparenting_Access_Restriction);
            }
        }
    }

    /**
     * @description This method is used to validate if the Pitch Amount of an Opportunity was updated
     * @param opportunitiesWithQuote
     */
    public void validateChangeInPitchAmount(Set<Id> opportunitiesWithQuote) {
        if (opportunitiesWithQuote.isEmpty()) {
            return;
        }
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);
        for (Opportunity eachOpportunity : getOpportunities()) {
            if (
                opportunitiesWithQuote.contains(eachOpportunity.Id) &&
                !isCurrentUserHaveByPassPermission
            ) {
                eachOpportunity.addError(
                    error(System.label.Opportunity_Pitch_Amount_validation, eachOpportunity)
                );
            }
        }
    }

    /**
     * @description This method is used to validate if the Sub Type of an Opportunity was updated at
     * a valid opportunity stage.
     */
    public void validateChangeInSubType() {
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);
        for (
            Opportunity eachOpportunity : (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.StageName,
                new Set<Object>{ CONTRACTING_STAGE, CLOSEDWON_STAGE }
            )
        ) {
            if (
                !CONTRACT_CORRECTION.contains(eachOpportunity.Opportunity_Sub_Type__c) &&
                !isCurrentUserHaveByPassPermission
            ) {
                eachOpportunity.addError(error(System.label.Contract_Correction, eachOpportunity));
            }
        }
    }

    /**
     * @description This method is used to validate if the Existing Opportunity
     */
    public void validatePrimaryOrderForOpportunityCloseWin() {
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);
        Boolean isEligibleForOrderCheck = false;
        Map<Id, Boolean> oppWithPipleProductQuotesMap = new Map<Id, Boolean>();
        List<Opportunity> changedOpportunities = new List<Opportunity>(
            (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.StageName,
                new Set<Object>{ CLOSEDWON_STAGE }
            )
        );
        oppWithPipleProductQuotesMap = getOpportunitiesWithPipelineProductOnQuote(
            changedOpportunities
        );
        Set<Id> opportunitiesWithoutPrimaryOrder = getOpportunitiesWithNoPrimaryOrder(
            (List<Opportunity>) getRecords()
        );
        for (Opportunity eachOpportunity : changedOpportunities) {
            //If the source is product (opp created for coo same store) skip validation.
            Boolean isSourceProduct = SOURCE_PRODUCT.equals(eachOpportunity.Source__c)
                ? true
                : false;
            isEligibleForOrderCheck =
                eachOpportunity.Type == EXISTING_TYPE &&
                eachOpportunity.Account_Type__c != FRANCHISE &&
                !opportunitiesWithoutPrimaryOrder.contains(eachOpportunity.Id) &&
                !isSourceProduct;
            if (
                String.isNotBlank(eachOpportunity.Opportunity_Sub_Type__c) &&
                String.isNotBlank(eachOpportunity.Deal_Type__c) &&
                eachOpportunity.Opportunity_Sub_Type__c.equalsIgnoreCase(SUB_TYPE) &&
                eachOpportunity.Deal_Type__c.equalsIgnoreCase(DEAL_TYPE)
            ) {
                continue;
            } else if (
                isEligibleForOrderCheck &&
                !isCurrentUserHaveByPassPermission &&
                !oppWithPipleProductQuotesMap.get(eachOpportunity.Id)
            ) {
                eachOpportunity.addError(
                    error(
                        System.label.Opportunity_ClosedWon_Stage_Validation_Error_Message,
                        eachOpportunity
                    )
                );
            }
        }
    }

    /**
     * @description This method is used to maintain the list of opportunities that do not have a
     * primary order.
     * @param opportunities
     * @return Set<Id>
     */
    private Set<Id> getOpportunitiesWithNoPrimaryOrder(List<Opportunity> opportunities) {
        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> changedOpportunityIds = getRecordIds();
        if (changedOpportunityIds != null && !changedOpportunityIds.isEmpty()) {
            for (
                Order eachOrder : OrdersSelector.newInstance()
                    .selectOrdersByOpportunityIds(changedOpportunityIds)
            ) {
                opportunityIds.add(eachOrder.SBQQ__Quote__r.SBQQ__Opportunity2__c);
            }
        }

        return opportunityIds;
    }

    /**
     * @description Fetch all parent account Ids with  Active - Franchise Agreement type of Agreement
     * @param parentAccounts
     * @return Set<Id>
     */
    private Set<Id> getAccountsWithLinkedAgreements(Map<Id, Account> parentAccounts) {
        Set<Id> parentAccountIds = new Set<Id>();
        if (parentAccounts.isEmpty()) {
            return new Set<Id>();
        }
        for (
            Agreement__c eachAgreement : AgreementsSelector.newInstance()
                .selectAgreementsByParentAccounts(parentAccounts.keySet())
        ) {
            parentAccountIds.add(eachAgreement.Account__c);
        }
        return parentAccountIds;
    }

    /**
     * @description This method is used to retrieve Quotes for all opportunities and extract the set of parent Opportunities.
     * @param opportunitiesToBeReparented
     * @return Set<Id>
     */
    public Set<Id> getOpportunitiesWithQuotes(List<Opportunity> opportunitiesToBeReparented) {
        if (opportunitiesToBeReparented.isEmpty()) {
            return new Set<Id>();
        }
        List<SBQQ__Quote__c> quotesOfAllReparentedOpportunities = QuotesSelector.newInstance()
            .selectByOpportunity(new Map<Id, Opportunity>(opportunitiesToBeReparented).keySet());
        Set<Id> opportunitiesWithQuote = new Set<Id>();

        if (quotesOfAllReparentedOpportunities == null) {
            return opportunitiesWithQuote;
        }
        for (SBQQ__Quote__c eachQuote : quotesOfAllReparentedOpportunities) {
            if (eachQuote.SBQQ__Opportunity2__c != null) {
                opportunitiesWithQuote.add(eachQuote.SBQQ__Opportunity2__c);
            }
        }
        return opportunitiesWithQuote;
    }

    /**
     * @description This method is used to update the opportunity Currency as the parent Account currency.
     */
    public void defaultOpportunityCurrencyToAccountCurrency() {
        if (getOpportunities().isEmpty()) {
            return;
        }
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>(
            AccountsSelector.newInstance().selectByOpportunity(getOpportunities())
        );
        for (
            Opportunity opportunity : (List<Opportunity>) getRecordsWithNotBlankFieldValues(
                Opportunity.AccountId
            )
        ) {
            opportunity.CurrencyIsoCode = accountIdToAccountMap.get(opportunity.AccountId)
                ?.CurrencyIsoCode;
        }
    }

    /**
     * @description method declaration for calculating QQ YY
     * @param closeDate
     * @return String - QQ YY
     */
    private String quarterAndFiscalYearEvaluation(Date closeDate) {
        String opportunityQuarterOfClosing;
        switch on closeDate.month() {
            when 1, 2, 3 {
                opportunityQuarterOfClosing = QUARTER_ONE;
            }
            when 4, 5, 6 {
                opportunityQuarterOfClosing = QUARTER_TWO;
            }
            when 7, 8, 9 {
                opportunityQuarterOfClosing = QUARTER_THREE;
            }
            when else {
                opportunityQuarterOfClosing = QUARTER_FOUR;
            }
        }
        String opportunityFiscalYearOfClosing = String.valueOf(closeDate.year());
        return HYPHEN_WITH_UNTRIMMED_SPACE +
            opportunityQuarterOfClosing +
            ' ' +
            opportunityFiscalYearOfClosing.substring(2);
    }

    /**
     * @description Assigning the standard Pricebook to pricebook2Id on new oppty
     */
    public void assignPriceBook() {
        //Invoking Pricebook Selector to query standard pricebook
        Id standardPriceBookId;
        if (Test.isRunningTest()) {
            standardPriceBookId = Test.getStandardPricebookId();
        } else {
            Pricebook2 standardPricebook = PricebookSelector.newInstance()
                .selectStandardPricebook();
            standardPriceBookId = standardPricebook.Id;
        }

        //Assigning Opportunity pricebook to the standard pricebook and
        //adding values to default on opportunity post lead conversion.
        for (Opportunity oppty : getOpportunities()) {
            oppty.Pricebook2Id = standardPriceBookId;
        }
    }

    /**
     * @description This method is used to populate the ContractId on Existing or Rescue type of Opportunity
     * and check if related Account has an activated Contract to prevent creation of New type of Opportunity.
     */
    public void assignContractAndPreventOpportunityNewTypeCreation() {
        List<Opportunity> newOpportunities = getOpportunities();
        if (newOpportunities == null || newOpportunities.isEmpty()) {
            return;
        }
        Set<Id> parentAccountIds = new Set<Id>();
        Map<Id, List<Contract>> accountsIdsToChildContracts = new Map<Id, List<Contract>>();
        Map<Id, List<Contract>> parentAccountsIdsToMiddlewareProviderContracts = new Map<Id, List<Contract>>();
        for (Opportunity eachOpportunity : newOpportunities) {
            if (eachOpportunity.AccountId != null) {
                parentAccountIds.add(eachOpportunity.AccountId);
            }
        }

        Map<Id, Account> accountIdToAccounts = new Map<Id, Account>(
            AccountsSelector.newInstance().selectByOpportunity(newOpportunities)
        );

        accountsIdsToChildContracts = ContractsService.setAllContractOnParentAccount(
            parentAccountIds
        );
        parentAccountsIdsToMiddlewareProviderContracts = ContractsService.setMiddlewareProviderContractOnParentAccount(
            parentAccountIds
        );
        Set<Id> deltaContractIds = new Set<Id>();
        if (accountsIdsToChildContracts != null) {
            for (Opportunity eachOpportunity : newOpportunities) {
                Boolean isValidForContractAssignment =
                    eachOpportunity.AccountId != null &&
                    accountsIdsToChildContracts.containsKey(eachOpportunity.AccountId) &&
                    eachOpportunity.Type != NEW_TYPE;
                deltaContractIds = getDeltaContractIds(
                    accountsIdsToChildContracts,
                    parentAccountsIdsToMiddlewareProviderContracts,
                    eachOpportunity.AccountId
                );
                Boolean isActivatedContractAssociatedToNewType =
                    accountsIdsToChildContracts.containsKey(eachOpportunity.AccountId) &&
                    !deltaContractIds.isEmpty() &&
                    eachOpportunity.Type == NEW_TYPE &&
                    eachOpportunity.Source__c != SOURCE_NINTEX &&
                    accountIdToAccounts.get(eachOpportunity.AccountId).RecordTypeId ==
                    BUSINESS_RECORD_TYPE_ID;
                Contract coreContract = getCoreContract(eachOpportunity, accountsIdsToChildContracts);
                if (
                    isValidForContractAssignment &&
                    accountsIdsToChildContracts.containsKey(eachOpportunity.AccountId) &&
                    !accountsIdsToChildContracts.get(eachOpportunity.AccountId).isEmpty() &&
                    eachOpportunity.ContractId == null && coreContract != null
                ) {
                    eachOpportunity.ContractId = coreContract.Id;
                } else if (isActivatedContractAssociatedToNewType) {
                    eachOpportunity.addError(
                        error(
                            System.Label.New_Opportunity_On_Account_With_Activated_Contract_Error,
                            eachOpportunity
                        )
                    );
                }
            }
        }
    }

    /**
     * @description It is used to get the core contract associated to the passed Opportunity.
     * @param opportunityInstance
     * @param accountsIdsToChildContracts
     * @return Contract
     */
    private Contract getCoreContract(
        Opportunity opportunityInstance,
        Map<Id, List<Contract>> accountsIdsToChildContracts
    ) {
        Contract coreContract;
        if (accountsIdsToChildContracts.containsKey(opportunityInstance.AccountId)
        ) {
            for (Contract eachContract: accountsIdsToChildContracts.get(opportunityInstance.AccountId)) {
                if (eachContract.Contract_Split_Category__c == CONTRACT_SPLIT_CATEGORY_CORE &&
                    coreContract == null
                ) {
                    coreContract = eachContract;
                    break;
                }
            }
        }
        return coreContract;
    }

    /**
     * @description This method is used to check the contact role on opportunity before changing the stage
     * @param oldOpportunityRecords
     * @param changedRecords
     * @JIRA# LEM-10077 - skip the validation for the opportunities when primary quote has only pipeline products.
     */
    public void contactRoleValidationBeforeStageChangePastPitching(
        Map<Id, SObject> oldOpportunityRecords,
        List<Opportunity> changedRecords
    ) {
        Boolean isStandAlonePipeLineProductQuote = false;
        Map<Id, Boolean> oppWithPipleProductQuotesMap = new Map<Id, Boolean>();
        Set<Id> opportunitiesWithContactRole = getOpportunitiesWithContactRole(changedRecords);
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);

        List<Opportunity> changedOpportunityList = new List<Opportunity>(
            (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.StageName,
                new Set<Object>{ CONTRACTING_STAGE, NEGOTIATING_STAGE, CLOSEDWON_STAGE }
            )
        );
        oppWithPipleProductQuotesMap = getOpportunitiesWithPipelineProductOnQuote(
            changedOpportunityList
        );
        for (Opportunity eachOpportunity : changedOpportunityList) {
            Boolean isEligibleToFireValidation =
                !isCurrentUserHaveByPassPermission &&
                !SOURCES_TO_SKIP_VALIDATION.contains(eachOpportunity.Source__c);
            isStandAlonePipeLineProductQuote = (oppWithPipleProductQuotesMap != null &&
                oppWithPipleProductQuotesMap.containsKey(eachOpportunity.Id))
                ? oppWithPipleProductQuotesMap.get(eachOpportunity.Id)
                : false;

            if (
                (opportunitiesWithContactRole.isEmpty() ||
                !opportunitiesWithContactRole.contains(eachOpportunity.Id)) &&
                isEligibleToFireValidation &&
                !isStandAlonePipeLineProductQuote &&
                !isCurrentUserProcessAutomationUser()
            ) {
                eachOpportunity.addError(System.Label.Contact_Role_Validation_Error_On_Opportunity);
            }
        }
    }

    /**
     * @description It creates Opportunity Brand Relationship on Opportunity insert when there is
     * only one Brand Association related to the associated Account.
     * @JIRA# LEM-13535
     */
    public void createBrandRelationshipOnOpportunityInsert() {
        Set<Id> associatedAccountIds = new Set<Id>();
        Set<Id> brandAssociationIds = new Set<Id>();
        Id businessAccountId;
        Id opportunityAccountId;
        List<Opportunity> opportunities = new List<Opportunity>();
        Map<Id, Set<Id>> accountIdToBrandAssociationIds = new Map<Id, Set<Id>>();
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Opportunity eachOpportunity : (List<Opportunity>) getRecords()) {
            if (
                eachOpportunity.Account_Record_Type__c == BUSINESS_RECORD_TYPE_ID &&
                (eachOpportunity.Account_Segment__c == ACCOUNT_SEGMENT_SMB ||
                (eachOpportunity.Account_Segment__c != ACCOUNT_SEGMENT_SMB &&
                eachOpportunity.Deal_Type__c == DEAL_TYPE &&
                eachOpportunity.Opportunity_Sub_Type__c == SUB_TYPE))
            ) {
                associatedAccountIds.add(eachOpportunity.AccountId);
                opportunities.add(eachOpportunity);
            }
        }
        if (associatedAccountIds == null) {
            return;
        }
        for (
            Brand_Association__c eachBrandAssociation : BrandAssociationsSelector.newInstance()
                .selectByBusinessAccountIds(associatedAccountIds)
        ) {
            businessAccountId = eachBrandAssociation.Business_Account_Name__c;
            if (
                !accountIdToBrandAssociationIds.containsKey(
                    eachBrandAssociation.Business_Account_Name__c
                )
            ) {
                accountIdToBrandAssociationIds.put(businessAccountId, new Set<Id>());
            }
            accountIdToBrandAssociationIds.get(businessAccountId).add(eachBrandAssociation.Id);
        }
        for (Opportunity opportunityToCreateBrandRelationship : opportunities) {
            opportunityAccountId = opportunityToCreateBrandRelationship.AccountId;
            if (accountIdToBrandAssociationIds.containsKey(opportunityAccountId)) {
                brandAssociationIds = accountIdToBrandAssociationIds.get(opportunityAccountId);
                if (brandAssociationIds.size() == 1) {
                    uow.registerNew(
                        new Opportunity_Brand_Relationship__c(
                            Brand__c = new List<Id>(
                                accountIdToBrandAssociationIds.get(opportunityAccountId)
                            )[0],
                            Opportunity__c = opportunityToCreateBrandRelationship.Id
                        )
                    );
                }
            }
        }
        uow.commitWork();
    }

    /**
     * @description It is used to validate if the Opportunities have related Opportunity Brand
     * Relationships in order to move it past Pitching.
     * @param oldOpportunityRecords
     * @param changedRecords
     * @JIRA# LEM-10077 - skip the validation for the opportunities when primary quote has only pipeline products.
     */
    public void validateOpportunitiesInNegotiatingStage(
        Map<Id, SObject> oldOpportunityRecords,
        List<Opportunity> changedRecords
    ) {
        Set<Id> opportunitiesWithBrandRelationships = OpportunitiesService.getOpportunitiesWithOpportunityBrandRelationships(
            changedRecords
        );
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);

        List<Opportunity> changedOpportunityList = new List<Opportunity>(
            (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.StageName,
                new Set<Object>{ CONTRACTING_STAGE, NEGOTIATING_STAGE, CLOSEDWON_STAGE }
            )
        );
        Map<Id, Boolean> oppWithPipleProductQuotesMap = getOpportunitiesWithPipelineProductOnQuote(
            changedOpportunityList
        );
        for (Opportunity eachOpportunity : changedOpportunityList) {
            Boolean isEligibleToFireValidation =
                !isCurrentUserHaveByPassPermission &&
                !SOURCES_TO_SKIP_VALIDATION.contains(eachOpportunity.Source__c);
            Boolean isStandAlonePipeLineProductQuote = (oppWithPipleProductQuotesMap != null &&
                oppWithPipleProductQuotesMap.containsKey(eachOpportunity.Id))
                ? oppWithPipleProductQuotesMap.get(eachOpportunity.Id)
                : false;

            if (
                String.isNotBlank(eachOpportunity.Opportunity_Sub_Type__c) &&
                eachOpportunity.Opportunity_Sub_Type__c.equalsIgnoreCase(SUB_TYPE)
            ) {
                continue;
            } else if (
                (opportunitiesWithBrandRelationships.isEmpty() ||
                !opportunitiesWithBrandRelationships.contains(eachOpportunity.Id)) &&
                eachOpportunity.Account_Record_Type__c == BUSINESS_RECORD_TYPE_ID &&
                isEligibleToFireValidation &&
                !isStandAlonePipeLineProductQuote &&
                !isCurrentUserProcessAutomationUser() &&
                ELIGIBLE_ACCOUNT_SEGMENTS.contains(eachOpportunity.Account_Segment__c)
            ) {
                eachOpportunity.addError(System.Label.Opportunity_Brand_Relationship_Validation);
            }
        }
    }

    /**
     * @description This method is used to check the contact role on opportunity while creating an Opportunity in Negotiating, Contracting or Closed Won Stage.
     */
    public void contactRoleValidationOnOpportunityCreation() {
        List<Opportunity> standardOpportunities = new List<Opportunity>(
            (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.Deal_Type__c,
                new Set<Object>{ System.Label.Opportunity_Lite }
            )
        );
        Boolean isCurrentUserHaveByPassPermission = FeatureManagementService.newInstance()
            .checkPermission(BYPASS_OPPORTUNITY_VALIDATION_RULES);
        for (
            Opportunity eachOpportunity : (List<Opportunity>) getRecordsByFieldValues(
                Opportunity.StageName,
                new Set<Object>{ CONTRACTING_STAGE, NEGOTIATING_STAGE, CLOSEDWON_STAGE }
            )
        ) {
            if (
                !standardOpportunities.contains(eachOpportunity) &&
                !isCurrentUserHaveByPassPermission &&
                eachOpportunity.Source__c != SOURCE_NINTEX &&
                String.isBlank(eachOpportunity.Unique_Identifier__c)
            ) {
                eachOpportunity.addError(
                    System.Label.Validation_Error_On_Opportunity_Creation_Past_Pitching_Stage
                );
            }
        }
    }

    /**
     * @description It is used to get delta Contract Ids
     * after removing Middleware Provider Contracts from all Contracts.
     * @JIRA# LEM-23361
     * @param accountsIdsToAllContracts
     * @param accountsIdsToMiddlewareProviderContracts
     * @param accountIdToEvaluate
     * @return Set<Id>
     */
    private Set<Id> getDeltaContractIds(
        Map<Id, List<Contract>> accountsIdsToAllContracts,
        Map<Id, List<Contract>> accountsIdsToMiddlewareProviderContracts,
        Id accountIdToEvaluate
    ) {
        Set<Id> deltaContractIds = new Set<Id>();
        List<Contract> allContractsByAccountIds = accountsIdsToAllContracts.containsKey(
                accountIdToEvaluate
            )
            ? accountsIdsToAllContracts.get(accountIdToEvaluate)
            : new List<Contract>();
        List<Contract> mwpContractsByAccountIds = accountsIdsToMiddlewareProviderContracts.containsKey(
                accountIdToEvaluate
            )
            ? accountsIdsToMiddlewareProviderContracts.get(accountIdToEvaluate)
            : new List<Contract>();
        deltaContractIds = new Map<Id, Contract>(allContractsByAccountIds).keySet();
        deltaContractIds.removeAll(new Map<Id, Contract>(mwpContractsByAccountIds).keySet());
        return deltaContractIds;
    }

    /**
     * @description This method is used to retrieve OpportunityContactRole for all opportunities and extract the set of parent Opportunities.
     * @param changedOpportunities
     * @return Set<Id>
     */
    private Set<Id> getOpportunitiesWithContactRole(List<Opportunity> changedOpportunities) {
        Set<Id> opportunitiesWithContactRole = new Set<Id>();
        if (changedOpportunities.isEmpty()) {
            return opportunitiesWithContactRole;
        }
        Set<Id> primaryOpportunityContactRoles = new Set<Id>();
        Set<Id> opportunityContactRoleWithContractSignatory = new Set<Id>();
        List<OpportunityContactRole> opportunityContactRoleRecords = OpportunityContactRoleSelector.newInstance()
            .selectPrimaryOrContractSignatoryOpportunityContactRoleByOpportunity(
                new Map<Id, Opportunity>(changedOpportunities).keySet()
            );

        if (opportunityContactRoleRecords == null) {
            return opportunitiesWithContactRole;
        }
        for (OpportunityContactRole eachOpportunityContactRole : opportunityContactRoleRecords) {
            if (eachOpportunityContactRole.IsPrimary) {
                primaryOpportunityContactRoles.add(eachOpportunityContactRole.OpportunityId);
            }
            if (eachOpportunityContactRole.Role == CONTRACT_SIGNATORY_ROLE) {
                opportunityContactRoleWithContractSignatory.add(
                    eachOpportunityContactRole.OpportunityId
                );
            }
        }
        for (OpportunityContactRole eachOpportunityContactRole : opportunityContactRoleRecords) {
            if (
                eachOpportunityContactRole.OpportunityId != null &&
                primaryOpportunityContactRoles.contains(eachOpportunityContactRole.OpportunityId) &&
                opportunityContactRoleWithContractSignatory.contains(
                    eachOpportunityContactRole.OpportunityId
                )
            ) {
                opportunitiesWithContactRole.add(eachOpportunityContactRole.OpportunityId);
            }
        }
        return opportunitiesWithContactRole;
    }

    /**
     * @description This method is to update the Opportunity in Stalled Stage to Closed Stage if there
     *              has been no activity in last 120 days.
     * @return List<Opportunity>
     */
    public List<Opportunity> updateInactiveOpportunitiesInStalledStageToClosed() {
        List<Opportunity> opportunitiesToUpdate = new List<Opportunity>();
        for (Opportunity eachOpportunity : getOpportunities()) {
            eachOpportunity.StageName = CLOSED_LOST;
            eachOpportunity.Lost_Reason__c = LACK_OF_ACTIVITY;
            eachOpportunity.Lost_Reason_Additional_Notes__c = LOST_ADDITIONAL_REASON;
            opportunitiesToUpdate.add(eachOpportunity);
        }
        return opportunitiesToUpdate;
    }

    /**
     * @description Opportunity Records
     * @return List<Opportunity>
     */
    public List<Opportunity> getOpportunities() {
        return (List<Opportunity>) getRecords();
    }

    /**
     * @description Account status set when insert/undelete related opportunities.
     */
    public void updateAccountLifecycleStatusOnOpportunityInsertOrUndelete() {
        //Tried with getRecordsByFieldValue(Opportunity.IsClosed, false) in inside of for loop query list, But its not returning any values. So we have used getRecords() and filtered from the for loop.
        Set<Id> accountIds = accountIdsOfTheOpportunities((List<Opportunity>) getRecords(), true);
        AccountsService.updateAcountLifeCycleStatusToInPursuit(accountIds);
    }

    /**
     * @description Account life cycle status checking after deleting opportunity records.
     * If there is no opportunity assosiated with account then status changed 'In Pursuit' to 'Unvetted'
     */
    public void checkAccountLifecycleStatusWhenOpportunityDeleted() {
        Set<Id> accountIds = accountIdsOfTheOpportunities(
            (List<Opportunity>) getRecordsWithNotBlankFieldValues(Opportunity.AccountId),
            false
        );
        if (accountIds == null || accountIds.isEmpty()) {
            return;
        }
        List<Opportunity> currentOpportunitiesInDB = OpportunitiesSelector.newInstance()
            .selectOpportunitiesByAccountId(accountIds);
        AccountsService.updateAcountLifeCycleStatusToUnvetted(
            accountIds,
            accountIdsOfTheOpportunities(currentOpportunitiesInDB, false)
        );
    }

    /**
     * @description Account Life cycle status set when the update takes place on related opportunities.
     * @param oldOpportunityRecords
     */
    public void updateAccountLifecycleStatusOnOpportunityUpdate(
        Map<Id, Opportunity> oldOpportunityRecords
    ) {
        //Tried with getRecordsByFieldValue(Opportunity.IsClosed, false) in inside of for loop query list, But its not returning any values. So we have used getRecords() and filtered from the for loop.
        Set<Id> accountIdsOfUpdatedOpportunities = accountIdsOfTheOpportunities(
            (List<Opportunity>) getRecords(),
            true
        );
        AccountsService.updateAcountLifeCycleStatusToInPursuit(accountIdsOfUpdatedOpportunities);

        Set<Id> accountIdsOfOldOpportunities = new Set<Id>();
        for (Opportunity oldOpportunity : oldOpportunityRecords.values()) {
            accountIdsOfOldOpportunities.add(oldOpportunity.AccountId);
        }
        if (accountIdsOfOldOpportunities.isEmpty()) {
            return;
        }
        List<Opportunity> currentOpportunitiesInDB = OpportunitiesSelector.newInstance()
            .selectOpportunitiesByAccountId(accountIdsOfOldOpportunities);
        AccountsService.updateAcountLifeCycleStatusToUnvetted(
            accountIdsOfOldOpportunities,
            accountIdsOfTheOpportunities(currentOpportunitiesInDB, false)
        );
    }

    /**
     * @description this method used to get account ids of existing opportunities.
     * @param opportunities passing opportunities list assoasiated with account
     * @param considerClosedOpportunities
     * @return Set<Id> account ids.
     */
    private Set<Id> accountIdsOfTheOpportunities(
        List<Opportunity> opportunities,
        Boolean considerClosedOpportunities
    ) {
        Set<Id> accountIdsOfTheOpportunities = new Set<Id>();
        for (Opportunity opportunity : opportunities) {
            if (considerClosedOpportunities && opportunity.IsClosed) {
                continue;
            }
            accountIdsOfTheOpportunities.add(opportunity.AccountId);
        }
        return accountIdsOfTheOpportunities;
    }

    /**
     * @description This method is used to get Opportunities with Nintex values updated.
     */
    public void createAgreementsFromOpportunities() {
        List<Opportunity> nintexOppList = (List<Opportunity>) getRecordsByFieldValues(
            Opportunity.Nintex_Use_Case__c,
            new Set<Object>{
                'New Franchise - Unknown',
                'Change of Ownership',
                'New additional stores',
                'Drive - Amendment',
                'Rate Change',
                'Integrated Franchise',
                'Drive Form - Franchise'
            }
        );
        List<Opportunity> closedWonNintexOppsList = new List<Opportunity>();
        for (Opportunity nintexOpp : nintexOppList) {
            if (nintexOpp.StageName == CLOSEDWON_STAGE) {
                closedWonNintexOppsList.add(nintexOpp);
            }
        }

        if (!closedWonNintexOppsList.isEmpty()) {
            NintexSubmissionService.submitOpportunities(new Opportunities(closedWonNintexOppsList));
        }
    }

    /**
     * @description It validates that corporate Opportunity is associated with
     * Work Order before moving to the contracting stage.
     * @JIRA# LEM-2132
     * @JIRA# LEM-10077 - skip the validation for the opportunities when primary quote has only pipeline products.
     */
    public void validateOpportunitiesInContractingStage() {
        List<Opportunity> changedOpportunityList = new List<Opportunity>(
            (List<Opportunity>) getRecords()
        );
        if (changedOpportunityList.isEmpty()) {
            return;
        }
        List<Opportunity> filteredOppList = OpportunitiesService.collectOpportunitiesWithoutWorkOrderInContractingStage(
            changedOpportunityList
        );
        if (filteredOppList == null) {
            return;
        }
        Map<Id, Boolean> oppWithPipleProductQuotesMap = getOpportunitiesWithPipelineProductOnQuote(
            filteredOppList
        );
        for (Opportunity eachOpportunity : filteredOppList) {
            Boolean isStandAlonePipeLineProductQuote = (oppWithPipleProductQuotesMap != null &&
                oppWithPipleProductQuotesMap.containsKey(eachOpportunity.Id))
                ? oppWithPipleProductQuotesMap.get(eachOpportunity.Id)
                : false;
            if (!isStandAlonePipeLineProductQuote) {
                eachOpportunity.addError(
                    error(
                        System.Label.Opportunity_Contracting_Stage_Validation_Error_Message,
                        eachOpportunity
                    )
                );
            }
        }
    }
    /**
     * @description LEM-10077 This method is used to retrieve Quotes which has BD pipeline Product Added
     * @param changedOpportunities
     * @return Map<Id, Boolean>
     */
    private Map<Id, Boolean> getOpportunitiesWithPipelineProductOnQuote(
        List<Opportunity> changedOpportunities
    ) {
        Map<Id, Boolean> oppPipeLineProductMap = new Map<Id, Boolean>();
        if (!changedOpportunities.isEmpty()) {
            Map<Id, Opportunity> oppQuoteMap = new Map<Id, Opportunity>(
                OpportunitiesSelector.newInstance()
                    .selectOpportunitiesWithQuotes(
                        new Map<Id, Opportunity>(changedOpportunities).keySet()
                    )
            );
            if (oppQuoteMap.isEmpty()) {
                return null;
            }
            for (Opportunity eachOpp : oppQuoteMap.values()) {
                if (oppQuoteMap.containsKey(eachOpp.Id)) {
                    oppPipeLineProductMap.put(
                        eachOpp.Id,
                        eachOpp.SBQQ__PrimaryQuote__r.HasPipelineProduct__c
                    );
                }
            }
        }
        return oppPipeLineProductMap;
    }

    /**
     * @description It checks whether the Opportunities is getting created or updated by Process Automation User.
     * @JIRA# LEM-2131
     * @return Boolean
     */
    private Boolean isCurrentUserProcessAutomationUser() {
        return UserInfo.getLastName()
            .startsWithIgnoreCase(System.Label.Automated_Process_User_Last_Name);
    }

    /**
     * @description Holds a mock instance of the constructor inner class.
     * Setting this will provide the ability to test the records being injected into
     * the domain class when it is instantiated.
     */
    private static fflib_IDomainConstructor constructorMock;

    /**
     * @description Private method that allows the domain constructor mock to be set by test class.
     * @param mock fflib_IDomainConstructor
     */
    @TestVisible
    private static void setConstructorMock(fflib_IDomainConstructor mock) {
        constructorMock = mock;
    }

    /**
     * @description To create instance of Opportunity domain class
     */
    public class Constructor implements fflib_IDomainConstructor {
        /**
         * @description construct
         * @param objects List<Object>
         * @return instance of Opportunties
         */
        public fflib_ISObjects construct(List<Object> objects) {
            if (Opportunities.constructorMock != null) {
                return (fflib_ISObjects) Opportunities.constructorMock.construct(objects);
            }
            return new Opportunities((List<Opportunity>) objects);
        }
    }

    /**
     * @description LEM-4974: It is used to create opportunity team members for new opportunities
     * and Opportunities when owner is changed
     * @param eventName
     */
    public void createOpportunityTeamMembersForManagersOnOwnerUpdate(String eventName) {
        Set<Id> opportunityIds = getRecordIds();
        if (opportunityIds.isEmpty()) {
            return;
        }
        NotifierEventsService.publishEvents(
            new Map<String, String>{ eventName => JSON.serialize(opportunityIds) }
        );
    }

    /**
     * @description LEM-13473 It is used to update OCR's for Opportunities created by Lead Conversion
     */
    public void updateOCRForLeadConvertedOpportunities() {
        Set<Id> opportunityIds = (new Map<Id, Opportunity>((List<Opportunity>) getRecords()))
            .keySet();
        if (opportunityIds.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<OpportunityContactRole> opportunityContactRolesToUpdate = new List<OpportunityContactRole>();
        for (
            OpportunityContactRole eachOpportunityContactRole : OpportunityContactRoleSelector.newInstance()
                .selectByOpportunity(opportunityIds)
        ) {
            eachOpportunityContactRole.Role = 'Contract Signatory';
            opportunityContactRolesToUpdate.add(eachOpportunityContactRole);
        }
        uow.registerDirty(opportunityContactRolesToUpdate);
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
        }
    }

    /**
     * @description It is used to create OCR record for the manually created Opportunities.
     * @JIRA# LEM-13473
     */
    public void createOCRForManuallyCreatedOpportunities() {
        Map<Id, AccountContactRelation> accountIdTolastModifiedACR = new Map<Id, AccountContactRelation>();
        Map<Id, Set<Id>> accountIdToOpportunityIds = new Map<Id, Set<Id>>();
        Map<Id, Id> opportunityIdToContactId = new Map<Id, Id>();
        for (Opportunity eachOpportunity : (List<Opportunity>) getRecords()) {
            if (
                eachOpportunity.AccountId != null &&
                !accountIdToOpportunityIds.containsKey(eachOpportunity.AccountId)
            ) {
                accountIdToOpportunityIds.put(eachOpportunity.AccountId, new Set<Id>());
            }
        accountIdToOpportunityIds.get(eachOpportunity.AccountId).add(eachOpportunity.Id);
        }
        if (accountIdToOpportunityIds.isEmpty()) {
            return;
        }
         accountIdTolastModifiedACR = getLastModifiedACR(
            AccountContactRelationsSelector.newInstance()
                .selectActiveACRByAccountIdsAndRoles(accountIdToOpportunityIds.keySet())
        );
        if (!accountIdTolastModifiedACR.isEmpty()) {
            for (Id eachAccountId : accountIdTolastModifiedACR.keySet()) {
                if (accountIdTolastModifiedACR.get(eachAccountId).ContactId != null) {
                    for (Id eachOpportunityId : accountIdToOpportunityIds.get(eachAccountId)) {
                        opportunityIdToContactId.put(
                            eachOpportunityId,
                            accountIdTolastModifiedACR.get(eachAccountId).ContactId
                        );
                    }
                }
            }
        }
        if (!opportunityIdToContactId.isEmpty()) {
            OpportunityContactRoleService.createOCR(opportunityIdToContactId, true);
        }
    }

    /**
     * @description It is used to get the Last modified ACR record.
     * @JIRA# LEM-13473
     * @param acrRecords
     * @return Map<Id,AccountContactRelation>
     */
    private Map<Id, AccountContactRelation> getLastModifiedACR(
        List<AccountContactRelation> acrRecords
    ) {
        Map<Id, AccountContactRelation> accountIdToDecisionMakerACR = new Map<Id, AccountContactRelation>();
        Map<Id, AccountContactRelation> accountIdToContractSignatoryACR = new Map<Id, AccountContactRelation>();
        for (AccountContactRelation eachACR : acrRecords) {
            if (eachACR.Roles != null) {
                if (
                    eachACR.Roles.contains(DECISION_MAKER_ROLE) &&
                    !accountIdToDecisionMakerACR.containsKey(eachACR.AccountId)
                ) {
                    accountIdToDecisionMakerACR.put(eachACR.AccountId, eachACR);
                } else if (
                    eachACR.Roles.contains(CONTRACT_SIGNATORY_ROLE) &&
                    !accountIdToContractSignatoryACR.containsKey(eachACR.AccountId)
                ) {
                    accountIdToContractSignatoryACR.put(eachACR.AccountId, eachACR);
                }
            }
        }
        for (Id eachAccountId : accountIdToContractSignatoryACR.keySet()) {
            if (!accountIdToDecisionMakerACR.containsKey(eachAccountId)) {
                accountIdToDecisionMakerACR.put(
                    eachAccountId,
                    accountIdToContractSignatoryACR.get(eachAccountId)
                );
            }
        }
        return accountIdToDecisionMakerACR;
    }
    /**
     * @description It is used to stamp Deck Rank and Medal Rank values
     * when Opportunities are marked as Closed.
     * @JIRA# LEM-14100
     * @param opportunitiesWithChangedStage
     */
    public void stampDeckRankAndMedalRankValues(List<Opportunity> opportunitiesWithChangedStage) {
        if (opportunitiesWithChangedStage.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        for (Opportunity eachOpportunityToBeUpdated : opportunitiesWithChangedStage) {
            if (eachOpportunityToBeUpdated.IsClosed) {
                eachOpportunityToBeUpdated.Medal_Rank_At_Closed_Stage__c = eachOpportunityToBeUpdated.Medal_Rank__c;
                eachOpportunityToBeUpdated.Deck_Rank_At_Closed_Stage__c = eachOpportunityToBeUpdated.Account_Deck_Rank__c;
                uow.registerDirty(eachOpportunityToBeUpdated);
            }
        }
        try {
            uow.commitWork();
        } catch (Exception uowException) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_STAMP_DECK_RANK_AND_MEDAL_RANK_ON_CLOSED,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.HIGH
                    )
                    .logException(uowException)
            );
        }
    }

    /**
     * @description It collects Lead to Opportunity conversion field mapping from
     * static resource file.
     * @return Map<String, String>
     */
    private Map<String, String> collectFields() {
        List<StaticResource> leadConversionFieldsMappingsStaticResource = StaticResourcesSelector.newInstance()
            .selectByName(System.Label.LeadConversionFieldsMapping);
        List<String> opportunityFieldMappings = new List<String>();
        Map<String, String> opportunityFieldToIsUpdatable = new Map<String, String>();
        Blob blobCSV = leadConversionFieldsMappingsStaticResource[0].Body;
        String csvString = blobCSV.toString();
        // Normalize line endings to Unix-style
        csvString = csvString.replace(FORWARDSLASH_R_N, FORWARDSLASH_N)
            .replace(FORWARDSLASH_R, FORWARDSLASH_N);
        String[] fieldMappings = csvString.split(FORWARDSLASH_N);
        if (fieldMappings.isEmpty()) {
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_FIELD_MAPPING_ERROR,
                    LOG_DOMAIN,
                    GenericLogEntry.SeverityLevel.LOW
                )
            );
            return opportunityFieldToIsUpdatable;
        }
        fieldMappings.remove(0);
        for (String eachFieldMapping : fieldMappings) {
            // Trim to remove any trailing carriage return character
            opportunityFieldMappings = eachFieldMapping.trim().split(COMMA);
            if (opportunityFieldMappings[0] == OPPORTUNITY_SOBJECT) {
                opportunityFieldToIsUpdatable.put(
                    opportunityFieldMappings[1],
                    opportunityFieldMappings[2]
                );
            }
        }
        return opportunityFieldToIsUpdatable;
    }

    /**
     * @description It is used to process opportunities post lead conversion.
     * @param existingRecords
     */
    public void processOpportunitiesOnLeadConversion(Map<Id, SObject> existingRecords) {
        Map<String, String> opportunityFieldToIsUpdatable = new Map<String, String>();
        if (((List<Opportunity>) getRecords()).isEmpty()) {
            return;
        }
        opportunityFieldToIsUpdatable = collectFields();
        for (Opportunity eachOpportunity : (List<Opportunity>) getRecords()) {
            for (String eachOpportunityField : opportunityFieldToIsUpdatable.keySet()) {
                if (
                    Boolean.valueOf(opportunityFieldToIsUpdatable.get(eachOpportunityField)) &&
                    (((Opportunity) existingRecords.get(eachOpportunity.Id))
                        .get(eachOpportunityField) == '' ||
                    ((Opportunity) existingRecords.get(eachOpportunity.Id))
                        .get(eachOpportunityField) == null)
                ) {
                    //LEM-17379 : Code optimization
                    continue;
                }
                eachOpportunity.put(
                    eachOpportunityField,
                    ((Opportunity) existingRecords.get(eachOpportunity.Id))
                        .get(eachOpportunityField)
                );
            }
        }
    }

    /**
     * @description It is used to set Opportunity lookup on MxTagAssociation
     * when an opportunity is created
     * @JIRA# LEM-14104
     */
    public void addMxTagAssociationToNewlyCreatedOpportunity() {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociation = new Map<Id, List<Mx_Tag_Association__c>>();
        List<Opportunity> opportunities = (List<Opportunity>) getRecords();
        for (Opportunity eachOpportunity : opportunities) {
            if (
                eachOpportunity.StageName != CLOSEDWON_STAGE &&
                eachOpportunity.AccountId != null &&
                eachOpportunity.Account_Segment__c == ACCOUNT_SEGMENT_SMB
            ) {
                accountIds.add(eachOpportunity.AccountId);
            }
        }
        if (accountIds.isEmpty()) {
            return;
        }
        for (
            Mx_Tag_Association__c eachMxTagAssociation : MxTagAssociationsSelector.newInstance()
                .selectByBusinessAccountIds(accountIds)
        ) {
            if (accountIdWithMxTagAssociation.containsKey(eachMxTagAssociation.Account__c)) {
                List<Mx_Tag_Association__c> mxTagAssociations = accountIdWithMxTagAssociation.get(
                    eachMxTagAssociation.Account__c
                );
                mxTagAssociations.add(eachMxTagAssociation);
                accountIdWithMxTagAssociation.put(
                    eachMxTagAssociation.Account__c,
                    mxTagAssociations
                );
            } else {
                accountIdWithMxTagAssociation.put(
                    eachMxTagAssociation.Account__c,
                    new List<Mx_Tag_Association__c>{ eachMxTagAssociation }
                );
            }
        }
        if (accountIdWithMxTagAssociation.keySet().isEmpty()) {
            return;
        }
        createMxTagAssociationForNewlyCreatedOpportunity(
            accountIdWithMxTagAssociation,
            opportunities
        );
    }

    /**
     * @description It is used to create new Mx Tag Association for newly created Opportunity
     * @param accountIdWithMxTagAssociation
     * @param opportunities
     * @JIRA# LEM-14104
     */
    private void createMxTagAssociationForNewlyCreatedOpportunity(
        Map<Id, List<Mx_Tag_Association__c>> accountIdWithMxTagAssociation,
        List<Opportunity> opportunities
    ) {
        fflib_ISobjectUnitOfWork uow = Application.UnitOfWork.newInstance();
        List<Mx_Tag_Association__c> mxTagAssociations = new List<Mx_Tag_Association__c>();
        for (Opportunity eachOpportunity : opportunities) {
            if (accountIdWithMxTagAssociation.containsKey(eachOpportunity.AccountId)) {
                mxTagAssociations = accountIdWithMxTagAssociation.get(eachOpportunity.AccountId);
            }
            for (Mx_Tag_Association__c eachMxTagAssociation : mxTagAssociations) {
                Mx_Tag_Association__c mxTagAssociationCopy = eachMxTagAssociation.clone(
                    false,
                    false,
                    false,
                    false
                );
                mxTagAssociationCopy.Opportunity__c = eachOpportunity.Id;
                mxTagAssociationCopy.Account__c = null;
                uow.registerNew(mxTagAssociationCopy);
            }
        }
        if (mxTagAssociations.size() > 0) {
            commitWork(uow);
        }
    }

    /**
     * @description It is used to evaluate and initiate Work Order Creation for Stores Added through Mx
     * Portal.
     * @JIRA# LEM-16267
     */
    public void evaluateAndInitiateWorkOrderCreationForMxPortalStoreAddition() {
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity eachOpportunity : (List<Opportunity>) getRecords()) {
            if (isOpportunityEligibleForWorkOrderCreation(eachOpportunity)) {
                opportunityIds.add(eachOpportunity.Id);
            }
        }
        if (!opportunityIds.isEmpty()) {
            WorkOrderCreationTriggerService.initiateWorkOrderCreation(
                opportunityIds,
                GENERIC_WORK_ORDER_CREATION
            );
        }
    }

    /**
     * @description It is used to check if Opportunity is eligible for Work Order creation.
     * @JIRA# LEM-16267
     * @param opportunityToEvaluate
     * @return Boolean
     */
    private Boolean isOpportunityEligibleForWorkOrderCreation(Opportunity opportunityToEvaluate) {
        return opportunityToEvaluate.Type == EXISTING_TYPE &&
            opportunityToEvaluate.Opportunity_Sub_Type__c == SUB_TYPE_NEW_STORE_EXPANSION &&
            opportunityToEvaluate.Source__c == SOURCE_MX_PORTAL;
    }

    /**
     * @description It is used to commit the unit for work for
     * set Opportunity lookup on MxTagAssociation when an opportunity is created
     * @JIRA# LEM-14104
     * @param uow
     */
    private void commitWork(fflib_ISObjectUnitOfWork uow) {
        try {
            uow.commitWork();
        } catch (Exception ex) {
            Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.LOW));
            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                        LOG_UPDATE_SOBJECT_BASED_ON_OPPORTUNITY,
                        LOG_DOMAIN,
                        GenericLogEntry.SeverityLevel.LOW
                    )
                    .logException(ex)
            );
        }
    }

    /**
     * @description It is used to assign the default values on newly created opportunities
     * post lead conversion.
     */
    public void assignValuesPostLeadConversion() {
        Map<Id, List<Contract>> accountIdToContracts = new Map<Id, List<Contract>>();
        List<Opportunity> changedOpportunityList = new List<Opportunity>(getOpportunities());
        accountIdToContracts = LeadConversionService.collectContractsOnAssociatedAccounts(
            changedOpportunityList
        );
        for (Opportunity eachOpportunity : changedOpportunityList) {
            if (String.isNotBlank(eachOpportunity.Converted_Lead_Id__c)) {
                eachOpportunity.StageName = PITCHING_STAGE;
                eachOpportunity.Substage__c = DISCOVERY;
                updateTypeAndSubTypeOnOpportunity(accountIdToContracts, eachOpportunity);
                eachOpportunity.OwnerId = UserInfo.getUserId();
                eachOpportunity.Deal_Type__c = DEAL_TYPE_STANDARD;
                if (eachOpportunity.Estimated_Number_of_Stores__c == null) {
                    eachOpportunity.Estimated_Number_of_Stores__c = 1;
                }
            }
        }
    }

    /**
     * @description It is used to update Type and Sub-Type for the passed Opportunity.
     * @param accountIdToContracts
     * @param currentOpportunity
     */
    private void updateTypeAndSubTypeOnOpportunity(
        Map<Id, List<Contract>> accountIdToContracts,
        Opportunity currentOpportunity
    ) {
        if (
            !accountIdToContracts.isEmpty() &&
            accountIdToContracts.containsKey(currentOpportunity.AccountId) &&
            (accountIdToContracts.get(currentOpportunity.AccountId).size() > 0)
        ) {
            currentOpportunity.Type = EXISTING_TYPE;
            currentOpportunity.Opportunity_Sub_Type__c = SUB_TYPE_NEW_STORE_EXPANSION;
        } else {
            currentOpportunity.Type = NEW_TYPE;
            currentOpportunity.Opportunity_Sub_Type__c = SUB_TYPE_NET_NEW_PARTNER;
        }
    }

    /**
     * @description It is used to update Last Inbound Date/Time for Opportunity.
     */
    public void updateLastInboundDateTime() {
        for (Opportunity eachOpportunity : (List<Opportunity>) getRecords()) {
            if (eachOpportunity.CampaignId != null) {
                eachOpportunity.Last_Inbound_Date_Time__c = System.now();
            }
        }
    }

    /**
     * @description It is used to assign the active Account plan on newly created opportunities LEM-17006
     * @description It is used to assign the active Account plan on newly created opportunities LEM-17006
     */
    public void assignActiveAccountPlanId() {
        Set<Id> businessAccountIdset = new Set<Id>();
        Map<Id, Id> accountToAccountPlanIdMap = new Map<Id, Id>();
        List<Opportunity> changedOpportunityList = new List<Opportunity>(getOpportunities());
        for (Opportunity eachOpportunity : changedOpportunityList) {
            if (eachOpportunity.Account_Plan__c == null) {
                businessAccountIdset.add(eachOpportunity.AccountId);
            }
        }
        if (businessAccountIdset.size() > 0 && Schema.sObjectType.Account_Plan__c.isAccessible()) {
            for (
                Account_Plan__c eachAccountPlan : AccountPlansSelector.newInstance()
                    .selectActiveAccountPlanByAccounts(businessAccountIdset)
            ) {
                accountToAccountPlanIdMap.put(eachAccountPlan.Account__c, eachAccountPlan.Id);
            }
        }
        for (Opportunity eachOpportunity : changedOpportunityList) {
            if (
                eachOpportunity.Account_Plan__c == null &&
                eachOpportunity.Type == EXISTING_TYPE &&
                accountToAccountPlanIdMap.get(eachOpportunity.AccountId) != null
            ) {
                eachOpportunity.Account_Plan__c = accountToAccountPlanIdMap.get(
                    eachOpportunity.AccountId
                );
            }
        }
    }

    /**
     * @description It is used to throw validation when Opportunities are moved
     * to Negotiating stage without any Events with held Status.
     */
    public void validateOpportunitiesMovedToNegotiatingWithoutHeldEvents() {
        List<Opportunity> opportunitiesWithChangedStage = (List<Opportunity>) getRecordsByFieldValues(
            Opportunity.StageName,
            new Set<Object>{ CONTRACTING_STAGE, NEGOTIATING_STAGE }
        );
        Set<Id> opportunityIds = (new Map<Id, SObject>(opportunitiesWithChangedStage)).keySet();
        Map<Id, Integer> opportunityIdToEventsCount = new Map<id, Integer>();
        if (opportunityIds.isEmpty()) {
            return;
        }
        for (
            Aggregate eachAggregate : EventsSelector.newInstance()
                .selectCountOfEventsByStatusAndRelatedToIds(opportunityIds, EVENT_STATUS_HELD)
        ) {
            opportunityIdToEventsCount.put(
                (Id) eachAggregate.get('WhatId'),
                (Integer) eachAggregate.get('countIds')
            );
        }
        for (Opportunity eachOpportunity : opportunitiesWithChangedStage) {
            if (
                eachOpportunity.Type == NEW_TYPE &&
                eachOpportunity.Account_Segment__c == ACCOUNT_SEGMENT_SMB
            ) {
                if (
                    eachOpportunity.StageName == NEGOTIATING_STAGE &&
                    !opportunityIdToEventsCount.containsKey(eachOpportunity.Id)
                ) {
                    eachOpportunity.addError(
                        System.Label.Error_on_Negotiating_Opportunity_without_held_Event
                    );
                } else if (
                    eachOpportunity.StageName == CONTRACTING_STAGE &&
                    eachOpportunity.SDR_Opportunity_Owner__c != null &&
                    !opportunityIdToEventsCount.containsKey(eachOpportunity.Id)
                ) {
                    eachOpportunity.addError(
                        System.Label.Error_on_Contracting_Opportunity_without_held_Event
                    );
                }
            }
        }
    }
}