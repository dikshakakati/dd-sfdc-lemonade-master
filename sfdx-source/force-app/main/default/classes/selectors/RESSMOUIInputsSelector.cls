/**
 * @description       : RESSMO_UI_Input__mdt Selector class
 * @author            : SamikshaDD
 * @group             : Aethereus
 * @last modified on  : 08-30-2024
 * @last modified by  : Soumya Dash
**/

public inherited sharing class RESSMOUIInputsSelector extends fflib_SObjectSelector implements IRESSMOUIInputsSelector{

    public static final String APPLICABLE_FOR_QUOTE = 'Quote';
    public static final String APPLICABLE_FOR_CONTRACT = 'Contract';
    public static final String TYPE_OIATTRIBUTE = 'OIAttribute';

    /**
    * @description
    * @author SamikshaDD | 07-29-2024
    * @return IRESSMOUIInputsSelector
    **/
    public static IRESSMOUIInputsSelector newInstance() {
        return (IRESSMOUIInputsSelector) Application.Selector.newInstance(
            RESSMO_UI_Input__mdt.SObjectType
        );
    }

    /**
     * @description It is used for getting RESSMO_UI_Input__mdt object type.
     * @return SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return RESSMO_UI_Input__mdt.SObjectType;
    }

    /**
     * @description It is used for getting the fields on RESSMO_UI_Input__mdt.
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            RESSMO_UI_Input__mdt.Label,
            RESSMO_UI_Input__mdt.MasterLabel,
            RESSMO_UI_Input__mdt.DeveloperName,
            RESSMO_UI_Input__mdt.Applicable_For__c,
            RESSMO_UI_Input__mdt.Field_API_Name__c,
            RESSMO_UI_Input__mdt.Input_Type__c,
            RESSMO_UI_Input__mdt.Input_UI_Label__c,
            RESSMO_UI_Input__mdt.Object_API_Name__c,
            RESSMO_UI_Input__mdt.Order__c,
            RESSMO_UI_Input__mdt.Validation__c,
            RESSMO_UI_Input__mdt.Section__c,
            RESSMO_UI_Input__mdt.Type__c,
            RESSMO_UI_Input__mdt.UI_Validation_Message__c,
            RESSMO_UI_Input__mdt.Picklist_Values__c
        };
    }

    /**
    * @description Select RESSMO UI Input of Contract
    * @return List<RESSMO_UI_Input__mdt>
    **/
    public List<RESSMO_UI_Input__mdt> selectRessmoUiInputsOfContract(){
        return (List<RESSMO_UI_Input__mdt>)Database.query(
                                            newQueryFactory()
                                                .setCondition('Applicable_For__c =: APPLICABLE_FOR_CONTRACT AND Is_Active__c = true AND Type__c != :TYPE_OIATTRIBUTE')
                                                .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING)
                                                .toSOQL()
                                            );
    }

    /**
    * @description Select RESSMO UI Input of Quote
    * @return List<RESSMO_UI_Input__mdt>
    **/
    public List<RESSMO_UI_Input__mdt> selectRessmoUiInputsOfQuote(){
        return (List<RESSMO_UI_Input__mdt>)Database.query(
                                            newQueryFactory()
                                                .setCondition('Applicable_For__c =:APPLICABLE_FOR_QUOTE AND Is_Active__c = true AND Type__c != :TYPE_OIATTRIBUTE')
                                                .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING)
                                                .toSOQL()
                                            );
    }


    /**
    * @description - select all active and inactive ressmo ui input releted to contract
    * @author Soumya Dash | 08-29-2024
    * @return List<RESSMO_UI_Input__mdt>
    **/
    public List<RESSMO_UI_Input__mdt> selectAllREESMOUIInputContract(){
        return (List<RESSMO_UI_Input__mdt>)Database.query(
                                            newQueryFactory()
                                                .selectField('OIAttributes__r.Field_API_Name__c')
                                                .selectField('OIAttributes__r.Data_Type__c')
                                                .setCondition('Applicable_For__c =:APPLICABLE_FOR_CONTRACT AND Is_Active__c = true')
                                                .setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING)
                                                .toSOQL()
                                            );
    }

}