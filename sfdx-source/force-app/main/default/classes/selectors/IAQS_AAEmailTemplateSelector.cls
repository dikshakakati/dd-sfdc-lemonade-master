/**
 * @author atg
 * @date 05/11/2022
 * @description Interface to add Selector class methods
 */
public interface IAQS_AAEmailTemplateSelector extends fflib_ISObjectSelector {

    /**
     * @description This method is used for getting all sbaa__EmailTemplate__c
     * @return List<sbaa__EmailTemplate__c> List of EmailTemplates
     */
    List<sbaa__EmailTemplate__c> selectAllOrderedByName();
}