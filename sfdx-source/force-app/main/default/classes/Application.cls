/**
 * @author Deloitte
 * @date 22/02/2022
 * @description Class provides inner classes implementing factories for the main components
 * of the Apex Enterprise Patterns: Service, Unit Of Work, Selector and Domain.
 * Use Application binding custom metadata for regiestering classes or objects.
 */
public class Application {
    // Configure and create the UnitOfWorkFactory for this Application
    public static final fflib_Application.UnitOfWorkFactory UNITOFWORK = new ApplicationUnitOfWorkFactory(
        (List<SObjectType>) ApplicationBindingService.getBindingSObjects(
            ApplicationBindingType.UNITOFWORK
        )
    );
    // Configure and create the ServiceFactory for this Application
    public static final fflib_Application.ServiceFactory SERVICE = new ApplicationServiceFactory(
        (Map<System.Type, System.Type>) ApplicationBindingService.getBindingsByType(
            ApplicationBindingType.SERVICE
        )
    );
    // Configure and create the SelectorFactory for this Application
    public static final fflib_Application.SelectorFactory SELECTOR = new ApplicationSelectorFactory(
        (Map<SObjectType, System.Type>) ApplicationBindingService.getBindingsBySObjectType(
            ApplicationBindingType.SELECTOR
        )
    );
    // Configure and create the DomainFactory for this Application
    public static final fflib_Application.DomainFactory DOMAIN = new ApplicationDomainFactory(
        Selector,
        (Map<Object, System.Type>) ApplicationBindingService.getBindingsByObject(
            ApplicationBindingType.DOMAIN
        )
    );
    // Configure and create the EmailOutboundFactory for this Application
    public static final ApplicationEmailOutboundFactory EMAIL_OUTBOUND_INTEGRATION_EVENT = new ApplicationEmailOutboundFactory();
    // Configure and create the NotifierEventFactory for this Application
    public static final ApplicationNotificationFactory NOTIFIER_EVENT = new ApplicationNotificationFactory();
    public static final ApplicationOnboardingActivationsFactory ONBOARDING_AND_ACTIVATIONS_EVENT = new ApplicationOnboardingActivationsFactory();
    public static final ApplicationInstantIngestorFactory INSTANT_INGESTOR_EVENT = new ApplicationInstantIngestorFactory();
    public static final ApplicationNonInstantIngestionFactory NON_INSTANT_INGESTOR_EVENT = new ApplicationNonInstantIngestionFactory();
}