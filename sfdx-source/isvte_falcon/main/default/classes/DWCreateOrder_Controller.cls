/**
  * Controller class for Create Order (Practice or Live)
 */

public with sharing class DWCreateOrder_Controller  extends ETLC_ApexBridge_Abstract {
    private static  Map<String, String> orderType = new Map<String, String>();
    private static  Map<String, String> side = new Map<String, String>();

    //These MAPs will be used when order is created and then to convert some values to readable strings
    static {
        orderType.put('1', 'Market Order');

        side.put('B', 'Buy');
        side.put('S', 'Sell');
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
        if (data.debug){
            Util.debug = data.debug;
        }
        Util.debug =  true;

        // Depending on the mode, determine which operation to perform
        String mode = (String) data.getInputValue('mode');
        if (mode == 'getAccount') {
            data.output = ETLC_ApexBridge_Data.encodeData(getAccount((Id)data.getInputValue('AccountID')));
        }else if (mode == 'submitOrder') {
            Util.log('DWCreateOrder_Controller.process():data: ' + data);
            Util.log(data.getInputValue('acc'));
            data.output = ETLC_ApexBridge_Data.encodeData(
                                submitOrder((Map<String, Object>)data.getInputValue('acc'),
                                    (Map<String, Object>)data.getInputValue('orderInfo'),
                                        (DriveWealthJsonInstrument)System.JSON.deserialize((String)data.getInputValue('instrument'), DriveWealthJsonInstrument.class)
                                )
                            );
        }
    }

    /**
     * Retrieve account information based on Account ID
     *
     * @param ID Account ID for the record which we want to query
     *
     * @return Account
     */
    public static Account getAccount(ID AccountId) {
        Account retValue = new Account();
        try{
            retValue = DataQuery.getAccount(AccountId);
            Util.log('DriveWealth.retrieveDriveWealthSessionInfo():retValue: ' + retValue);
        }catch (SFDCAccessControlException e) {
            String message = 'Access Control violation - Type: ' + e.getExceptionType() + ' Reason: ' + e.getExceptionReason() + ' Object: ' + e.getExceptionObject() + ' Field: ' + e.getExceptionField() + ' Text: ' + e.getText();Util.log('DWCreateOrder_Controller.getDWAccountList():SFDCAccessControlException: ' + message);
        }catch(Exception e){ Util.log('DWCreateOrder_Controller.getAccount():Exception: ' + e.getMessage()); }
        return retValue;
    }

    /**
     * Process user information and submit to submit order
     *
     * 1) Process user data
     * 2) Query DWAccount to get upto date information (accountID, accountType, Account.userID etc); to ensure info is correct
     * 2) User submitted and queried information to Submit order
     * 3) Save to database in case of success
     *
     * @param Map<String, Object> Account information for order
     * @param Map<String, Object> Order information to submit for Market Order
     */
    public static DriveWealthJsonMarketOrder submitOrder(Map<String, Object> acc, Map<String, Object> orderInfo, DriveWealthJsonInstrument instrument) {
        DriveWealthJsonMarketOrder retVal = new DriveWealthJsonMarketOrder();

        try {

            //CRUD/FLS check
            Util.AccessController.assertAuthorizedToCreate(
                    Schema.DW_Order__c.getSobjectType(),
                    new List<Schema.SobjectField>{
                            Schema.DW_Order__c.fields.Comment__c, Schema.DW_Order__c.fields.DW_Account__c,
                            Schema.DW_Order__c.fields.Order_ID__c, Schema.DW_Order__c.fields.Order_Quantity__c,
                            Schema.DW_Order__c.fields.Order_Type__c, Schema.DW_Order__c.fields.Side__c,
                            Schema.DW_Order__c.fields.Expires_Time_Stamp__c, Schema.DW_Order__c.fields.Instrument_ID__c,
                            Schema.DW_Order__c.fields.Instrument_Name__c
                    }
            );


            Util.log('DWCreateOrder_Controller.submitOrder():acc: ' + acc);
            Util.log('DWCreateOrder_Controller.submitOrder():orderInfo: ' + orderInfo);
            Util.log('DWCreateOrder_Controller.submitOrder():instrument: ' + instrument);

            DW_Account__c dwAccount = DataQuery.getDWAccount((Id) orderInfo.get('DW_Account__c'));
            Util.log('DWCreateOrder_Controller.submitOrder():dwAccount: ' + dwAccount);


            Account acRecord = DataQuery.getAccount(dwAccount.Account__c);

            Map<String, Object> orderInfoToPlaceOrder = new Map<String, Object>();
            orderInfoToPlaceOrder.put('accountID', dwAccount.Account_ID__c);
            orderInfoToPlaceOrder.put('accountNo', dwAccount.Account_No__c);
            orderInfoToPlaceOrder.put('userID', dwAccount.Account__r.DW_User_ID__c);
            orderInfoToPlaceOrder.put('accountType', dwAccount.Account_Type__c);
            orderInfoToPlaceOrder.put('instrumentID', instrument.instrumentID);
            orderInfoToPlaceOrder.put('ordType', orderInfo.get('Order_Type__c'));
            orderInfoToPlaceOrder.put('side', orderInfo.get('Side__c'));
            orderInfoToPlaceOrder.put('orderQty', Double.valueOf(orderInfo.get('Order_Quantity__c')));
            orderInfoToPlaceOrder.put('comment', orderInfo.get('Comment__c'));


            Util.log('DWCreateOrder_Controller.submitOrder():orderInfoToPlaceOrder: ' + orderInfoToPlaceOrder);

            //Need to login to DriveWealth
            DriveWealthJsonSession sessionInfo = DriveWealth.doSetup(acRecord);
            if(sessionInfo != null) { 
                retVal = DriveWealth.createMarketOrder(orderInfoToPlaceOrder);
                Util.log('DWCreateOrder_Controller.submitOrder():retVal: ' + retVal);

                //If code is null then it means call was succesfull and there was no error
                if(retVal.code == null) {
                    DW_Order__c dwOrder = new DW_Order__c();
                    dwOrder.Comment__c = (String)orderInfo.get('Comment__c');
                    dwOrder.DW_Account__c = dwAccount.Id;
                    dwOrder.Order_ID__c = retVal.orderID;
                    dwOrder.Order_Quantity__c = retVal.leavesQty;
                    dwOrder.Order_Type__c = orderType.get(retVal.ordType);
                    dwOrder.Side__c = side.get(retval.side);
                    dwOrder.Expires_Time_Stamp__c = retVal.expireTimestamp ;
                    dwOrder.Instrument_ID__c = retVal.instrumentID;
                    dwOrder.Instrument_Name__c = instrument.name;
                    dwOrder.Account__c = (Id)acc.get('Id');
                    dwOrder.Instrument_Symbol__c = instrument.symbol;

                    Util.log('DWCreateOrder_Controller.submitOrder():BEFORE Insert:dwOrder: ' + dwOrder);
                    insert dwOrder;
                    Util.log('DWCreateOrder_Controller.submitOrder():AFTER Insert:dwOrder: ' + dwOrder);
                }
                DriveWealth.doCleanup();
            }


        }catch(Exception e){ Util.log('DWCreateOrder_Controller.submitOrder():Exception: ' + e.getMessage()); }

        return retVal;
    }
}