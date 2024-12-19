/**
 * @author Deloitte
 * @date   04/03/2022
 * @description This is the service implementation class for AQS_AAEmailTemplateService related logic
 */
public inherited sharing class AQS_AAEmailTemplateServiceImpl implements IAQS_AAEmailTemplateService {
    /**
	* @description create Templates based off of existing EmailTemplates
    * @param existingTemplates
	*/
    public void createTemplates(List<EmailTemplate> existingTemplates) {
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();

        //loops through existing templates, sets values for SBAA email template records
        for(EmailTemplate currentEmailTemplate : existingTemplates) {
            sbaa__EmailTemplate__c addedSBAAEmailTemplate = new sbaa__EmailTemplate__c();
            addedSBAAEmailTemplate.Name = currentEmailTemplate.name;
            addedSBAAEmailTemplate.sbaa__templateID__c = currentEmailTemplate.Id;
            uow.registerNew(addedSBAAEmailTemplate);
        }
        uow.commitWork();
    }

}