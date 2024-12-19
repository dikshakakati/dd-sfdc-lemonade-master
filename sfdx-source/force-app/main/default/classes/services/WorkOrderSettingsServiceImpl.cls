/**
 * @author Deloitte
 * @date 10/19/2022
 * @description Service implementation class for disabling or bypassing Work Order related
 * functionalities based on Type and Sub-Type values.
 */
public inherited sharing class WorkOrderSettingsServiceImpl implements IWorkOrderSettingsService {
    private static final String DRIVE_AMENDMENT_USE_CASE = 'Drive - Amendment';
    private static final String NONE_USE_CASE = System.Label.NintexUseCaseNone;
    private static final String NINTEX_USE_CASE_MWP = 'Middleware Provider';
    private static final String INTEGRATED_FRANCHISE_USE_CASE = 'Integrated Franchise';
    private static final String SEGMENT_ENTERPRISE = 'Enterprise';
    private static final String SEGMENT_MID_MARKET = 'Mid-Market';
    private static final String SEGMENT_SMB = 'SMB';
    private static final String SEPARATOR = System.Label.Separator;
    private static final String STOREFRONT = 'Storefront';
    private static final String WORK_ORDER_CREATION_SOURCE_MX_PORTAL = 'Mx Portal';
    private static final String WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME = 'Place It For Me';
    private static final String WORK_ORDER_CREATION_SOURCE_SSMO = 'SSMO';
    private static final String WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS = 'Auto-Activations';
    private static final String WORK_ORDER_SUB_TYPE_BUSINESS_STORE_MAPPING_UPDATE = 'Business/store mapping update';
    private static final String WORK_ORDER_SUB_TYPE_COO = 'COO';
    private static final String WORK_ORDER_SUB_TYPE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE = 'Invoicing group/NetSuite setup/update';
    private static final String WORK_ORDER_SUB_TYPE_METRO_BASED_PROMO = 'Metro Based Promo';
    private static final String WORK_ORDER_SUB_TYPE_MENU_UPDATES = 'Menu Updates';
    private static final String WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS = 'Net-new business';
    private static final String WORK_ORDER_SUB_TYPE_NET_NEW_TABLET = 'Net-New';
    private static final String WORK_ORDER_SUB_TYPE_OTHER = 'Other';
    private static final String WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION = 'Partnership creation/update';
    private static final String WORK_ORDER_SUB_TYPE_PORTAL_ACCESS = 'Portal access';
    private static final String WORK_ORDER_SUB_TYPE_REPLACEMENT = 'Replacement';
    private static final String WORK_ORDER_SUB_TYPE_RETURN = 'Return';
    private static final String WORK_ORDER_SUB_TYPE_SAAS_FEE_SETUP = 'SaaS Fee Setup';
    private static final String WORK_ORDER_SUB_TYPE_WITHHOLDING = 'Withholding';
    private static final String WORK_ORDER_TYPE_ADS_AND_PROMOS = 'Ads & Promos';
    private static final String WORK_ORDER_TYPE_COO = 'COO';
    private static final String WORK_ORDER_TYPE_DRIVE = 'Drive';
    private static final String WORK_ORDER_TYPE_MARKETPLACE = 'Marketplace';
    private static final String WORK_ORDER_TYPE_MARKETING_KIT = 'Marketing Kit';
    private static final String WORK_ORDER_TYPE_PHOTOSHOOT = 'Photoshoot';
    private static final String WORK_ORDER_TYPE_POS = 'POS';
    private static final String WORK_ORDER_TYPE_POST_SALES = 'Post-Sales';
    private static final String WORK_ORDER_TYPE_TABLET = 'Tablet';
    private static final String COO_KEY = WORK_ORDER_TYPE_COO + SEPARATOR + null;
    private static final String PHOTOSHOOT_KEY = WORK_ORDER_TYPE_PHOTOSHOOT + SEPARATOR + null;
    private static final String POS_KEY = WORK_ORDER_TYPE_POS + SEPARATOR + null;
    private static final String WORK_ORDER_SUB_TYPE_COO_SAME_STORE = 'COO Same Store';
    private static final String WORK_ORDER_CREATION_SOURCE_RESSMO = 'RESSMO';
    private static final String COO_SAME_STORE_KEY =
        WORK_ORDER_TYPE_COO +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_COO_SAME_STORE;
    private static final String DRIVE_AUTO_ACTIVATIONS_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_AUTO_ACTIVATIONS;
    private static final String DRIVE_WITHHOLDING_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_WITHHOLDING;
    private static final String DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY =
        NONE_USE_CASE +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_KEY;
    private static final String DRIVE_WITHHOLDING_CORPORATE_KEY =
        NONE_USE_CASE +
        SEPARATOR +
        DRIVE_WITHHOLDING_KEY;
    private static final String DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY =
        INTEGRATED_FRANCHISE_USE_CASE +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_KEY;
    private static final String DRIVE_AUTO_ACTIVATIONS_MWP_KEY =
        NINTEX_USE_CASE_MWP +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_KEY;
    private static final String DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY =
        INTEGRATED_FRANCHISE_USE_CASE +
        SEPARATOR +
        DRIVE_WITHHOLDING_KEY;
    private static final String DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_BUSINESS_STORE_MAPPING_UPDATE;
    private static final String DRIVE_COO_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_COO;
    private static final String DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE;
    private static final String DRIVE_METRO_BASED_PROMO_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_METRO_BASED_PROMO;
    private static final String DRIVE_NET_NEW_BUSINESS_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_NET_NEW_BUSINESS;
    private static final String DRIVE_NET_NEW_CORPORATE_KEY =
        NONE_USE_CASE +
        SEPARATOR +
        DRIVE_NET_NEW_BUSINESS_KEY;
    private static final String DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY =
        INTEGRATED_FRANCHISE_USE_CASE +
        SEPARATOR +
        DRIVE_NET_NEW_BUSINESS_KEY;
    private static final String DRIVE_NET_NEW_MWP_KEY =
        NINTEX_USE_CASE_MWP +
        SEPARATOR +
        DRIVE_NET_NEW_BUSINESS_KEY;
    private static final String DRIVE_PARTNERSHIP_CREATION_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION;
    private static final String DRIVE_PARTNERSHIP_CREATION_KEY_WITH_AMENDMENT_USE_CASE =
        DRIVE_AMENDMENT_USE_CASE +
        SEPARATOR +
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_PARTNERSHIP_CREATION;
    private static final String DRIVE_PORTAL_ACCESS_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_PORTAL_ACCESS;
    private static final String DRIVE_SAAS_FEE_SETUP_KEY =
        WORK_ORDER_TYPE_DRIVE +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_SAAS_FEE_SETUP;
    private static final String MARKETPLACE_KEY = WORK_ORDER_TYPE_MARKETPLACE + SEPARATOR + null;
    private static final String MARKETING_KIT_KEY =
        WORK_ORDER_TYPE_MARKETING_KIT +
        SEPARATOR +
        null;
    private static final String POST_SALES_MENU_UPDATES_KEY =
        WORK_ORDER_TYPE_POST_SALES +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_MENU_UPDATES;
    private static final String POST_SALES_OTHER_KEY =
        WORK_ORDER_TYPE_POST_SALES +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_OTHER;
    private static final String TABLET_NET_NEW_KEY =
        WORK_ORDER_TYPE_TABLET +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_NET_NEW_TABLET;
    private static final String TABLET_REPLACEMENT_KEY =
        WORK_ORDER_TYPE_TABLET +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_REPLACEMENT;
    private static final String TABLET_RETURN_KEY =
        WORK_ORDER_TYPE_TABLET +
        SEPARATOR +
        WORK_ORDER_SUB_TYPE_RETURN;
    private static final String ENT_COO_SAME_STORE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        COO_SAME_STORE_KEY;
    private static final String ENT_DRIVE_PARTNERSHIP_CREATION_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_PARTNERSHIP_CREATION_KEY;
    private static final String ENT_POS_KEY = SEGMENT_ENTERPRISE + SEPARATOR + POS_KEY;
    private static final String ENT_TABLET_NET_NEW_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        TABLET_NET_NEW_KEY;
    private static final String ENT_TABLET_REPLACEMENT_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        TABLET_REPLACEMENT_KEY;
    private static final String ENT_TABLET_RETURN_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        TABLET_RETURN_KEY;
    private static final String SMB_ADS_AND_PROMOS_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        WORK_ORDER_TYPE_ADS_AND_PROMOS +
        SEPARATOR +
        null;
    private static final String SMB_COO_SAME_STORE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        COO_SAME_STORE_KEY;
    private static final String SMB_DRIVE_AUTO_ACTIVATIONS_MWP_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_MWP_KEY;
    private static final String DRIVE_PARTNERSHIP_CREATION_NONE_KEY =
        NONE_USE_CASE +
        SEPARATOR +
        DRIVE_PARTNERSHIP_CREATION_KEY;
    private static final String SMB_DRIVE_AMENDMENT_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_PARTNERSHIP_CREATION_NONE_KEY;
    private static final String SMB_DRIVE_NET_NEW_CORPORATE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_NET_NEW_CORPORATE_KEY;
    private static final String SMB_DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY;
    private static final String ENT_DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY;
    private static final String ENT_DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY;
    private static final String SMB_DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY;
    private static final String ENT_DRIVE_NET_NEW_CORPORATE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_NET_NEW_CORPORATE_KEY;
    private static final String SMB_DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY;
    private static final String ENT_DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY;
    private static final String ENT_DRIVE_WITHHOLDING_CORPORATE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_WITHHOLDING_CORPORATE_KEY;
    private static final String ENT_MARKETING_KIT_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        MARKETING_KIT_KEY;
    private static final String SMB_DRIVE_WITHHOLDING_CORPORATE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_WITHHOLDING_CORPORATE_KEY;
    private static final String SMB_DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY;
    private static final String ENT_DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY;
    private static final String SMB_ADS_AND_PROMOS_NINTEX_USE_CASE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        NONE_USE_CASE +
        SEPARATOR +
        WORK_ORDER_TYPE_ADS_AND_PROMOS +
        SEPARATOR +
        null;
    private static final String SMB_DRIVE_NET_NEW_MWP_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_NET_NEW_MWP_KEY;
    private static final String SMB_DRIVE_PARTNERSHIP_CREATION_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_PARTNERSHIP_CREATION_KEY;
    private static final String SMB_MARKETING_KIT_KEY = SEGMENT_SMB + SEPARATOR + MARKETING_KIT_KEY;
    private static final String SMB_PHOTOSHOOT_KEY = SEGMENT_SMB + SEPARATOR + PHOTOSHOOT_KEY;
    private static final String SMB_POS_KEY = SEGMENT_SMB + SEPARATOR + POS_KEY;
    private static final String SMB_TABLET_NET_NEW_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        TABLET_NET_NEW_KEY;
    private static final String SMB_TABLET_REPLACEMENT_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        TABLET_REPLACEMENT_KEY;
    private static final String SMB_TABLET_RETURN_KEY = SEGMENT_SMB + SEPARATOR + TABLET_RETURN_KEY;
    private static final String ENT_COO_KEY = SEGMENT_ENTERPRISE + SEPARATOR + COO_KEY;
    private static final String SMB_COO_KEY = SEGMENT_SMB + SEPARATOR + COO_KEY;
    private static final String SMB_DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY;
    private static final String ENT_DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY;
    private static final String ENT_DRIVE_COO_KEY = SEGMENT_ENTERPRISE + SEPARATOR + DRIVE_COO_KEY;
    private static final String SMB_DRIVE_COO_KEY = SEGMENT_SMB + SEPARATOR + DRIVE_COO_KEY;
    private static final String SMB_DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY;
    private static final String ENT_DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY;
    private static final String ENT_DRIVE_METRO_BASED_PROMO_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_METRO_BASED_PROMO_KEY;
    private static final String SMB_DRIVE_METRO_BASED_PROMO_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_METRO_BASED_PROMO_KEY;
    private static final String SMB_DRIVE_PORTAL_ACCESS_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_PORTAL_ACCESS_KEY;
    private static final String ENT_DRIVE_PORTAL_ACCESS_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_PORTAL_ACCESS_KEY;
    private static final String ENT_DRIVE_SAAS_FEE_SETUP_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        DRIVE_SAAS_FEE_SETUP_KEY;
    private static final String SMB_DRIVE_SAAS_FEE_SETUP_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        DRIVE_SAAS_FEE_SETUP_KEY;
    private static final String SMB_POST_SALES_MENU_UPDATES_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        POST_SALES_MENU_UPDATES_KEY;
    private static final String ENT_POST_SALES_MENU_UPDATES_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        POST_SALES_MENU_UPDATES_KEY;
    private static final String ENT_POST_SALES_OTHER_KEY =
        SEGMENT_ENTERPRISE +
        SEPARATOR +
        POST_SALES_OTHER_KEY;
    private static final String SMB_POST_SALES_OTHER_KEY =
        SEGMENT_SMB +
        SEPARATOR +
        POST_SALES_OTHER_KEY;
    private static final Map<String, Boolean> CHILDWORKORDER_TYPESUBTYPE_TO_ISPROVISIONINGSTATUSNOTIFICATIONENABLED = new Map<String, Boolean>{
        ENT_COO_KEY => false,
        ENT_DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY => false,
        ENT_DRIVE_COO_KEY => true,
        ENT_DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY => false,
        ENT_DRIVE_METRO_BASED_PROMO_KEY => false,
        ENT_DRIVE_PARTNERSHIP_CREATION_KEY => true,
        ENT_DRIVE_PORTAL_ACCESS_KEY => false,
        ENT_DRIVE_SAAS_FEE_SETUP_KEY => false,
        ENT_POST_SALES_MENU_UPDATES_KEY => false,
        ENT_POST_SALES_OTHER_KEY => false,
        ENT_COO_SAME_STORE_KEY => false,
        ENT_MARKETING_KIT_KEY => false,
        ENT_TABLET_NET_NEW_KEY => false,
        ENT_TABLET_REPLACEMENT_KEY => false,
        ENT_TABLET_RETURN_KEY => false,
        SMB_ADS_AND_PROMOS_KEY => false,
        SMB_COO_KEY => false,
        SMB_DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY => false,
        SMB_DRIVE_COO_KEY => true,
        SMB_DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY => false,
        SMB_DRIVE_METRO_BASED_PROMO_KEY => false,
        SMB_DRIVE_PARTNERSHIP_CREATION_KEY => true,
        SMB_DRIVE_PORTAL_ACCESS_KEY => false,
        SMB_DRIVE_SAAS_FEE_SETUP_KEY => false,
        SMB_POST_SALES_MENU_UPDATES_KEY => false,
        SMB_POST_SALES_OTHER_KEY => false,
        SMB_COO_SAME_STORE_KEY => false,
        SMB_MARKETING_KIT_KEY => false,
        SMB_PHOTOSHOOT_KEY => false,
        SMB_TABLET_NET_NEW_KEY => false,
        SMB_TABLET_REPLACEMENT_KEY => false,
        SMB_TABLET_RETURN_KEY => false
    };
    private static final Set<String> CREATION_SOURCES_TO_BYPASS_READINESS_CHECK = new Set<String>{
        WORK_ORDER_CREATION_SOURCE_MX_PORTAL,
        WORK_ORDER_CREATION_SOURCE_PLACE_IT_FOR_ME,
        WORK_ORDER_CREATION_SOURCE_SSMO,
        WORK_ORDER_CREATION_SOURCE_RESSMO
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISPDOAMATCHINGENABLED = new Map<String, Boolean>{
        MARKETPLACE_KEY => true,
        COO_KEY => true
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISPROVISIONINGSTATUSNOTIFICATIONENABLED = new Map<String, Boolean>{
        ENT_DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY => true,
        ENT_DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY => true,
        ENT_DRIVE_NET_NEW_CORPORATE_KEY => true,
        ENT_DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY => true,
        ENT_DRIVE_WITHHOLDING_CORPORATE_KEY => true,
        ENT_DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY => true,
        SMB_ADS_AND_PROMOS_NINTEX_USE_CASE_KEY => false,
        SMB_DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY => true,
        SMB_DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY => true,
        SMB_DRIVE_AUTO_ACTIVATIONS_MWP_KEY => true,
        SMB_DRIVE_NET_NEW_CORPORATE_KEY => true,
        SMB_DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY => true,
        SMB_DRIVE_NET_NEW_MWP_KEY => true,
        SMB_DRIVE_WITHHOLDING_CORPORATE_KEY => true,
        SMB_DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY => true,
        SMB_PHOTOSHOOT_KEY => false
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISTYPEMATCHINGDISABLED = new Map<String, Boolean>{
        WORK_ORDER_TYPE_COO => true,
        WORK_ORDER_TYPE_DRIVE => true,
        WORK_ORDER_TYPE_MARKETPLACE => true
    };
    private static final Map<String, Boolean> SEGMENTTYPESUBTYPE_TO_ISREADINESSCHECKBYPARENTBYPASSED = new Map<String, Boolean>{
        ENT_COO_SAME_STORE_KEY => true,
        ENT_DRIVE_PARTNERSHIP_CREATION_KEY => true,
        ENT_MARKETING_KIT_KEY => true,
        ENT_POS_KEY => true,
        ENT_TABLET_NET_NEW_KEY => true,
        ENT_TABLET_REPLACEMENT_KEY => true,
        ENT_TABLET_RETURN_KEY => true,
        SMB_COO_SAME_STORE_KEY => true,
        SMB_DRIVE_PARTNERSHIP_CREATION_KEY => true,
        SMB_MARKETING_KIT_KEY => true,
        SMB_PHOTOSHOOT_KEY => true,
        SMB_POS_KEY => true,
        SMB_TABLET_NET_NEW_KEY => true,
        SMB_TABLET_REPLACEMENT_KEY => true,
        SMB_TABLET_RETURN_KEY => true
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISREADINESSCHECKBYSTOREBYPASSED = new Map<String, Boolean>{
        DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY => true,
        DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY => true,
        DRIVE_AUTO_ACTIVATIONS_MWP_KEY => true,
        DRIVE_NET_NEW_CORPORATE_KEY => true,
        DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY => true,
        DRIVE_NET_NEW_MWP_KEY => true,
        DRIVE_PARTNERSHIP_CREATION_KEY_WITH_AMENDMENT_USE_CASE => true,
        DRIVE_WITHHOLDING_CORPORATE_KEY => true,
        DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY => true,
        TABLET_NET_NEW_KEY => true,
        TABLET_REPLACEMENT_KEY => true,
        TABLET_RETURN_KEY => true
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISREADINESSCHECK_ON_PARENTWORKORDER_CREATION = new Map<String, Boolean>{
        SMB_DRIVE_NET_NEW_MWP_KEY => true,
        SMB_DRIVE_AUTO_ACTIVATIONS_MWP_KEY => true,
        SMB_DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY => true,
        SMB_DRIVE_AMENDMENT_KEY => true,
        SMB_DRIVE_NET_NEW_CORPORATE_KEY => true
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISWORKPLANAUTOCREATIONENABLED = new Map<String, Boolean>{
        DRIVE_COO_KEY => true,
        DRIVE_BUSINESS_STORE_MAPPING_UPDATE_KEY => true,
        DRIVE_INVOICING_GROUP_NETSUITE_SETUP_UPDATE_KEY => true,
        DRIVE_METRO_BASED_PROMO_KEY => true,
        DRIVE_PARTNERSHIP_CREATION_KEY => true,
        DRIVE_PORTAL_ACCESS_KEY => true,
        DRIVE_SAAS_FEE_SETUP_KEY => true,
        MARKETING_KIT_KEY => true,
        TABLET_NET_NEW_KEY => true,
        TABLET_REPLACEMENT_KEY => true,
        TABLET_RETURN_KEY => true
    };
    private static final Map<String, Boolean> TYPESUBTYPE_TO_ISWORKPLANELIGIBILITYBYSTOREBYPASSED = new Map<String, Boolean>{
        DRIVE_AUTO_ACTIVATIONS_CORPORATE_KEY => true,
        DRIVE_AUTO_ACTIVATIONS_INTEGRATED_FRANCHISE_KEY => true,
        DRIVE_AUTO_ACTIVATIONS_MWP_KEY => true,
        DRIVE_NET_NEW_CORPORATE_KEY => true,
        DRIVE_NET_NEW_INTEGRATED_FRANCHISE_KEY => true,
        DRIVE_NET_NEW_MWP_KEY => true,
        DRIVE_WITHHOLDING_CORPORATE_KEY => true,
        DRIVE_WITHHOLDING_INTEGRATED_FRANCHISE_KEY => true
    };
    private static final Map<String, Boolean> WORKORDER_TYPESUBTYPE_TO_DECISION_MAKER_APPLICABILITY = new Map<String, Boolean>{
        COO_KEY => true,
        MARKETPLACE_KEY => true
    };

    /**
     * @description It checks whether the Decision Maker population is applicable on the
     * passed Work Order.
     * @JIRA# LEM-4195
     * @param workOrder
     * @return Boolean
     */
    public Boolean isDecisionMakerApplicableOnWorkOrder(WorkOrder workOrder) {
        Boolean isApplicable = false;
        String workOrderTypeSubTypeKey = workOrder.Type__c + SEPARATOR + workOrder.Sub_Type__c;
        if (
            WORKORDER_TYPESUBTYPE_TO_DECISION_MAKER_APPLICABILITY.containsKey(
                workOrderTypeSubTypeKey
            )
        ) {
            isApplicable = WORKORDER_TYPESUBTYPE_TO_DECISION_MAKER_APPLICABILITY.get(
                workOrderTypeSubTypeKey
            );
        }
        return isApplicable;
    }

    /**
     * @description It checks whether the passed Work Order Type value
     * is eligible for matching parent Work Order by Type.
     * @JIRA# LEM-4281
     * @param workOrderType
     * @return Boolean
     */
    public Boolean isMatchByTypeDisabled(String workOrderType) {
        Boolean isDisabled = false;
        if (TYPESUBTYPE_TO_ISTYPEMATCHINGDISABLED.containsKey(workOrderType)) {
            isDisabled = TYPESUBTYPE_TO_ISTYPEMATCHINGDISABLED.get(workOrderType);
        }
        return isDisabled;
    }

    /**
     * @description It checks whether the passed Work Order Type and Sub Type key value
     * is eligible for matching parent Work Order by PDOA.
     * @JIRA# LEM-3384
     * @param workOrderTypeSubTypeKey
     * @return Boolean
     */
    public Boolean isPDOAMatchingEnabled(String workOrderTypeSubTypeKey) {
        Boolean isEnabled = false;
        if (TYPESUBTYPE_TO_ISPDOAMATCHINGENABLED.containsKey(workOrderTypeSubTypeKey)) {
            isEnabled = TYPESUBTYPE_TO_ISPDOAMATCHINGENABLED.get(workOrderTypeSubTypeKey);
        }
        return isEnabled;
    }

    /**
     * @description It checks whether the provisioning status notification is enabled for the
     * passed child Work Order.
     * @JIRA# LEM-3920
     * @param workOrder
     * @return Boolean
     */
    public Boolean isProvisioningStatusNotificationEnabledOnChildWorkOrder(WorkOrder workOrder) {
        // Default value is set to true since all child Work Order types & sub-types are expected
        // to send Provisioning Status notification.
        Boolean isEnabled = true;
        String segment = workOrder.Segment__c == SEGMENT_MID_MARKET
            ? SEGMENT_ENTERPRISE
            : workOrder.Segment__c;
        String workOrderSegmentTypeSubTypeKey =
            segment +
            SEPARATOR +
            workOrder.Type__c +
            SEPARATOR +
            workOrder.Sub_Type__c;
        if (CREATION_SOURCES_TO_BYPASS_READINESS_CHECK.contains(workOrder.Creation_Source__c)) {
            // Disabling Provisioning Status notification for Place It for Me - Storefront scenarios && SSMO.
            isEnabled = false;
        } else if (
            CHILDWORKORDER_TYPESUBTYPE_TO_ISPROVISIONINGSTATUSNOTIFICATIONENABLED.containsKey(
                workOrderSegmentTypeSubTypeKey
            )
        ) {
            isEnabled = CHILDWORKORDER_TYPESUBTYPE_TO_ISPROVISIONINGSTATUSNOTIFICATIONENABLED.get(
                workOrderSegmentTypeSubTypeKey
            );
        }
        return isEnabled;
    }

    /**
     * @description It checks whether the provisioning status notification is enabled for the
     * passed parent Work Order.
     * @JIRA# LEM-3094
     * @param workOrder
     * @return Boolean
     */
    public Boolean isProvisioningStatusNotificationEnabledOnParentWorkOrder(WorkOrder workOrder) {
        Boolean isEnabled = false;
        String segment = workOrder.Segment__c == SEGMENT_MID_MARKET
            ? SEGMENT_ENTERPRISE
            : workOrder.Segment__c;
        String workOrderSegmentTypeSubTypeKey =
            segment +
            SEPARATOR +
            workOrder.Nintex_Use_Case__c +
            SEPARATOR +
            workOrder.Type__c +
            SEPARATOR +
            workOrder.Sub_Type__c;
        if (CREATION_SOURCES_TO_BYPASS_READINESS_CHECK.contains(workOrder.Creation_Source__c)) {
            // Disabling Provisioning Status notification for Place It for Me - Storefront scenarios && SSMO.
            isEnabled = false;
        } else if (
            TYPESUBTYPE_TO_ISPROVISIONINGSTATUSNOTIFICATIONENABLED.containsKey(
                workOrderSegmentTypeSubTypeKey
            )
        ) {
            isEnabled = TYPESUBTYPE_TO_ISPROVISIONINGSTATUSNOTIFICATIONENABLED.get(
                workOrderSegmentTypeSubTypeKey
            );
        }
        return isEnabled;
    }

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check.
     * @JIRA# LEM-15489
     * @param workOrder
     * @return Boolean
     */
    public Boolean isReadinessCheckEligibilityByParentBypassed(WorkOrder workOrder) {
        Boolean isBypassed = false;
        String segment = workOrder.Segment__c == SEGMENT_MID_MARKET
            ? SEGMENT_ENTERPRISE
            : workOrder.Segment__c;
        String workOrderSegmentTypeSubTypeKey =
            segment +
            SEPARATOR +
            workOrder.Type__c +
            SEPARATOR +
            workOrder.Sub_Type__c;
        if (CREATION_SOURCES_TO_BYPASS_READINESS_CHECK.contains(workOrder.Creation_Source__c)) {
            isBypassed = true;
        } else if (
            SEGMENTTYPESUBTYPE_TO_ISREADINESSCHECKBYPARENTBYPASSED.containsKey(
                workOrderSegmentTypeSubTypeKey
            )
        ) {
            isBypassed = SEGMENTTYPESUBTYPE_TO_ISREADINESSCHECKBYPARENTBYPASSED.get(
                workOrderSegmentTypeSubTypeKey
            );
        }
        return isBypassed;
    }

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check
     * when stores are not expected.
     * @JIRA# LEM-3094
     * @param workOrder
     * @return Boolean
     */
    public Boolean isReadinessCheckEligibilityByStoreBypassed(WorkOrder workOrder) {
        Boolean isBypassed = false;
        String workOrderUseCaseTypeSubTypeKey =
            workOrder.Nintex_Use_Case__c +
            SEPARATOR +
            workOrder.Type__c +
            SEPARATOR +
            workOrder.Sub_Type__c;
        if (CREATION_SOURCES_TO_BYPASS_READINESS_CHECK.contains(workOrder.Creation_Source__c)) {
            isBypassed = true;
        } else if (
            TYPESUBTYPE_TO_ISREADINESSCHECKBYSTOREBYPASSED.containsKey(
                workOrderUseCaseTypeSubTypeKey
            )
        ) {
            isBypassed = TYPESUBTYPE_TO_ISREADINESSCHECKBYSTOREBYPASSED.get(
                workOrderUseCaseTypeSubTypeKey
            );
        }
        return isBypassed;
    }

    /**
     * @description It checks whether the passed Work Order is eligible for readiness check
     * on creation.
     * @JIRA# LEM-17052
     * @param workOrder
     * @return Boolean
     */
    public Boolean isReadinessCheckEligibleOnParentWorkOrderCreation(WorkOrder workOrder) {
        Boolean isEligible = false;
        String segment = workOrder.Segment__c == SEGMENT_MID_MARKET
            ? SEGMENT_ENTERPRISE
            : workOrder.Segment__c;
        String workOrderSegmentUseCaseTypeSubTypeKey =
            segment +
            SEPARATOR +
            workOrder.Nintex_Use_Case__c +
            SEPARATOR +
            workOrder.Type__c +
            SEPARATOR +
            workOrder.Sub_Type__c;
        if (
            String.isBlank(workOrder.ParentWorkOrderId) &&
            TYPESUBTYPE_TO_ISREADINESSCHECK_ON_PARENTWORKORDER_CREATION.containsKey(
                workOrderSegmentUseCaseTypeSubTypeKey
            )
        ) {
            isEligible = TYPESUBTYPE_TO_ISREADINESSCHECK_ON_PARENTWORKORDER_CREATION.get(
                workOrderSegmentUseCaseTypeSubTypeKey
            );
        }
        return isEligible;
    }

    /**
     * @description It checks whether the passed Work Order is eligible for automatic
     * creation of Work Plans.
     * @JIRA# LEM-3474
     * @param workOrder
     * @return Boolean
     */
    public Boolean isWorkPlansAutoCreationEnabled(WorkOrder workOrder) {
        Boolean isEnabled = false;
        String workOrderTypeSubTypeKey = workOrder.Type__c + SEPARATOR + workOrder.Sub_Type__c;
        if (TYPESUBTYPE_TO_ISWORKPLANAUTOCREATIONENABLED.containsKey(workOrderTypeSubTypeKey)) {
            isEnabled = TYPESUBTYPE_TO_ISWORKPLANAUTOCREATIONENABLED.get(workOrderTypeSubTypeKey);
        }
        return isEnabled;
    }

    /**
     * @description It checks whether the passed Work Order is eligible for Work Plan creation
     * when stores are not expected.
     * @JIRA# LEM-3094
     * @param workOrder
     * @return Boolean
     */
    public Boolean isWorkPlansEligibilityByStoreBypassed(WorkOrder workOrder) {
        Boolean isBypassed = false;
        String workOrderTypeSubTypeKey =
            workOrder.Nintex_Use_Case__c +
            SEPARATOR +
            workOrder.Type__c +
            SEPARATOR +
            workOrder.Sub_Type__c;
        if (
            TYPESUBTYPE_TO_ISWORKPLANELIGIBILITYBYSTOREBYPASSED.containsKey(workOrderTypeSubTypeKey)
        ) {
            isBypassed = TYPESUBTYPE_TO_ISWORKPLANELIGIBILITYBYSTOREBYPASSED.get(
                workOrderTypeSubTypeKey
            );
        }
        return isBypassed;
    }
}