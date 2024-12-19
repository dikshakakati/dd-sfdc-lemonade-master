/**
 * @author Deloitte
 * @date 22/03/2022
 * @description Selector Class for SBQQ__Quote__c Object
 */
public inherited sharing class QuotesSelector extends fflib_SObjectSelector implements IQuotesSelector {
    private static final String CONTRACT_SIGNATORY_CONTACT_ROLE = 'Contract Signatory';
    private static final String SELF_SERVE_HALTED_QUOTES_CONDITION = System.Label.Self_Serve_Halted_Quotes_Condition;
    private static final List<String> PRODUCT_FAMILIES = new List<String>{
        'Marketplace Promotion',
        'Advertisement',
        'Family'
    };
    private static final List<String> PRODUCT_NAMES = new List<String>{
        'Marketing Commitment',
        'CnG Search',
        'CnG DoubleDash',
        'CnG Collections',
        'CnG Categories'
    };
    private static final String SPONSORED_PRODUCTS_PACKAGE = 'Sponsored Products';
    private static final List<String> SPONSORED_PRODUCTS_NAMES = new List<String>{
        'CnG Search',
        'CnG DoubleDash',
        'CnG Collections',
        'CnG Categories'
    };
    private static final List<String> QUOTE_STATUSES_FOR_BRIEF_CREATION = new List<String>{
        'In Review',
        'Approved',
        'Contract Signed'
    };
    private static final Schema.Fieldset FIELDS_TO_QUERY = SObjectType.SBQQ__QuoteLine__c.FieldSets.Fields_for_Brief_Item_Creation;
    private static final String CONTRACT_SIGNED = 'Contract Signed';
    private static final String SPONSORSHIPS = 'Sponsorships';
    private static final String ACCOUNT_SEGMENT_SMB = 'SMB';
    /**
     * @description Default constructor for the Quotes Selector class
     * @return IQuotesSelector - interface of IQuotesSelector
     */
    public static IQuotesSelector newInstance() {
        return (IQuotesSelector) Application.Selector.newInstance(SBQQ__Quote__c.SObjectType);
    }

    /**
     * @description This method is used for getting the fields on Quote object
     * @return List of Schema.SObjectField
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            SBQQ__Quote__c.Id,
            SBQQ__Quote__c.SBQQ__Opportunity2__c,
            SBQQ__Quote__c.Name,
            SBQQ__Quote__c.Opt_In_Opt_Out_Decision__c,
            SBQQ__Quote__c.Opt_In_Out_Responsible_Party__c,
            SBQQ__Quote__c.Opt_In_Opt_Out_Response_Time_in_Days__c,
            SBQQ__Quote__c.Opt_Out_Save_Period_days__c,
            SBQQ__Quote__c.Migrated_Record__c,
            SBQQ__Quote__c.Quote_Migration_External_ID__c,
            SBQQ__Quote__c.SBQQ__Status__c,
            SBQQ__Quote__c.Contract_Signatory_Exists__c,
            SBQQ__Quote__c.SBQQ__StartDate__c,
            SBQQ__Quote__c.CurrencyIsoCode,
            SBQQ__Quote__c.SBQQ__Notes__c,
            SBQQ__Quote__c.SBQQ__Account__c,
            SBQQ__Quote__c.Signed_Contract_link__c,
            SBQQ__Quote__c.SBQQ__SalesRep__c,
            SBQQ__Quote__c.Franchise_Supplemental_Agreement_Link__c,
            SBQQ__Quote__c.Signed_Contract_link__c,
            SBQQ__Quote__c.Use_Corporate_Cherry_Picking__c,
            SBQQ__Quote__c.SBQQ__Type__c,
            SBQQ__Quote__c.Jira_Request_Ticket_link__c,
            SBQQ__Quote__c.Jira_Request_Ticket_status__c,
            SBQQ__Quote__c.Contract_Generation_Path__c,
            SBQQ__Quote__c.Approval_Requested_Reason__c,
            SBQQ__Quote__c.Number_of_Stores__c,
            SBQQ__Quote__c.Check_Start_Date_For_A_P_Product__c,
            SBQQ__Quote__c.Check_Delay_After_Activation_For_A_P__c,
            SBQQ__Quote__c.Unique_Identifier__c,
            SBQQ__Quote__c.Contracting_Flow__c,
            SBQQ__Quote__c.Nintex_Use_Case__c,
			SBQQ__Quote__c.Slack_Notification_To_Opportunity_Owner__c
        };
    }

    /**
     * @description This method is used for getting object type
     * @return Quote - Quote fields
     */
    public Schema.SObjectType getSObjectType() {
        return SBQQ__Quote__c.SObjectType;
    }

    /**
     * @description This method is used for getting Quotes based on Id
     * @param setIds Set of Ids
     * @return list of Quote records
     */
    public List<SBQQ__Quote__c> selectById(Set<Id> setIds) {
        return (List<SBQQ__Quote__c>) selectSObjectsById(setIds);
    }

    /**
     * @description This method is used to get the list of child quotes for opportunities
     * @param opportunityIds
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectByOpportunity(Set<Id> opportunityIds) {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.selectField('Segment__c');
        query.setCondition('SBQQ__Opportunity2__c IN: opportunityIds');
        return (List<SBQQ__Quote__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It queries related Quote Line Items and Quote Brief Relationships
     * by the passed parent Quote Ids.
     * @param quoteIds
     * @return List<SBQQ__Qoote__c>
     */
    public List<SBQQ__Quote__c> selectQuotesWithQuoteLineAndQuoteBriefRelationships(
        Set<Id> quoteIds
    ) {
        fflib_QueryFactory quoteQuery = newQueryFactory()
            .selectField('SBQQ__Opportunity2__r.OwnerId')
            .selectField('SBQQ__Opportunity2__r.Purchase_Order__c')
            .selectField('Payment_Account__r.NetSuite_ID__c')
            .selectField('SBQQ__Account__r.OwnerId')
            .setCondition(
                'Id IN :quoteIds AND SBQQ__Primary__c = TRUE AND SBQQ__Status__c IN :QUOTE_STATUSES_FOR_BRIEF_CREATION AND Segment__c != :ACCOUNT_SEGMENT_SMB'
            );

        new QuoteLineItemsSelector()
            .addQueryFactorySubselect(quoteQuery, 'SBQQ__LineItems__r')
            .selectFieldSet((Schema.FieldSet) FIELDS_TO_QUERY)
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__c')
            .selectField('SBQQ__Quote__r.SBQQ__Account__r.OwnerId')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.Purchase_Order__c')
            .selectField('SBQQ__Quote__r.Payment_Account__r.NetSuite_ID__c')
            .selectField('Package__c')
            .selectField('SBQQ__Quote__r.Invoicing_Payment_Account__r.Type__c')
            .selectField('SBQQ__Quote__r.SBQQ__Opportunity2__r.Agency__c')
            .selectField('SBQQ__Quote__r.Signed_Contract_link__c')
            .selectField('SBQQ__Quote__r.Invoicing_Payment_Account__r.NetSuite_ID__c')
            .setCondition(
                'SBQQ__ProductFamily__c  IN :PRODUCT_FAMILIES AND ' +
                    '((SBQQ__ProductName__c NOT IN :PRODUCT_NAMES AND Campaign_Name__c != null) OR ' +
                    '((SBQQ__ProductName__c IN :SPONSORED_PRODUCTS_NAMES OR Package__c = :SPONSORSHIPS) AND ' +
                    ' SBQQ__RequiredBy__r.Campaign_Name__c != null) OR ' +
                    '(SBQQ__ProductName__c = :SPONSORED_PRODUCTS_PACKAGE AND Campaign_Name__c != null))'
            );
        new QuoteBriefRelationshipsSelector()
            .addQueryFactorySubselect(quoteQuery, 'Quote_Brief_Relationships__r')
            .setCondition(
                'Quote__c IN :quoteIds AND Campaign_of_Brief__c != null AND Brief__c != null'
            );
        return (List<SBQQ__Quote__c>) Database.query(quoteQuery.toSOQL());
    }

    /**
     * @description This method is used to get the list of contract signed child quotes for accounts
     * @param accountIds
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectByAccounts(Set<Id> accountIds) {
        fflib_QueryFactory query = newQueryFactory(false, false, true);
        query.setCondition(
            'SBQQ__Account__c IN: accountIds AND SBQQ__Status__c = :CONTRACT_SIGNED'
        );
        return (List<SBQQ__Quote__c>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used to fetch fields from quotes from which an amendment is amended.
     * @param quoteIds
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectQuoteFieldsFromOriginalQuote(Set<Id> quoteIds) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('Is_this_for_Ads_Promos__c')
            .selectField('SBQQ__MasterEvergreenContract__c')
            .selectField('SBQQ__MasterEvergreenContract__r.SBQQ__Order__c')
            .selectField('SBQQ__MasterEvergreenContract__r.SBQQ__Order__r.SBQQ__Quote__c')
            .selectField('SBQQ__MasterEvergreenContract__r.Contract_Split_Category__c')
            .selectField(
                'SBQQ__MasterEvergreenContract__r.SBQQ__Order__r.SBQQ__Quote__r.Is_this_for_Ads_Promos__c'
            )
            .setCondition(
                'Id IN :quoteIds ' +
                    'AND SBQQ__MasterEvergreenContract__c != NULL ' +
                    'AND SBQQ__MasterEvergreenContract__r.SBQQ__Order__c != NULL ' +
                    'AND SBQQ__MasterEvergreenContract__r.SBQQ__Order__r.SBQQ__Quote__c != NULL'
            );
        return (List<SBQQ__Quote__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description It is used to select quotes by the passed unique identifiers.
     * @JIRA LEM-14588
     * @param uniqueIdentifiers
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectQuotesbyUniqueIdentifiers(Set<String> uniqueIdentifiers) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Unique_Identifier__c')
            .selectField('CurrencyIsoCode')
            .selectField('RESSMO_Payload__c')
            .selectField('SBQQ__Opportunity2__c')
            .selectField('SBQQ__Opportunity2__r.RESSMO_Link__c')
            .selectField('SBQQ__Opportunity2__r.Accepted_Partnership_Details__c')
            .selectField('SBQQ__Primary__c')
            .selectField('SBQQ__Opportunity2__r.CloseDate')
            .setCondition('Unique_Identifier__c IN :uniqueIdentifiers');
        return (List<SBQQ__Quote__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Retrieves a list of SBQQ__Quote__c records along with their related Quote Lines
     * @JIRA LEM-16305
     * @param quoteIds The set of Quote record IDs to retrieve.
     * @param fieldSetMap the map of Quote , QuoteLine, Contact with set of fields respectively
     * @return A list of SBQQ__Quote__c records with their related Quote Lines and OCR with given fields
     */
    public List<SBQQ__Quote__c> selectQuotewithQuoteLinesAndOpportunityContactRoleWithGivenFields(
        Set<Id> quoteIds,
        Map<String, Set<String>> fieldSetMap
    ) {
        fflib_QueryFactory quoteQuery = newQueryFactory()
            .selectFields(fieldSetMap.get('SBQQ__Quote__c'))
            .selectField('SBQQ__SalesRep__r.Email')
            .selectField('SBQQ__Primary__c')
            .selectField('SBQQ__Opportunity2__r.RESSMO_Link__c')
            .selectField('SBQQ__Opportunity2__r.StageName')
            .selectField('SBQQ__Opportunity2__r.Opportunity_Sub_Type__c')
            .selectField('SSMO_Expiration_Date__c')
            .selectField('RESSMO_Store_Account_Id__c')
            .selectField('SBQQ__Account__r.BillingCountry')
            .selectField('SBQQ__Account__r.Segment__c')
            .selectField('SBQQ__Account__r.Primary_Vertical__c')
            .selectField('UTA_Check__c')
            .selectField('SSMO_Validation__c')
            .selectField('RESSMO_Store_Account_Id__c')
            .selectField('SBQQ__Status__c')
            .selectField('Store_Specific_Variations__c')
            .selectField('Contracting_Flow__c')
            .setCondition('Id IN :quoteIds');

        new QuoteLineItemsSelector()
            .addQueryFactorySubselect(quoteQuery, 'SBQQ__LineItems__r')
            .selectField('SBQQ__Product__r.ProductCode')
            .selectField('SBQQ__Product__r.SSMO_Eligible__c')
            .selectField('SBQQ__Product__r.Name')
            .selectField('SBQQ__RequiredBy__c')
            .selectFields(fieldSetMap.get('SBQQ__QuoteLine__c'));

        new OpportunityContactRoleSelector()
            .addQueryFactorySubselect(quoteQuery, 'Opportunity_Contact_Role__r')
            .selectFields(fieldSetMap.get('Contact'))
            .selectField('Contact.Name')
            .setCondition('Role = :CONTRACT_SIGNATORY_CONTACT_ROLE')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (List<SBQQ__Quote__c>) Database.query(quoteQuery.toSOQL());
    }

    /**
     * @description - select business account details related to the quote along with contract signatory
     * @author Soumya Dash | 07-30-2024
     * @param quoteId
     * @param fields
     * @return SBQQ__Quote__c
     **/
    public SBQQ__Quote__c selectByIdWithBusinessAccount(
        Id quoteId,
        map<String, set<String>> fields
    ) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('SBQQ__Account__r.Name')
            .selectField('SBQQ__Account__r.Total_Number_Of_Stores__c')
            .selectField('SBQQ__Account__c')
            .selectField('SBQQ__Opportunity2__r.RESSMO_Link__c')
            .selectField('RESSMO_Store_Account_Id__c')
            .selectField('SBQQ__Opportunity2__c') //LEM-17078
            .selectField('RESSMO_Payload__c')
            .selectField('SBQQ__Account__r.Legal_Business_Name__c')
            .selectFields(fields.get('SBQQ__Quote__c'))
            .setCondition('Id = :quoteId')
            .setLimit(1);

        new OpportunityContactRoleSelector()
            .addQueryFactorySubselect(query, 'Opportunity_Contact_Role__r')
            .selectFields(fields.get('Contact'))
            .selectField('Contact.Unique_Identifier__c')
            .setCondition('Role = :CONTRACT_SIGNATORY_CONTACT_ROLE')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);

        return (SBQQ__Quote__c) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get all the Original Quote field values by passing Quote Id.
     * @param quoteId
     * @param targetFieldAPIs
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectOriginalQuotewithDynamicFields(
        Set<Id> quoteId,
        Set<String> targetFieldAPIs
    ) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectFields(targetFieldAPIs);
        query.setCondition('Id = :quoteId');
        return (List<SBQQ__Quote__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to select primary quotes with status contract signed
     * by the passed account ids.
     * @JIRA LEM-15849
     * @param accountIdsToUpdate
     * @return List<SBQQ__Quote__c>
     */
    public List<SBQQ__Quote__c> selectPrimaryQuotesBySalesforceAccountIds(
        Set<Id> accountIdsToUpdate
    ) {
        fflib_QueryFactory quoteLineQuery = newQueryFactory()
            .selectField('Custom_Partnership_Type__c')
            .selectField('SBQQ__StartDate__c')
            .selectField('Initial_Term_and_Termination_Years__c')
            .selectField('Contract_Signed_Date__c')
            .selectField('SBQQ__Account__c')
            .selectField('SSMO_Validation__c')
            .setCondition(
                'SBQQ__Account__c  IN :accountIdsToUpdate ' +
                    'AND SBQQ__Primary__c = true ' +
                    'AND Initial_Term_and_Termination_Years__c != null ' +
                    'AND SBQQ__Status__c = :CONTRACT_SIGNED'
            )
            .setOrdering('Contract_Signed_Date__c', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (List<SBQQ__Quote__c>) Database.query(quoteLineQuery.toSOQL());
    }

    /**
     * @description select quote by quoteId with given fields
     * @author SamikshaDD | 07-12-2024
     * @param quoteIds
     * @param fieldSet
     * @return List<SBQQ__Quote__c>
     **/
    public List<SBQQ__Quote__c> selectQuoteByIdWithGivenFields(
        Set<Id> quoteIds,
        Set<String> fieldSet
    ) {
        fflib_QueryFactory quoteQuery = newQueryFactory()
            .selectFields(fieldSet)
            .setCondition('Id IN :quoteIds');

        return (List<SBQQ__Quote__c>) Database.query(quoteQuery.toSOQL());
    }

    /**
     * @description - select business account details related to the quote
     * @JIRA# LEM-17078
     * @param quoteId
     * @return SBQQ__Quote__c
     **/
    public SBQQ__Quote__c selectByIdWithAccountOpportunityContacts(Id quoteId) {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('SBQQ__Account__r.Name')
            .selectField('SBQQ__Account__c')
            .selectField('SSMO_Expiration_Date__c')
            .selectField('RESSMO_Store_Account_Id__c')
            .selectField('SBQQ__Opportunity2__c')
            .setCondition('Id = :quoteId')
            .setLimit(1);

        new OpportunityContactRoleSelector()
            .addQueryFactorySubselect(query, 'Opportunity_Contact_Role__r')
            .selectField('Contact.Unique_Identifier__c')
            .selectField('Contact.FirstName')
            .selectField('Contact.LastName')
            .selectField('Contact.Id')
            .selectField('Contact.Email')
            .setCondition('Role = :CONTRACT_SIGNATORY_CONTACT_ROLE')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
            .setLimit(1);
        return (SBQQ__Quote__c) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to query the self-serve A&P quotes that are stuck in non-primary and
     * approved status. It selects the quotes created before the current date.
     * @JIRA #LEM-23462
     * @return Database.QueryLocator
     **/
    public Database.QueryLocator selectSelfServeHaltedQuotes() {
        fflib_QueryFactory query = newQueryFactory(false)
            .selectField('SBQQ__Opportunity2__r.Ingestion_log_Id__c')
            .selectField('SBQQ__Primary__c')
            .selectField('SBQQ__Status__c')
            .selectField('SBQQ__Ordered__c')
            .setCondition(SELF_SERVE_HALTED_QUOTES_CONDITION);
        return Database.getQueryLocator(query.toSOQL());
    }
}