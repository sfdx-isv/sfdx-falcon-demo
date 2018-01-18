trigger DWAccount on Account (before insert, before update) {

    if(Trigger.isBefore && Trigger.isInsert){
        //Run on Account Before
        if(DWTriggerRecursiveCheck.hasRun('DWAccount_Before_Insert') == false) {
            //Mark as run so that the triggers run by DML in handler won't get into recursive
            DWTriggerRecursiveCheck.markAsRun('DWAccount_Before_Insert');
            DWAccountTriggerHandler.handleBeforeInsert(Trigger.new);

            //Reset the trigger run
            //This is needed so that next batch can run without issues
            //If we don't reset then next batch won't run the trigger at all
            DWTriggerRecursiveCheck.markAsRun('DWAccount_Before_Insert', false);

        }
    }else if(Trigger.isBefore && Trigger.isUpdate){
        //Run on Account After
        if(DWTriggerRecursiveCheck.hasRun('DWAccount_Before_Update') == false) {

            DWTriggerRecursiveCheck.markAsRun('DWAccount_Before_Update');

            DWAccountTriggerHandler.handleBeforeUpdate(Trigger.new,  Trigger.newMap, Trigger.oldMap);

            DWTriggerRecursiveCheck.markAsRun('DWAccount_Before_Update', false);
        }
    }
}