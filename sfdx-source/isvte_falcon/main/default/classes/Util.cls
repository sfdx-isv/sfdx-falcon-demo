/**
 * Creating as per https://github.com/CodeScience/CSUtils/wiki/Using-Security-Coding-Library-(ESAPI)Uti
 */

public with sharing class Util {
    public static Boolean debug = false;
    public static void log(Object message) {
        if(debug == true) {
            System.debug(message);
        }
    }
    /**
     * @return the current ESAPI SFDCAccessController object being used to maintain the access control rules for this application.
     */
    public static SFDCAccessController AccessController {
        get {
            if (AccessController == null) {
                AccessController = new SFDCAccessController();
            }
            return AccessController;
        } private set;
    }
}