public with sharing class DWCreateAccount  extends ETLC_ApexBridge_Abstract {
    
    /**
* Method implementation for method in abstract class ETLC_ApexBridge_Abstract
*
* This is where we will process user input and decide which functions to call and return required output
*
* @param ETLC_ApexBridge_Data Data sent by lightning component
*/
    public override void process(ETLC_ApexBridge_Data data) {
        //Set debugging
        if (data.debug) {
            Util.debug = data.debug;
        }
        
        // Depending on the mode, determine which operation to perform
        
        String mode = (String) data.getInputValue('mode');
        if (mode == 'getAccount') {
            data.output = ETLC_ApexBridge_Data.encodeData(getAccount(data, (Id) data.getInputValue('AccountID')));
        } else if (mode == 'createAccount') {
            Util.log('DWCreateAccount.process():data: ' + data);
            Util.log(data.getInputValue('acc'));
            data.output = ETLC_ApexBridge_Data.encodeData(
                createAccount( data,
                              (Map<String, Object>) data.getInputValue('acc'),
                              (String)  data.getInputValue('FirstName'),
                              (String)  data.getInputValue('LastName'),
                              (String)  data.getInputValue('UserName'),
                              (String)  data.getInputValue('Password')
                             )
            );
        }
    }
    // VI - what is this doing - why are we passing the parameters here if it is not using anything for create account ?
    public Account createAccount(ETLC_ApexBridge_Data data, Map<String, Object> acc, String fname, String lname, String uname, String passwd)
    {
        Util.log('DWCreateAccount.createAccount():data: ' + acc);
        Util.log('DWCreateAccount.createAccount():data: ' + uname);
        Util.log('DWCreateAccount.createAccount():data: ' + lname);
        Util.log('DWCreateAccount.createAccount():data: ' + passwd);
        Util.log('DWCreateAccount.createAccount():data: ' + fname);
        //  Util.log('DWCreateAccount.process():data: ' + acc.DW_Email__c);
        Account a = new Account();
        Account retval= new Account();
        try {
            
            // a = DataQuery.getAccount(acc.Id);
            a = DataQuery.getAccount((Id)acc.get('Id'));
            if (a != null) {
                //getting DW custom settings - which has the orgwide user/pass
                DriveWealth__c dw = DriveWealth__c.getInstance() ;
                
                
                // String username = a.AccountNumber; //'sfusername';
                //  String password = a.AccountNumber; //'sfpassword';
                
                
                //Data for Practice Account Creation
                Map<String, String> dataDW = new Map<String, String>();
                
                dataDW.put('emailAddress1', (String) a.DW_Email__c);//Pull from Account
                dataDW.put('firstName', fname);//Pull from Account
                dataDW.put('lastName', lname);//Pull from Account
                dataDW.put('referralCode', dw.Referral_Code__c);
                //If new account then provide username/password
                dataDW.put('username', uname);
                dataDW.put('password', passwd);
                
                
                Util.log('DWCreateAccount.createAccount():dataDW: ' + dataDW);
                
                
                
                //There is no setup because we want to use new username info for login
                DriveWealthJsonAccount aInfo = DriveWealth.createPracticeAccount(dataDW);
                
                if (aInfo.code==null) {
                    
                    
                    //Update account with new userID and username and password
                    a.DW_Username__c = uname;
                    a.DW_Password__c = passwd;
                    a.DW_User_ID__c = aInfo.userID;
                    
                    //Now login with new username/password to start session and get account info
                    //Provide string directly because we can't do DML beore callout; Because of that trigger hasn't run so we don't have encrypted account credentials
                    //Even if we do DML before this, to get encrypted data we will need to do SOQL again
                    DriveWealthJsonSession sessionInfo = DriveWealth.doSetup(a, a.DW_Username__c, a.DW_Password__c, a.DW_User_ID__c);
                    
                    
                    //Just confirm to be sure that session was established
                    if(sessionInfo != null && sessionInfo.code == null) {
                        //Update main account object with new username, password and user I
                        //Do DML after doSetup as we cannot callout AFTER DML
                        update a;
                        
                        
                        //Go through entire list of accounts returned for that user and update the list
                        //This will return newly created account if user is new.
                        //But will also return account for old user
                        List<DW_Account__c> listAcc = new List<DW_Account__c>();
                        for (Integer i = 0; i < sessionInfo.Accounts.size(); i++) {
                            DW_Account__c dwacc = new DW_Account__c();
                            dwacc.name = sessionInfo.Accounts[i].nickname;
                            dwacc.Account__c = a.Id;
                            dwacc.Account_ID__c = sessionInfo.Accounts[i].accountID; //accountId = Drivewealth Account Id when it was opened
                            dwacc.Account_No__c = sessionInfo.Accounts[i].accountNo;
                            dwacc.Account_Type__c = sessionInfo.Accounts[i].accountType;
                            dwacc.Created_When__c = sessionInfo.Accounts[i].createdWhen;
                            dwacc.Opened_When__c = sessionInfo.Accounts[i].openedWhen;
                            
                            listAcc.add(dwacc);
                        }
                        //Upsert all accounts using Account_ID__c as External key so that it's unique
                        upsert listAcc Account_ID__c;
                        Util.log(listAcc);
                        
                        //Update new session Info from DriveWealth
                        DriveWealth.doCleanup();
                        
                        retval = DataQuery.getAccount(a.Id);
                        Util.log(retval);
                    }else{
                        
                        data.addMessage(ETLC_ApexBridge_Data.MessageType.Errors, 'DriveWealth Login Error: ' + sessionInfo.code + ': ' + sessionInfo.message);
                    }
                    
                }else {// end of if
                    data.addMessage(ETLC_ApexBridge_Data.MessageType.Errors, 'DriveWealth CreateAccount Error: ' + aInfo.code + ': ' + aInfo.message);
                }
                
                
            }else{
                data.addMessage(ETLC_ApexBridge_Data.MessageType.Errors, 'Couldn\'t find account with ID ' + acc.get('Id'));
            }
        }catch (SFDCAccessControlException e) {
            String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DWCreateOrder_Controller.getDWAccountList():SFDCAccessControlException: ' + message);
        }catch(Exception e){ Util.log('DWCreateAccount.CreateAccount():Exception: ' + e.getMessage()); }
        
        return retVal;
    }
    
    
    public Account getAccount(ETLC_ApexBridge_Data data, ID AccountId){
        
        Account retValue;
        try{
            retValue = DataQuery.getAccount(AccountId);
            Util.log('DWCreateAccount.getAccount():retValue: ' + retValue);
        }catch (SFDCAccessControlException e) {String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DWCreateOrder_Controller.getDWAccountList():SFDCAccessControlException: ' + message);data.addMessage(ETLC_ApexBridge_Data.MessageType.Errors, 'DWCreateAccount.getAccount():Error: ' + message);
                                              }catch(Exception e){ Util.log('DWCreateAccount.getAccount():Exception: ' + e.getMessage()); }
        return retValue;
    }
    
}