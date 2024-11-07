trigger EventTrigger on CAMPX__Event__c (before insert, before update) {

    if(trigger.isBefore){
        if(trigger.isInsert || Trigger.isUpdate){
            for(CAMPX__Event__c event : Trigger.new){
                if(event.CAMPX__GrossRevenue__c == null || event.CAMPX__TotalExpenses__c == null){
                    event.CAMPX__NetRevenue__c = null;
                }else{
                    event.CAMPX__NetRevenue__c = event.CAMPX__GrossRevenue__c - event.CAMPX__TotalExpenses__c;
                }
            }
    }
}
}