/**
 * @description Provides all business ids in an account hierarchy to a flow
 */
public with sharing class BusinessIdHierarchyFlowController {
    /**
     * @description It is used to return all business ids in an account hierarchy
     * For very large enterprise Mx, there is a possibility of exceeding the query limit with a single accountId. Also,
     * if the system was to bulkify this controller because multiple users are executing the same flows, this could lead
     * to unexpected results where an incomplete list of business ids was returned to the user.  Given the synchronous
     * nature of the process, theres a low probability that the perfect storm of multiple users causing the system to
     * bulkify the invocable method AND the combined number of xref__c records for the Mx accounts the users are working
     * with to exceed the maximum queryable records.  That said, it is a known possibility.
     * @param accountIds A list of Account IDs for which to retrieve business references
     * @return List<Results> A list of Results objects, each containing business references for an account
     */
    @InvocableMethod(
        Label='Business References in the Account Hierarchy'
        Description='Get a list business references in the account hierarchy'
    )
    public static List<Results> getBusinessReferences(
        List<String> accountIds
    ) {
        Results[] results = new Results[]{};
        if( accountIds == null || accountIds.isEmpty() ) {
            return results;
        }

        Map<String, BusinessReference[]> mapRecordsByAccountId = mapToAccountHierarchy(
            accountIds,
            BusinessReferencesSelector.newInstance().selectAllBusinessIdsInAccountHierarchy( accountIds )
        );

        for( String accountId : accountIds ) {
            results.add( new Results( mapRecordsByAccountId.get( accountId ) ) );
        }

        return results;
    }

    /**
     * @description Returns aggregate records grouped by the accountIds that exist in their account hierarchy
     * @param accountIds A list of Account IDs for which to retrieve business references
     * @param records An array of Aggregate objects containing business reference data for the account hierarchy
     * @return Business Ids grouped by Account Id
     */
    private static Map<String, BusinessReference[]> mapToAccountHierarchy( String[] accountIds, Aggregate[] records ) {
        Map<String, BusinessReference[]> mapBusinessReferencesByAccountId = new Map<String, BusinessReference[]>();
        for( String accountId : accountIds ) {
            mapBusinessReferencesByAccountId.put( accountId, getRecordsInAccountHierarchy( accountId, records ) );
        }
        return mapBusinessReferencesByAccountId;
    }

    /**
     * @description Retrieves Business Reference records associated with a given account in its hierarchy from the
     * set of Aggregate records
     * @param accountId The ID of the account for which to retrieve Business References
     * @param records An array of Aggregate objects containing Business Reference data
     * @return An array of Business_Reference__c objects associated with the given account in its hierarchy
     */
    private static BusinessReference[] getRecordsInAccountHierarchy( String accountId, Aggregate[] records ) {
        Map<String, BusinessReference> businessReferencesById = new Map<String, BusinessReference>();
        if( accountId == null ) {
            return businessReferencesById.values();
        }

        for( Aggregate record : records ) {
            Set<String> parentIds = new Set<String>{
                (String) record.get( 'AccountId' ),
                (String) record.get( 'ParentAccountId1' ),
                (String) record.get( 'ParentAccountId2' ),
                (String) record.get( 'ParentAccountId3' ),
                (String) record.get( 'ParentAccountId4' ),
                (String) record.get( 'ParentAccountId5' )
            };
            if( parentIds.contains( accountId ) ) {
                BusinessReference businessReference = extractBusinessReference( record );
                businessReferencesById.put( businessReference.Id, businessReference );
            }
        }
        return businessReferencesById.values();
    }

    /**
     * @description Constructs a set of business reference objects based on the business reference fields
     *              included with the xrefs.
     * @param record A list of Xref__c objects containing business reference information
     * @return Business_Reference__c[] A list of Business_Reference__c objects for display purposes
     */
    private static BusinessReference extractBusinessReference( Aggregate record ) {
        if( record == null ) {
            return null;
        }

        BusinessReference bizRef = new BusinessReference();
        bizRef.Id = (String) record.get( 'BusinessReferenceId' );
        bizRef.ExternalId = (String) record.get( 'BusinessReferenceExternalId' );
        bizRef.ExternalIdSource = (String) record.get( 'BusinessReferenceExternalIdSource' );
        bizRef.BusinessName = (String) record.get( 'BusinessReferenceBusinessName' );
        bizRef.BusinessVerticalName = (String) record.get( 'BusinessReferenceVerticalName' );
        return bizRef;
    }

    /**
     * @description Wrapper class for the output of the getBusinessReferences invocable method.
     *              This class is designed to be compatible with Salesforce Flow, allowing
     *              for easy integration of the returned data into Flow elements.
     */
    public class Results {
        @InvocableVariable( Label='Business Reference' )
        public List<BusinessReference> businessReferences;

        /**
         * @description Constructor for the Results class
         * @param businessReferences A list of Business_Reference__c objects to be wrapped
         */
        public Results( List<BusinessReference> businessReferences ) {
            this.businessReferences = businessReferences;
            if( this.businessReferences == null ) {
                this.businessReferences = new BusinessReference[]{};
            }
        }
    }


}
