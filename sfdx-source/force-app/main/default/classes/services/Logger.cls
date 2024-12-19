/**
 * @description This is a generic class created to handle exception in case of
 * any exception scenarios.
 * @author Deloitte
 * @date 21/02/2022
 */
public without sharing class Logger {
    /**
     * @description Add a message to the buffer without publishing it.
     * Assumes a null severity
     * @param messageToLog The string message to add to the buffer.
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    public static ILogger add(String messageToLog) {
        return service().add(messageToLog);
    }

    /**
     * @description Add a message to the buffer without publishing it.
     * @param messageToLog The string message to add to the buffer.
     * @param severity LogSeverity enum
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    public static ILogger add(String messageToLog, LogEntry.SeverityLevel severity) {
        return service().add(messageToLog, severity);
    }

    /**
     * @description Add an formatted exception message to the buffer without
     * publishing it. Assumes a null Severity
     * @param exceptionToLog Exception to format and log
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    public static ILogger add(Exception exceptionToLog) {
        return service().add(exceptionToLog);
    }

    /**
     * @description Add an formatted exception message to the buffer without
     * publishing it.
     * @param exceptionToLog Exception to format and log
     * @param severity LogSeverity enum
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    public static ILogger add(Exception exceptionToLog, LogEntry.SeverityLevel severity) {
        return service().add(exceptionToLog, severity);
    }

    /**
     * @description Add a log entry object to the buffer without
     * publishing it.
     * @param logMessage LogEntry
     * @return ILogger Returns the current instance of Logger for fluent method chaining
     */
    public static ILogger add(LogEntry logMessage) {
        return service().add(logMessage);
    }

    /**
     * @description Publish any messages currently in the buffer, without adding
     * any new ones.
     */
    public static void publish() {
        service().publish();
    }

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivelent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     */
    public static void publish(Exception exceptionToLog) {
        service().publish(exceptionToLog);
    }

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     * @param severity LogSeverity enum
     */
    public static void publish(Exception exceptionToLog, LogEntry.SeverityLevel severity) {
        service().publish(exceptionToLog, severity);
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivelent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     */
    public static void publish(String messageToLog) {
        service().publish(messageToLog);
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     * @param severity LogSeverity enum
     */
    public static void publish(String messageToLog, LogEntry.SeverityLevel severity) {
        service().publish(messageToLog, severity);
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivelent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param logMessage LogMessage object to log
     */
    public static void publish(LogEntry logMessage) {
        service().publish(logMessage);
    }

    /**
     * @description calling newInstance for service class.
     * @return ILogger - returning interface.
     */
    private static ILogger service() {
        return (ILogger) Application.SERVICE.newInstance(ILogger.class);
    }
}