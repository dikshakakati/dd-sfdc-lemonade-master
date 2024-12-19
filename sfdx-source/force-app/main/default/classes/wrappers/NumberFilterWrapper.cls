/**
 * @author CriticalRiver
 * @date   Sep 20, 2024
 * @description Wrapper used by frameworks utilizing the ddNumberFilter lwc filter
 */
public with sharing class NumberFilterWrapper {
    @AuraEnabled public Decimal minValue;
    @AuraEnabled public Decimal maxValue;
    @AuraEnabled public Decimal value;
    @AuraEnabled public String operator;
}