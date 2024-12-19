/**
 * @author BizApps
 * @date 17-April-2024
 * @description Interface for the JurisdictionService, which evaluates location-based rules against records
 **/
public interface IJurisdictionService {
    /**
     * @description Determines if a specified Mx is in a given Jurisdiction from its Record ID
     * @param recordId
     * @param jurisdiction
     * @return Boolean
     **/
    Boolean isMerchantInJurisdiction(Id recordId, JurisdictionService.Jurisdiction jurisdiction);

    /**
     * @description Returns true if ANY of the inputted records match the jurisdiction
     * @param recordIds
     * @param jurisdiction
     * @return Boolean
     **/
    Boolean areAnyMerchantsInJurisdiction(
        Set<Id> recordIds,
        JurisdictionService.Jurisdiction jurisdiction
    );

    /**
     * @description Determines if a specified Mx (from its record ID) is in every supplied Jurisdiction
     * @param recordId
     * @param jurisdictions
     * @return Boolean
     **/
    Boolean isMerchantInAllJurisdictions(
        Id recordId,
        List<JurisdictionService.Jurisdiction> jurisdictions
    );

    /**
     * @description Returns results for a number of inputted records based in the jurisdiction,
     *              bulkifying repeated `isMerchantInJurisdiction()` calls.
     * @param recordIds
     * @param jurisdiction
     * @return Map<Id, Boolean>
     **/
    Map<Id, Boolean> checkIdsInJurisdiction(
        Set<Id> recordIds,
        JurisdictionService.Jurisdiction jurisdiction
    );

    /**
     * @description Returns true if either the parent or any of the children are in the jurisdiction
     * @param parentAndChildrenMap
     * @param jurisdiction
     * @return Map<Id, Boolean>
     **/
    Map<Id, Boolean> checkParentAndChildrenInJurisdiction(
        Map<Id, Set<Id>> parentAndChildrenMap,
        JurisdictionService.Jurisdiction jurisdiction
    );
}