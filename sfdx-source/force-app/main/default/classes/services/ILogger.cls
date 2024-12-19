/**
 * @description : Interface to add reusable methods.
 * @author Deloitte
 * @date 25/02/2022
 */
public interface ILogger {
    /**
     * @description Add a message to the buffer without publishing it.
     * Assumes a LOW severity
     * @param messageToLog The string message to add to the buffer.
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    ILogger add(String messageToLog);

    /**
     * @description Add a message to the buffer without publishing it.
     * @param messageToLog The string message to add to the buffer.
     * @param severity LogMessage.SeverityLevel enum
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    ILogger add(String messageToLog, LogEntry.SeverityLevel severity);

    /**
     * @description Add an formatted exception message to the buffer without
     * publishing it. Assumes a LOW severity
     * @param exceptionToLog Exception to format and log
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    ILogger add(Exception exceptionToLog);

    /**
     * @description Add an formatted exception message to the buffer without
     * publishing it.
     * @param exceptionToLog Exception to format and log
     * @param severityLevel LogSeverity enum
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    ILogger add(Exception exceptionToLog, LogEntry.SeverityLevel severityLevel);

    /**
     * @description Add a log entry object to the buffer without
     * publishing it.
     * @param logMessage LogEntry
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    ILogger add(LogEntry logMessage);

    /**
     * @description Publish any messages currently in the buffer, without adding
     * any new ones.
     */
    void publish();

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     */
    void publish(Exception exceptionToLog);

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     * @param severityLevel LogSeverity enum
     */
    void publish(Exception exceptionToLog, LogEntry.SeverityLevel severityLevel);

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     */
    void publish(String messageToLog);

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     * @param severityLevel LogSeverity enum
     */
    void publish(String messageToLog, LogEntry.SeverityLevel severityLevel);

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param logMessage LogMessage object to log
     */
    void publish(LogEntry logMessage);
}