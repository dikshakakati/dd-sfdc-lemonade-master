/**
 * @author Deloitte
 * @date 06/13/2024
 * @description Selector class for Mx_Onboarding_Link__c custom metadata.
 */
public inherited sharing class MxOnboardingLinksSelector extends fflib_SObjectSelector implements IMxOnboardingLinksSelector {
    private static final String ACTIVE = 'Active';
    /**
     * @description default constructor for the class.
     * @return IMxOnboardingLinksSelector - interface of IMxOnboardingLinksSelector
     */
    public static IMxOnboardingLinksSelector newInstance() {
        return (IMxOnboardingLinksSelector) Application.Selector.newInstance(
            Mx_Onboarding_Link__c.SObjectType
        );
    }

    /**
     * @description It is used for getting Object type.
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Mx_Onboarding_Link__c.SObjectType;
    }

    /**
     * @description It is for getting the fields on Mx_Onboarding_Link__c.
     * @return List<Schema.SObjectField>- Mx_Onboarding_Link__c fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Mx_Onboarding_Link__c.Business_Account__c,
            Mx_Onboarding_Link__c.Contract__c,
            Mx_Onboarding_Link__c.Expiration_Date_Time__c,
            Mx_Onboarding_Link__c.Onboarding_Scenario__c,
            Mx_Onboarding_Link__c.One_Time_Mx_Link__c,
            Mx_Onboarding_Link__c.Payment_Method__c,
            Mx_Onboarding_Link__c.Payload__c,
            Mx_Onboarding_Link__c.Product_on_Contract__c,
            Mx_Onboarding_Link__c.Record_Creation_Status__c,
            Mx_Onboarding_Link__c.Source__c,
            Mx_Onboarding_Link__c.UUID__c
        };
    }

    /**
     * @description It is used to query Mx Onboarding links associated with the passed contractIds.
     * @param contractIds
     * @return List<Mx_Onboarding_Link__c>
     */
    public List<Mx_Onboarding_Link__c> selectByContractIds(Set<Id> contractIds) {
        fflib_QueryFactory query = newQueryFactory()
            .setCondition(
                'Contract__c IN :contractIds AND ' +
                    'Expiration_Date_Time__c > TODAY AND ' +
                    'Status__c = :ACTIVE'
            );
        return (List<Mx_Onboarding_Link__c>) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for getting Sobject type Id
     * @param idSet
     * @return List<Order>
     */
    public List<Mx_Onboarding_Link__c> selectById(Set<Id> idSet) {
        return (List<Mx_Onboarding_Link__c>) selectSObjectsById(idSet);
    }

    /**
     * @description It is used to query Business Onboarding Details, Store Details and Contracts
     * associated with the passed MxOnboarding Links Id.
     * @param mxOnboardingLinksIds
     * @return List<Mx_Onboarding_Link__c>
     */
    public List<Mx_Onboarding_Link__c> selectByMxOnboardingLinkIds(Set<Id> mxOnboardingLinksIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Id')
            .selectField('Business_Account__c')
            .selectField('Business_Account__r.Legal_Business_Name__c')
            .selectField('Contract__r.AccountId')
            .selectField('Contract__r.Drive_Auto_Activation_Supported__c')
            .selectField('Contract__r.Number_of_Stores__c')
            .selectField('Contract__r.SBQQ__Order__r.OpportunityId')
            .selectField('Contract__r.SBQQ__Quote__c')
            .selectField('Contract__r.RESSMO_Sales_Rep_Name__c')
            .selectField('Contract__r.SBQQ__Quote__c.SBQQ__SalesRep__c')
            .selectField('Product_on_Contract__c')
            .selectField('Payment_Method__c')
            .selectField('Source__c')
            .selectField('Store_Count__c')
            .selectField('Payload__c')
            .selectField('UUID__c')
            .selectField('Business_Account__r.Name')
            .selectField('CreatedById')
            .selectField('Opportunity__c')
            .setCondition('Id IN :mxOnboardingLinksIds');
        new BusinessOnboardingDetailsSelector()
            .addQueryFactorySubselect(query, 'Business_Onboarding_Details__r')
            .selectField('Activated_Centrally_AC__c')
            .selectField('Mx_Requested_Photoshoot__c')
            .selectField('Order_Protocol__c')
            .selectField('Business_Owner_DOB__c')
            .selectField('Photoshoot_Date__c')
            .selectField('Photoshoot_Time__c')
            .selectField('Proposed_Date_of_Activation__c')
            .selectField('Legal_Business_Name__c')
            .selectField('Business_Address__Street__s')
            .selectField('Business_Address__City__s')
            .selectField('Business_Address__StateCode__s')
            .selectField('Business_Address__CountryCode__s')
            .selectField('Business_Address__PostalCode__s')
            .selectField('Business_ID__c')
            .selectField('Address__City__s')
            .selectField('Address__CountryCode__s')
            .selectField('Address__PostalCode__s')
            .selectField('Address__StateCode__s')
            .selectField('Representative_Email__c')
            .selectField('Address__Street__s')
            .selectField('Routing_Number__c')
            .selectField('Bank_Account_Number__c')
            .selectField('Payment_Descriptor__c')
            .selectField('Institution_Number__c')
            .selectField('Tax_ID__c')
            .selectField('Mx_Onboarding_Link__c')
            .selectField('Provincial_Tax_ID__c')
            .selectField('Address_Line_1__c')
            .selectField('Photoshoot_Contact_First_Name__c')
            .selectField('Photoshoot_Contact_Last_Name__c')
            .selectField('Photoshoot_Contact_Email__c')
            .selectField('Photoshoot_Contact_Mobile_Phone__c')
            .selectField('Business_Owner_First_Name__c')
            .selectField('Business_Owner_Last_Name__c')
            .selectField('Business_Owner_Email__c')
            .selectField('Billing_Contact_Phone__c')
            .selectField('Billing_Contact_Email__c')
            .selectField('State_Provide__c')
            .selectField('Business_Director_First_Name__c')
            .selectField('Business_Director_Last_Name__c')
            .selectField('Business_Director_Email__c')
            .selectField('Representative_Phone__c')
            .selectField('Representative_First_Name__c')
            .selectField('Representative_Last_Name__c')
            .selectField('Representative_Date_of_Birth__c')
            .selectField('Brand__c')
            .selectField('Photoshoot_Contact_Phone__c')
            .selectField('Billing_Contact_First_Name__c')
            .selectField('Billing_Contact_Last_Name__c')
            .selectField('Payment_Address__Street__s')
            .selectField('Payment_Address__City__s')
            .selectField('Payment_Address__StateCode__s')
            .selectField('Payment_Address__CountryCode__s')
            .selectField('Payment_Address__PostalCode__s')
            .selectField('Business_Owner_Address__CountryCode__s')
            .selectField('Business_Owner_Address__StateCode__s')
            .selectField('Business_Owner_Address__Street__s')
            .selectField('Business_Owner_Address__City__s')
            .selectField('Business_Owner_Address__PostalCode__s')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        new StoreDetailsSelector()
            .addQueryFactorySubselect(query, 'Store_Details__r')
            .selectField('Alternative_Store_Name_Mx_Portal__c')
            .selectField('Menu_Setup_Method__c')
            .selectField('Menu_to_be_Completed_By__c')
            .selectField('Sales_Notes_for_Menu_Team__c')
            .selectField('Street__c')
            .selectField('Routing_Number__c')
            .selectField('Bank_Account_Number__c')
            .selectField('Payment_Descriptor__c')
            .selectField('Institution_Number__c')
            .selectField('City__c')
            .selectField('Address__PostalCode__s')
            .selectField('Address__StateCode__s')
            .selectField('Address__City__s')
            .selectField('Address__Street__s')
            .selectField('Address__CountryCode__s')
            .selectField('State_Provide__c')
            .selectField('Country__c')
            .selectField('zip_Postal_Code__c')
            .selectField('Store_Name_Account_Name__c')
            .selectField('Type__c')
            .selectField('Merchant_Supplied_ID__c')
            .selectField('Phone__c')
            .selectField('Hours_of_Operation__c')
            .selectField('Menu_URL__c')
            .selectField('Menu_Setup_Method__c')
            .selectField('Menu_to_be_Completed_By__c')
            .selectField('Sales_Notes_for_Menu_Team__c')
            .selectField('Inflation__c')
            .selectField('Item_Level_Tax_Categories_Rates__c')
            .selectField('Inflation_Rounding_Unit__c')
            .selectField('Tax_Override_Rate__c')
            .selectField('In_Store_Pickup_Instructions__c')
            .selectField('DM_Email__c')
            .selectField('DM_First_Name__c')
            .selectField('DM_Last_Name__c')
            .selectField('DM_Phone__c')
            .selectField('Parking_Arrival_Instructions__c')
            .selectField('Store_Detail__c')
            .selectField('CreatedDate')
            .selectField('Storefront_Website__c')
            .selectField('Storefront_Match_Branded_Website__c')
            .selectField('Storefront_Mx_Has_Website__c')
            .selectField('Website_Creation_Needed_for_Storefront__c')
            .selectField('Account_Type__c')
            .selectField('Storefront_Proposed_Date_of_Impl__c')
            .selectField('Order_Protocol_Email__c')
            .selectField('AOR_Distance__c')
            .selectField('AOR_Enabled__c')
            .selectField('POS_Integration_Type__c')
            .selectField('POS_Integration_ID__c')
            .selectField('POS_System__c')
            .selectField('POS_Fallback_Protocol__c')
            .selectField('Custom_Delivery_Fee__c')
            .selectField('Custom_Delivery_Radius__c')
            .selectField('Max_Delivery_Radius_KM__c')
            .selectField('Delay_Tablet_Shipment__c')
            .selectField('Proposed_Date_of_Tablet__c')
            .selectField('Tablet_Delivery_Method__c')
            .selectField('Representative_First_Name__c')
            .selectField('Representative_Last_Name__c')
            .selectField('Representative_Email__c')
            .selectField('Representative_Phone__c')
            .selectField('Representative_Date_of_Birth__c')
            .selectField('Accessibilities__c')
            .selectField('Birthdate__c')
            .selectField('SSN_Last_4Digits__c')
            .selectField('Coverage__c')
            .selectField('Is_Store_For_No_Rep_Scenario__c')
            .selectField('User_Entered_Address__Street__s')
            .selectField('User_Entered_Address__City__s')
            .selectField('User_Entered_Address__StateCode__s')
            .selectField('User_Entered_Address__CountryCode__s')
            .selectField('User_Entered_Address__PostalCode__s')
            .selectField('Coverage__c')
            .selectField('Address_Verification_Status__c')
            .selectField('Address_ID__c')
            .selectField('Rejected_Reason__c')
            .selectField('Address_Verification_Date__c')
            .selectField('Last_Coverage_Check_Time__c')
            .selectField('Starting_Point__c')
            .selectField('Starting_Point_ID__c')
            .selectField('Alcohol_Eligibility__c')
            .selectField('Submarket__c')
            .selectField('Time_Zone_Backend__c')
            .selectField('Legal_Business_Name__c')
            .selectField('Provincial_Tax_Id__c')
            .selectField('Tax_ID__c')
            .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Mx_Onboarding_Link__c>) Database.query(query.toSOQL());
    }

    /**
     * @description Get all the Mx onboardings by UUIDs
     * @author VenkateshDD | 08-05-2024
     * @param uuids
     * @return List<Mx_Onboarding_Link__c>
     **/
    public List<Mx_Onboarding_Link__c> selectByUUID(Set<String> uuids) {
        fflib_QueryFactory query = newQueryFactory().setCondition('UUID__c IN : uuids');
        return (List<Mx_Onboarding_Link__c>) Database.query(query.toSOQL());
    }

    /**
     * @description It is used to get Mx Onboarding Links by record Ids.
     * @param recordIds
     * @return Mx_Onboarding_Link__c
     */
    public Mx_Onboarding_Link__c currentOnBoardingLink(Set<Id> recordIds) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Rep_Collecting_On_Mx_Behalf__c')
            .selectField('Onboarding_Scenario__c')
            .selectField('Product_on_Contract__c')
            .setCondition('ID IN :recordIds');
        return (Mx_Onboarding_Link__c) Database.query(query.toSOQL());
    }

    /**
     * @description This method is used for gettingMXOnboardinglink record by UUID
     * @param uniqueIdentifier
     * @return List<Mx_Onboarding_Link__c>
     */
    public List<Mx_Onboarding_Link__c> currentOnBoardingLinkByUUID(String uniqueIdentifier) {
        fflib_QueryFactory query = newQueryFactory()
            .selectField('Rep_Collecting_On_Mx_Behalf__c')
            .selectField('Onboarding_Scenario__c')
            .selectField('Product_on_Contract__c')
            .selectField('Payload__c')
            .selectField('Store_Count__c')
            .selectField('Status__c')
            .selectField('Expiration_Date_Time__c')
            .setCondition('UUID__c = :uniqueIdentifier');
        StoreDetailsSelector subSelector = new StoreDetailsSelector();
        subSelector.addQueryFactorySubselect(query, 'Store_Details__r')
            .selectField('Is_Store_For_No_Rep_Scenario__c')
            .selectField('Store_Name__c');
        return Database.query(query.toSOQL());
    }



    /**
    * @description - select mx onboarding link record by id along with its store and busines related records
    * @author Soumya Dash | 08-16-2024
    * @param mxLinkId
    * @return List<Mx_Onboarding_Link__c>
    **/
    public List<Mx_Onboarding_Link__c> selectByIdWithPayloadAndRelated(Id mxLinkId){
        fflib_QueryFactory query = newQueryFactory()
             .selectField('Payload__c')
        	 .setCondition('Id = :mxLinkId');

        new StoreDetailsSelector()
            .addQueryFactorySubselect(query,'Store_Details__r')
            .selectField('Id');

        new BusinessOnboardingDetailsSelector()
            .addQueryFactorySubselect(query, 'Business_Onboarding_Details__r')
            .selectField('Id');

        return (List<Mx_Onboarding_Link__c>)Database.query(query.toSOQL());
    }
}