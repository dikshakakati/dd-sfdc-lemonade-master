/**
 * @description       : IRESSMOUIInputsSelector interface for RESSMOUIInputsSelector
 * @author            : SamikshaDD
 * @group             : Aethereus
 * @last modified on  : 08-29-2024
 * @last modified by  : Soumya Dash
**/

public interface IRESSMOUIInputsSelector extends fflib_ISObjectSelector
{
    /**
    * @description Select RESSMO UI Input of Contract where Applicable_For__c = contract
    * @Jira
    * @return List<RESSMO_UI_Input__mdt>
    **/
    List<RESSMO_UI_Input__mdt> selectRessmoUiInputsOfContract();

    /**
    * @description Select RESSMO UI Input of Contract where Applicable_For__c = quote
    * @Jira
    * @return List<RESSMO_UI_Input__mdt>
    **/
    List<RESSMO_UI_Input__mdt> selectRessmoUiInputsOfQuote();

    /**
    * @description - select all active and inactive ressmo ui input releted to contract
    * @author Soumya Dash | 08-29-2024
    * @param ;
    * @return List<RESSMO_Mapping__mdt>
    **/
    List<RESSMO_UI_Input__mdt> selectAllREESMOUIInputContract();
}