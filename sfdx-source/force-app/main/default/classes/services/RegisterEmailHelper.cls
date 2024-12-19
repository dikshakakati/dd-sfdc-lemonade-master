/**
 * @author Deloitte
 * @date 05/22/2024
 * @description Register Email helper class to perform Messaging.sendEmail.
 * It leverages IEmailWork interface of fflib framework to overide the OOTB fflib commitWork method.
 * @purpose Sends Email using Messaging.sendEmail method by also implementing it through
 * fflib framework for mocking and stubbing (refer LEM-14703).
 * @documentation https://github.com/apex-enterprise-patterns/fflib-apex-common/blob/master/sfdx-source/apex-common/main/classes/fflib_SObjectUnitOfWork.cls
 */
public inherited sharing class RegisterEmailHelper implements fflib_SObjectUnitOfWork.IEmailWork {
    private static final String NULL_LIST_EXCEPTION_MESSAGE = 'null list cannot be registered';
    /**
     * @description It can be used by the calling class to identify the failed email transactions.
     */
    public Messaging.SendEmailResult[] sendEmailResults { get; private set; }
    @TestVisible
    private List<Messaging.SingleEmailMessage> singleEmailMessagesToSend;

    //Initialize variable and method as per IEmailWork interface.
    @TestVisible
    private List<Messaging.Email> emailsToInitialize;

    /**
     * @description Default constructor to instantiate variables.
     */
    public RegisterEmailHelper() {
        singleEmailMessagesToSend = new List<Messaging.SingleEmailMessage>();
    }

    /**
     * @description Default constructor to instantiate variables.
     * @param emailInstance
     */
    public void registerEmail(Messaging.Email emailInstance) {
        emailsToInitialize.add(emailInstance);
    }

    /**
     * @description It is implementation of doWork() method for sending
     * the Messaging.SingleEmailMessage records.
     */
    public void doWork() {
        sendEmailResults = Messaging.sendEmail(singleEmailMessagesToSend);
    }

    /**
     * @description It acts as the OOTB fflib registerNew() method
     * to collect a record for sending email.
     * @param singleEmailMessageInstance
     */
    public void registerSingleEmailMessage(
        Messaging.SingleEmailMessage singleEmailMessageInstance
    ) {
        singleEmailMessagesToSend.add(singleEmailMessageInstance);
    }

    /**
     * @description It acts as the OOTB fflib registerNew() method
     * to collect a list of records for sending email.
     * @param singleEmailMessageInstances
     */
    public void registerSingleEmailMessage(
        List<Messaging.SingleEmailMessage> singleEmailMessageInstances
    ) {
        if (singleEmailMessageInstances == null) {
            throw new fflib_SObjectUnitOfWork.UnitOfWorkException(NULL_LIST_EXCEPTION_MESSAGE);
        }
        for (Messaging.SingleEmailMessage eachSingleEmailMessage : singleEmailMessageInstances) {
            registerSingleEmailMessage(eachSingleEmailMessage);
        }
    }
}