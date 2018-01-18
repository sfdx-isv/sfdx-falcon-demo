public with sharing class DWTriggerRecursiveCheck {

    public static Map<String, Boolean> check = new Map<String, Boolean>();

    /**
     * If key is set then return the value
     * If not then return false
     */
    public static Boolean hasRun(String key){
        Boolean retval = false;
        //If key exists then it was already run
        //If doesn't then it wasn't run but set the key for next time
        if(check.containsKey(key)){
            retVal = check.get(key);//return the key as it can be false in cases where trigger is reset
        }else{
            retval = false;
        }
        return retval;
    }

    /**
     * Mark that trigger has run
     * Explicitly call to set to true
     */
    public static void markAsRun(String key){
        markAsRun(key, true);
    }

    /**
     * Can send false as flag to reset the trigger
     * Explicitly call to set to true
     */
    public static void markAsRun(String key, Boolean flag){
        check.put(key, flag);
    }
}