@isTest
public with sharing class OverdueTaskBatchTest {
    @isTest
    static void testBatchExecution(){
        List<Task> testTasks = new List<Task>{
            new Task(Subject = 'Overdue Task 1', ActivityDate = Date.today().addDays(-2), Status = 'Not Started', OwnerId = UserInfo.getUserId()),
            new Task(Subject = 'Overdue Task 2', ActivityDate = Date.today().addDays(-3), Status = 'In Progress', OwnerId = UserInfo.getUserId())
        };
        insert testTasks;
        Test.startTest();
        OverdueTaskBatch batchJob = new OverdueTaskBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<Task> updatedTasks = [SELECT Id, Status FROM Task WHERE Id IN :testTasks];
        for (Task t : updatedTasks){
            System.assertEquals('Overdue', t.Status);
        }
    }
}
