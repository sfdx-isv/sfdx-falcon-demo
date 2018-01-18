@isTest
private class DWCreateAccount_Test {

	@testSetup
	private static void dataSetup() {
		DriveWealth__c dw = new DriveWealth__c();
		dw.Endpoint__c = 'https://api.drivewealth.io/v1/';
		insert dw;

		List<DW_Account__c> dwAccountList = new List<DW_Account__c>();


		List<Account> listAcc = new List<Account>();
		for (Integer i = 0; i < 10; i++) {
			Account acc = new Account();
			acc.Name = 'Account A' + i;
			acc.DW_Username__c = 'abc1234';
			acc.DW_Password__c = 'abc1234';
			acc.DW_Email__c= 'abc1234@salesxxx.com';

			//This ID matches the data from HTTPMockResponse in createSession()
			acc.DW_User_ID__c = '02e57c7d-d071-4c63-b491-1194a9939ea5';

			listAcc.add(acc);

		}

		insert listAcc;
	}
	@isTest
	private static void createAccountController_createAccount_positive(){
		Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];


		Map<String, Object> data = new Map<String, Object>{'mode'=>'createAccount', 'acc' => acc, 'FirstName'=>'abc123', 'LastName'=>'def123', 'UserName'=>'adsfasdfasd', 'Password'=>'password123' };

		Test.setMock(HTTPCalloutMock.class, new HTTPMockResponse());

		Test.startTest();
		ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
		d1.operation = 'DWCreateAccount';
		d1.input = ETLC_ApexBridge_Data.encodeData(data);
		d1.debug = true;

		String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
		Test.stopTest();

		ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
		Account a = (Account)ETLC_ApexBridge_Data.decodeData(d2.output, Account.class);
		System.assertEquals('Account A0', a.Name);
		System.assertEquals(1, a.DW_Accounts__r.size());
	}

//create PRactice account
	@isTest
	private static void createAccountController_getAccount_positive(){
		Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];


		Map<String, String> data = new Map<String, String>{'mode'=>'getAccount', 'AccountID' => acc.Id};

		ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
		d1.operation = 'DWCreateAccount';
		d1.input = ETLC_ApexBridge_Data.encodeData(data);
		d1.debug = true;

		String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
		ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
		Account a = (Account)ETLC_ApexBridge_Data.decodeData(d2.output, Account.class);
		System.assertEquals('Account A0', a.Name);
		System.assertEquals(0, a.DW_Accounts__r.size());
	}

	@isTest
	private static void createAccountController_getAccount_negative(){
		Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];
//create a drivewealth account manually


			DW_Account__c dwAccount = new DW_Account__c();
			dwAccount.Name = 'Test DW Account';

			dwAccount.Account__c = Acc.Id;
			dwAccount.Account_No__c = '1111';
			dwAccount.Account_ID__c = '1111';
			dwAccount.Account_Type__c = 1;
			//dwAccountList.add(dwAccount);

		insert dwAccount;

		Map<String, String> data = new Map<String, String>{'mode'=>'getAccount', 'AccountID' => acc.Id};

		ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
		d1.operation = 'DWCreateAccount';
		d1.input = ETLC_ApexBridge_Data.encodeData(data);
		d1.debug = true;

		String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
		ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
		Account a = (Account)ETLC_ApexBridge_Data.decodeData(d2.output, Account.class);
		System.assertEquals('Account A0', a.Name);
		System.assertEquals(1, a.DW_Accounts__r.size());
	}




/*
	@isTest
	private static void createAccountController_createAccount_negative(){
		Account acc = [SELECT Id, DW_Username__c, DW_Password__C from Account where name='Account A0' limit 1];


		Map<String, String> data = new Map<String, String>{'mode'=>'getAccount', 'AccountID' => acc.Id};

		ETLC_ApexBridge_Data d1 = new ETLC_ApexBridge_Data();
		d1.operation = 'DWCreateAccount';
		d1.input = ETLC_ApexBridge_Data.encodeData(data);
		d1.debug = true;

		String strD2 =  ETLC_ApexBridge_Controller.execute(d1.toJson());
		ETLC_ApexBridge_Data d2 = ETLC_ApexBridge_Data.fromJSON(strD2);
		Account a = (Account)ETLC_ApexBridge_Data.decodeData(d2.output, Account.class);
		System.assertEquals('Account A0', a.Name);
		System.assertEquals(0, a.DW_Accounts__r.size());
	}

*/
}