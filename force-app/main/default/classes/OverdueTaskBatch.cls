global class OverdueTaskBatch implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    
    private Set<Id> taskOwnerIds = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext bc){
        Date today = Date.today();
        return Database.getQueryLocator([SELECT Id, Subject, Status, ActivityDate, OwnerId FROM Task WHERE Status != 'Completed'AND ActivityDate < :today
        ]);
    }
    global void execute(Database.BatchableContext bc, List<Task> taskList){
        List<Task> overdueTasks = new List<Task>();
        for(Task t : taskList){
            t.Status = 'Overdue'; 
            overdueTasks.add(t);
            taskOwnerIds.add(t.OwnerId);
        }
        if(!overdueTasks.isEmpty()){
            update overdueTasks;
        }
    }
    global void finish(Database.BatchableContext bc){
        if (!taskOwnerIds.isEmpty()){
            List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
            for (Id ownerId : taskOwnerIds){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(ownerId);
                email.setSaveAsActivity(false);
                email.setSubject('Overdue Task Alert');
                email.setPlainTextBody('You have overdue tasks. Please review your task list.');
                emailMessages.add(email);
            }
            Messaging.sendEmail(emailMessages);
        }
    }
    global void execute(SchedulableContext sc){
        OverdueTaskBatch batchJob = new OverdueTaskBatch();
        Database.executeBatch(batchJob);
    }
}
