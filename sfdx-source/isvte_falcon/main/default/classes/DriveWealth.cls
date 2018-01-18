/**
 * DriveWealth class is wrapper fto DriveWealthAPI
 * This class takes care of calling API methods, handling errors, dealing with database (for session) and more
 *
 * @author Jaswinder Rattanpal <jrattanpal@salesforce.com>
 */

public with sharing class DriveWealth {

    //DriveWealth custom settings for DWW Endpoint (and maybe other) information
    private static DriveWealth__c dw = DriveWealth__c.getInstance() ;

    //DriveWealth protected custom setting to store crypto key
    private static DriveWealthP__c dwp = DriveWealthP__c.getOrgDefaults();

    /** Store account information for later user; if need */
    private static Account acc;

    /**
      * Get DriveWealth session information from DW_Session__c object
      * Name of a record for a session will show as "Account:DW_SESSION_KEY"
     */
    public static DW_Session__C dws;

    /**
     * Temporarialy store Login information to use during class execution
     */
    private static DriveWealthJsonSession sessionInfo;

    /**
     * Retrieve DriveWealth session information from DW_Session__c object
     * Record name matches with "Account:DW_SESSION_KEY" for each sesison because session key will be unique
     * This is becasue each Account will have a separate user account in DriveWealth
     *
     * If a record exists then return it to be checked for validatiy
     *
     * @param AccountID ID of account for which we are checking session
     * @param DWUserID ID of DW User account associated with salesforce Account
     *
     * @return DW_Session__C
     */
    private static DW_Session__C retrieveDWSessionInfo(String AccountID, String DWUserID){
        try{
            //CRUD/FLS check
            Util.AccessController.assertAuthorizedToView(
                    Schema.DW_Session__C.getSobjectType(),
                    new List<Schema.SobjectField>{
                            Schema.DW_Session__C.fields.Name, Schema.DW_Session__C.fields.Account__c,
                            Schema.DW_Session__C.fields.DW_Session_Key__c, Schema.DW_Session__C.fields.DW_User_ID__c,
                            Schema.DW_Session__C.fields.Active__c
                    }
            );


            Util.log('DriveWealth.retrieveDriveWealthSessionInfo():AccountID: ' + AccountID);
            Util.log('DriveWealth.retrieveDriveWealthSessionInfo():DWUserID: ' + DWUserID);

            //Get record based on AccountID from DW_Session__c
            List<DW_Session__C> DWSession = [
                    select ID, Name, DW_Session_Key__c, DW_User_ID__c, Account__c, Active__c
                    from DW_Session__c
                    where Account__c = :AccountID and DW_User_ID__c=:DWUserID
                    limit 1
            ];


            Util.log('DriveWealth.retrieveDriveWealthSessionInfo():DWSession: ' + DWSession);

            if (DWSession.size() > 0) {
                dws = DWSession[0];
            }else{
                dws = new DW_Session__C();
                dws.Active__c = false;
                dws.Name = '';
                dws.DW_User_ID__c = '';
                dws.Account__c = null;
                dws.DW_Session_Key__c = '';
                dws.ID = null;

            }
        }catch (SFDCAccessControlException e) {
            String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DriveWealth.retrieveDriveWealthSessionInfo():SFDCAccessControlException: ' + message);
        }catch(Exception e){ Util.log('DriveWealth.retrieveDriveWealthSessionInfo():Exception: ' + e.getMessage()); }
        return dws;
    }

     /**
     * Upset session information for an account with new session
     *
     *
     * @param AccountID Need to provide it explicitly as it's future method
     * @param DWUserID ID of DW User account associated with salesforce Account
     * @param DWSessionKey Session key returned after login call to DriveWealth
     *
     * @return Boolean
     */
    private static void saveDWSessionInfo(String AccountID, String DWID, String DWUserID, String DWSessionKey){
        try{

            //CRUD/FLS check
            Util.AccessController.assertAuthorizedToCreate(
                    Schema.DW_Session__C.getSobjectType(),
                    new List<Schema.SobjectField>{
                            Schema.DW_Session__C.fields.Name, Schema.DW_Session__C.fields.Account__c,
                            Schema.DW_Session__C.fields.DW_Session_Key__c, Schema.DW_Session__C.fields.DW_User_ID__c,
                            Schema.DW_Session__C.fields.Active__c
                    }
            );
            Util.AccessController.assertAuthorizedToUpdate(
                    Schema.DW_Session__C.getSobjectType(),
                    new List<Schema.SobjectField>{
                            Schema.DW_Session__C.fields.Name, Schema.DW_Session__C.fields.Account__c,
                            Schema.DW_Session__C.fields.DW_Session_Key__c, Schema.DW_Session__C.fields.DW_User_ID__c,
                            Schema.DW_Session__C.fields.Active__c
                    }
            );

            dws = new DW_Session__C();
            dws.Id = DWID;
            dws.Name = 'Account:' + AccountID;
            dws.Active__c = true;
            dws.DW_Session_Key__c = DWSessionKey;
            dws.Account__c = AccountID;
            dws.DW_User_ID__c = DWUserID;
            upsert dws DW_User_ID__c;

            Util.log('DriveWealth.setDWSessionInfo():Upsert: ' + dws) ;

        }catch (SFDCAccessControlException e) {
            String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DriveWealth.setDWSessionInfo():SFDCAccessControlException: ' + message);
        }catch(Exception e){ Util.log('DriveWealth.setDWSessionInfo():Exception: ' + e.getMessage()); }
    }

    /**
     * Wrapper to login to DriveWealth
     *
     * First check if existing session is valid
     *
     * @param username DW Username
     * @param password DW Password
     *
     * @return DriveWealthJsonSession
     */
    public static DriveWealthJsonSession login(String username, String password){
        DriveWealthJsonSession retValue = null;

        try {
            //Check if valid SID exists in
            if (dws.Active__c == true) {
                retValue = DriveWealthAPI.getSession(DriveWealthAPI.getEndpointGetSession(dws.DW_Session_Key__c), dws.DW_Session_Key__c);
                Util.log('DriveWealth:login():getSession():retValue: ' + retValue);
            }
            //If Session is not valid then let's do new login
            //retValue.code might be 500 (wrong session format) or 401 (not valid); if NOT null then let's do login
            if (retValue == null || retValue.code != null) {
                retValue = DriveWealthAPI.createSession(DriveWealthAPI.getEndpointCreateSession(), username, password);

                //Save session info variable as we will be using it before it's saved (at the end)
                dws.DW_Session_Key__c = retValue.sessionKey;

                Util.log('DriveWealth:login():retValue: ' + retValue);
            }
        }catch(Exception e){ Util.log('DriveWealth.login(username, password):Exception: ' + e.getMessage()); }
        return retValue;
    }
    /**
     * Retrieve account information and initialize variable
     *
     * @param AccountID ID for account to get information
     */

    private static Account retrieveAccountInfo(String AccountID){
        try{

            //retrieve account information
            if(acc == null){
                //CRUD/FLS check
                Util.AccessController.assertAuthorizedToView(Schema.Account.getSobjectType(),
                        new List<Schema.SobjectField>{
                                Schema.Account.fields.Name, Schema.Account.fields.DW_Username__c,
                                Schema.Account.fields.DW_Password__c, Schema.Account.fields.DW_User_ID__c
                        }
                );

                List<Account> listAccounts = [select id, DW_Username__c, DW_Password__c, DW_User_ID__c FROM account where ID=:AccountID limit 1];
                if(listAccounts.size() > 0){
                    acc = listAccounts[0];
                }
            }
        }
        catch (SFDCAccessControlException e) {
            String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DriveWealth.retrieveAccountInfo():Exception: ' + message);
        }catch(Exception e){ Util.log('DriveWealth.retrieveAccountInfo():Exception: ' + e.getMessage()); }
        return acc;
    }
    /**
     * This is used to prepare information for login. We need Account ID as we need to get DriveWealth username/password and other information
     * This function will take care of preparing all that
     *
     * This method should be used before calling any function in this class. This will ensure that proper session is setup (only once) before proceeding
     *
     * @param AccountID ID of Account to retrieve information
     *
     * @return DriveWealthJsonSession
     */
    public static DriveWealthJsonSession doSetup(String AccountID){
        retrieveAccountInfo(AccountID);
        return doSetup(acc);
    }

    /**
     * Sometimes, like when searching symbols, we might want to use orgwide credentials rather than account credentials
     * BUT, this will only happen if account credentials do not exist
     * Otherise, continue to use account credentials
     */
    public static DriveWealthJsonSession doSetup(Account a, Boolean useOrgWideCredentials) {
        //If account doesn't have Username OR Password OR DW User ID then use org wide
        if(String.isEmpty(a.DW_Username__c) || String.isEmpty(a.DW_Password__c) || String.isEmpty(a.DW_User_ID__c)){
            Util.log('DriveWealth.doSetup():Using OrgWideCredentials');
            return doSetup(a, dw.Username__c, dw.Password__c, dw.User_ID__c);
        }else{
            Util.log('DriveWealth.doSetup():Using Account Credentials');
            return doSetup(a);
        }
    }
    /**
     * Use Account credentials on it's own
     */
    public static DriveWealthJsonSession doSetup(Account a){

        //username/password are encrypted. Now decrypt those here so we can use those for login
        return doSetup(a, decryptString(a.DW_Username__c), decryptString(a.DW_Password__c), a.DW_User_ID__c);
    }
    /**
     * Same as doSetup but this one takes explicit username/password in case we need to supply it directly and not from Account
     *
     * If you already have account username (Etc) info then pass it. But if not then pass null and it will be queried
     *
     * @param AccountID ID of Account to retrieve information
     * @param Username DW Username to login
     * @param Password DW Password to login
     * @param DWUserID User ID for DriveWealth
     */
//    public static DriveWealthJsonSession doSetup(String AccountID, String Username, String Password, String DWUserId){
    public static DriveWealthJsonSession doSetup(Account a, String DWUsername, String DWPassword, String DWUserID){
        try {
            Util.log('DriveWealth:init():doSetup:a: ' + a);
            acc = a;

            if(acc != null) {
                //Retrieve session information from object if it's there
                retrieveDWSessionInfo(acc.Id, DWUserID);
                Util.log('DriveWealth:doSetup():retrieveDWSessionInfo:dws: ' + dws);

                if(dws != null) {
                    //Login to make sure session is valid
                    sessionInfo = login(DWUsername, DWPassword);
                    Util.log('DriveWealth:init():doSetup:retValue: ' + sessionInfo);
                }
            }
        }catch(Exception e){ Util.log('DriveWealth.doSetup(AccountID):Exception: ' + e.getMessage()); }
        return sessionInfo;
    }
    /** 
     * This is to update session information. But we need to do it AFTER the callouts otherwise we will get following error
     *
     *
     * You have uncommitted work pending. Please commit or rollback before calling out
     *
     */
    public static void doCleanup(){
        try {
            if(dws != null && acc != null) {
                //Update DW Session to newest
                Util.log('DriveWealth:doCleanup():acc ' + acc);
                Util.log('DriveWealth:doCleanup():dws ' + dws);
                Util.log('DriveWealth:doCleanup():sessionInfo ' + sessionInfo);
                saveDWSessionInfo(acc.Id, dws.ID, sessionInfo.userID, sessionInfo.sessionKey);
            }
        }catch(Exception e){ Util.log('DriveWealth.doCleanup():Exception: ' + e.getMessage()); }
    }


    /**
     * Search instrument, this is to get Stock Symbol information. This will later be used for orders
     *
     * Ensure that init() is called before this to make sure there is valid session
     *
     * <pre>
            Util.debug = true;
            //Need to login to DriveWealth
            //User "generic" username/password from Custom Settings
            DriveWealth.doSetup('00141000007RP8r');

            List<DriveWealthJsonInstrument> inInfo = DriveWealth.searchInstrument('CRM,AAPL');
            //Update new session Info from DriveWealth
            DriveWealth.doCleanup();
     * </pre>
     *
     * @param symbol One or more (comma separated) symbols; CRM OR CRM,AAPL
     *
     * @return DriveWealthJsonSession
     */
    public static List<DriveWealthJsonInstrument> searchInstrument(String symbol){
        List<DriveWealthJsonInstrument> retVal = new List<DriveWealthJsonInstrument>();
        try{
            retVal = DriveWealthAPI.searchInstrument(DriveWealthAPI.getEndpointSearchInstrument(symbol), dws.DW_Session_Key__c);
            //retVal might be null, in that case, login() again
        }catch(Exception e){ Util.log('DriveWealth.searchInstrument():Exception: ' + e.getMessage());  }

        return retVal;
    }

    /**
     * Create a Practice Account
     *
     * Ensure that init() is called before this to make sure there is valid session
     *
     * <pre>
            //Set this if you need to see debug statements
            Util.debug = true;

            //If there is no DW User ID" AND/OR "DW Account ID" associate with (standard) Account
            //Then create new Practice account
            //Hint: Use SOQL or initial data load to get this informaiton in, say, Lightning Component
            String AccountID = '00141000007RP8w';
            Account a = [select Id, AccountNumber, DW_Username__c, DW_Password__c, DW_Total_Practice_Accounts__c
                            from account
                            where id=:AccountId];

            //If no DW Accounts then create one
            if(a.DW_Total_Practice_Accounts__c <= 0 ){
                //Custom setting to get "referralCode" needed to create account
                DriveWealth__c dw = DriveWealth__c.getInstance() ;

                String username = a.AccountNumber; //'sfusername';
                String password = a.AccountNumber; //'sfpassword';

                //Data for Practice Account Creation
                Map<String, String> data = new Map<String, String> ();
                data.put('emailAddress1', 'test@test.com2');//Pull from Account
                data.put('firstName', 'FirstName 2');//Pull from Account
                data.put('lastName', 'LastName 2');//Pull from Account
                data.put('referralCode', dw.Referral_Code__c);
                //If new account then provide username/password
                data.put('username', username);
                data.put('password', password);

                System.debug(data);

                //There is no setup because we want to use new username info for login
                DriveWealthJsonAccount aInfo = DriveWealth.createPracticeAccount(data);

                //Now login with new username/password to start session and get account info
                DriveWealthJsonSession sessionInfo = DriveWealth.doSetup(a.Id, username, password);


                //userID as returned after creating user
                String DWUserID = aInfo.userID;

                //Update account with new userID and username and password
                a.DW_Username__c = username;
                a.DW_Password__c = password;
                a.DW_User_ID__c = sessionInfo.userID;

                //Update account with new username, password and user I
                update a;


                //Go through entire list of accounts returned for that user and update the list
                //This will return newly created account if user is new.
                //But will also return account for old user
                List<DW_Account__c> listAcc = new List<DW_Account__c>();
                for(Integer i=0; i<sessionInfo.Accounts.size(); i++){
                    DW_Account__c acc = new DW_Account__c();
                    acc.name = sessionInfo.Accounts[i].nickname;
                    acc.Account__c = a.Id;
                    acc.Account_ID__c = sessionInfo.Accounts[i].accountID;
                    acc.Account_No__c = sessionInfo.Accounts[i].accountNo;
                    acc.Account_Type__c = sessionInfo.Accounts[i].accountType;
                    acc.Created_When__c = sessionInfo.Accounts[i].createdWhen;
                    acc.Opened_When__c = sessionInfo.Accounts[i].openedWhen;

                    listAcc.add(acc);
                }
                //Upsert all accounts using Account_ID__c as External key so that it's unique
                upsert listAcc Account_ID__c;
                System.debug(listAcc);

                //Update new session Info from DriveWealth
                DriveWealth.doCleanup();

            }else{

            }


            List<DW_Account__c> listDWAcc = [select Account_ID__c, Account__r.Id,
                                                    Account__r.AccountNumber, Account__r.DW_User_ID__c
                                                from DW_Account__c
                                                where Account__r.Id=:AccountID];
            //listDWAcc can be returned for use
            System.debug(listDWAcc);

     * </pre>
     *
     * @param UserID If this is NOT empty then append it to API call to add
     * @param data Map of data to be sent to DriveWealth for creating practice account
     *
     * @return DriveWealthJsonAccount
     */
    public static DriveWealthJsonAccount createPracticeAccount(Map<String, Object> data) {
        DriveWealthJsonAccount retVal = new DriveWealthJsonAccount();
        try{
            //If userID is provided then it's an existing account so we need to send session key
            String sessionKey = (data.containsKey('userID') && data.get('userID') != null)?dws.DW_Session_Key__c:null;

            retVal = DriveWealthAPI.createPracticeAccount(DriveWealthAPI.getEndpointCreatePracticeAccount(), data, sessionKey) ;

            //retVal might be null, in that case, login() again
        }catch(Exception e){ Util.log('DriveWealth.createPracticeAccount():Exception: ' + e.getMessage());  }

        return retVal ;
    }

    /**
      * Creating order needs information from multiple steps; http://developer.drivewealth.com/docs/add-market-order
      * 1) Need to request Instrument information for stock; instrumentID
      * 2) Present List of DW_Accounts and ask users to pick one (there should be only one as we are only creating Practice Accounts)
      * --- Based on that selection, we can get accountID, accountNo, accountType, Account.userID
      * 3) From user, we have to get ordType, side, orderQty
      *
      * Once we have this information, we can send it to DriveWealth
     */
    public static DriveWealthJsonMarketOrder createMarketOrder(Map<String, Object> data){
        DriveWealthJsonMarketOrder  retVal = new DriveWealthJsonMarketOrder();
        try{
            retVal = DriveWealthAPI.createMarketOrder(DriveWealthAPI.getEndpointCreateMarketOrder(), data, dws.DW_Session_Key__c) ;
            //retVal = DriveWealthAPI.createMarketOrder('http://requestb.in/1jw445t1', data, dws.DW_Session_Key__c) ;


            //retVal might be null, in that case, login() again
        }catch(Exception e){ Util.log('DriveWealth.createMarketOrder():Exception: ' + e.getMessage());  }

        return retVal ;
    }

    /**
      * Get Order status for an Order ID
      *
     */
    public static DriveWealthJsonOrderStatus getOrderStatus(String OrderID){
        DriveWealthJsonOrderStatus  retVal = new DriveWealthJsonOrderStatus();
        try{
            retVal = DriveWealthAPI.getOrderStatus(DriveWealthAPI.getEndpointOrderStatus(), OrderID, dws.DW_Session_Key__c) ;

        }catch(Exception e){ Util.log('DriveWealth.getOrderStatus():Exception: ' + e.getMessage());  }

        return retVal ;
    }


    /**
     * Encrypt username/password
     */
    public static string encryptString(String stringToEncrypt){
        if(String.isBlank(stringToEncrypt)){
            return '';
        }
        Blob key = Blob.valueOf(DriveWealth.getCryptoKey());
        Blob encryptedValue = Crypto.encryptWithManagedIV('AES256', key, Blob.valueOf(stringToEncrypt));
        String encryptedString = EncodingUtil.base64encode(encryptedValue);

        return encryptedString;
    }
    /**
     * Decrypt username/password
     */
    public static string decryptString(String stringToDecrypt){
        if(String.isBlank(stringToDecrypt)){
            return '';
        }
        Blob key = Blob.valueOf(DriveWealth.getCryptoKey());
        Blob base64 = EncodingUtil.base64decode(stringToDecrypt);
        Blob decryptedValue = Crypto.decryptWithManagedIV('AES256', key, base64);
        String decryptedString = decryptedValue.toString();

        return decryptedString;
        //return  Crypto.decryptWithManagedIV('AES128', getCryptoKey(), stringToDecrypt);
    }
    /**
     * Generate 32 letter crypto key for AES256
     */
    public static String getCryptoKey(){
        //If string is empty then it might be the first time and we need to generate the key
        if(String.isBlank(dwp.Crypto_Key__c)){
            String key = EncodingUtil.convertToHex(crypto.generateAesKey(256));
            dwp.Crypto_Key__c = key.substring(0, 32);
            upsert dwp;
        }
        return dwp.Crypto_Key__c;
    }
}