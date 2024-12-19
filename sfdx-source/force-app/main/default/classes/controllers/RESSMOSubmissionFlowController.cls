/**
 * @description       : LEM-25715 Ressmo Submission flow to send emails
 * @author            : VenkateshDD
 * @group             : Aethereus
 * @last modified on  : 12-13-2024
 * @last modified by  : VenkateshDD
**/
public with sharing class RESSMOSubmissionFlowController {
    /**
    * @description will render the email based on What Id and sends email
    * @author VenkateshDD | 12-13-2024
    * @param emailInputs
    **/
    @InvocableMethod(label='Send Emails to User')
    public static void sendEmails(List<EmailInput> emailInputs){
        fflib_ISObjectUnitOfWork unitOfWork = Application.UNITOFWORK.newInstance();

        for(EmailInput ei : emailInputs){
            Messaging.SingleEmailMessage singleEmailMessageToProcess = renderEmail(ei.templateId, null, ei.whatId);
            singleEmailMessageToProcess.setSaveAsActivity(false);
            singleEmailMessageToProcess.setToAddresses(ei.emailAddresses);
            singleEmailMessageToProcess.setOrgWideEmailAddressId(ei.orgWideAddress);
            singleEmailMessageToProcess.setTemplateId(ei.templateId);
            unitOfWork.registerEmail(singleEmailMessageToProcess);
        }

        unitOfWork.commitWork();
    }

    /**
    * @description renders the email and return the single email message
    * @author VenkateshDD | 12-13-2024
    * @param templateId
    * @param whoId
    * @param whatId
    * @return Messaging.SingleEmailMessage
    **/
    private static Messaging.SingleEmailMessage renderEmail(Id templateId, Id whoId, Id whatId){
        return Messaging.renderStoredEmailTemplate(templateId, whoId, whatId);
    }

    /**
    * @description wrapper to get input
    */
    public class EmailInput{
        @InvocableVariable
        public Id templateId;
        @InvocableVariable
        public Id orgWideAddress;
        @InvocableVariable
        public List<String> emailAddresses;
        @InvocableVariable
        public Id whatId;
    }
}