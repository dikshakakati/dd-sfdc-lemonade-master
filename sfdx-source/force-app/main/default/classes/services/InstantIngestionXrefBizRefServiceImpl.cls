/**
 * @author Deloitte
 * @date 05/15/2024
 * @description Service Implementation class for Xref and Biz Ref creation from payload related logic.
 *
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public inherited sharing class InstantIngestionXrefBizRefServiceImpl implements IInstantIngestionXrefBizRefService {
    private static final String DEFAULT_TYPE = 'Corporate';
    private static final String EXTERNAL_ID_SOURCE_MDS = 'MDS';
    private static final String EXTERNAL_ID_SOURCE_DRIVEDB = 'DriveDb';
    private static final String INTEGRATION_STATUS_SUCCESS = 'Success';
    private static final String INTEGRATION_STATUS_NEW = 'New';
    private static final String PRIMARY_VERTICAL = 'Rx';
    private static final String MENU_UI_TYPE = 'Restaurant';
    private static final String SOURCE_SSMO = 'SSMO';
    private static final String XREF_ACTIVE_STATUS = 'Active';
    private static final String XREF_INACTIVE_STATUS = 'Inactive';
    private static final String SOURCE_SSOB = 'SSOB';

    /**
     * @description It is used to create the business references from the Payload.
     * @param payload
     * @param ssobPayload
     * @param brandId
     * @param currencyIsoCode
     * @param businessVertical
     * @param source
     * @return Business_Reference__c
     */
    public Business_Reference__c createBusinessReference(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobPayload,
        Id brandId,
        String currencyIsoCode,
        Business_Vertical__c businessVertical,
        String source
    ) {
        Business_Reference__c businessReference = new Business_Reference__c();

        businessReference.Unique_Identifier__c = source == SOURCE_SSOB
            ? ssobPayload.uuid
            : payload.Uuid;
        businessReference.Default_Type__c = DEFAULT_TYPE;
        businessReference.External_Id_Source__c = source == SOURCE_SSOB
            ? EXTERNAL_ID_SOURCE_DRIVEDB
            : EXTERNAL_ID_SOURCE_MDS;
        businessReference.Integration_Status__c = INTEGRATION_STATUS_SUCCESS;
        businessReference.Business_Vertical__c = businessVertical.Id;
        businessReference.Primary_Vertical__c = PRIMARY_VERTICAL;
        businessReference.Menu_UI_Type__c = MENU_UI_TYPE;
        businessReference.Business_Name__c = source == SOURCE_SSOB
            ? ssobPayload.account.name
            : payload.business.name;
        businessReference.Brand__c = brandId;
        businessReference.CurrencyIsoCode = currencyIsoCode;
        businessReference.External_Id__c = source == SOURCE_SSOB
            ? ssobPayload.account.businessId
            : payload.business.businessId;
        businessReference.Business_Group_Id__c = payload.businessGroup?.businessGroupId;

        return businessReference;
    }

    /**
     * @description It is used to create the xrefs from the Payload.
     * @param payload
     * @param ssobPayload
     * @param businessAccount
     * @param storeAccount
     * @param businessReference
     * @param source
     * @return Contact
     */
    public Xref__c createXref(
        InstantIngestionPayloadParser payload,
        SSOBOnboardingPayloadParser ssobPayload,
        Account businessAccount,
        Account storeAccount,
        Business_Reference__c businessReference,
        String source
    ) {
        Xref__c xref = new Xref__c();
        xref.Salesforce_Account_Name__c = storeAccount != null
            ? storeAccount.Id
            : businessAccount.Id;
        xref.Unique_Identifier__c = source == SOURCE_SSOB ? ssobPayload.uuid : payload.Uuid;
        xref.Business_Reference__c = businessReference.Id;
        xref.Integration_Status__c = storeAccount != null
            ? INTEGRATION_STATUS_SUCCESS
            : INTEGRATION_STATUS_NEW;
        xref.Record_Source__c = SOURCE_SSMO;
        xref.Xref_Status__c = XREF_ACTIVE_STATUS;
        xref.External_Id_Source__c = source == SOURCE_SSOB
            ? EXTERNAL_ID_SOURCE_DRIVEDB
            : EXTERNAL_ID_SOURCE_MDS;
        xref.External_ID__c = storeAccount != null ? payload.store.storeId : null;
        return xref;
    }
}