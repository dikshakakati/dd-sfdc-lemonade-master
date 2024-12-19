/**
 * @author Aethereus
 * @date 23/07/2024
 * @description Interface for EmailMessage selector class methods.
 */
public interface IEmailMessagesSelector extends fflib_ISObjectSelector {

    /**
     * @description It is used to fetch all email message activity for store accounts.
     * @param accountIds
     * @return List<Account> accounts
     */
    List<EmailMessage> selectEmailMessagesByRelatedId(Set<Id> accountIds);

}