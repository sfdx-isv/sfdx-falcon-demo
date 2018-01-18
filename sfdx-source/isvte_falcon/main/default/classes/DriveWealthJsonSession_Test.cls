@isTest
private class DriveWealthJsonSession_Test {
    static testMethod void testParse() {
        String json = '{' +
                '    "appTypeID": 2000,' +
                '    "commissionRate": 2.99,' +
                '    "loginState": 1,' +
                '    "referralCode": "VL7FN4",' +
                '    "sessionKey": "02e57c7d-d071-4c63-b491-1194a9939ea5.2016-01-20T20:50:48.680Z",' +
                '    "userID": "02e57c7d-d071-4c63-b491-1194a9939ea5",' +
                '    "wlpID": "DW",' +
                '    "accounts": [' +
                '        {' +
                '            "accountID": "02e57c7d-d071-4c63-b491-1194a9939ea5.1452548320228",' +
                '            "accountNo": "DPAJ000003",' +
                '            "userID": "02e57c7d-d071-4c63-b491-1194a9939ea5",' +
                '            "accountType": 1,' +
                '            "cash": 9950.04,' +
                '            "currencyID": "USD",' +
                '            "defaultGoalID": "64924fd9-8ef6-48ac-ade2-c628cbfbd6b9",' +
                '            "freeTradeBalance": 0,' +
                '            "goodFaithViolations": 0,' +
                '            "ibID": "80f9b672-120d-4b73-9cc9-42fb3262c4b9",' +
                '            "interestFree": false,' +
                '            "margin": 1,' +
                '            "nickname": "Bob\'s Practice Account", ' +
                ' "openedWhen": "2016-01-11T21:38:40Z", ' +
                ' "goals": [], ' +
                ' "orders": [], ' +
                ' "patternDayTrades": 0, ' +
                ' "positions": [], ' +
                ' "status": 2, ' +
                ' "tradingType": "C",' +
                ' "updatedWhen": "2016-01-20T08:17:46.770Z", ' +
                ' "createdWhen": "2016-01-11T21:38:40.228Z", ' +
                ' "bodMoneyMarket": 9950.04, ' +
                ' "bodEquityValue": 43.56, ' +
                ' "bodCashAvailForWith": 9950.04, ' +
                ' "bodCashAvailForTrading": 9950.04,' +
                ' "rtCashAvailForTrading": 9950.04, ' +
                ' "rtCashAvailForWith": 9950.04, ' +
                ' "accountMgmtType": 0, ' +
                ' "longOnly": true' +
                ' },' +
                ' {' +
                ' "accountID": "02e57c7d-d071-4c63-b491-1194a9939ea5.1452548617456", ' +
                ' "accountNo": "DWTE000005", ' +
                ' "userID": "02e57c7d-d071-4c63-b491-1194a9939ea5", ' +
                ' "accountType": 2, ' +
                ' "cash": 22117.56, ' +
                ' "currencyID": "USD", ' +
                ' "defaultGoalID": "353c5517-c10f-4505-81d9-c7887b6fe10e", ' +
                ' "freeTradeBalance": 0, ' +
                ' "goodFaithViolations": 0, ' +
                ' "ibID": "80f9b672-120d-4b73-9cc9-42fb3262c4b9", ' +
                ' "interestFree": false, ' +
                ' "margin": 1, ' +
                ' "nickname": "Bob\'s Live Account",' +
                '            "openedWhen": "2016-01-11T21:43:37Z",' +
                '            "goals": [],' +
                '            "orders": [],' +
                '            "patternDayTrades": 0,' +
                '            "positions": [],' +
                '            "status": 2,' +
                '            "tradingType": "C",' +
                '            "updatedWhen": "2016-01-20T19:50:08.320Z",' +
                '            "createdWhen": "2016-01-11T21:43:37.455Z",' +
                '            "bodMoneyMarket": 22142.36,' +
                '            "bodEquityValue": 2738.61,' +
                '            "bodCashAvailForWith": 22142.36,' +
                '            "bodCashAvailForTrading": 22142.36,' +
                '            "rtCashAvailForTrading": 22117.56,' +
                '            "rtCashAvailForWith": 22117.56,' +
                '            "accountMgmtType": 0,' +
                '            "longOnly": true' +
                '        }' +
                '    ],' +
                '    "instruments": [],' +
                '    "guest": false' +
                '}';
        DriveWealthJsonSession obj = DriveWealthJsonSession.parse(json);
        System.assert(obj != null);
    }
}