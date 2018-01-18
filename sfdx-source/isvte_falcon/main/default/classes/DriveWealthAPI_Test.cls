@isTest

private class DriveWealthAPI_Test {

    private static Profile p;
    private static User u;

    @testSetup
    private static void dataSetup(){
        DriveWealth__c dw = new DriveWealth__c();
        dw.Endpoint__c = 'https://api.drivewealth.io/v1/';
        insert dw;

        List<Account> listAcc = new List<Account>();
        for(Integer i=0;i<10; i++){
            Account acc = new Account();
            acc.Name = 'Account A' + i;
            acc.DW_Username__c = 'abc1234';
            acc.DW_Password__c = 'abc1234';

            listAcc.add(acc);
        }

        insert listAcc;

    }
    private static void dataSetupForRunAs(){
        p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        u = new User(Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='user@aipfscdemo.com');
    }


    @isTest
    private static void createAccount_negative(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointCreatePracticeAccount();

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        Map<String, String> data = new Map<String, String>();
        data.put('username', 'abcd1234');
        data.put('password', 'abcd1234');
        DriveWealthJsonAccount res = DriveWealthAPI.createPracticeAccount(endpoint, data, 'sessKey401');
        Test.stopTest();

        System.assertEquals(401, res.code);
    }
    @isTest
    private static void createAccount_negative_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            createAccount_negative();
        }
    }


    @isTest
    private static void createMarketOrder_positive(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointCreateMarketOrder();

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        Map<String, Object> data = new Map<String, Object>();
        data.put('accountID', '02e57c7d-d071-4c63-b491-1194a9939ea5.1452548617456');
        data.put('accountNo', 'DWTE000005');
        data.put('userID', '02e57c7d-d071-4c63-b491-1194a9939ea5');
        data.put('accountType', 2);
        data.put('ordType', 1);
        data.put('side', 'B');
        data.put('instrumentID', '06926627-e950-48f3-9c53-b679f61120ec');
        data.put('orderQty', 1.4312);
        data.put('comment', '');


        DriveWealthJsonMarketOrder res = DriveWealthAPI.createMarketOrder(endpoint, data, 'sessionKey');
        Test.stopTest();

        System.assertEquals('DB.f88c392e-4d0a-4893-9623-baf72ac0296a', res.orderID);
    }


    @isTest
    private static void getOrderStatus_positive(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointOrderStatus();

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        DriveWealthJsonOrderStatus res = DriveWealthAPI.getOrderStatus(endpoint, 'a', 'sessionKey');
        Test.stopTest();

        System.assertEquals('8', res.ordStatus);
    }


    @isTest
    private static void DriveWealthEnpoint_Test(){
        System.assertEquals('https://api.drivewealth.io/v1/userSessions', DriveWealthAPI.getEndpointCreateSession());
        System.assertEquals('https://api.drivewealth.io/v1/userSessions/sessionKey', DriveWealthAPI.getEndpointGetSession('sessionKey'));

    }
    @isTest
    private static void getIpAddress_NoIPInHeader(){
        System.assertEquals(DriveWealthAPI.ipAddressDefault, DriveWealthAPI.getIpAddress());
    }
    @istest
    private static void getIpAddress_WithIPInHeader(){
        ApexPages.currentPage().getHeaders().put('X-Salesforce-SIP', '1.1.1.1');
        System.assertEquals('1.1.1.1', DriveWealthAPI.getIpAddress());
    }
    @isTest
    private static void createSession_positive(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointCreateSession();

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());


        Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];

        Test.startTest();
        DriveWealthJsonSession res = DriveWealthAPI.createSession(endpoint, acc.DW_username__c, acc.DW_password__c);
        Test.stopTest();

        System.assertEquals(2000, res.appTypeID);
    }

    @isTest
    private static void createSession_positive_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            createSession_positive();
        }
    }
    @isTest
    private static void createSession_negative(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = 'https://api.drivewealth.io/v1/userSessionsINVALID'; 
        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];

        Test.startTest();
        DriveWealthJsonSession res = DriveWealthAPI.createSession(endpoint, acc.DW_username__c, acc.DW_password__c);
        Test.stopTest();

        System.assertEquals(404, res.code);
    }

    @isTest
    private static void createSession_negative_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            createSession_negative();
        }
    }
    @isTest
    private static void getSession_positive(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointGetSession('sessionKey');

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        DriveWealthJsonSession res = DriveWealthAPI.getSession(endpoint, 'sessionKey');
        Test.stopTest();

        System.assertEquals(2000, res.appTypeID);
    }
    @isTest
    private static void getSession_positive_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            getSession_positive();
        }
    }
    @isTest
    private static void getSession_negative(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointGetSession('sessionKeyINVALID');

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        DriveWealthJsonSession res = DriveWealthAPI.getSession(endpoint, 'sessionKey');
        Test.stopTest();

        System.assertEquals(401, res.code);
    }
    @isTest
    private static void getSession_negative_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            getSession_negative();
        }
    }
    @isTest
    private static void searchInstrument_positive(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointSearchInstrument('crm');

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        List<DriveWealthJsonInstrument> res = DriveWealthAPI.searchInstrument(endpoint, 'sessionKey');
        Test.stopTest();

        System.assertEquals('a67422af-8504-43df-9e63-7361eb0bd99e', res[0].instrumentID);
    }
    @isTest
    private static void searchInstrument_positive_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            searchInstrument_positive();
        }
    }
    @isTest
    private static void searchInstrument_negative(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointSearchInstrument('crmINVALID');

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        List<DriveWealthJsonInstrument> res = DriveWealthAPI.searchInstrument(endpoint, 'sessionKey');
        Test.stopTest();

        System.assertEquals(null, res);
    }
    @isTest
    private static void searchInstrument_negative_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            searchInstrument_negative();
        }
    }
    @isTest
    private static void searchInstrument_empty(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointSearchInstrument('crmEMPTY');

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        List<DriveWealthJsonInstrument> res = DriveWealthAPI.searchInstrument(endpoint, 'sessionKey');
        Test.stopTest();

        System.assertEquals(0, res.size());
    }
    @isTest
    private static void searchInstrument_empty_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            searchInstrument_empty();
        }
    }
    @isTest
    private static void searchInstrument_multiple(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointSearchInstrument('crm,AAPL');

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        List<DriveWealthJsonInstrument> res = DriveWealthAPI.searchInstrument(endpoint, 'sessionKey');
        Test.stopTest();

        System.assertEquals(2, res.size());
    }

    @isTest
    private static void searchInstrument_multiple_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            searchInstrument_multiple();
        }
    }

    @isTest
    private static void createAccount_positive(){
        DriveWealth__c dw = DriveWealth__c.getInstance();
        System.assert(dw != null);

        String endpoint = DriveWealthAPI.getEndpointCreatePracticeAccount();

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

        Test.startTest();
        Map<String, String> data = new Map<String, String>();
        data.put('username', 'abcd1234');
        data.put('password', 'abcd1234');
        DriveWealthJsonAccount res = DriveWealthAPI.createPracticeAccount(endpoint, data, 'sessionKey');
        Test.stopTest();

        System.assertEquals('abcd1234', res.password);
    }

    @isTest
    private static void createAccount_positive_runas(){
        dataSetupForRunAs();
        System.runAs(u){
            createAccount_positive();
        }
    }

    /****/

}