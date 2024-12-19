/**
 * @description test class for ApplicationBindings
 * @author DoorDash
 * @date 2023-10-05
 */
@isTest(seeAllData=false)
public with sharing class ApplicationBindingsTest {
    /**
     * @description test method for filter the bindings by application type.
     */
    @isTest
    static void testWhenListOfApplicationBindingPassedThenReturnApplicationBindingsByApplicationType() {
    	List<ApplicationBinding> bindings = mockApplicationBindingRecords();
        ApplicationBindings appBindings = new ApplicationBindings(bindings);
        IApplicationBindings filteredAppBindings = appBindings.filteredByApplicationBindingType( ApplicationBindingType.DOMAIN );
        List<ApplicationBinding> domBindings = filteredAppBindings.getApplicationBindings();
        System.assertEquals(1, domBindings.size(), 'Domain Binding size not matching' );
    }
     /**
     * @description test method for filter list of binding sobjects.
     */
    @isTest
    static void testWhenListOfApplicationBindingPassedThenReturnlstOfBindingSObjectsType() {
		List<ApplicationBinding> bindings = mockApplicationBindingRecords();
        ApplicationBindings appBindings = new ApplicationBindings(bindings);
        List<SObjectType> bindingSObjectsType = appBindings.getBindingSObjectsType();
        System.assertEquals(3, bindingSObjectsType.size(), 'Expected three SObject types');
        System.assertEquals(Account.SObjectType, bindingSObjectsType[0], 'Expected Account SObjectType');
        System.assertEquals(Contact.SObjectType, bindingSObjectsType[1], 'Expected Contact SObjectType');
    }
     /**
     * @description test method for filter and return implementations by binding type.
     */
    @isTest
    static void testWhenListOfApplicationBindingPassedThenReturnImplementationsByBindingType() {
		List<ApplicationBinding> bindings = mockApplicationBindingRecords();
        ApplicationBindings appBindings = new ApplicationBindings(bindings);
        Map<System.Type, System.Type> implementationsByBindingType = appBindings.getImplementationsByBindingType();
        System.Type bingingType = System.Type.forName('IAccountsService');
        System.Type implementationType = System.Type.forName('AccountsServiceImpl');
        System.assertEquals(1, implementationsByBindingType.size(), 'Expected one entry in the map');
        System.assertEquals(implementationType, implementationsByBindingType.get(bingingType),
                            'Mismatch in implementation for IAccountsService binding type');
    }
     /**
     * @description test method for filter and return implmenetations by binding object.
     */
    @isTest
    static void testWhenListOfApplicationBindingPassedThenReturnImplementationsByBindingObject() {
		List<ApplicationBinding> bindings = mockApplicationBindingRecords();
        ApplicationBindings appBindings = new ApplicationBindings(bindings);
        Map<Object, System.Type> implementationsByBindingObject
            = appBindings.getImplementationsByBindingObject();
        System.Type implementationType = System.Type.forName('ContactsSelector');
        SObjectType sObjTypeAct = Schema.getGlobalDescribe().get('Contact');
        System.assertEquals(2, implementationsByBindingObject.size(), 'Expected two entries in the map');
        System.assertEquals(implementationType, implementationsByBindingObject.get(sObjTypeAct), 'Mismatch in implementation for sObjType Account');
    }
     /**
     * @description test method for filter and return implementation by sobject type
     */
    @isTest
    static void testWhenListOfApplicationBindingPassedThenReturnImplementationsByBindingSObjectType() {
		List<ApplicationBinding> bindings = mockApplicationBindingRecords();
        ApplicationBindings appBindings = new ApplicationBindings(bindings);
        Map<SObjectType, System.Type> implementationsByBindingObject
            = appBindings.getImplementationsByBindingSObjectType();
        System.Type implementationType = System.Type.forName('ContactsSelector');
        SObjectType sObjTypeAct = Schema.getGlobalDescribe().get('Contact');
        System.assertEquals(2, implementationsByBindingObject.size(), 'Expected two entries in the map');
        System.assertEquals(implementationType, implementationsByBindingObject.get(sObjTypeAct), 'Mismatch in implementation for sObjType Account');
    }
    static List<ApplicationBinding> mockApplicationBindingRecords(){
        List<ApplicationBinding> lstBindings = new List<ApplicationBinding>();
        ApplicationBinding__mdt domainAct = new ApplicationBinding__mdt (
              MasterLabel = 'Domain Account',
              DeveloperName = 'Domain_Account',
              ApplicationType__c = 'Domain',
              BindingObjectApiName__c = 'Account',
              ImplementationType__c = 'Accounts.Constructor'
        );
        ApplicationBinding__mdt selectorAct = new ApplicationBinding__mdt (
              MasterLabel = 'Selector_Contact',
              DeveloperName = 'Selector Contact',
              ApplicationType__c = 'Selector',
              BindingObjectApiName__c = 'Contact',
              ImplementationType__c = 'ContactsSelector'
        );
        ApplicationBinding__mdt serviceAct = new ApplicationBinding__mdt (
              MasterLabel = 'AccountsService',
              DeveloperName = 'AccountsService',
              ApplicationType__c = 'Service',
              BindingType__c = 'IAccountsService',
              ImplementationType__c = 'AccountsServiceImpl'
        );
        ApplicationBinding__mdt uowAct = new ApplicationBinding__mdt (
              MasterLabel = 'UnitOfWork Case',
              DeveloperName = 'UnitOfWork_Case',
              ApplicationType__c = 'UnitOfWork',
              BindingObjectApiName__c = 'Case'
        );
        List<ApplicationBinding__mdt> applicBindingMetadata
            = new List<ApplicationBinding__mdt>{domainAct, selectorAct, serviceAct, uowAct};
        for(ApplicationBinding__mdt objBinding: applicBindingMetadata){
            lstBindings.add(new ApplicationBinding(objBinding));
        }
      return lstBindings;
    }
}