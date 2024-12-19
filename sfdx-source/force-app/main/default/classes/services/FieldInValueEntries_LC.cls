/**
 * @description derived class for checking if one operand is an entry in the comma separate values of the other
 */
public without sharing class FieldInValueEntries_LC implements ILogicalComparator {
    /**
     * @description returns outcome of the comparison
     * @param field first operand in comparison
     * @param value second operand in comparison
     * @return Boolean
     */
    public Boolean compare(Object field, Object value) {
        String fieldToUpperCase = (field == null) ? '' : String.valueOf(field).toUpperCase().trim();
        String valueToUpperCase = (value == null) ? '' : String.valueOf(value).toUpperCase();
        if (fieldToUpperCase == valueToUpperCase) {
            return false;
        }
        Set<string> valueToSet = new Set<String>();
        for (String v : valueToUpperCase.split(',')) {
            valueToSet.add(v.trim());
        }
        return valueToSet.contains(fieldToUpperCase);
    }
}