public with sharing class TaskController {
    @AuraEnabled(cacheable=true)
    public static List<Task> getTasks(String filterType){
        Date today = Date.today();
        if (filterType == 'Today') {
            return [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE ActivityDate = :today AND Status != 'Completed' ORDER BY ActivityDate];
        } else if(filterType == 'Upcoming') {
            return [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE ActivityDate > :today AND Status != 'Completed' ORDER BY ActivityDate];
        } else if(filterType == 'Completed') {
            return [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE Status = 'Completed' ORDER BY ActivityDate];
        } else if(filterType == 'Overdue') {
            return [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE ActivityDate < :Date.today() AND Status != 'Completed' ORDER BY ActivityDate];
        } else{
            return [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE Status != 'Completed' ORDER BY ActivityDate];
        }
    }

    @AuraEnabled
    public static void createTask(String taskName, Date dueDate){
        if(String.isEmpty(taskName)){
            throw new AuraHandledException('Task Name cannot be empty');
        }
        if(dueDate < Date.today()){
            throw new AuraHandledException('Due Date cannot be in the past');
        }
        Task newTask = new Task(
            Subject = taskName,
            ActivityDate = dueDate,
            Status = 'Not Started'
        );
        insert newTask;
    }

    @AuraEnabled
    public static void updateTaskStatus(String taskId, String newStatus){
        if(String.isBlank(taskId) || taskId.length() != 18){
            throw new AuraHandledException('Invalid Task ID');
        }
        try {
            Task taskToUpdate = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
            taskToUpdate.Status = newStatus;
            update taskToUpdate;
            System.debug('Task updated successfully.');
        } catch (Exception e) {
            System.debug('Error updating task: ' + e.getMessage());
            throw new AuraHandledException('Error updating task: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteTask(String taskId){
        if(String.isBlank(taskId) || taskId.length() != 18){
            throw new AuraHandledException('Invalid Task ID');
        }
        try{
            List<Task> tasks = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
            if(tasks.isEmpty()){
                throw new AuraHandledException('Task not found');
            }
            delete tasks[0]; 
        } catch(Exception e){
            throw new AuraHandledException('Failed to delete task: ' + e.getMessage());
        }
    }
}
