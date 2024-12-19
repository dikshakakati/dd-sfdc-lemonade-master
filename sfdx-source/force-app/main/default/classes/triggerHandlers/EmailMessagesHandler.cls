/**
 * @author Deloitte
 * @date 22/02/2022
 * @description EmailMessage Object Trigger Handler
 */
public class EmailMessagesHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method
     * @param sObjectList - EmailMessage Record List
     */
    public EmailMessagesHandler(List<EmailMessage> sObjectList) {
        super(sObjectList);
        setContextBypass(EmailMessage.SObjectType, EmailMessagesHandler.class);
    }
    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjectList - List of SObjects
         * @return EmailMessagesHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new EmailMessagesHandler(sObjectList);
        }
    }

    /**
     * @description It is used to perform processing after EmailMessage insertion.
     */
    public override void onAfterInsert() {
        EmailMessages.newInstance(this.records).updateEmailCountWhenEmailMessageInserted();
        EmailMessages.newInstance(this.records).updateWorkPlanWhenEmailMessageInserted();
        EmailMessages.newInstance(this.records).setLastEmailReceivedDate();
    }
}