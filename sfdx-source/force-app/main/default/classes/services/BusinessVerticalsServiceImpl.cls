/**
 * @author Deloitte
 * @date 11/10/2023
 * @description Service implementation class for Business_Vertical__c related logic.
 */
public class BusinessVerticalsServiceImpl implements IBusinessVerticalsService {
    private static final String BUSINESS_VERTICAL_API_NAME = 'Business_Vertical__c';
    private static final String BUSINESS_VERTICAL_ID_API_NAME = 'Business_Vertical_ID__c';
    private static final String PRIMARY_VERTICAL_API_NAME = 'Primary_Vertical__c';
    private static final String MENU_UI_TYPE_API_NAME = 'Menu_UI_Type__c';
    private static final String EXTERNAL_ID_SOURCE_API_NAME = 'External_Id_Source__c';
    private static final String DEFAULT_TYPE_API_NAME = 'Default_Type__c';

    /**
     * @description It is used to default business vertical from a blank value to Rx on Business References where
     * 'External Id Source' is not "DriveDb" and 'Deafult Type' is not "COO Graveyard".
     * @param eachSobject
     */
    private void defaultBusinessVerticalRxOnSObjects(SObject eachSobject) {
        if (
            (eachSObject instanceof Business_Reference__c) &&
            ((String) eachSObject.get(EXTERNAL_ID_SOURCE_API_NAME) != System.Label.DriveDb) &&
            ((String) eachSObject.get(DEFAULT_TYPE_API_NAME) != System.Label.COO_Graveyard)
        ) {
            List<Business_Vertical__c> businessVerticalRX = BusinessVerticalsSelector.newInstance()
                .selectPrimaryVerticalRxRecord();
            if (!businessVerticalRX.isEmpty()) {
                eachSobject.put(BUSINESS_VERTICAL_API_NAME, businessVerticalRX[0].Id);
                eachSobject.put(
                    BUSINESS_VERTICAL_ID_API_NAME,
                    businessVerticalRX[0].Business_Vertical_ID__c
                );
                eachSobject.put(
                    PRIMARY_VERTICAL_API_NAME,
                    businessVerticalRX[0].Primary_Vertical__c
                );
                eachSobject.put(MENU_UI_TYPE_API_NAME, businessVerticalRX[0].Menu_UI_Type__c);
            }
        }
    }

    /**
     * @description It is used to set the business vertical and associated fields on the given sobjects.
     * @param eachSobject
     * @param businessVerticalsById
     */
    private void defaultBusinessVerticalDetailsOnSObjects(
        SObject eachSobject,
        Map<Id, Business_Vertical__c> businessVerticalsById
    ) {
        if (eachSObject instanceof Business_Reference__c) {
            eachSobject.put(
                BUSINESS_VERTICAL_ID_API_NAME,
                businessVerticalsById.get((String) eachSObject.get(BUSINESS_VERTICAL_API_NAME))
                    .Business_Vertical_ID__c
            );
        }

        eachSobject.put(
            PRIMARY_VERTICAL_API_NAME,
            businessVerticalsById.get((String) eachSObject.get(BUSINESS_VERTICAL_API_NAME))
                .Primary_Vertical__c
        );

        eachSobject.put(
            MENU_UI_TYPE_API_NAME,
            businessVerticalsById.get((String) eachSObject.get(BUSINESS_VERTICAL_API_NAME))
                .Menu_UI_Type__c
        );
    }

    /**
     * @description It is used to map Primary Vertical, Business Vertical Id, Menu UI Type from Business Vertical records to the
     * Sboject records passed.
     * @JIRA# LEM-11072
     * @param sObjects
     */
    public void populateBusinessVerticalDetails(List<SObject> sObjects) {
        Set<Id> businessVerticalIds = new Set<Id>();
        for (SObject eachSObject : sObjects) {
            businessVerticalIds.add((Id) eachSObject.get(BUSINESS_VERTICAL_API_NAME));
        }

        Map<Id, Business_Vertical__c> businessVerticalsById = new Map<Id, Business_Vertical__c>(
            BusinessVerticalsSelector.newInstance().selectById(businessVerticalIds)
        );

        for (SObject eachSobject : sObjects) {
            if (
                !businessVerticalsById.isEmpty() &&
                businessVerticalsById.containsKey((Id) eachSObject.get(BUSINESS_VERTICAL_API_NAME))
            ) {
                defaultBusinessVerticalDetailsOnSObjects(eachSobject, businessVerticalsById);
            } else {
                defaultBusinessVerticalRxOnSObjects(eachSobject);
            }
        }
    }
}