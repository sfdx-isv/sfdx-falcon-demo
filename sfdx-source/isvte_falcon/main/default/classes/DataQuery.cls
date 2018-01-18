/**
  * Class to build all the queries that we will be using
  * This is helpful as we will only need to keep all SOQL queries in one place in case we need to add/remove columns
  *
  * This class will also take care of CRUD/FLS as needed
 */
public with sharing class DataQuery {

    /**
      * Return User information for current logged in user
      *
      *
      * Note: Use try/catch in calling function to trap any Exceptions
      * This funciton can raise SFDCAccessControlException or Eception
      *
      * @param UserID ID for record to return
      * @return Account
     */

    public static User getUser(ID UserId){

        //CRUD/FLS check
        Util.AccessController.assertAuthorizedToView(
                Schema.User.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.User.fields.AccountId
                }
        );

        User u = [SELECT AccountId FROM User WHERE Id = :UserId];

        return u;
    }

    /**
      * Return DriveWealth Account List created for an Account based on Account ID
      *
      *
      * Note: Use try/catch in calling function to trap any Exceptions
      * This funciton can raise SFDCAccessControlException or Eception
      *
      * @param AccountID ID of account
      *
      * @return Account
     */

    public static Account getAccount(Id AccountId){

        //CRUD/FLS check
        Util.AccessController.assertAuthorizedToView(
            Schema.Account.getSobjectType(),
            new List<Schema.SobjectField>{
                    Schema.Account.fields.Name, Schema.Account.fields.DW_Username__c,
                    Schema.Account.fields.DW_Password__c, Schema.Account.fields.DW_User_ID__c,
                    Schema.Account.fields.DW_Total_Practice_Accounts__c, Schema.Account.fields.DW_Email__c
            }
        );
        //CRUD/FLS Check
        Util.AccessController.assertAuthorizedToView(
                Schema.DW_Account__c.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.DW_Account__c.fields.Name,
                        Schema.DW_Account__c.fields.Account_No__c,
                        Schema.DW_Account__c.fields.Account_Type__c,
                        Schema.DW_Account__c.fields.Created_When__c

                }
        );

        Account a;
        List<Account> listAcc =  [select ID, Name, DW_Email__c,  DW_Username__c, DW_Password__c, DW_User_ID__c, DW_Total_Practice_Accounts__c, (select Id, Name, Account_No__c, Account_Type__c, Created_When__c from DW_Accounts__r) from Account WHERE Id=:AccountId];
        if(listAcc.size() > 0 ){
            a = listAcc[0];
        }
        return a;
    }
    /**
      * Return DriveWealth Account information created for an Account based on DW Account ID
      *
      * Note: Use try/catch in calling function to trap any Exceptions
      * This funciton can raise SFDCAccessControlException or Eception
      *
      * @param AccountID ID of account
      *
      * @return DW_Account__c
     */

    public static DW_Account__c getDWAccount(Id DWAccountID){

        //CRUD/FLS check
        //Chek for DW Account
        Util.AccessController.assertAuthorizedToView(
                Schema.DW_Account__c.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.DW_Account__c.fields.Name, Schema.DW_Account__c.fields.Account__c,
                        Schema.DW_Account__c.fields.Account_ID__c, Schema.DW_Account__c.fields.Account_No__c,
                        Schema.DW_Account__c.fields.Account_Type__c
                }
        );
        //Check for account as we also need it for that
        Util.AccessController.assertAuthorizedToView(
                Schema.Account.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.Account.fields.Name, Schema.Account.fields.DW_User_ID__c,
                        Schema.Account.fields.DW_Username__c, Schema.Account.fields.DW_Password__c
                }
        );
        return [select ID,Name,Account__c,Account_ID__c, Account_No__c, Account_Type__c, Account__r.DW_User_ID__c,
                        Account__r.DW_Username__c, Account__r.dW_Password__c
                    from DW_Account__c WHERE Id=:DWAccountID];
    }

    /**
     * return list of all orders associated with an account
     */

    public static  Map<Id, DW_Order__c> getOrders(Id AccountID) {
        //CRUD/FLS check
        //Chek for DW Account
        Util.AccessController.assertAuthorizedToView(
                Schema.DW_Account__c.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.DW_Account__c.fields.Name
                }
        );

        //Chek for Order
        Util.AccessController.assertAuthorizedToView(
                Schema.DW_Order__c.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.DW_Order__c.fields.DW_Account__c, Schema.DW_Order__c.fields.Instrument_Name__c,
                        Schema.DW_Order__c.fields.Order_Quantity__c, Schema.DW_Order__c.fields.Order_ID__c,
                        Schema.DW_Order__c.fields.Order_Type__c, Schema.DW_Order__c.fields.Side__c,
                        Schema.DW_Order__c.fields.Order_Status__c, Schema.DW_Order__c.fields.Executed_When__c
                }
        );

        //CRUD/FLS check

        Map<Id, DW_Order__c> retVal = new  Map<Id, DW_Order__c>(
                [Select Id, DW_Account__r.Name, DW_Account__c, Instrument_Name__c, Order_Quantity__c, Order_ID__c,
                        Order_Type__c, Side__c, Order_Status__c, Executed_When__c, CreatedDate, Instrument_Symbol__c
                    FROM DW_Order__c where Account__c=:AccountID
                    ORDER BY CreatedDate ASC]
        );
        return retval;
    }

    /**
     * return order based on Order ID
     */
    public static  DW_Order__c getOrder(Id OrderID) {

        //Chek for Order
        Util.AccessController.assertAuthorizedToView(
                Schema.DW_Order__c.getSobjectType(),
                new List<Schema.SobjectField>{
                        Schema.DW_Order__c.fields.Name
                }
        );

        DW_Order__c  dwOrder;
        List<DW_Order__c> dwOrderList = [Select Id, Order_ID__c FROM DW_Order__c where Id=:OrderId];
        if(dwOrderList.size() > 0){
            dwOrder = dwOrderList[0];
        }
        return dwOrder;
    }
}