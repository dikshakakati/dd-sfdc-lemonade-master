/**
 * @description       :Wrapper for SSMO
 * @author            : Soumya Dash
 * @group             :
 * @last modified on  : 07-15-2024
 * @last modified by  : Pankaj
**/
public class SSMOWrapper {

        /**
        * @description Result Data from api
        */
        public class ResultMessageWrapper{
            @AuraEnabled public List<String> messages;
            @AuraEnabled public List<String> warningMessages;
            @AuraEnabled public String status;
            @AuraEnabled public String uuid;
            @AuraEnabled public Boolean isPrimaryQuote;
            @AuraEnabled public String onboardingLink;

           /**
           * @description Result Data from api
           */
           public ResultMessageWrapper(){
                messages = new List<String>();
                warningMessages = new List<String>();
                status = '';
                isPrimaryQuote = false;
                uuid = '';
                onboardingLink = '';
           }
        }
}