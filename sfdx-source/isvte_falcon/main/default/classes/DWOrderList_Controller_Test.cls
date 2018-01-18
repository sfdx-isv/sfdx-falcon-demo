@isTest
private class DWOrderList_Controller_Test {

    @testSetup
    private static void doSetup(){ 
        //Need for API calls
        DriveWealth__c dw = new DriveWealth__c();
        dw.Endpoint__c = 'https://api.drivewealth.io/v1/'; 
        insert dw;

        Account a = new Account();
        a.Name = 'Account A0';
        a.DW_Username__c = 'username';
        a.DW_Password__c = 'password';
        insert a;

        DW_Account__c dwAccount = new DW_Account__c();
        dwAccount.Name = 'DW Account';
        dwAccount.Account__c = a.Id;
        insert dwAccount;

        DW_Order__c dwOrder = new DW_Order__c();
        dwOrder.Account__c = a.Id;
        dwOrder.DW_Account__c = dwAccount.Id;
        dwOrder.Order_ID__c = 'a00';//Need order ID to start with a for MockResponse to work
        dwOrder.Order_Quantity__c = 12;
        dwOrder.Order_Type__c = 'Market Order';
        dwOrder.Side__c = 'Sell';
        dwOrder.Expires_Time_Stamp__c = '';
        dwOrder.Instrument_ID__c = 'instrumentID';
        dwOrder.Instrument_Name__c = 'instrument.name';
        insert dwOrder;

    }
    @istest
    private static void fetchStatus_positive() {
        Util.debug = true;
        Account acc = [SELECT Id, DW_Username__c, DW_Password__C, DW_User_ID__c from Account where name='Account A0' limit 1];
        DW_Order__c dwOrder = [select id, Order_Status__c from DW_Order__c where Account__c=:acc.Id];
        System.assertEquals('New', dwOrder.Order_Status__c);

        Map<String, Object> data = new Map<String, Object>{'mode'=>'fetchStatus', 'OrderID' => dwOrder.Id, 'AccountID'=>acc.Id};

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());


        Test.startTest();

        ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
        d1.operation = 'DWOrderList_Controller';
        d1.input = ETLC_ApexBridge_Data.encodeData(data);
        d1.debug = true;

        String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
        ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
        DriveWealthJsonOrderStatus retVal = (DriveWealthJsonOrderStatus)ETLC_ApexBridge_Data.decodeData(d2.output, DriveWealthJsonOrderStatus.class);

        test.stopTest();

        System.assertEquals('Rejected', retVal.ordStatus);

        //When saving to database, we change it to readbale form so testing for Rejected
        DW_Order__c dwOrder1 = [select id, Order_Status__c from DW_Order__c where Account__c=:acc.Id];
        System.assertEquals('Rejected', dwOrder1.Order_Status__c);
    }

    @istest
    private static void getOrders_positive() {
        Account acc = [SELECT Id, DW_Username__c, DW_Password__C, DW_User_ID__c from Account where name='Account A0' limit 1];
        DW_Order__c dwOrder = [select id from DW_Order__c where Account__c=:acc.Id];

        Map<String, Object> data = new Map<String, Object>{'mode'=>'getOrders', 'AccountID' => acc.Id};

        ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
        d1.operation = 'DWOrderList_Controller';
        d1.input = ETLC_ApexBridge_Data.encodeData(data);
        d1.debug = true;

        String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
        ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
        MAP<Id, DW_Order__c> retVal = (MAP<Id, DW_Order__c>)ETLC_ApexBridge_Data.decodeData(d2.output, MAP<Id, DW_Order__c>.class);
        DW_Order__c retOrder = retVal.get(dwOrder.Id);
        System.assertEquals(12, retOrder.Order_Quantity__c);
    }

}