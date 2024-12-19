/**
 * @author Deloitte
 * @date 02/12/2022
 * @description AccountContactRelation Object Trigger Handler.
 */
public class AccountContactRelationsHandler extends ApplicationDomainHandler {
    /**
     * @description Constructor Method for AccountContactRelationsHandler class
     * @param sObjects - AccountContactRelation Records List
     */
    public AccountContactRelationsHandler(List<AccountContactRelation> sObjects) {
        super(sObjects);
        setContextBypass(AccountContactRelation.SObjectType, AccountContactRelationsHandler.class);
    }

    /**
     * @description Constructor class implements fflib_SObjectDomain class
     */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        /**
         * @description This method implements construct method of fflib_SObjectDomain.IConstructable
         * @param sObjects - List of SObjects
         * @return AccountContactRelationsHandler
         */
        public fflib_SObjectDomain construct(List<SObject> sObjects) {
            return new AccountContactRelationsHandler(sObjects);
        }
    }

    /**
     * @description Called to perform before update processing
     * @param existing - The map of old requests
     */
    public override void onBeforeUpdate(Map<Id, SObject> existing) {
        List<AccountContactRelation> updatedACR = new List<AccountContactRelation>(
            (List<AccountContactRelation>) getChangedRecords(
                new Set<SObjectField>{ AccountContactRelation.Roles }
            )
        );
        AccountContactRelations.newInstance(updatedACR).validateSSNAndBirthdate();
    }
    /**
     * @description Called to perform before insert processing
     */
    public override void onBeforeInsert() {
        AccountContactRelations.newInstance(this.records).validateSSNAndBirthdate();
        AccountContactRelations.newInstance(this.records).updateRolesByEventType();
    }

    /**
     * @description Called to perform after insert processing
     */
    public override void onAfterInsert() {
        AccountContactRelations.newInstance(this.records).validateOCRCreation();
    }
}