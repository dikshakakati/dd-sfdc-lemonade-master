/**
 * @author Deloitte
 * @date 10/03/2023
 * @description Wrapper class to prepare JSON payload for business error logs creation.
 */
public class LogCreationEntry {
    private static final String GROUP_BY_ID_TYPE_STORE_ACCOUNT_ID = 'STORE_ACCOUNT_ID';
    public String groupByIdType;
    public List<LogMessageEntry> logMessageEntries;
    public String sourceClassName;
    public String sourceMethodName;

    /**
     * @description Parameterized constructor to set wrapper class variables.
     * @param sourceClassName
     * @param sourceMethodName
     * @param logMessageEntries
     */
    public LogCreationEntry(
        String sourceClassName,
        String sourceMethodName,
        List<LogMessageEntry> logMessageEntries
    ) {
        this.groupByIdType = GROUP_BY_ID_TYPE_STORE_ACCOUNT_ID;
        this.sourceClassName = sourceClassName;
        this.sourceMethodName = sourceMethodName;
        this.logMessageEntries = logMessageEntries;
    }
}