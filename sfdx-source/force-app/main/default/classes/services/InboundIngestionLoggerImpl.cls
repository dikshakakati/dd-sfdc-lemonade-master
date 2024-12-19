/**
 * @author Shiva Pochamalla
 * @description This is the impl class for InboundIngestionLoggerImpl
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
public class InboundIngestionLoggerImpl implements IInboundIngestionLoggerImpl {

    /**
     * @description It is used to log the governer success
     * @param ingestionLogEntry
     * @param message
     */
    public void logSuccess(IInboundIngestionLoggerEntry ingestionLogEntry, String message){
        ingestionLogEntry = ingestionLogEntry.logSuccess(message);
        IGenericLogEntry gle = ingestionLogEntry.createGenericLogEntry();
        GenericLoggerService.publish(gle);
        //GenericLoggerService.publish(ingestionLogEntry.logSuccess(message).createGenericLogEntry());
    }
    /**
     * @description It is used to log the governer success
     * @param ingestionLogEntry
     * @param e
     * @param businessErrorMessage
     * @param failedSteps
     * @param sfRecordIds
     * @param errorCategory
     */
    public void logException(IInboundIngestionLoggerEntry ingestionLogEntry, Exception e, String businessErrorMessage,String failedSteps,Set<String> sfRecordIds, String errorCategory){
        //GenericLoggerService.publish(ingestionLogEntry.logException(e,businessErrorMessage,failedSteps,sfRecordIds,errorCategory).createGenericLogEntry());
        ingestionLogEntry = ingestionLogEntry.logException(e,businessErrorMessage,failedSteps,sfRecordIds,errorCategory);
        IGenericLogEntry gle = ingestionLogEntry.createGenericLogEntry();
        GenericLoggerService.publish(gle);
    }

    /**
     * @description It is used to log the governer limits exception
     * @param ingestionLogEntry
     * @param errorMessage
     * @param failedSteps
     * @param className
     * @param methodName
     */
    public void logGovLimitsException(IInboundIngestionLoggerEntry ingestionLogEntry, String errorMessage,String failedSteps,String className, string methodName){
        //GenericLoggerService.publish(ingestionLogEntry.logGovtLimitException(errorMessage,FailedSteps,className,methodName).createGenericLogEntry());
        ingestionLogEntry = ingestionLogEntry.logGovtLimitException(errorMessage,FailedSteps,className,methodName);
        IGenericLogEntry gle = ingestionLogEntry.createGenericLogEntry();
        GenericLoggerService.publish(gle);
    }

    /**
     * @description It is used to get limit exceeded error string
     * @return error message
     */
    public String errorOnGovtLimitsExceeded(){
        if(Limits.getQueries() >= Limits.getLimitQueries()-2){
            return 'Salesforce Governor Limit - Total number of Soql Query count limit is exceeded';
            }
            else if(Limits.getDMLRows() >= Limits.getLimitDMLRows()){
            return 'Salesforce Governor Limit - DML limit is exceeded';
        }
        else if (Limits.getDMLStatements()>= Limits.getLimitDMLStatements()){
            return 'Salesforce Governor Limit - DML Statement limit is exceeded';
        }
        else if(Limits.getQueryRows() >= Limits.getLimitQueryRows()-2){
            return'Salesforce Governor Limit - number of records count by SOQL queries limit is exceeded';
        }
        else if(Limits.getCpuTime() >= Limits.getLimitCpuTime()-2000){
            return'Salesforce Governor Limit - Apex CPU time limit exceeded';
        }
        else{
            return null;
        }
    }

}