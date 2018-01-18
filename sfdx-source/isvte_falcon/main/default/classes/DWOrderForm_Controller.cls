public with sharing class DWOrderForm_Controller {
    public DWOrderForm_Controller() {
    }

    @AuraEnabled
    public static Boolean serverSymbolSearchEnabled() {
        return Application.Features.SymbolSearchEnabled;
    }
}