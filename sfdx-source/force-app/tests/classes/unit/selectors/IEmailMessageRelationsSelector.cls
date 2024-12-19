/**
 * @author Deloitte
 * @date 04/29/2024
 * @description Interface to add Selector class methods.
 */
public interface IEmailMessageRelationsSelector extends fflib_ISObjectSelector{
	/**
     * @description  It is used to get EmailMessageRelation by EmailMessage Ids.
     * @param emailMessageIds
     * @return List<EmailMessageRelation>
     */
    
    List<EmailMessageRelation> selectByEmailMessageIds(Set<Id> emailMessageIds);
}