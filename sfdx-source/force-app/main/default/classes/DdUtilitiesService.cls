/**
 * @author CriticalRiver
 * @date   Sept, 20 2024
 * @description Class for generic Utilities.
*/
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class DdUtilitiesService {
	public static final Map<String, Schema.SObjectType> SOBJECT_TYPES = Schema.getGlobalDescribe();
    public static final String LOG_DD_UTILITIES = 'Dd Utilities Service';
    public static final String LOG_IS_DECIMAL = 'Check if Number is Decimal.';
    public static final String LOG_GET_FIELD_VALUE = 'We Cannot get the field value';
    public static final String LOG_FIELD_VALUE_STRING = 'Get Field Value As String';

    /**
     * @description Check if a string is a Decimal
     * @param val - a string which contains a number, may be commafied
     * @return Boolean
     */
    public static boolean isDecimal(String val) {
        Boolean isValidDecimal = false;
        val = String.isNotBlank(val) ? val.replaceAll(DdConstants.DELIMITER_COMMA,DdConstants.BLANK_STRING) : DdConstants.BLANK_STRING;
        if (String.isNotBlank(val)){
            try {
                Decimal.valueOf(val);
                isValidDecimal = true;
            } catch(TypeException unitOfWorkException) {
                //set the static error message so that we can search by Id in Scalayr
                unitOfWorkException.setMessage(unitOfWorkException.getMessage());

                GenericLoggerService.publish(
                    GenericLoggerService.createGenericLog(
                        LOG_DD_UTILITIES,LOG_IS_DECIMAL,GenericLogEntry.SeverityLevel.MEDIUM
                    ).logException(unitOfWorkException)
                );
            }
        }
        return isValidDecimal;
    }

    /**
     * @description Format a Decimal String
     * @param val - a string which contains a number
     * @return String - Commafied and scaled Decimal
     */
    public static String formatDecimal(String val) {
        Decimal d = Decimal.valueOf(val).setScale(2);
        String f = d.format();
        if (f.indexOf(DdConstants.DELIMITER_DOT) == -1) {
            return f + '.00';
        } else if (f.substringAfterLast(DdConstants.DELIMITER_DOT).length() == 1) {
            return f + '0';
        }
        return f;
    }

    /**
     * @description Get the value of an Object's Field
     * @param obj - Object record
     * @param fieldName - Field API Name (can be field in the Object (x__c) or a Lookup (y__r.z__c))
     * @return Object - Field Value
     */
    public static Object getFieldVal(Sobject obj, String fieldName) {
        Object fieldVal = null;
        try {
            if (fieldName.contains(DdConstants.DELIMITER_DOT)) {
                List<String> fieldPath = fieldName.split('\\.');
                for (Integer i = 0; i < fieldPath.size(); i++) {
                    if (i < (fieldPath.size() - 1)) {
                        obj = obj.getSobject(fieldPath[i]);
                    } else {
                        fieldVal = obj.get(fieldPath[i]);
                    }
                }
            } else {
                fieldVal = obj.get(fieldName);
            }
        } catch (Exception unitOfWorkException) {
			//set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(unitOfWorkException.getMessage());

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_DD_UTILITIES,LOG_GET_FIELD_VALUE,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
        }
        return fieldVal;
    }

   /**
     * @description Is an Sobject accessible to current logged in user
     * @param objName - Object Name
     * @return Boolean - If object is accessible to current logged in user
     */
    public static Boolean objectIsAccessible(String objName) {
        return String.isNotBlank(objName) && SOBJECT_TYPES.get(objName).getDescribe().isAccessible();
    }

    private static final List<String> MONTHS = new List<String>{'','January','February',
    'March','April','May','June','July','August','September','October',
    'November','December'};

    /**
     * @description Get the value of an Object's Field as a formatted string
     * @param obj - Object record
     * @param fieldName - Field API Name (can be field in the Object (x__c) or a Lookup (y__r.z__c))
     * @return  String - Field Value
     */
    public static String getFieldValAsString(Sobject obj, String fieldName) {
        String retVal = DdConstants.BLANK_STRING;
        try {
            Object fieldVal = getFieldVal(obj,fieldName);
            retVal = (fieldVal == null) ? DdConstants.BLANK_STRING : String.valueOf(fieldVal);
        } catch (Exception unitOfWorkException) {
			//set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(unitOfWorkException.getMessage());

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_DD_UTILITIES,LOG_FIELD_VALUE_STRING,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
        }
        return retVal;
    }

    /**
     * @description Get the value of an Object's Field as a formatted string
     * @param obj - Object record
     * @param fieldName - Field API Name (can be field in the Object (x__c) or a Lookup (y__r.z__c))
     * @param datatype - Data type of the field
     * @return  String - Field Value
     */
    public static String getFieldValAsString(Sobject obj, String fieldName, String datatype) {
        String retVal = DdConstants.BLANK_STRING;
        try {
            Object fieldVal = getFieldVal(obj,fieldName);

            retVal = (fieldVal == null) ? DdConstants.BLANK_STRING : String.valueOf(fieldVal);

            if (String.isBlank(datatype) || datatype == 'Boolean') {
                if (retVal == 'true') {
                    retVal = DdConstants.STRING_YES;
                }
                if (retVal == 'false') {
                    retVal = DdConstants.STRING_NO;
                }
            }

            if (datatype == 'Date') {
                Date d = Date.valueOf(retVal);
                retVal = MONTHS[d.month()] + DdConstants.DELIMITER_SPACE + d.day() +
                    DdConstants.DELIMITER_COMMA + DdConstants.DELIMITER_SPACE +  d.year();
            }

            if ((String.isBlank(datatype) || datatype == 'Decimal') &&
                    String.isNotBlank(retVal) && isDecimal(retVal)) {
                retVal = formatDecimal(retVal);
            }
        } catch (Exception unitOfWorkException) {
			//set the static error message so that we can search by Id in Scalayr
            unitOfWorkException.setMessage(unitOfWorkException.getMessage());

            GenericLoggerService.publish(
                GenericLoggerService.createGenericLog(
                    LOG_DD_UTILITIES,LOG_FIELD_VALUE_STRING,GenericLogEntry.SeverityLevel.MEDIUM
                ).logException(unitOfWorkException)
            );
        }
        return retVal;
    }

    /**
     * @description  Sanitizes the SOQL by escaping the reserved characters
     *              https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_sosl_find.htm#:~:text=Reserved%20Characters
     * 				https://anothersalesforceblog.com/2021/07/01/regular-expression-soql-sosl/
     * @param text {String} - to search in
     * @return String
    */
    public static String sanitizeStringSOSL(String text) {
		if ( String.isBlank( text ) ) {
            return text;
        }
        // \\p{Punct} in the pattern class matches all punctuation, including single quotes
        // https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html
        String regexp = '[\\p{Punct}&&[^.#$%,/;<=>@_`]]';
        // \\$0 is the entire matched string, and \\ escapes it
        String replace = '\\\\$0';
        return text.replaceAll(regexp, replace);
    }
}