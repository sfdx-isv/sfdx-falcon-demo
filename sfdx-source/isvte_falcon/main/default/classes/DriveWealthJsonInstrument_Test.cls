@isTest
private class DriveWealthJsonInstrument_Test {
    static testMethod void testParse() {
        String json= '[{"instrumentID": "a67422af-8504-43df-9e63-7361eb0bd99e","name": "Apple, Inc.","category": "Stock","currencyID": "USD","exchangeID": "XNAS","limitStatus": 0}]';
        List<DriveWealthJsonInstrument> obj = DriveWealthJsonInstrument.parse(json);
        System.assert(obj != null);
    }
}