/**
 * @description derived class for checking if one operand is a substring to the other
 */
public without sharing class FieldContainsValue_LC implements ILogicalComparator {
    /**
     * @description returns outcome of the comparison
     * @param field first operand in comparison
     * @param value second operand in comparison
     * @return Boolean
     */
    public Boolean compare(Object field, Object value) {
        String fieldToUpperCase = (field == null) ? '' : String.valueOf(field).toUpperCase().trim();
        String valueToUpperCase = (value == null) ? '' : String.valueOf(value).toUpperCase().trim();
        return (String.isBlank(fieldToUpperCase) || String.isBlank(valueToUpperCase))
            ? false
            : fieldToUpperCase.contains(valueToUpperCase);
    }
}