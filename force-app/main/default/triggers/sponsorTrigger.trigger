trigger sponsorTrigger on CAMPX__Sponsor__c (before insert, before update) {

    if( trigger.isInsert && trigger.isBefore){

        
        for(CAMPX__Sponsor__c sponsor : Trigger.new){
            if(sponsor.CAMPX__Status__c == null){

                sponsor.CAMPX__Status__c = 'Pending';
            }
        }

        for(CAMPX__Sponsor__c sponsor : Trigger.new){
            if(String.isBlank(sponsor.CAMPX__Email__c)){

                sponsor.addError('A sponsor can not be created without an email address');
            }
        }

        for(CAMPX__Sponsor__c sponsor : Trigger.new){
            if(sponsor.CAMPX__ContributionAmount__c == null){

                sponsor.CAMPX__Tier__c = '';
            }
            if(sponsor.CAMPX__ContributionAmount__c <= 0){

                sponsor.CAMPX__Tier__c = '';
            }
            if(sponsor.CAMPX__ContributionAmount__c > 0 &&  sponsor.CAMPX__ContributionAmount__c < 1000){

                sponsor.CAMPX__Tier__c = 'Bronze';
            }
            if(sponsor.CAMPX__ContributionAmount__c >= 1000 &&  sponsor.CAMPX__ContributionAmount__c < 5000){

                sponsor.CAMPX__Tier__c = 'Silver';
            }
            if(sponsor.CAMPX__ContributionAmount__c >= 5000){

                sponsor.CAMPX__Tier__c = 'Gold';
            }
        }
} 

    if( (trigger.isUpdate && trigger.isBefore) || (trigger.isInsert && trigger.isBefore)){
            for(CAMPX__Sponsor__c sponsor : Trigger.new){
                if(sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Event__c == null){
                    sponsor.addError('A Sponsor must be associated with an event before being Accepted.');
                }
            }
    }

    if(trigger.isInsert && trigger.isBefore){
        Map<Id, Decimal> idToContribution = new Map<Id, Decimal>();
        for(CAMPX__Sponsor__c sponsor : Trigger.new){
            if(sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Event__c != null){
                idToContribution.put(sponsor.CAMPX__Event__c, sponsor.CAMPX__ContributionAmount__c);
            }
        }
        
    List<CAMPX__Event__c> eventList = new list<CAMPX__Event__c>();
    for(Id id : idToContribution.keySet()){

        CAMPX__Event__c event = new CAMPX__Event__c();
        event.Id = id;
        event.CAMPX__GrossRevenue__c = idToContribution.get(id);
        eventList.add(event);
    }

    if(eventList.size() > 0){
        update eventList;
    }
    }


    if (trigger.isUpdate && trigger.isBefore) {
        Set<Id> eventIds = new Set<Id>();
    
        // Collect event IDs where the sponsor status is changing to 'Accepted' or where the contribution amount is modified
        for (CAMPX__Sponsor__c sponsor : Trigger.new) {
            CAMPX__Sponsor__c oldSponsor = Trigger.oldMap.get(sponsor.Id);
            if (sponsor.CAMPX__Status__c == 'Accepted' && sponsor.CAMPX__Event__c != null &&
                (oldSponsor.CAMPX__Status__c != 'Accepted' || sponsor.CAMPX__ContributionAmount__c != oldSponsor.CAMPX__ContributionAmount__c)) {
                eventIds.add(sponsor.CAMPX__Event__c);
            }
        }
    
        // Query all sponsors linked to the affected events to get their contributions
        Map<Id, Decimal> eventIdToTotalContribution = new Map<Id, Decimal>();
        if (!eventIds.isEmpty()) {
            List<CAMPX__Sponsor__c> acceptedSponsors = [
                SELECT CAMPX__Event__c, CAMPX__ContributionAmount__c
                FROM CAMPX__Sponsor__c
                WHERE CAMPX__Status__c = 'Accepted' AND CAMPX__Event__c IN :eventIds
            ];
    
            // Sum contributions for each event
            for (CAMPX__Sponsor__c sponsor : acceptedSponsors) {
                if (eventIdToTotalContribution.containsKey(sponsor.CAMPX__Event__c)) {
                    eventIdToTotalContribution.put(sponsor.CAMPX__Event__c, eventIdToTotalContribution.get(sponsor.CAMPX__Event__c) + sponsor.CAMPX__ContributionAmount__c);
                } else {
                    eventIdToTotalContribution.put(sponsor.CAMPX__Event__c, sponsor.CAMPX__ContributionAmount__c);
                }
            }
        }
    
        // Query events and update their CAMPX__GrossRevenue__c with the total contributions
        List<CAMPX__Event__c> eventsToUpdate = new List<CAMPX__Event__c>();
        if (!eventIdToTotalContribution.isEmpty()) {
            List<CAMPX__Event__c> events = [SELECT Id, CAMPX__GrossRevenue__c FROM CAMPX__Event__c WHERE Id IN :eventIdToTotalContribution.keySet()];
            
            for (CAMPX__Event__c event : events) {
                event.CAMPX__GrossRevenue__c = eventIdToTotalContribution.get(event.Id);
                eventsToUpdate.add(event);
            }
        }
    
        // Update events with new gross revenue values
        if (!eventsToUpdate.isEmpty()) {
            update eventsToUpdate;
        }
    }
    
}