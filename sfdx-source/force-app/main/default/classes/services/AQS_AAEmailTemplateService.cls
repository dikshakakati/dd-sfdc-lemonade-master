/**
 * @author atg
 * @date   05/13/2022
 * @description This is the service class for AQS_AAEmailTemplateService related logic
 */
public inherited sharing class AQS_AAEmailTemplateService {
    /**
     * @description create SBAA Email templates from standard Templates
     * @param existingTemplates
     */
    public static void createTemplates(List<EmailTemplate> existingTemplates) {
        service().createTemplates(existingTemplates);
    }

    private static IAQS_AAEmailTemplateService service() {
        return (IAQS_AAEmailTemplateService) Application.Service.newInstance(IAQS_AAEmailTemplateService.class);
    }
}