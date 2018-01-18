/**
 * Controller to return information about order status
 */

public with sharing class DWOrderList_Controller extends ETLC_ApexBridge_Abstract {
    private static  Map<String, String> orderStatus = new Map<String, String>(); 

    //These MAPs will be used when order is created and then to convert some values to readable strings
    static{
        orderStatus.put('0', 'New');
        orderStatus.put('1', 'Partial Fill');
        orderStatus.put('2', 'Fill');
        orderStatus.put('4', 'Canceled');
        orderStatus.put('8', 'Rejected');

    }
    /**
     * Method implementation for method in abstract class ETLC_ApexBridge_Abstract
     *
     * This is where we will process user input and decide which functions to call and return required output
     *
     * @param ETLC_ApexBridge_Data Data sent by lightning component
     */
    public override void process(ETLC_ApexBridge_Data data) {
        //Set debugging
        if (data.debug) {
            Util.debug = data.debug;
        }

        // Depending on the mode, determine which operation to perform
        String mode = (String) data.getInputValue('mode');
        if (mode == 'getOrders') {
            data.output = ETLC_ApexBridge_Data.encodeData(getOrders((Id) data.getInputValue('AccountID')));
        }else if(mode == 'fetchStatus') {
            data.output = ETLC_ApexBridge_Data.encodeData(fetchStatus((Id) data.getInputValue('OrderID'), (Id) data.getInputValue('AccountID')));
        }
    }
    /***
     * Return list of all orders specific to an Account
     *
     * @param Id AccountID Account ID to return orders for
     *
     * @return List<DWOrder__c>
     */

    private Map<Id, DW_Order__c> getOrders(Id AccountID){
        Map<Id, DW_Order__c> retVal = new Map<Id, DW_Order__c>();
        try{
            retVal = DataQuery.getOrders(AccountID);
        }catch(Exception e){ Util.log('DWOrderList_Controller.getOrders():Exception: ' + e.getMessage()); }

        return retVal;

    }
    private static DriveWealthJsonOrderStatus fetchStatus(ID OrderID, ID AccountID) {
        DriveWealthJsonOrderStatus retVal = new DriveWealthJsonOrderStatus();
        try{
            Util.log('DWOrderList_Controller.fetchStatus():OrderID: ' + OrderID);
            DW_Order__c dwOrder = DataQuery.getOrder(OrderID);
            Util.log('DWOrderList_Controller.fetchStatus():dwOrder: ' + dwOrder);

            Account acc = DataQuery.getAccount(AccountID);

            //Chek for Order
            //Need to update status after fetching
            Util.AccessController.assertAuthorizedToUpdate(
                    Schema.DW_Order__c.getSobjectType(),
                    new List<Schema.SobjectField>{
                            Schema.DW_Order__c.fields.Order_Status__c, Schema.DW_Order__c.fields.Executed_When__c
                    }
            );
            DriveWealthJsonSession sessionInfo = DriveWealth.doSetup(acc);
            if(sessionInfo != null) {
                retVal = DriveWealth.getOrderStatus((String) dwOrder.Order_ID__c);

                Util.log('DWOrderList_Controller.fetchStatus():retVal: ' + retVal);
                if(retVal.code == null) {

                    dwOrder.Order_Status__c = orderStatus.get(retVal.ordStatus);
                    dwOrder.Executed_When__c = retVal.executedWhen;
                    update dwOrder;

                    //Before return, convert status to readable value
                    retVal.ordStatus = orderStatus.get(retVal.ordStatus);
                }
                DriveWealth.doCleanup();
            }
        }catch (SFDCAccessControlException e) {
            String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DWOrderList_Controller.fetchStatus():SFDCAccessControlException: ' + message);
        }catch(Exception e){ Util.log('DWOrderList_Controller.fetchStatus():Exception: ' + e.getMessage()); }
        return retVal;
    }

}