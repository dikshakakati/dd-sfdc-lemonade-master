/**
 * @author Aethereus
 * @date 05/27/2024
 * @description Selector Class for Contract Table Mapping custom metadata
 */
public inherited sharing class ContractTableMappingSelector extends fflib_SObjectSelector implements IContractTableMappingSelector {
    private static final String OBJECT_CONTRACT = 'Contract';
    private static final String OBJECT_SUBSCRIPTION = 'Subscription';
    private static final String PRODUCT_SPLIT_CATEGORY_ALL = 'All';
    private static final String OBJECT_SERVICES = 'Services';

    /**
     * @description default constructor for the class
     * @return IContractTableMappingSelector
     */
    public static IContractTableMappingSelector newInstance() {
        return (IContractTableMappingSelector) Application.Selector.newInstance(
            Contract_Table_Mapping__mdt.SObjectType
        );
    }

    /**
     * @description override default getSObjectType method
     * @return SObjectType - object type of metadata
     */
    public Schema.SObjectType getSObjectType() {
        return Contract_Table_Mapping__mdt.SObjectType;
    }

    /**
     * @description This method is for getting all field values for Contract_Table_Mapping__mdt
     * @return List<Contract_Table_Mapping__mdt> - List of metadata records with values
     */
    public List<Contract_Table_Mapping__mdt> getAllValues() {
        return Contract_Table_Mapping__mdt.getall().values();
    }

     /**
     * @description This method is used for getting metadata records sorted by order and custom segment.
     * @param initiatedFromSobject
     * @param customerSegment
     * @return List<Contract_Table_Mapping__mdt>
     */
    public List<Contract_Table_Mapping__mdt> selectContractTableMappingSortedByOrder(String initiatedFromSobject,String customerSegment) {
        fflib_QueryFactory query = newQueryFactory();
        query.selectField('Id');
        query.selectField('Label');
        query.selectField('API_Name__c');
        query.selectField('Order__c');
        query.selectField('Segment__c');
        query.selectField('Hyper_Link_Display_Field__c');
        query.selectField('Type__c');
        query.selectField('DeveloperName');
        query.setCondition('Segment__c = :customerSegment AND Available_On__c '+
                ' LIKE \'%' + String.escapeSingleQuotes(initiatedFromSobject) + '%\'');
        query.setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract_Table_Mapping__mdt>) Database.query(query.toSOQL());
    }

     /**
        query.selectField('Object__c');
        query.setCondition('Segment__c =: customerSegment AND Object__c =: OBJECT_CONTRACT');
        query.setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract_Table_Mapping__mdt>) Database.query(query.toSOQL());
    }
    /**
     * @description It is used for fetching Subscriptions' columns sorted by order and
     * custom segment.
     * @param customerSegment
     * @param splitCategory
     * @return List<Contract_Table_Mapping__mdt>
     */
    public List<Contract_Table_Mapping__mdt> selectSubscriptionObjectContractTableMappingsBySegmentAndApplicableProductsSortedByOrder(
        String customerSegment,
        String splitCategory
    ) {
        fflib_QueryFactory subsriptionColumnsQuery = newQueryFactory(false)
            .selectField('Label')
            .selectField('API_Name__c')
            .selectField('Order__c')
            .selectField('Segment__c')
            .selectField('Hyper_Link_Display_Field__c')
            .selectField('Type__c')
            .selectField('DeveloperName')
            .selectField('Object__c')
            .selectField('Applicable_for_Product__c')
            .setCondition(
                'Segment__c = :customerSegment AND Object__c = :OBJECT_SUBSCRIPTION AND (Applicable_for_Product__c = :splitCategory OR Applicable_for_Product__c = :PRODUCT_SPLIT_CATEGORY_ALL)'
            )
            .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract_Table_Mapping__mdt>) Database.query(subsriptionColumnsQuery.toSOQL());
    }

    /**
     * @description It is used for fething metadata records for Services sorted by order and custom segment.
     * @param customerSegment
     * @return List<Contract_Table_Mapping__mdt>
     */
    public List<Contract_Table_Mapping__mdt> selectMerchantServicesContractTableMappingByCustomerSegmentAndServiceObject(
        String customerSegment
    ) {
        fflib_QueryFactory servicesColumnsQuery = newQueryFactory(true)
            .setCondition('Segment__c =:customerSegment AND Object__c =:OBJECT_SERVICES')
            .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING);
        return (List<Contract_Table_Mapping__mdt>) Database.query(servicesColumnsQuery.toSOQL());
    }

    /**
     * @description This method is for getting the fields on Contract_Table_Mapping__mdt
     * @return List<Schema.SObjectField>- Contract_Table_Mapping__mdt fields
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Contract_Table_Mapping__mdt.Label,
            Contract_Table_Mapping__mdt.DeveloperName,
            Contract_Table_Mapping__mdt.API_Name__c,
            Contract_Table_Mapping__mdt.Segment__c,
            Contract_Table_Mapping__mdt.Hyper_Link_Display_Field__c,
            Contract_Table_Mapping__mdt.Order__c,
            Contract_Table_Mapping__mdt.Type__c,
            Contract_Table_Mapping__mdt.Object__c,
            Contract_Table_Mapping__mdt.Applicable_for_Product__c
        };
    }
}