/**
 * @description Custom implementation of the UnitOfWork Factory.
 * Override fflib_Application.UnitOfWorkFactory methods here for any custom behavior
 */
public inherited sharing class ApplicationUnitOfWorkFactory  extends fflib_Application.UnitOfWorkFactory {

    /**
     * @description Constructs an instance of the UnitOfWork factory
     * @param lstObjectTypes - List of SObjectTypes in dependency order
     */
    public ApplicationUnitOfWorkFactory( List<SObjectType> lstObjectTypes ) {
        super( lstObjectTypes );
    }

    /**
     * @description Injects an implementation of IDML into all instances of UnitOfWork
     * @return Instance of UnitOfWork
     */
    public override fflib_ISObjectUnitOfWork newInstance() {
        return resolvedInstance( new fflib_SObjectUnitOfWork( m_objectTypes ) );
    }

    /**
     * @description Resolves whether a mock instance of UnitOfWork should be used
     * @param uow - Instance of UnitOfWork
     * @return Instance of UnitOfWork
     */
    public fflib_ISObjectUnitOfWork resolvedInstance( fflib_ISObjectUnitOfWork uow ) {
        if( m_mockUow != null ) {
            return m_mockUow;
        }
        return uow;
    }
}