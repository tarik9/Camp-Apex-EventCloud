trigger eventPlanningStatus on CAMPX__Event__c (before insert, before update) {

   
    if(trigger.isInsert && trigger.isBefore)

    for(CAMPX__Event__c event : Trigger.new){
        
        event.CAMPX__Status__c = 'Planning';
    }

    if(trigger.isUpdate && trigger.isBefore){

       // List<CAMPX__Event__c> listEvent = new List<CAMPX__Event__c>();

        for(CAMPX__Event__c event : Trigger.new){
            CAMPX__Event__c oldRecord = Trigger.oldMap.get(event.Id);
        if (event.CAMPX__Status__c != oldRecord.CAMPX__Status__c) {
            DateTime currentDateTime = DateTime.now();
            event.CAMPX__StatusChangeDate__c = currentDateTime;
        }

        }

        //update listEvent;
    }

    if( trigger.isInsert && trigger.isBefore){

        // List<CAMPX__Event__c> listEvent = new List<CAMPX__Event__c>();
         for(CAMPX__Event__c event : Trigger.new){
 
             DateTime currentDateTime = DateTime.now();
             event.CAMPX__StatusChangeDate__c = currentDateTime;
             //listEvent.add(event);
         }
 
         //update listEvent;
     }

     

    
}