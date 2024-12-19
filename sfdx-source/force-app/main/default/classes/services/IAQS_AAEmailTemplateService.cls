/**
 * @author atg
 * @date   05/13/2022
 * @description This is the service interface for Advance Approval EmailTemplate related logic
 */
public interface IAQS_AAEmailTemplateService {
    /**
	* @description create sbaa__EmailTemplate__c objects
    * @param existingTemplates
	*/
    void createTemplates(List<EmailTemplate> existingTemplates);
}