@isTest
public with sharing class OverdueTaskBatchTest {
    private static Task createTaskTest(String subjectName, Date activityDate, String status, Id ownerId){
        Task testTask = new Task(
            Subject = subjectName,
            ActivityDate = activityDate,
            Status = status,
            OwnerId = ownerId
        );
        insert testTask;
        return testTask;
    }
    @isTest
    static void testBatchExecution(){
        Id currentUserId = UserInfo.getUserId();
        Task task1 = createTaskTest('Overdue Task 1', Date.today().addDays(-2), 'Not Started', currentUserId);
        Task task2 = createTaskTest('Overdue Task 2', Date.today().addDays(-3), 'In Progress', currentUserId);
        Test.startTest();
        OverdueTaskBatch batchJob = new OverdueTaskBatch();
        Database.executeBatch(batchJob);
        Test.stopTest();
        List<Task> updatedTasks = [SELECT Id, Status FROM Task WHERE Id IN (:task1.Id, :task2.Id)];
        for (Task t : updatedTasks){
            Assert.areEqual('Overdue', t.Status, 'Task status should be updated to Overdue');
        }
    } 
    @isTest
    static void testScheduledJob(){
        Id currentUserId = UserInfo.getUserId();
        Task task1 = OverdueTaskBatchTest.createTaskTest('Overdue Task 1', Date.today().addDays(-2), 'Not Started', currentUserId);
        Task task2 = OverdueTaskBatchTest.createTaskTest('Overdue Task 2', Date.today().addDays(-3), 'In Progress', currentUserId);
        Test.startTest();
        String jobId = System.schedule('Test Overdue Task Job', '0 0 0 1 1 ? 2050', new OverdueTaskBatch());
        Test.stopTest();    
        Assert.areNotEqual(null, jobId, 'Job ID should not be null');
    }
}
