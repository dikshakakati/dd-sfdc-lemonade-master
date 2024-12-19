/**
 * @description factory class to create various instances of LogicalComparator
 */
public without sharing class LogicalComparatorFactory {
    final static Map<String, ILogicalComparator> COMPARATORS;

    static {
        comparators = new Map<String, ILogicalComparator>();
        for (
            PicklistEntry entry : Schema.SObjectType.Criterion__c.fields.Comparator__c.getPicklistValues()
        ) {
            if (entry.getValue() == 'N/A') {
                continue;
            }
            comparators.put(entry.getValue().toUpperCase(), null);
        }
    }

    /**
     * @description returns outcome of the comparison
     * @param comparatorName used to identify the correct derive type to return
     * @return ILogicalComparator
     */
    public static ILogicalComparator getComparator(String comparatorName) {
        if (!comparators.containsKey(comparatorName)) {
            throw new LogicalComparatorFactoryException(
                String.format('Comparator {0} unknown', new List<String>{ comparatorName })
            );
        }

        if (comparators.get(comparatorName) == null) {
            ILogicalComparator comparator = (ILogicalComparator) Type.forName(
                    comparatorName.remove('_') + '_LC'
                )
                .newInstance();
            comparators.put(comparatorName, comparator);
        }

        return comparators.get(comparatorName);
    }

    /**
     * @description factory's exception class
     */
    public class LogicalComparatorFactoryException extends Exception {
    }
}