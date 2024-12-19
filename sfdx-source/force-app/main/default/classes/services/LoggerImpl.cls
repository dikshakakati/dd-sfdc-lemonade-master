/**
 * @description : Service Implimentation class for Logger Object
 * @author Deloitte
 * @date 25/02/2022
 */
public without sharing class LoggerImpl implements ILogger {
    private List<LogEntry> buffer;
  
    /**
     * @description LoggerImpl contructer.
     */
    public LoggerImpl() {
        buffer = new List<LogEntry>();
    }

    /**
     * @description Add a message to the buffer without publishing it.
     * Assumes a null severity
     * @param messageToLog The string message to add to the buffer.
     * @return ILogger
     */
    public ILogger add(String messageToLog) {
        this.add(messageToLog, LogEntry.SeverityLevel.LOW);
        return this;
    }

    /**
     * @description Add a message to the buffer without publishing it.
     * @param messageToLog The string message to add to the buffer.
     * @param severity LogEntry.SeverityLevel enum
     * @return ILogger
     */
    public ILogger add(String messageToLog, LogEntry.SeverityLevel severity) {
        if (severity == null) {
            severity = LogEntry.SeverityLevel.LOW;
        }
        buffer.add(LogEntry.newLog(messageToLog, severity));
        return this;
    }

    /**
     * @description Add an formatted exception message to the buffer without
     * publishing it. Assumes a null Severity
     * @param exceptionToLog Exception to format and log
     * @return ILogger
     */
    public ILogger add(Exception exceptionToLog) {
        this.add(exceptionToLog, LogEntry.SeverityLevel.LOW);
        return this;
    }

    /**
     * @description Add an formatted exception message to the buffer without
     * publishing it.
     * @param exceptionToLog Exception to format and log
     * @param severity LogEntry.SeverityLevel enum
     * @return ILogger
     */
    public ILogger add(Exception exceptionToLog, LogEntry.SeverityLevel severity) {
        if (severity == null) {
            severity = LogEntry.SeverityLevel.LOW;
        }
        buffer.add(LogEntry.newExceptionLog(exceptionToLog, severity));
        return this;
    }

    /**
     * @description Add a log entry object to the buffer without
     * publishing it.
     * @param logMessage LogEntry
     * @return ILogger
     */
    public ILogger add(LogEntry logMessage) {
        buffer.add(logMessage);
        return this;
    }

    /**
     * @description Publish any messages currently in the buffer, without adding
     * any new ones.
     */
    public void publish() {
        if (this.buffer.isEmpty()) {
            return;
        }
        fflib_ISObjectUnitOfWork uow = Application.UNITOFWORK.newInstance();
        for (LogEntry msg : this.buffer) {
            uow.registerNew(msg.toRecord());
        }
        uow.commitWork();
        this.buffer.clear();
    }

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     */
    public void publish(Exception exceptionToLog) {
        this.add(LogEntry.newExceptionLog(exceptionToLog));
        this.publish();
    }

    /**
     * @description Auto-format exception details, add it to the log buffer,
     * and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param exceptionToLog exception to format and log
     * @param severityLevel LogEntry.SeverityLevel
     */
    public void publish(Exception exceptionToLog, LogEntry.SeverityLevel severityLevel) {
        this.add(LogEntry.newExceptionLog(exceptionToLog, severityLevel));
        this.publish();
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     */
    public void publish(String messageToLog) {
        this.add(LogEntry.newLog(messageToLog));
        this.publish();
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param messageToLog String to log
     * @param severityLevel LogEntry.SeverityLevel
     */
    public void publish(String messageToLog, LogEntry.SeverityLevel severityLevel) {
        this.add(LogEntry.newLog(messageToLog, severityLevel));
        this.publish();
    }

    /**
     * @description Auto-format a custom log message string, add it to the log
     * buffer, and then publish the current buffer. Use the equivalent add
     * method if you intend to add multiple messages rapidly to minimize DML
     * usage.
     * @param logMessage LogMessage object to log
     */
    public void publish(LogEntry logMessage) {
        this.add(logMessage);
        this.publish();
    }
}