@isTest
private class DWCreateOrder_Controller_Test {
    @testSetup
    private static void dataSetup(){
        DriveWealth__c dw = new DriveWealth__c();
        dw.Endpoint__c = 'https://api.drivewealth.io/v1/'; 
        insert dw;

        List<DW_Account__c> dwAccountList = new List<DW_Account__c>();


        List<Account> listAcc = new List<Account>();
        for(Integer i=0;i<10; i++){
            Account acc = new Account();
            acc.Name = 'Account A' + i;
            acc.DW_Username__c = 'abc1234';
            acc.DW_Password__c = 'abc1234';

            //This ID matches the data from HTTPMockResponse in createSession()
            acc.DW_User_ID__c = '02e57c7d-d071-4c63-b491-1194a9939ea5';

            listAcc.add(acc);

        }

        insert listAcc;

        for(Integer i=0; i<10; i++){

            DW_Account__c dwAccount = new DW_Account__c();
            dwAccount.Name = 'Test DW Account';

            dwAccount.Account__c = listAcc[i].Id;
            dwAccount.Account_No__c = '1111';
            dwAccount.Account_ID__c = '1111';
            dwAccount.Account_Type__c = 1;
            dwAccountList.add(dwAccount);
        }
        insert dwAccountList;

    }
    @isTest
    private static void createOrderController_submitOrder_positive(){

        Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];
        DW_Account__c dwAccount = [SELECT Id, Account_No__c from DW_Account__c where Account__c=:acc.Id];

        Map<String, Object> orderInfo = new Map<String,Object>();
        orderInfo.put('DW_Account__c', dwAccount.Id);
        orderInfo.put('Order_Type__c', 1);
        orderInfo.put('Side__c', 'B' );
        orderInfo.put('Order_Quantity__c', 11);
        orderInfo.put('Comment__c', '');

        DriveWealthJsonInstrument instrument = new DriveWealthJsonInstrument();
        instrument.instrumentID = 'IDID';
        instrument.Name = 'INS Name';
        instrument.symbol = 'CRM';

        Map<String, Object> data = new Map<String, Object>{'mode'=>'submitOrder', 'acc' => acc,
                                                'orderInfo' => orderInfo,
                                                'instrument' => JSON.serialize(instrument)
                                        };

        Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());


        Test.startTest();

        ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
        d1.operation = 'DWCreateOrder_Controller';
        d1.input = ETLC_ApexBridge_Data.encodeData(data);
        d1.debug = true;


        String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
        ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);

        DriveWealthJsonMarketOrder retVal = (DriveWealthJsonMarketOrder)ETLC_ApexBridge_Data.decodeData(d2.output, DriveWealthJsonMarketOrder.class);
        Test.stopTest();

        System.assertEquals(1, [select id from dw_order__c].size());
        System.assertEquals('06926627-e950-48f3-9c53-b679f61120ec', retVal.instrumentID);

    }
    @isTest
    private static void createOrderController_getAccount_negative(){
        Id AccountID = '00141000007RP8w';//WRONG ID

        Map<String, String> data = new Map<String, String>{'mode'=>'getAccount', 'AccountID' => AccountID};

        ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
        d1.operation = 'DWCreateOrder_Controller';
        d1.input = ETLC_ApexBridge_Data.encodeData(data);
        d1.debug = true;

        String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
        ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
        Account a = (Account)ETLC_ApexBridge_Data.decodeData(d2.output, Account.class);

        System.assertEquals(null, a);
    }

    @isTest
    private static void createOrderController_getAccount_positive(){
        Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];


        Map<String, String> data = new Map<String, String>{'mode'=>'getAccount', 'AccountID' => acc.Id};

        ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
        d1.operation = 'DWCreateOrder_Controller';
        d1.input = ETLC_ApexBridge_Data.encodeData(data);
        d1.debug = true;

        String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
        ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
        Account a = (Account)ETLC_ApexBridge_Data.decodeData(d2.output, Account.class);
        System.assertEquals('Account A0', a.Name);
        System.assertEquals(1, a.DW_Accounts__r.size());
    }


}