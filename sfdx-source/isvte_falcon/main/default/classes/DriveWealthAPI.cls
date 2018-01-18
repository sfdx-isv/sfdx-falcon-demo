/**
 * Class to work with DriveWealth API. This class will be responsible for generating payload and process result
 * Although, this class can be used as is, it's best used via an Apex wrapper which will supply username/password, handle exception, session expiration etc
 *
 * http://developer.drivewealth.com/
 *
 * @author Jaswinder Rattanpal (jrattanpal@salesforce.com)
 *
 */
global with sharing class DriveWealthAPI {

    /** Logic to get endpoint URL, userbame and password stored in custom setting */
    private static DriveWealth__c dw = DriveWealth__c.getInstance();

    /** API Endpoint for login like https://api.drivewealth.io/v1/userSessions */
    private static String endpointLogin = 'userSessions';

    /** End point for establishing new session with DriveWealth; http://developer.drivewealth.com/docs/create-session*/
    public static String getEndpointCreateSession() {
        return dw.Endpoint__c + endpointLogin;
    }

    /** Validate an existing session with DriveWealth */
    public static String getEndpointGetSession(String sessionKey) {
        return dw.Endpoint__c + endpointLogin + '/' + sessionKey;
    }

    /** Endpoint for Searching Instrument; like CRM, AAPL etc to get up to date information */
    public static String getEndpointSearchInstrument(String symbol) {
        /**
            If "," is in the symbol then it means it has multiple symbol
            Endpoint is different form multiple symbols
        */
        String symbolEndpoint = 'symbol';
        if(symbol.contains(',')){
            symbolEndpoint = 'symbols';
        }
        return dw.Endpoint__c + 'instruments?'+ symbolEndpoint + '=' + symbol;
    }

    /** Endpoint for creating Practice Accounts */
    public static String getEndpointCreatePracticeAccount() {
        return dw.Endpoint__c + 'signups/practice';
    }

    /** Endpoint for creating Market Order  */
    public static String getEndpointCreateMarketOrder() {
        return dw.Endpoint__c + 'orders';
    }

    /** Endpoint for getting order status  */
    public static String getEndpointOrderStatus() {
        return dw.Endpoint__c + 'orders';
    }

    /** Default values for some of the information required by DriveWealth API */
    public static string contentType = 'application/json';
    public static String appTypeId = '2000';
    public static string appVersion = 'v1.0';
    public static string ipAddressDefault = '96.43.144.0';
    public static string ipAddress;
    public static string languageID = UserInfo.getLocale();
    public static string osVersion = 'salesforce';
    public static string osType = 'salesforce';
    public static string scrRes = '1920x1080';
    public static string emailAddress = UserInfo.getUserEmail();


    /** Get IP address of current user from Visualforce headers */
    public static String getIpAddress() {
        if (ApexPages.currentPage() != null && ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP') != null) {
            return ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');
        }
        return ipAddressDefault;
    }


    /**
     * Create sesssion by login to DriveWealthAPI; http://developer.drivewealth.com/docs/create-session
     *
     * NOTE: Use try/catch when calling this code. It's upto the calling code to figure out how to deal with exceptions
     *
     * <pre>
     *     try{
     *          DriveWealthJsonSession dwSession = DriveWealthAPI.createSession('https://api.drivewealth.io/v1/userSessions', 'username', 'password');
     *          if(String.isNotBlank(dwSession.sessionKey)) {
     *              //Success
     *          }else{
     *              //Failure
     *          }
     *     }catch(Exception e){}
     * </pre>
     * @param endPoint  DriveWealth Login Endpoint
     * @param username  DriveWealth username
     * @param password  DriveWealth password
     *
     * @return DriveWealthJsonSession
    */
    Public Static DriveWealthJsonSession createSession(String endpoint, String username, String password) {
        Map<String, String> data = new Map<String, String>();
        data.put('appTypeID', appTypeId);
        data.put('appVersion', appVersion);
        data.put('username', username);
        data.put('emailAddress', emailAddress);
        data.put('ipAddress', ipAddress);
        data.put('languageID', languageID);
        data.put('osVersion', osVersion);
        data.put('osType', osType);
        data.put('scrRes', scrRes);
        data.put('password', password);

        HTTPUtilities hu = new HTTPUtilities();
        hu.setEndpoint(endpoint);
        hu.setMethod('POST');
        hu.setHeader('Content-Type', contentType);
        hu.setBody(JSON.serialize(data));

        HTTPResponse res = hu.sendRequest();

        //If login call was successful then parse JSON data and return
        return DriveWealthJsonSession.parse(res.getBody());
    }

    /**
     * Validate existing session with DriveWealth; http://developer.drivewealth.com/docs/get-session
     * If valid then 200 HTTP Status will be returned, 401 otherwise
     *
     * NOTE: Use try/catch when calling this code. It's upto the calling code to figure out how to deal with exceptions
     *

     * <pre>
     *     try{
     *          DriveWealthSession__c dws = DriveWealthSession__c.getInstance(UserInfo.getUserId());
     *          DriveWealthJsonSession dwSession = DriveWealthAPI.getSession('https://api.drivewealth.io/v1/userSessions/SESSION_KEY', 'SESSION_KEY')
     *          if(dwSession == null || dwSession != 200) {
     *              //Session invalid
     *              //Explicit login
     *          }else{
     *              //Session valid
     *          }
     *     }catch(Exception e){}
     * </pre>
     * @param endPoint  DriveWealth Login Endpoint
     * @param sessionKey  DriveWealth Session Key to validate
     *
     * @return DriveWealthJsonSession
    */
    Public Static DriveWealthJsonSession getSession(String endpoint, String sessionKey) {
        HTTPUtilities hu = new HTTPUtilities();
        hu.setEndpoint(endpoint);
        hu.setMethod('GET');
        hu.setHeader('Content-Type', contentType);
        hu.setHeader('x-mysolomeo-session-key', sessionKey);

        HTTPResponse res = hu.sendRequest();

        return DriveWealthJsonSession.parse(res.getBody());
    }

    /**
     * Search Instrument Data; http://developer.drivewealth.com/docs/search-instruments
     *
     * NOTE: Use try/catch when calling this code. It's upto the calling code to figure out how to deal with exceptions
     *
     * <pre>
     *     //Single symbol search
     *     List<DriveWealthJsonInstrument> inInfo1 = DriveWealthAPI.searchInstrument('https://api.drivewealth.io/v1/instruments?symbol=CRM', 'SESSION_KEY');
     *     if(inInfo1 == null){
     *          //Login again and retry
     *     }
     *
     *     //Multiple symbol search
     *     List<DriveWealthJsonInstrument> inInfo1 = DriveWealthAPI.searchInstrument('https://api.drivewealth.io/v1/instruments?symbol=CRM,AAPL', 'SESSION_KEY');
     * </pre>
     *
     * @param endpoint      DriveWealth search instrument endpoint
     * @param sessionKey    Need valid session key for the API for authentication
     *
     * @return List<DriveWealthJsonInstrument>
    */
    Public Static List<DriveWealthJsonInstrument> searchInstrument(String endpoint, String sessionKey) {
        HTTPUtilities hu = new HTTPUtilities();
        hu.setEndpoint(endpoint);
        hu.setMethod('GET');
        hu.setHeader('Content-Type', contentType);
        hu.setHeader('x-mysolomeo-session-key', sessionKey);

        HTTPResponse res = hu.sendRequest();

        List<DriveWealthJsonInstrument> retVal;
                //If 401 then return null to indicate to calling function to do a login() request
        if(res.getStatusCode() == 401){
            retVal = null;
        }else{
            retVal = DriveWealthJsonInstrument.parse(res.getBody());
        }

        return retVal;
    }

    /**
     * Create Practice Account; http://developer.drivewealth.com/docs/create-practice-account
     *
     * NOTE: Use try/catch when calling this code. It's upto the calling code to figure out how to deal with exceptions
     *
     * <pre>
     *     //Single symbol search
     *     DriveWealthJsonAccount inInfo1 = DriveWealthAPI.createPracticeAccount('https://api.drivewealth.io/v1/signups/practice', 'SESSION_KEY', {name: NAME....});
     *     if(inInfo1 == null){
     *          //Login again
     *     }
     * </pre>
     *
     * @param endpoint      DriveWealth search instrument endpoint
     * @param sessionKey    Need valid session key for the API for authentication
     * @param data          Map of Account data to create account
     *
     * @return List<DriveWealthJsonInstrument>
    */
    Public Static DriveWealthJsonAccount createPracticeAccount(String endpoint, Map<String, Object> data, String sessionKey) {
        HTTPUtilities hu = new HTTPUtilities();
        hu.setEndpoint(endpoint);
        hu.setMethod('POST');
        hu.setHeader('Content-Type', contentType);
        //Sending session is optional because we might create a new account for user or account for an existing user
        if(sessionKey != null) {
            hu.setHeader('x-mysolomeo-session-key', sessionKey);
        }
        hu.setBody(JSON.serialize(data));

        HTTPResponse res = hu.sendRequest() ;

        return DriveWealthJsonAccount.parse(res.getBody());
    }

    /**
     * Create Market Order; http://developer.drivewealth.com/docs/add-market-order
     *
     * NOTE: Use try/catch when calling this code. It's upto the calling code to figure out how to deal with exceptions
     *
     * <pre>
     *     //Single symbol search
     *     DriveWealthJsonAccount inInfo1 = DriveWealthAPI.createMartketOrder('https://api.drivewealth.io/v1/orders', 'SESSION_KEY', {name: NAME....});
     *     if(inInfo1 == null){
     *          //Login again
     *     }
     * </pre>
     *
     * @param endpoint      DriveWealth search instrument endpoint
     * @param sessionKey    Need valid session key for the API for authentication
     * @param data          Map of Account data to create account
     *
     * @return List<DriveWealthJsonInstrument>
    */
    Public Static DriveWealthJsonMarketOrder createMarketOrder(String endpoint, Map<String, Object> data, String sessionKey) {
        HTTPUtilities hu = new HTTPUtilities();
        hu.setEndpoint(endpoint);
        hu.setMethod('POST');
        hu.setHeader('Content-Type', contentType);
        hu.setHeader('x-mysolomeo-session-key', sessionKey);

        hu.setBody(JSON.serialize(data));

        HTTPResponse res = hu.sendRequest() ;

        return DriveWealthJsonMarketOrder.parse(res.getBody());
    }
    /**
     * Check order Status; http://developer.drivewealth.com/docs/get_market
     *
     * NOTE: Use try/catch when calling this code. It's upto the calling code to figure out how to deal with exceptions
     *
     * <pre>
     *     //Single symbol search
     *     DriveWealthJsonAccount inInfo1 = DriveWealthAPI.createPracticeAccount('https://api.drivewealth.io/v1/orders/ORDERID', 'SESSION_KEY', {name: NAME....});
     *     if(inInfo1 == null){
     *          //Login again
     *     }
     * </pre>
     *
     * @param endpoint      DriveWealth search instrument endpoint
     * @param sessionKey    Need valid session key for the API for authentication
     * @param data          Map of Account data to create account
     *
     * @return List<DriveWealthJsonInstrument>
    */
    Public Static DriveWealthJsonOrderStatus getOrderStatus(String endpoint, String OrderID, String sessionKey) {
        HTTPUtilities hu = new HTTPUtilities();
        hu.setEndpoint(endpoint + '/' + OrderID);
        hu.setMethod('GET');
        hu.setHeader('Content-Type', contentType);
        hu.setHeader('x-mysolomeo-session-key', sessionKey);

        HTTPResponse res = hu.sendRequest() ;

        return DriveWealthJsonOrderStatus.parse(res.getBody());
    }
}