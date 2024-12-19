/**
 * @description test class for ApplicationBindingServiceImpl
 * @author DoorDash
 * @date 2023-10-05
 */
@isTest(seeAllData=false)
public class ApplicationBindingServiceImplTest {
    /**
     * @description test method for when getBindingSObjects called return list of binding sobjects.
     */
    @isTest
    static void testWhenGetBindingSObjectsCalledThenReturnListOfSobjects(){
        List<ApplicationBinding> lstOfBindings = mockApplicationBindingRecords(); 
        List<SObjectType> lstOfSobjects = ApplicationBindingService.setAppBindingType(ApplicationBindingType.UNITOFWORK, lstOfBindings)
            .getBindingSObjects();
        System.assertEquals(1, lstOfSobjects.size(), 'Expected one SObject types');
        System.assertEquals(Case.SObjectType, lstOfSobjects[0], 'Expected Case SObjectType');
    }
     /**
     * @description test method for when getBindingsByType called returns implementations by binding type.
     */
    @isTest
    static void testWhenGetBindingTypeCalledThenReturnImpByBindingObj(){
		List<ApplicationBinding> lstOfBindings = mockApplicationBindingRecords(); 
        Map<System.Type, System.Type> bindingTypeToImpl = ApplicationBindingService.setAppBindingType(ApplicationBindingType.Service, lstOfBindings)
            .getBindingsByType();
        System.Type bindingType = System.Type.forName('IAccountsService');
        System.Type implementationType = System.Type.forName('AccountsServiceImpl');
        System.assertEquals(1, bindingTypeToImpl.size(), 'Expected one entry in the map');
        System.assertEquals(implementationType, bindingTypeToImpl.get(bindingType),
                            'Mismatch in implementation for IAccountsService binding type');
    }
     /**
     * @description test method for when getBindingsByObject called return implmenetations by binding object.
     */
    @isTest
    static void testWhenGetBindingsByObjectCalledThenReturnImplementationsByBinding(){
		List<ApplicationBinding> lstOfBindings = mockApplicationBindingRecords(); 
        Map<Object, System.Type> objectToImpl = ApplicationBindingService.setAppBindingType(ApplicationBindingType.Selector, lstOfBindings)
            .getBindingsByObject();
        System.Type implementationType = System.Type.forName('ContactsSelector');
        SObjectType sObjTypeCon = Schema.getGlobalDescribe().get('Contact');
        System.assertEquals(1, objectToImpl.size(), 'Expected one entry in the map');
        System.assertEquals(implementationType, objectToImpl.get(sObjTypeCon),
                            'Mismatch in implementation for Contact object');
    }
     /**
     * @description test method for when getBindingsBySObjectType called implementation by sobject type.
     */
    @isTest
    static void testWhenBindingsBySObjectTypeCalledThenReturnImplementationsBySObjectType(){
		List<ApplicationBinding> lstOfBindings = mockApplicationBindingRecords(); 
        Map<SObjectType, System.Type> objectToImpl = ApplicationBindingService.setAppBindingType(ApplicationBindingType.Selector, lstOfBindings)
            .getBindingsBySObjectType();
        System.Type implementationType = System.Type.forName('ContactsSelector');
        SObjectType sObjTypeCon = Schema.getGlobalDescribe().get('Contact');
        System.assertEquals(1, objectToImpl.size(), 'Expected one entry in the map');
        System.assertEquals(implementationType, objectToImpl.get(sObjTypeCon),
                            'Mismatch in implementation for Contact object');
    }
    /**
     * @description method for mocking the data.
     * @return List<ApplicationBinding__mdt>
     */
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