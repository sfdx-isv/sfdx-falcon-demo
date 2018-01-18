@isTest
private class Util_Test {
    @istest
    private static void doTest(){
        Util.log('test');
        Util.AccessController.assertAuthorizedToView(Schema.Account.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.Account.fields.Name
                }
        );
    }

}