/**
 * @author BizApps
 * @date 17-April-2024
 * @description Implementation of a Jurisdiction Service, which determines what records are part of which municipalities
 **/
public without sharing class JurisdictionServiceImpl implements IJurisdictionService {
    private List<Jurisdiction_Rule__mdt> rules {
        get {
            if (rules == null) {
                // Use static query here as `Jurisdiction_Rule__mdt.getAll().values()` does not support long text area
                // fields (for Postal Codes), and instead truncates them at 255 characters
                rules = new List<Jurisdiction_Rule__mdt>(
                    [
                        SELECT
                            Id,
                            MasterLabel,
                            DeveloperName,
                            Jurisdiction_Name__c,
                            Is_Active__c,
                            City__c,
                            Country__c,
                            Postal_Code__c,
                            State_Province__c
                        FROM Jurisdiction_Rule__mdt
                        WHERE Is_Active__c = TRUE
                    ]
                );
            }

            return rules;
        }
        set;
    }

    private static Map<JurisdictionService.Jurisdiction, String> jurisdictionNames = new Map<JurisdictionService.Jurisdiction, String>{
        JurisdictionService.Jurisdiction.CANADA => 'Canada',
        JurisdictionService.Jurisdiction.SEATTLE => 'Seattle'
        // Map other jurisdictions as needed
    };

    public static final String UNSUPPORTED_OBJECT_EXCEPTION_MSG = 'The inputted object type is not supported: ';

    /**
     * @description Determines if a specified record is located in a given jurisdiction
     * @param recordId
     * @param jurisdiction
     * @return Boolean
     **/
    public Boolean isMerchantInJurisdiction(
        Id recordId,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        sObject record = JurisdictionServiceHelper.fetchDataById(recordId);
        return isMerchantInJurisdiction(record, jurisdiction);
    }

    /**
     * @description Determines if a specified Mx is in every supplied Jurisdiction
     * @param recordId
     * @param jurisdictions
     * @return Boolean
     **/
    public Boolean isMerchantInAllJurisdictions(
        Id recordId,
        List<JurisdictionService.Jurisdiction> jurisdictions
    ) {
        sObject record = JurisdictionServiceHelper.fetchDataById(recordId);

        for (JurisdictionService.Jurisdiction jurisdiction : jurisdictions) {
            if (!isMerchantInJurisdiction(record, jurisdiction)) {
                return false;
            }
        }

        return true;
    }

    /**
     * @description Returns true if ANY of the inputted records match the jurisdiction
     * @param recordIds
     * @param jurisdiction
     * @return Boolean
     **/
    public Boolean areAnyMerchantsInJurisdiction(
        Set<Id> recordIds,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        if (recordIds == null || recordIds.isEmpty()) {
            return false;
        }

        Map<String, List<SObject>> recordsByType = JurisdictionServiceHelper.fetchDataByType(
            recordIds
        );
        for (String thisObjectType : recordsByType.keySet()) {
            for (sObject thisRecord : recordsByType.get(thisObjectType)) {
                // Exit if we find a single Mx in the location
                if (isMerchantInJurisdiction(thisRecord, jurisdiction)) {
                    return true;
                }
            }
        }

        return false;
    }

    /**
     * @description Returns results for a number of inputted records based in the jurisdiction,
     *              bulkifying repeated `isMerchantInJurisdiction()` calls.
     * @param recordIds
     * @param jurisdiction
     * @return Map<Id, Boolean>
     **/
    public Map<Id, Boolean> checkIdsInJurisdiction(
        Set<Id> recordIds,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        Map<Id, Boolean> results = new Map<Id, Boolean>();

        if (recordIds != null && !recordIds.isEmpty()) {
            Map<String, List<SObject>> recordsByType = JurisdictionServiceHelper.fetchDataByType(
                recordIds
            );
            for (String thisObjectType : recordsByType.keySet()) {
                for (sObject thisRecord : recordsByType.get(thisObjectType)) {
                    results.put(thisRecord.Id, isMerchantInJurisdiction(thisRecord, jurisdiction));
                }
            }
        }

        return results;
    }

    /**
     * @description Returns true if either the parent or any of the children are in the jurisdiction
     * @param parentAndChildrenMap
     * @param jurisdiction
     * @return Map<Id, Boolean>
     **/
    public Map<Id, Boolean> checkParentAndChildrenInJurisdiction(
        Map<Id, Set<Id>> parentAndChildrenMap,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        Map<Id, Boolean> results = new Map<Id, Boolean>();

        // Only run the queries, etc if we have records
        if (parentAndChildrenMap != null && !parentAndChildrenMap.isEmpty()) {
            Set<Id> allRecordIds = JurisdictionServiceHelper.convertParentChildMapToSetOfIds(
                parentAndChildrenMap
            );
            // Convert the IDs to SObject records to evaluate against the Jurisdiction Rule
            Map<String, List<SObject>> recordsByType = JurisdictionServiceHelper.fetchDataByType(
                allRecordIds
            );

            Map<Id, Boolean> recordsWithJurisdictionStatus = new Map<Id, Boolean>();
            // Now, store every record - parent or child - by its status of being in the Jurisdiction
            for (String thisObjectType : recordsByType.keySet()) {
                for (SObject thisRecord : recordsByType.get(thisObjectType)) {
                    recordsWithJurisdictionStatus.put(
                        thisRecord.Id,
                        isMerchantInJurisdiction(thisRecord, jurisdiction)
                    );
                }
            }

            // If we are evaluating Work Orders, convert the Accounts back into a Work Order map
            recordsWithJurisdictionStatus = JurisdictionServiceHelper.convertAccountResultsToWorkOrders(
                allRecordIds,
                recordsWithJurisdictionStatus
            );

            // The `recordsWithJurisdictionStatus` Map will hold the results for each individual record
            // Now, with those results, determine which PARENTS are in the Jurisdiction by returning
            // true if the parent OR any of its children have a jurisdiction status of `true`.
            for (Id thisParentId : parentAndChildrenMap.keySet()) {
                // If the parent is in the jurisdiction, no need to consider the children
                if (recordsWithJurisdictionStatus.get(thisParentId) == true) {
                    results.put(thisParentId, true);
                    continue;
                }

                Boolean isInJurisdiction = false;
                for (Id thisChildId : parentAndChildrenMap.get(thisParentId)) {
                    isInJurisdiction = recordsWithJurisdictionStatus.get(thisChildId);

                    // We only care if any are in the jurisdiction, so we can quit once we find one
                    if (isInJurisdiction == true) {
                        break;
                    }
                }

                results.put(thisParentId, isInJurisdiction);
            }
        }

        return results;
    }

    /**
     * @description Determines if a specified record is in a given Jurisdiction
     * @param record
     * @param jurisdiction
     * @return Boolean
     **/
    private Boolean isMerchantInJurisdiction(
        SObject record,
        JurisdictionService.Jurisdiction jurisdiction
    ) {
        String jurisdictionName = jurisdictionNames.get(jurisdiction);

        for (Jurisdiction_Rule__mdt rule : rules) {
            if (
                rule.Jurisdiction_Name__c.equalsIgnoreCase(jurisdictionName) &&
                rule.Is_Active__c &&
                matchesJurisdiction(record, rule)
            ) {
                return true;
            }
        }

        return false;
    }

    /**
     * @description Looks into a Record and a Jurisdiction Rule and returns `true` if their location values match.
     * @param record
     * @param rule
     * @return Boolean
     **/
    @SuppressWarnings('PMD.CyclomaticComplexity')
    @TestVisible
    private static Boolean matchesJurisdiction(SObject record, Jurisdiction_Rule__mdt rule) {
        if (record == null) {
            return false;
        }

        String objectApiName = record.getSObjectType().getDescribe().getName();
        if (JurisdictionServiceHelper.getFieldMap(objectApiName) == null) {
            throw new UnsupportedObjectException(UNSUPPORTED_OBJECT_EXCEPTION_MSG + objectApiName);
        }

        Map<String, String> objectFieldNames = JurisdictionServiceHelper.getFieldMap(objectApiName);

        // Check static fields
        if (
            !String.isEmpty(rule.City__c) &&
            !rule.City__c.equalsIgnoreCase(
                (String) record.get(objectFieldNames.get(JurisdictionServiceHelper.CITY))
            )
        ) {
            return false;
        }
        if (
            !String.isEmpty(rule.State_Province__c) &&
            !rule.State_Province__c.equalsIgnoreCase(
                (String) record.get(objectFieldNames.get(JurisdictionServiceHelper.STATE))
            )
        ) {
            return false;
        }
        if (
            !String.isEmpty(rule.Country__c) &&
            !rule.Country__c.equalsIgnoreCase(
                (String) record.get(objectFieldNames.get(JurisdictionServiceHelper.COUNTRY))
            )
        ) {
            return false;
        }
        // Check Postal Code, considering semi-colon-delimited list and possible spaces
        if (!String.isEmpty(rule.Postal_Code__c)) {
            List<String> validPostalCodes = new List<String>();
            for (String code : rule.Postal_Code__c.split(';')) {
                validPostalCodes.add(code.trim()); // Trim spaces around codes
            }

            String thisZipCode = (String) record.get(
                objectFieldNames.get(JurisdictionServiceHelper.POSTAL_CODE)
            );

            if (String.isBlank(thisZipCode) || !validPostalCodes.contains((thisZipCode).trim())) {
                return false;
            }
        }

        return true;
    }

    /**
     * @description Exception type thrown if there is an issue with the inputted object type
     **/
    public class UnsupportedObjectException extends Exception {
    }
}