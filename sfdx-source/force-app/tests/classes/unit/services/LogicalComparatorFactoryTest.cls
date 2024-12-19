@isTest
private without sharing class LogicalComparatorFactoryTest {
    @isTest
    static void testWhenXanEntryOfComparatorFieldThenYaLogicalComparatorDefinedForX() {
        String className;
        Type classType;
        for (
            PicklistEntry entry : Schema.SObjectType.Criterion__c.fields.Comparator__c.getPicklistValues()
        ) {
            if (entry.getValue() == 'N/A') {
                continue;
            }
            className = entry.getValue().remove('_') + '_LC';
            classType = Type.forName(className);
            System.assertNotEquals(
                null,
                classType,
                String.format(
                    'There is no logical comparator class Named: {0}, defined for comparator: {1}',
                    new List<Object>{ className, entry.getValue() }
                )
            ); // a class must be defined for picklist entry
            System.assertNotEquals(
                null,
                LogicalComparatorFactory.getComparator(entry.getValue()),
                String.format(
                    'There is no logical comparator class Named: {0}, defined for comparator: {1}',
                    new List<Object>{ className, entry.getValue() }
                )
            ); // the factory must construct and return a non null instance for the picklist entry
            System.assertEquals(
                true,
                String.valueOf(LogicalComparatorFactory.getComparator(entry.getValue()))
                    .containsIgnoreCase(className),
                String.format(
                    'Expected type of the returned instance: {0}; actual: {1} ',
                    new List<Object>{
                        className,
                        String.valueOf(LogicalComparatorFactory.getComparator(entry.getValue()))
                    }
                )
            );
            System.assertEquals(
                true,
                (ILogicalComparator.class).isAssignableFrom(classType),
                String.format(
                    '{0} is not a derived type of {1}',
                    new List<Object>{ classType, ILogicalComparator.class }
                )
            ); // the class defined for picklist entry must implement ILogicalComparator
        }

        try {
            LogicalComparatorFactory.getComparator(null);
        } catch (LogicalComparatorFactory.LogicalComparatorFactoryException e) {
            System.assert(
                e.getMessage()
                    .equals(String.format('Comparator {0} unknown', new List<String>{ null })),
                String.format(
                    'Expected: {0}; Actual: {1}',
                    new List<Object>{
                        String.format('Comparator {0} unknown', new List<String>{ null }),
                        e.getMessage()
                    }
                )
            );
        }
    }
}