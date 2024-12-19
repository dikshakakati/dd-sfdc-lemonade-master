/**
 * @author CriticalRiver
 * @date Sep 20, 2024
 * @description Wrapper used by frameworks utilizing the ddDateFilter lwc filter
 */
public with sharing class DateFilterWrapper {
	@AuraEnabled public DateTime minValue;
    @AuraEnabled public DateTime maxValue;
    @AuraEnabled public DateTime value;
    @AuraEnabled public String operator;
}