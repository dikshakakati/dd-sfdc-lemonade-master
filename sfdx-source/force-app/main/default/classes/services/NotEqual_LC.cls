/**
 * @description derived class for checking negation of equality
 */
public without sharing class NotEqual_LC implements ILogicalComparator {
    /**
     * @description returns outcome of the comparison
     * @param field first operand in comparison
     * @param value second operand in comparison
     * @return Boolean
     */
    public Boolean compare(Object field, Object value) {
        String fieldToUpperCase = (field == null) ? '' : String.valueOf(field).toUpperCase().trim();
        String valueToUpperCase = (value == null) ? '' : String.valueOf(value).toUpperCase().trim();
        return fieldToUpperCase != valueToUpperCase;
    }
}