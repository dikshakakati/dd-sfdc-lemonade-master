/**
 * @author CriticalRiver
 * @date 20th Sep 2024
 * @description Constant Class to Store Constant used in GridReportClass & Component
 */
public class DdConstants {
	/*****************************************************************************************************************************
    *
    * Constants
    *
    *****************************************************************************************************************************/
    /**
     * Delimiters
     */
    public static final String DELIMITER_AT = '@';
    public static final String DELIMITER_COLON = ':';
    public static final String DELIMITER_COMMA = ',';
    public static final String DELIMITER_COMMA_WITH_TRAILING_SPACE = ', ';
    public static final String DELIMITER_DOT = '.';
    public static final String DELIMITER_EQUAL = '=';
    public static final String DELIMITER_EXCLAMATION = '!';
    public static final String DELIMITER_HASH = '#';
    public static final String DELIMITER_SEMICOLON = ';';
    public static final String DELIMITER_SPACE = ' ';
    public static final String DELIMITER_UNDERSCORE = '_';
    public static final String DELIMITER_HYPHEN = '-';
    public static final String DELIMITER_HYPHEN_WITH_SPACE = ' - ';
    public static final String DELIMITER_AMPERSAND = '&';
    public static final String DELIMITER_QUESTION_MARK = '?';
    public static final String DELIMITER_BACKWARD_SLASH = '\'';
    public static final String DELIMITER_SINGLE_QUOTE = '\',';
    public static final String DELIMITER_FORWARD_SLASH = '/';
    public static final String DEFAULT_ONE = '-- Select One --';
    public static final String OPTION_NONE = '--None--';
    public static final String DELIMITER_PERCENT = '%';
    public static final String PARENTHESES_LEFT = '(';
    public static final String PARENTHESES_RIGHT = ')';
    public static final String RIGHT_ARROW = '=>';

    public static final String BLANK_STRING = '';
    public static final String DELIMITER_PLUS = '+';
    public static final String DELIMITER_PIPE = '|';
    public static final String CARRIAGE_RETURN = '\r\n';
    public static final String NEW_LINE = '\n';
    public static final String HTML_NEW_LINE = '<br/>';
    public static final String QUOTE = '"';

    public static final String STRING_ALL = 'All';
    public static final String STRING_YES = 'Yes';
    public static final String STRING_NO = 'No';

    /*
     * Mask Strings
     */
    public static final String MASK_VALUE_STRING ='x';

    /*
     * User Type strings
     */
    public static final String USER_TYPE_STANDARD = 'Standard';

    /**
     * Sharing constants
     */
    public static final String SHARE_LEVEL_EDIT = 'Edit';
    public static final String SHARE_LEVEL_READ = 'Read';
    public static final String SHARE_LEVEL_NONE= 'None';
    public static final String SHARE_CAUSE_MANUAL = 'Manual';


    /**
     *  Roles
     */
    public static final String ROLES_ROLES_AND_SUBORDINATES = 'RoleAndSubordinates';

    /**
     *  Approval process constants
     */
    public static final String APPROVAL_PROCESS_PENDING = 'Pending';


    /**
     * Regex constants
     */
    public static final String REGEX_WILDCARD = '.*';

    /**
    * Language
    */
    public static final String DEFAULT_LOCALE_EN = 'en';

    /**
     * Data Type
     */
    public static final String DATATYPE_STRING = 'String';

    /**
     * HTTP Methods
     */
    public static final String HTTP_POST = 'POST';

    /**
     * HTTP Status codes
     */
    public static final Integer CODE_SERVER_ERROR = 500;
    public static final Integer CODE_REQUEST_TIMEOUT = 408;
    public static final Integer CODE_REQUEST_SUCCESS = 200;
    public static final Integer CODE_SUCCESS_END = 299;

    /**
     * HTTP Messages
     */
    public static final String HTTP_NO_RESP = 'No Response From Server';
    public static final String HTTP_REQ_FAILED = 'HTTP Request Failed';
    public static final String HTTP_CALL_DISABLED = 'HTTP Callout Disabled';
    /**
     * Locale
     */
    public static final String JAPAN_LOCALE = 'ja_JP';

    /**
     * Legal Entity
     */
    public static final String JPN = 'JPN';
    public static final String US = 'US';
    public static final String DEU = 'DEU';
    public static final String AUS = 'AUS';
    public static final String CAD = 'CAD';

    /**
     * Trigger operations
     */
    public enum TriggerOperationType {
        BEFORE_INSERT,
        AFTER_INSERT,
        BEFORE_UPDATE,
        AFTER_UPDATE
    }

    /**
     * Queue
     */
    public static final String QUEUE_TYPE = 'Queue';


    /**
     * Org Related
     */

    public static final String PROD_ORG_URL = 'https://figment.my.salesforce.com';

    /**
     * Lead Source values
     */
    public static final String LEADSOURCE_DETAIL_FORMSTACK = 'Formstack';
    public static final String LEADSOURCE_DETAIL_SSMO = 'SSMO';

    /**
     * Integration User types
     */
    public static final String INTEGRATION_USER_TYPE_MULESOFT = 'Mulesoft';
    /**
     * Sobject Prefixes
     */
    public static final string LEAD_SOBJECT_PREFIX = '00Q';
    public static final string ACCOUNT_SOBJECT_PREFIX = '001';
    public static final string CASE_SOBJECT_PREFIX = '500';

    /**
     * Generic Fields
     */

    public static final String OWNER_ID = 'OwnerId';

    //BIZS-3273 Severity Levels
    public static final String SEVERITY_LEVEL_ERROR = 'Error';
    public static final String SEVERITY_LEVEL_WARNING = 'Warning';
    public static final String SEVERITY_LEVEL_SUCCESS = 'Success';
    public static final String SEVERITY_LEVEL_INFO = 'Info';

    /**
     * Batch Statuses
     */

    public static final String BATCH_HOLDING = 'Holding';
    public static final String BATCH_QUEUED = 'Queued';
    public static final String BATCH_PREPARING = 'Preparing';
    public static final String BATCH_PROCESSING = 'Processing';

    /* Text Area Field Default */
    public static final Integer TEXTAREA_SIZE_DEFAULT = 32768;
    public static final Integer TEXTAREA_SIZE_MAX = 131072;

    /* Date Format */
    public static final String DATEFORMAT = 'yyyy-MM-dd';

    /* Time Format */
    public static final String TIMEFORMAT = 'yyyy-MM-dd HH:mm:ss';
    public static final String TIMEFORMAT_UTC = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
}