/**
 * @author Deloitte
 * @date 22/02/2022
 * @description  Application Domain handler to disable TriggerCRUDSecurity
 **/
@SuppressWarnings('PMD.ClassNamingConventions')
public inherited sharing abstract class ApplicationDomainHandler extends fflib_SObjectDomain {
    /**
     * @description default constructor for the class
     * @author Deloitte
     * @/**
     * @description default constructor for the class.
     * @param records - list of records
     */
    @SuppressWarnings('PMD.ApexDangerousMethods')
    public ApplicationDomainHandler(List<SObject> records) {
        super(records);
        // This design decision is intended to shift the responsibility of enforcing the object security checking to the calling code,
        // rather than setting it globally. Individual trigger handler classes can re-enable this feature if their particular use case requires it.
        Configuration.disableTriggerCRUDSecurity();
    }

    /**
     * @description This method checks if trigger is bypassed and sets the context bypass
     * @param sObjectType Schema.SObjectType
     * @param domainClass System.Type
     */
    protected void setContextBypass(Schema.SObjectType sObjectType, System.Type domainClass) {
        System.TriggerOperation triggerContext = SystemFacade.getTriggerContext();
        if (!BypassLogicModel.isTriggerBypassed(String.valueOf(sObjectType), triggerContext)) {
            return;
        }
        switch on triggerContext {
            when BEFORE_INSERT {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableBeforeInsert();
            }
            when AFTER_INSERT {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableAfterInsert();
            }
            when BEFORE_UPDATE {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableBeforeUpdate();
            }
            when AFTER_UPDATE {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableAfterUpdate();
            }
            when BEFORE_DELETE {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableBeforeDelete();
            }
            when AFTER_DELETE {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableAfterDelete();
            }
            when AFTER_UNDELETE {
                fflib_SObjectDomain.getTriggerEvent(domainClass).disableAfterUndelete();
            }
        }
    }
}