/**
 * Controller for community wrapper components
 */

public with sharing class DWCommunityWrapper_Controller  extends ETLC_ApexBridge_Abstract {
    /**
     * Method implementation for method in abstract class ETLC_ApexBridge_Abstract
     *
     * This is where we will process user input and decide which functions to call and return required output
     *
     * @param ETLC_ApexBridge_Data Data sent by lightning component
     */
    public override void process(ETLC_ApexBridge_Data data) {
        Util.log('DWCommunityWrapper_Controller.process():data: ' + data);
        //Set debugging
        if (data.debug) {
            Util.debug = data.debug;
        }

        // Depending on the mode, determine which operation to perform
        String mode = (String) data.getInputValue('mode');
        if (mode == 'loadAccount') {
            data.output = ETLC_ApexBridge_Data.encodeData(loadAccount());
        } else if (mode == 'submitOrder') {
        }
    }

    private User loadAccount(){
        User retVal = new User();
        try {
            Util.log('DWCommunityWrapper_Controller.loadAccount():UserId: ' + UserInfo.getUserId());
            retVal = DataQuery.getUser(UserInfo.getUserId());
        }catch(Exception e){ Util.log('DWCommunityWrapper_Controller.loadAccount():Exception: ' + e.getMessage()); }

        return retVal;
    }
}