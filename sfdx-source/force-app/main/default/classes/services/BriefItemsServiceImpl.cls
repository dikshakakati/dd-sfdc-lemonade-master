/**
 * @author Deloitte
 * @date 11/10/2022
 * @description Service implementation class for logic related to Brief Items.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public inherited sharing class BriefItemsServiceImpl implements IBriefItemsService {
    private static final String BANNER_TYPE_HOMEPAGE = 'Home Page';
    private static final String CRM_CAMPAIGN_TYPE_EMAIL = 'Email';
    private static final String HYPHEN_DELIMITER = ' - ';
    private static final String NOT_APPLICABLE_TEXTAREA = 'N/A';
    private static final String PAYMENT_PROTOCOL_INVOICING = 'Invoicing';
    private static final String PICKLIST_VALUE_NO = 'No';
    private static final String PICKLIST_VALUE_YES = 'Yes';
    private static final String PRICING_TYPE_FLAT_FEE = 'Flat Fee';
    private static final String STATUS_WAITINGFORINPUTS = 'Waiting for Inputs';
    private static final String STATUS_CAMPAIGN_BUILDING = 'Campaign Building';
    private static final String BLANK_VALUE = '';
    private static final String SPONSORED_PRODUCTS = 'Sponsored Products';
    private static final String SPONSORSHIPS = 'Sponsorships';
    private static final String IN_CAMPAIGN_CHANGE = 'In_Campaign_Change__c';
    private static final String IN_CAMPAIGN_CHANGE_YES = 'Yes';
    private static final String IN_CAMPAIGN_CHANGE_COMPLETE = 'Yes-Completed';
    private static final String CAMPAIGN_FULLFILLMENT_FOLDER = 'Campaign Fulfillment Email Templates';
    private static final String TABLE_HEADER = '<table border="1" style="border-collapse: collapse"><caption style="text-align:left"><b>Change(s):</b></caption><tr><th>Field</th><th>Old Value</th><th>New Value</th></tr>';
    private static final String TABLE_CLOSE_TAG = '</table>';
    private static final String LINE_BREAK = '<br>';
    private static final String EMAIL_SUBJECT = 'In-campaign change requested for ';
    private static final String OPP_OWNER = '<b>Opportunity owner:</b> ';
    private static final String BRIEF_ITEM_STRING = '<b>Brief item link:</b> ';
    private static final String HTML_BODY_TEXT_START = 'An in-campaign change has been requested for ';
    private static final String HTML_BODY_TEXT_END = '. Please see details below: <br><br>';
    private static final String ACCOUNT_STRING = '<b>Account:</b> ';
    private static final String CAMPAIGN_NAME_STRING = '<b>Campaign name:</b> ';
    private static final String TABLE_ROW = '<tr>';
    private static final String TABLE_ROW_CLOSE = '</tr>';
    private static final String TABLE_DATA = '<td>';
    private static final String TABLE_DATA_CLOSE = '</td>';
    private static final String HYPERLINK_START = '<a href="';
    private static final String HYPERLINK_MID = '">';
    private static final String HYPERLINK_END = '</a>';
    private Map<Id, List<SBQQ__QuoteLine__c>> sponsoredProductsToCnGProductIds;
    private Map<Id, Set<Id>> existingBriefsToQuotes;
    private Map<Id, Set<Id>> briefsToQuotes;
    private Map<Id, String> briefsToCampaign;
    private fflib_ISObjectUnitOfWork unitOfWorkBriefItemCreation;
    private Set<SBQQ__QuoteLine__c> sponsoredProductsHavingBriefItemsToCnGProduct;
    private static final String CONTENT_DOC_PATH = '/lightning/r/ContentDocument/';
    private static final String VIEW = '/view';
    private static final Set<String> BRIEF_CAMPAIGN_STATUS_UPDATES = new Set<String>{
        'Cancelled',
        'Waiting for Inputs'
    };
    List<Quote_Line_to_Brief_Item_Mapping__mdt> quoteLineToBriefItemFieldMapping;

    /**
     * @description Singleton reference to the dummy Contact needed to make the Email Templates function properly.
     *              This query was being executed multiple times per transaction, leading to SOQL issues. While we
     *              are continuing with this approach for now in a more optimized form, this should be revisited later
     *              to confirm if its use is still needed, as it still runs a query against the Contact object.
     * @return Contact
    **/    
    private static Contact dummyContactForEmailSend {get {
        if(dummyContactForEmailSend == null) {
            // For the templatized Email we must send in a Contact Id with the SetTargetObjectId call.
            // We can set a Brief_Item__c using the setWhatId call, and the Brief_Item__c
            // will be used to get the info for the email template.  We can use any Contact, but a valid contact must be set
            // for the email template to work correctly.            
            dummyContactForEmailSend = ContactsSelector.newInstance().selectDummyContact();
        }

        return dummyContactForEmailSend;
    } set;}

    private enum FieldNames {
        CNG_SEARCH,
        CNG_DOUBLE_DASH,
        CNG_COLLECTIONS,
        CNG_CATEGORIES
    }
    private static final Map<String, FieldNames> PRODUCTS_TO_SPONSORED_PRODUCTS_NAME = new Map<String, FieldNames>{
        'CnG Search' => FieldNames.CNG_SEARCH,
        'CnG DoubleDash' => FieldNames.CNG_DOUBLE_DASH,
        'CnG Collections' => FieldNames.CNG_COLLECTIONS,
        'CnG Categories' => FieldNames.CNG_CATEGORIES
    };
    private static final Set<String> PRODUCTS_ON_BRIEF_ITEM_EXCLUSION = new Set<String>{
        'CnG Search',
        'CnG DoubleDash',
        'CnG Collections',
        'CnG Categories',
        'Sponsorships'
    };

    /**
     * @description Default constructor to initialize class variables.
     */
    public BriefItemsServiceImpl() {
        sponsoredProductsToCnGProductIds = new Map<Id, List<SBQQ__QuoteLine__c>>();
        existingBriefsToQuotes = new Map<Id, Set<Id>>();
        briefsToQuotes = new Map<Id, Set<Id>>();
        briefsToCampaign = new Map<Id, String>();
        unitOfWorkBriefItemCreation = Application.UNITOFWORK.newInstance();
        sponsoredProductsHavingBriefItemsToCnGProduct = new Set<SBQQ__QuoteLine__c>();
        quoteLineToBriefItemFieldMapping = QuoteLineBriefItemMappingSelector.newInstance()
            .getAllValues();
    }

    /**
     * @description It is used to collect all the CnG Products for each Sponsored Product
     * @param quoteLineItems
     */
    private void collectCnGProductsForEachSponsoredProduct(
        List<SBQQ__QuoteLine__c> quoteLineItems
    ) {
        for (SBQQ__QuoteLine__c eachQuoteLineItem : quoteLineItems) {
            if (
                !isProductCnG(eachQuoteLineItem) ||
                (eachQuoteLineItem.SBQQ__RequiredBy__c == null && isProductCnG(eachQuoteLineItem))
            ) {
                continue;
            }
            if (eachQuoteLineItem.SBQQ__RequiredBy__r.Has_Brief_Item__c) {
                sponsoredProductsHavingBriefItemsToCnGProduct.add(
                    eachQuoteLineItem.SBQQ__RequiredBy__r
                );
            }
            if (
                !sponsoredProductsToCnGProductIds.containsKey(eachQuoteLineItem.SBQQ__RequiredBy__c)
            ) {
                sponsoredProductsToCnGProductIds.put(
                    eachQuoteLineItem.SBQQ__RequiredBy__c,
                    new List<SBQQ__QuoteLine__c>{ eachQuoteLineItem }
                );
            } else {
                sponsoredProductsToCnGProductIds.get(eachQuoteLineItem.SBQQ__RequiredBy__c)
                    .add(eachQuoteLineItem);
            }
        }
    }

    /**
     * @description It is used to create Brief Items for all Quote Line Items related to the
     * contract signed Quotes.
     * @param quoteLineItems
     * @param quoteBriefRelationships
     */
    public void generateBriefItemsByQuoteLineItems(
        List<SBQQ__QuoteLine__c> quoteLineItems,
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    ) {
        Quote_Brief_Relationship__c quoteBriefRelationship;
        generateExistingBriefsToQuoteIds(quoteBriefRelationships);
        Map<String, Quote_Brief_Relationship__c> campaignQuoteToBrief = new Map<String, Quote_Brief_Relationship__c>();
        String campaignIdentifierKey = '';
        Brief_Item__c briefItem;
        campaignQuoteToBrief = getCampaignQuoteRelationshipMappings(quoteBriefRelationships);
        collectCnGProductsForEachSponsoredProduct(quoteLineItems);
        for (SBQQ__QuoteLine__c eachQuoteLineItem : quoteLineItems) {
            if (PRODUCTS_ON_BRIEF_ITEM_EXCLUSION.contains(eachQuoteLineItem.SBQQ__ProductName__c)) {
                continue;
            }
            if (isProductCnG(eachQuoteLineItem)) {
                continue;
            }
            if(eachQuoteLineItem.Create_Brief_Item__c == PICKLIST_VALUE_NO){
                continue;
            }
            campaignIdentifierKey = getCampaignQuoteKey(eachQuoteLineItem);
            quoteBriefRelationship = campaignQuoteToBrief.containsKey(campaignIdentifierKey)
                ? campaignQuoteToBrief.get(campaignIdentifierKey)
                : null;
            briefItem = createBriefItemInstanceBySponsoredProductQuoteLineItem(
                quoteBriefRelationship,
                eachQuoteLineItem
            );

            if (briefItem != null) {
                generateBriefsToQuoteIds(briefItem, eachQuoteLineItem);
                unitOfWorkBriefItemCreation.registerNew(briefItem);
                eachQuoteLineItem.Has_Brief_Item__c = true;
                unitOfWorkBriefItemCreation.registerDirty(eachQuoteLineItem);
            }
        }
        updateSponsoredProductBriefItemForCnGProductAddition();
        commitUnitOfWork(unitOfWorkBriefItemCreation);
        QuoteBriefRelationshipsService.createQuoteBriefRelationshipsWithBriefToQuoteMapping(
            briefsToQuotes,
            briefsToCampaign
        );
    }

    /**
     * @description Product is CnG as per PRODUCTS_TO_SPONSORED_PRODUCTS_NAME
     * @param eachQuoteLineItem
     * @return Boolean
     */
    private Boolean isProductCnG(SBQQ__QuoteLine__c eachQuoteLineItem) {
        return PRODUCTS_TO_SPONSORED_PRODUCTS_NAME.keySet()
            .contains(eachQuoteLineItem.SBQQ__ProductName__c);
    }

    /**
     * @description It is used to create a mapping between Campaign-Quote and Brief.
     * @param quoteBriefRelationships
     * @return Map<String, Quote_Brief_Relationship__c>
     */
    public Map<String, Quote_Brief_Relationship__c> getCampaignQuoteRelationshipMappings(
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    ) {
        String campaignIdentifierKey = '';
        Map<String, Quote_Brief_Relationship__c> campaignQuoteToBrief = new Map<String, Quote_Brief_Relationship__c>();
        for (Quote_Brief_Relationship__c eachRelationship : quoteBriefRelationships) {
            campaignIdentifierKey =
                eachRelationship.Campaign_of_Brief__c +
                HYPHEN_DELIMITER +
                eachRelationship.Account__c;
            if (!campaignQuoteToBrief.containsKey(campaignIdentifierKey)) {
                campaignQuoteToBrief.put(campaignIdentifierKey, eachRelationship);
            }
        }
        return campaignQuoteToBrief;
    }

    /**
     * @description It is used to generate a map of Briefs with all the related Quote Ids for
     * already existing Quote Brief Relationships
     * @param quoteBriefRelationships
     */
    private void generateExistingBriefsToQuoteIds(
        List<Quote_Brief_Relationship__c> quoteBriefRelationships
    ) {
        for (Quote_Brief_Relationship__c eachRelationship : quoteBriefRelationships) {
            if (!existingBriefsToQuotes.containsKey(eachRelationship.Brief__c)) {
                existingBriefsToQuotes.put(eachRelationship.Brief__c, new Set<Id>());
            }
            existingBriefsToQuotes.get(eachRelationship.Brief__c).add(eachRelationship.Quote__c);
        }
    }

    /**
     * @description It is used to generate a map of Briefs with all related Quote Ids to create new
     * Quote Brief Relationships
     * @param newBriefItem
     * @param quoteLineItem
     */
    private void generateBriefsToQuoteIds(
        Brief_Item__c newBriefItem,
        SBQQ__QuoteLine__c quoteLineItem
    ) {
        if (!briefsToQuotes.containsKey(newBriefItem.Brief__c)) {
            briefsToQuotes.put(newBriefItem.Brief__c, new Set<Id>());
        }
        Boolean checkForExistingBriefToQuoteRelationship =
            !existingBriefsToQuotes.containsKey(newBriefItem.Brief__c) ||
            !existingBriefsToQuotes.get(newBriefItem.Brief__c)
                .contains(quoteLineItem.SBQQ__Quote__c);
        if (checkForExistingBriefToQuoteRelationship) {
            briefsToQuotes.get(newBriefItem.Brief__c).add(quoteLineItem.SBQQ__Quote__c);
            briefsToCampaign.put(newBriefItem.Brief__c, quoteLineItem.Campaign_Name__c);
        }
    }

    /**
     * @description It is used to generate key to map Quote Brief Relationships by Quote Line Items.
     * @param quoteLineItem
     * @return campaignQuoteKey
     */
    private String getCampaignQuoteKey(SBQQ__QuoteLine__c quoteLineItem) {
        String campaignName = (isProductCnG(quoteLineItem) ||
            quoteLineItem.Package__c == SPONSORSHIPS)
            ? quoteLineItem.SBQQ__RequiredBy__r.Campaign_Name__c
            : quoteLineItem.Campaign_Name__c;
        return campaignName + HYPHEN_DELIMITER + quoteLineItem.SBQQ__Quote__r.SBQQ__Account__c;
    }

    /**
     * @description It is used to initialize the Brief Item for
     * Quote Lines of Sponsored Products package.
     * @param quoteBriefRelationship
     * @param quoteLineItem
     * @return Brief_Item__c
     */
    public Brief_Item__c createBriefItemInstanceBySponsoredProductQuoteLineItem(
        Quote_Brief_Relationship__c quoteBriefRelationship,
        SBQQ__QuoteLine__c quoteLineItem
    ) {
        Brief_Item__c briefItem;
        if (quoteBriefRelationship != null && !quoteLineItem.Has_Brief_Item__c) {
            briefItem = new Brief_Item__c(
                Brief__c = quoteBriefRelationship.Brief__c,
                CurrencyIsoCode = quoteLineItem.SBQQ__Quote__r.CurrencyIsoCode,
                Status__c = STATUS_WAITINGFORINPUTS,
                Number_of_Campaign_Setup_Errors_Found__c = 0,
                Opportunity_Owner__c = quoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId,
                Holdout_Audience_Experiment__c = PICKLIST_VALUE_NO,
                Evergreen_Ongoing_Promo__c = quoteLineItem.End_Date__c != null
                    ? PICKLIST_VALUE_NO
                    : PICKLIST_VALUE_YES,
                Store_Page_Banner_Included_for_Promo__c = PICKLIST_VALUE_NO
            );
            updateAgencyFields(briefItem, quoteLineItem);
            if (quoteLineItem.SBQQ__ProductName__c == SPONSORED_PRODUCTS) {
                updateBriefBidVariables(briefItem, quoteLineItem);
            }
            mapQuoteLineFieldsToBriefItem(quoteLineToBriefItemFieldMapping, quoteLineItem, briefItem);
        }
        return briefItem;
    }

    /**
     * @description updates bid values for different products of sponsored product.
     * @param briefItem
     * @param sponsoredBriefLineItem
     */
    private void updateBriefBidVariables(
        Brief_Item__c briefItem,
        SBQQ__QuoteLine__c sponsoredBriefLineItem
    ) {
        if (sponsoredProductsToCnGProductIds.get(sponsoredBriefLineItem.Id) == null) {
            return;
        }
        Decimal categoriesBid = null;
        Decimal collectionsBid = null;
        Decimal doubleDashBid = null;
        Decimal searchBid = null;
        for (
            SBQQ__QuoteLine__c eachRelatedCnGQuoteLineItem : sponsoredProductsToCnGProductIds.get(
                sponsoredBriefLineItem.Id
            )
        ) {
            switch on
                PRODUCTS_TO_SPONSORED_PRODUCTS_NAME.get(
                    eachRelatedCnGQuoteLineItem.SBQQ__ProductName__c
                ) {
                when CNG_CATEGORIES {
                    categoriesBid = eachRelatedCnGQuoteLineItem.Bid__c;
                }
                when CNG_COLLECTIONS {
                    collectionsBid = eachRelatedCnGQuoteLineItem.Bid__c;
                }
                when CNG_DOUBLE_DASH {
                    doubleDashBid = eachRelatedCnGQuoteLineItem.Bid__c;
                }
                when CNG_SEARCH {
                    searchBid = eachRelatedCnGQuoteLineItem.Bid__c;
                }
            }
        }
        briefItem.Categories_Bid__c = categoriesBid;
        briefItem.Collections_Bid__c = collectionsBid;
        briefItem.DoubleDash_Bid__c = doubleDashBid;
        briefItem.Search_Bid__c = searchBid;
    }

    /**
     * @description updates bid values for different products of sponsored product when brief item
     * is available
     */
    private void updateSponsoredProductBriefItemForCnGProductAddition() {
        if (sponsoredProductsHavingBriefItemsToCnGProduct.isEmpty()) {
            return;
        }
        Brief_Item__c briefItemToUpdate;
        Map<Id, SBQQ__QuoteLine__c> sponsoredProductQuoteLineIdsWithBriefItems = new Map<Id, SBQQ__QuoteLine__c>(
            new List<SBQQ__QuoteLine__c>(sponsoredProductsHavingBriefItemsToCnGProduct)
        );
        for (
            Brief_Item__c eachBriefItem : BriefItemsSelector.newInstance()
                .selectByQuoteLineItems(sponsoredProductQuoteLineIdsWithBriefItems.keySet())
        ) {
            briefItemToUpdate = new Brief_Item__c(Id = eachBriefItem.Id);
            SBQQ__QuoteLine__c quoteWithBriefItem = sponsoredProductQuoteLineIdsWithBriefItems.get(
                eachBriefItem.Quote_Line__c
            );
            updateBriefBidVariables(briefItemToUpdate, quoteWithBriefItem);
            unitOfWorkBriefItemCreation.registerDirty(briefItemToUpdate);
        }
    }
    /**
     * @description updates the in-campaign field if a required field is changed
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    public void sendCampaignCompletedEmails(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    ) {
        Map<Schema.SObjectField, Boolean> briefItemTrackingMap = BriefItemTrackingSelector.newInstance()
            .getAllTrackingFields();
        List<Schema.SObjectField> briefItemFields = new List<Schema.SObjectField>();
        briefItemFields.addAll(briefItemTrackingMap.keySet());
        List<Brief_Item__c> campaignCompleteEmails = new List<Brief_Item__c>();
        List<Brief_Item__c> campaignChangeEmails = new List<Brief_Item__c>();
        for (Brief_Item__c briefItemInstance : changedBriefItemsList) {
            if (
                briefItemInstance.In_Campaign_Change__c == IN_CAMPAIGN_CHANGE_COMPLETE &&
                existingBriefItemMap.get(briefItemInstance.Id).get(IN_CAMPAIGN_CHANGE) ==
                IN_CAMPAIGN_CHANGE_YES
            ) {
                campaignCompleteEmails.add(briefItemInstance);
            }
            if (
                briefItemInstance.In_Campaign_Change__c == IN_CAMPAIGN_CHANGE_YES &&
                existingBriefItemMap.get(briefItemInstance.Id).get(IN_CAMPAIGN_CHANGE) !=
                IN_CAMPAIGN_CHANGE_YES
            ) {
                campaignChangeEmails.add(briefItemInstance);
            }
        }
        sendCampaignChangeRequestEmail(campaignCompleteEmails, 1, null);
        sendCampaignChangeRequestEmail(campaignChangeEmails, 0, null);
    }
    /**
     * @description creates brief Item tracking records for each updated brief item field
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    public void createBriefItemTrackingRecords(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    ) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Map<Id,String> briefItemIdWithMailBody = New Map<Id,String>();
        List<Brief_Item__c> briefItemEmails = new List<Brief_Item__c>();
        Map<Schema.SObjectField, Boolean> briefItemTrackingMap = BriefItemTrackingSelector.newInstance().getAllTrackingFields();
        List<Schema.SObjectField> briefItemFields = new List<Schema.SObjectField>();
        briefItemFields.addAll(briefItemTrackingMap.keySet());
        for (Brief_Item__c briefItemInstance : changedBriefItemsList) {
            String htmlBody = TABLE_HEADER;
            Brief_Item__c existingBriefItem  = (Brief_Item__c)existingBriefItemMap.get(briefItemInstance.Id);
            if ((existingBriefItem != null) && shouldBriefItemTrackingObjectBeCreated(existingBriefItem, briefItemInstance)) {
                for (Schema.SObjectField fieldName : briefItemFields) {
                    if ( (briefItemInstance.get(fieldName)) != (existingBriefItem.get(fieldName)))
                    {
                        htmlBody += TABLE_ROW + TABLE_DATA + fieldName.getDescribe().getLabel() + TABLE_DATA_CLOSE + TABLE_DATA + String.valueOf(
                                existingBriefItem.get(fieldName)) + TABLE_DATA_CLOSE + TABLE_DATA + String.valueOf(
                                briefItemInstance.get(fieldName))+ TABLE_DATA_CLOSE + TABLE_ROW_CLOSE;
                        Brief_Item_Field_Tracking__c briefItemTrackingObj = new Brief_Item_Field_Tracking__c(
                            Field_Name__c = fieldName.getDescribe().getLabel(),
                            Prior_Value_Rich_Text__c = String.valueOf(
                                existingBriefItem.get(fieldName)
                            ),
                            New_Value_Rich_Text__c = String.valueOf(
                                briefItemInstance.get(fieldName)
                            ),
                            Brief_Item__c = briefItemInstance.Id
                        );
                        uow.registerNew(briefItemTrackingObj);
                    }
                }
                htmlBody += TABLE_CLOSE_TAG;
                briefItemIdWithMailBody.put(briefItemInstance.Id, htmlBody);
                briefItemEmails.add(briefItemInstance);
            }
        }
        commitUnitOfWork(uow);
        sendCampaignChangeRequestEmail(briefItemEmails, null, briefItemIdWithMailBody);
    }
    /**
     * @description sends email to opp owner when brief item in campaign changes
     * *template param of 0 indicates Change Request Template 1 indicates change complete
     * @param briefItemsChanged
     * @param template
     * @param briefItemIdWithMailBody
     */
    private void sendCampaignChangeRequestEmail(
        List<Brief_Item__c> briefItemsChanged,
        Integer template,
        Map<Id,String> briefItemIdWithMailBody
    ) {
        List<EmailTemplate> emailTemplates = EmailTemplateSelector.newInstance()
            .selectByFolderName(CAMPAIGN_FULLFILLMENT_FOLDER);
        EmailTemplate emailTemplate;
        if(template != null) {
            emailTemplate = emailTemplates[template];
        } else {
            emailTemplate = null;
        }
        List<Messaging.SingleEmailMessage> allMsg = new List<Messaging.SingleEmailMessage>();
        Set<Id> briefItemIds = new Set<Id>();
        for (Brief_Item__c brItem : briefItemsChanged) {
            briefItemIds.add(brItem.Id);
        }

        List<Brief_Item__c> briefItemsWithEmails = BriefItemsSelector.newInstance()
            .selectByIds(briefItemIds);

        if ((briefItemsWithEmails != null) && (!briefItemsWithEmails.isEmpty())) {
            for (Brief_Item__c changedBriefItemToEmail : briefItemsWithEmails) {
                String htmlBody = BLANK_VALUE;
                List<string> toAddress = new List<string>();
                if (
                    changedBriefItemToEmail.Opportunity_Owner__r.Email != null &&
                    changedBriefItemToEmail.In_Campaign_Change__c == IN_CAMPAIGN_CHANGE_COMPLETE
                ) {
                    toAddress.add(changedBriefItemToEmail.Opportunity_Owner__r.Email);
                } else {
                    toAddress.add(changedBriefItemToEmail.Owner.Email);
                }

                Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
                if(emailTemplate == null && briefItemIdWithMailBody.containsKey(changedBriefItemToEmail.Id) &&
                    briefItemIdWithMailBody.get(changedBriefItemToEmail.Id)!= null) {

                    String briefItemLink = URL.getOrgDomainUrl().toExternalForm() +
                        '/lightning/r/Brief_Item__c/' +
                        changedBriefItemToEmail.id +
                        '/view';
                    htmlBody += HTML_BODY_TEXT_START + changedBriefItemToEmail.Name + HTML_BODY_TEXT_END +
                    ACCOUNT_STRING + changedBriefItemToEmail.Account_Val__c + LINE_BREAK +
                    CAMPAIGN_NAME_STRING + changedBriefItemToEmail.Campaign_Name__c + LINE_BREAK +
                    OPP_OWNER + changedBriefItemToEmail.Opportunity_Owner__r.name + LINE_BREAK +
                    BRIEF_ITEM_STRING + HYPERLINK_START + briefItemLink + HYPERLINK_MID + changedBriefItemToEmail.Name +
                    HYPERLINK_END + LINE_BREAK + briefItemIdWithMailBody.get(changedBriefItemToEmail.Id);

                    msg.setHtmlBody(htmlBody);
                    msg.setsubject(EMAIL_SUBJECT + changedBriefItemToEmail.Name);

                } else {
                    msg.setTemplateId(emailTemplate.Id);
                }
                
                msg.setTargetObjectId(dummyContactForEmailSend.Id); // Must be set to a valid Contact Id so the template will work correctly.
                msg.setWhatId(changedBriefItemToEmail.Id);
                msg.setToAddresses(toAddress);
                msg.setTreatTargetObjectAsRecipient(false);
                allMsg.add(msg);
            }
            //check limits before sending email.
            Boolean limitError = false;
            try {
                Messaging.reserveSingleEmailCapacity(allMsg.size());
            } catch (Exception ex) {
                Logger.publish(LogEntry.newExceptionLog(ex, LogEntry.SeverityLevel.HIGH));
                limitError = true;
            }

            if (!limitError) {
                Messaging.sendEmail(allMsg, false);
            }
        }
    }

    /**
     * @description update in campaign change
     * @param existingBriefItemMap
     * @param changedBriefItemsList
     */
    public void updateInCampaignChangeOnBriefItem(
        Map<Id, SObject> existingBriefItemMap,
        List<Brief_Item__c> changedBriefItemsList
    ) {
        // fflib_ISObjectUnitOfWork briefItemUoW = Application.UNITOFWORK.newInstance();
        Map<Schema.SObjectField, Boolean> briefItemTrackingMap = BriefItemTrackingSelector.newInstance()
            .getAllTrackingFields();
        if (!briefItemTrackingMap.isEmpty()) {
            List<Schema.SObjectField> briefItemFields = new List<Schema.SObjectField>();
            briefItemFields.addAll(briefItemTrackingMap.keySet());
            for (Brief_Item__c briefItem : changedBriefItemsList) {
                updateInCampaignChangeFieldOnExistingBriefItems(
                    briefItem,
                    briefItemFields,
                    briefItemTrackingMap,
                    existingBriefItemMap
                );
            }
        }
    }
    /**
     * @description updates the related brief items In_Campaign_Change field if necessary
     * @param briefItem
     * @param briefItemFields
     * @param briefItemTrackingMap
     * @param existingBriefItemMap
     */
    private void updateInCampaignChangeFieldOnExistingBriefItems(
        Brief_Item__c briefItem,
        List<Schema.SObjectField> briefItemFields,
        Map<Schema.SObjectField, Boolean> briefItemTrackingMap,
        Map<Id, SObject> existingBriefItemMap
    ) {
        Brief_Item__c existingBriefItem  = (Brief_Item__c)existingBriefItemMap.get(briefItem.Id);
        //Changing the values of In_Campaign_Change__c uses the same logic as creating Brief Item Field Tracking objects.
        if ((existingBriefItem != null) && shouldBriefItemTrackingObjectBeCreated(existingBriefItem, briefItem)) {
            for (Schema.SObjectField fieldName : briefItemFields) {
                if (
                    (briefItemTrackingMap.get(fieldname)) &&
                    (briefItem.In_Campaign_Change__c != IN_CAMPAIGN_CHANGE_YES) &&
                    (existingBriefItemMap.containsKey(briefItem.Id)) &&
                    (existingBriefItemMap.get(briefItem.Id).get(fieldName) !=
                    briefItem.get(fieldName))
                ) {
                    briefItem.In_Campaign_Change__c = IN_CAMPAIGN_CHANGE_YES;
                }
            }
        }
    }
    /** @description updates the related quoteline with the Brief Item ID
     * @param briefItems
     * @JIRA LEM-9452
     */
    public void updateQuoteLinesFromBriefItems(List<Brief_Item__c> briefItems) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        Set<Id> quoteLineIds = new Set<Id>();
        for (Brief_Item__c briefItem : briefItems) {
            if (briefItem.Quote_Line__c != null) {
                quoteLineIds.add(briefItem.Quote_Line__c);
            }
        }
        Map<Id, SBQQ__QuoteLine__c> quoteLineMap = QuoteLineItemsSelector.newInstance()
            .selectQuoteLinesFromIdsWithBriefItems(quoteLineIds);
        for (Brief_Item__c briefItem : briefItems) {
            if (quoteLineMap.containsKey(briefItem.Quote_Line__c)) {
                SBQQ__QuoteLine__c qLine = quoteLineMap.get(briefItem.Quote_Line__c);
                qLine.Brief_Item__c = briefItem.Id;
                qLine.Has_Brief_Item__c = true;
                uow.registerDirty(qLine);
            }
        }
        commitUnitOfWork(uow);
    }
    /**
     * @description updates the related brief items agency fields if necessary
     * @param mapBriefItemIdToQuoteline
     */
    public void updateAgencyFieldOnExistingBriefItems(
        Map<Id, SBQQ__QuoteLine__c> mapBriefItemIdToQuoteline
    ) {
        fflib_ISObjectUnitOfWork briefItemUoW = Application.UNITOFWORK.newInstance();
        Set<Id> briefItemIds = mapBriefItemIdToQuoteline.keySet();
        List<Brief_Item__c> briefItems = BriefItemsSelector.newInstance().selectByIds(briefItemIds);
        for (Brief_Item__c briefItem : briefItems) {
            SBQQ__QuoteLine__c quoteLineItem = mapBriefItemIdToQuoteLine.get(briefItem.Id);
            briefItem.Opportunity_Owner__c = quoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.OwnerId;
            if (quoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Agency__c != null) {
                briefItem.Agency_Contract__c = quoteLineItem.SBQQ__Quote__r.Signed_Contract_link__c;
                briefItem.Agency_Netsuite_ID__c = quoteLineItem.SBQQ__Quote__r.Invoicing_Payment_Account__r.NetSuite_ID__c;
            } else {
                briefItem.Signed_Contract__c = quoteLineItem.SBQQ__Quote__r.Signed_Contract_link__c;
                briefItem.Netsuite_ID__c = quoteLineItem.SBQQ__Quote__r.Invoicing_Payment_Account__r.NetSuite_ID__c;
            }
            briefItemUoW.registerDirty(briefItem);
        }
        commitUnitOfWork(briefItemUoW);
    }
    /**
     * @description Commits all the Units of Work created/updated/deleted.
     * @param unitOfWorkInstance
     */
    private void commitUnitOfWork(fflib_ISObjectUnitOfWork unitOfWorkInstance) {
        try {
            unitOfWorkInstance.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
    /**
     * @description this method is to update agency fields on brief item if needed
     * @param briefItem
     * @param quoteLineItem
     */
    private void updateAgencyFields(Brief_Item__c briefItem, SBQQ__QuoteLine__c quoteLineItem){
        if (quoteLineItem.SBQQ__Quote__r.SBQQ__Opportunity2__r.Agency__c != null) {
            briefItem.Agency_Contract__c = quoteLineItem.SBQQ__Quote__r.Signed_Contract_link__c;
            briefItem.Agency_Netsuite_ID__c = quoteLineItem.SBQQ__Quote__r.Invoicing_Payment_Account__r.NetSuite_ID__c;
        } else {
            briefItem.Signed_Contract__c = quoteLineItem.SBQQ__Quote__r.Signed_Contract_link__c;
            briefItem.Netsuite_ID__c = quoteLineItem.SBQQ__Quote__r.Invoicing_Payment_Account__r.NetSuite_ID__c;
        }
    }
    /**
     * @description this method maps quoteline fields to brief item
     * @param quoteLineToBriefItemFieldMapping
     * @param quoteLineItem
     * @param briefItem
     */
    private void mapQuoteLineFieldsToBriefItem(
        List<Quote_Line_to_Brief_Item_Mapping__mdt> quoteLineToBriefItemFieldMapping,
        SBQQ__QuoteLine__c quoteLineItem,
        Brief_Item__c briefItem
    ){
        for(Quote_Line_to_Brief_Item_Mapping__mdt mapping: quoteLineToBriefItemFieldMapping){
            if (
                briefItem.get(mapping.BriefItemFieldAPIName__c) == null &&
                mapping.BriefItemFieldAPIName__c != null &&
                mapping.QuoteLineFieldAPIName__c != null
            ) {
                briefItem.put(
                    mapping.BriefItemFieldAPIName__c,
                    quoteLineItem.get(mapping.QuoteLineFieldAPIName__c)
                );
            }
        }
    }
    /**
     * @description determine if a Brief Item Tracking record should be created. LEM-11961
     * @param existingBriefItem
     * @param briefItem
     * @return Boolean
     */
    @TestVisible
    private static Boolean shouldBriefItemTrackingObjectBeCreated(
        Brief_Item__c existingBriefItem,
        Brief_Item__c briefItem
    ) {
        Boolean returnValue = false;
        Boolean campaignLinkSet = briefItem?.Campaign_Link_s__c != null ? true : false;
        //LEM-11961
        Boolean changingToCampaignBuilding = ((existingBriefItem.Status__c == STATUS_WAITINGFORINPUTS) &&
                                              (briefItem.Status__c == STATUS_CAMPAIGN_BUILDING));
        Boolean afterWaitingForInput = ((String.isNotBlank(briefItem.Status__c)) &&
                                        (!BRIEF_CAMPAIGN_STATUS_UPDATES.contains(briefItem.Status__c)));

        if ((campaignLinkSet) || (afterWaitingForInput && (!changingToCampaignBuilding))) {
            returnValue = true;
        }
        return returnValue;
    }

    /**
     * @description updates the draft Io template on brief items
     * @param quoteIdTempIdmap
     */
    public static Void updateDraftIoTemplateOnExistingBriefItems(Map<Id, Id> quoteIdTempIdmap) {
        fflib_ISObjectUnitOfWork briefItemUoW = Application.UNITOFWORK.newInstance();
        List<Brief_Item__c> briefItems = BriefItemsSelector.newInstance().selectBriefItemsWithQuoteIds(quoteIdTempIdmap.keySet());
        if(briefItems.isEmpty()) {
            return;
        }
        for(Brief_Item__c bItem : briefItems) {
            if(quoteIdTempIdmap.containsKey(bItem.Quote_Line__r.SBQQ__Quote__c) &&
                quoteIdTempIdmap.get(bItem.Quote_Line__r.SBQQ__Quote__c) != NULL) {
                Id ioTemplateId = quoteIdTempIdmap.get(bItem.Quote_Line__r.SBQQ__Quote__c);
                    if(bItem.Brief__r.Opportunity_Name__c != NULL && bItem.Brief__r.Opportunity_Name__r.Agency__c != NULL) {
                        bItem.Draft_Agency_Contract__c = URL.getSalesforceBaseUrl().toExternalForm() +
                        CONTENT_DOC_PATH +
                        ioTemplateId +
                        VIEW;
                    } else {
                        bItem.Draft_Contract__c = URL.getSalesforceBaseUrl().toExternalForm() +
                        CONTENT_DOC_PATH +
                        ioTemplateId +
                        VIEW;
                    }
                briefItemUoW.registerDirty(bItem);
            }
        }
        try {
            briefItemUoW.commitWork();
        } catch (Exception unitOfWorkException) {
            Logger.publish(
                LogEntry.newExceptionLog(unitOfWorkException, LogEntry.SeverityLevel.HIGH)
            );
        }
    }
}