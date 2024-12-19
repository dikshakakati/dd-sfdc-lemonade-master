/**
 * @author BizApps
 * @date 17-April-2024
 * @description Implementation of a Jurisdiction Service, which determines what records are part of which municipalities
 **/
public class JurisdictionService {
    public enum Jurisdiction {
        CANADA,
        SEATTLE
    }

    private static IJurisdictionService serviceInstance;
    private static IJurisdictionService getService() {
        if (serviceInstance == null) {
            serviceInstance = (IJurisdictionService) Application.Service.newInstance(
                IJurisdictionService.class
            );
        }
        return serviceInstance;
    }

    /**
     * @description Determines if a specified Mx is in a given Jurisdiction from its record ID
     * @param recordId
     * @param jurisdiction
     * @return Boolean
     **/
    public static Boolean isMerchantInJurisdiction(Id recordId, Jurisdiction jurisdiction) {
        return getService().isMerchantInJurisdiction(recordId, jurisdiction);
    }

    /**
     * @description Returns true if ANY of the inputted records match the jurisdiction
     * @param recordIds
     * @param jurisdiction
     * @return Boolean
     **/
    public static Boolean areAnyMerchantsInJurisdiction(
        Set<Id> recordIds,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        return getService().areAnyMerchantsInJurisdiction(recordIds, jurisdiction);
    }

    /**
     * @description Determines if a specified Mx (from its record ID) is in every supplied Jurisdiction
     * @param recordId
     * @param jurisdictions
     * @return Boolean
     **/
    public static Boolean isMerchantInAllJurisdictions(
        Id recordId,
        List<JurisdictionService.Jurisdiction> jurisdictions
    ) {
        return getService().isMerchantInAllJurisdictions(recordId, jurisdictions);
    }

    /**
     * @description Returns results for a number of inputted records based in the jurisdiction,
     *              bulkifying repeated `isMerchantInJurisdiction()` calls.
     * @param recordIds
     * @param jurisdiction
     * @return Map<Id, Boolean>
     **/
    public static Map<Id, Boolean> checkIdsInJurisdiction(
        Set<Id> recordIds,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        return getService().checkIdsInJurisdiction(recordIds, jurisdiction);
    }

    /**
     * @description Returns true if either the parent or any of the children are in the jurisdiction
     * @param parentAndChildrenMap
     * @param jurisdiction
     * @return Map<Id, Boolean>
     **/
    public static Map<Id, Boolean> checkParentAndChildrenInJurisdiction(
        Map<Id, Set<Id>> parentAndChildrenMap,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        return getService()
            .checkParentAndChildrenInJurisdiction(parentAndChildrenMap, jurisdiction);
    }
}