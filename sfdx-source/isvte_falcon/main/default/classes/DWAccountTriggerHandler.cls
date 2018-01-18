public with sharing class DWAccountTriggerHandler {
    public static void handleBeforeInsert(List<Account> accListNew){
        //Always encrypt username/password on new account
        for(Account acc: accListNew){
            if(String.isNotBlank(acc.DW_Username__c)) {
                acc.DW_Username__c = DriveWealth.encryptString(acc.DW_Username__c);
            }
            if(String.isNotBlank(acc.DW_Password__c)) {
                acc.DW_Password__c = DriveWealth.encryptString(acc.DW_Password__c);
            }
        }
    }

    public static void handleBeforeUpdate(List<Account> accListNew, Map<Id, Account> accListNewMap, Map<Id, Account> accListOldMap){
        //Only encrypt if username/password fields have been changed
        for(Account acc: accListNew){
            if(String.isNotBlank(acc.DW_Username__c) && accListNewMap.get( acc.Id ).DW_Username__c != accListOldMap.get( acc.Id ).DW_Username__c ){
                //Username has changed
                acc.DW_Username__c = DriveWealth.encryptString(acc.DW_Username__c);
            }
            if(String.isNotBlank(acc.DW_Password__c) && accListNewMap.get( acc.Id).DW_Password__c != accListOldMap.get(  acc.Id ).DW_Password__c ){
                //Password has changed
                acc.DW_Password__c  = DriveWealth.encryptString(acc.DW_Password__c);
            }
        }
    }
}