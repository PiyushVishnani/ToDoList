@isTest
private class TaskControllerTest{
    private static Task createTestTask(String subject, Date activityDate, String status){
        Task testTask = new Task(
            Subject = subject,
            ActivityDate = activityDate,
            Status = status
        );
        insert testTask;
        return testTask;
    }

    @isTest
    static void testGetTasks(){
        Task t1 = createTestTask('Test Task 1', Date.today(), 'Not Started');
        Task t2 = createTestTask('Test Task 2', Date.today().addDays(3), 'In Progress');
        List<Task> tasks = TaskController.getTasks('Inbox');
        Assert.isNotNull(tasks.size(), '2 tasks should be there');
        Assert.isTrue(tasks[0].Subject.contains('Test Task'), 'Subject does not match');
    }

    @isTest
    static void testCreateTask(){
        Test.startTest();
        TaskController.createTask('New Task', Date.today().addDays(2));
        Test.stopTest();
        Task insertedTask = [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE Subject = 'New Task' LIMIT 1];
        Assert.isNotNull(insertedTask, 'there should be a task');
        Assert.areEqual('Not Started', insertedTask.Status, 'Task status should be Not Started');
    }

    @isTest
    static void testUpdateTaskStatus(){
        Task t = createTestTask('Task to Update', Date.today(), 'Not Started');
        Test.startTest();
        TaskController.updateTaskStatus(t.Id, 'Completed');
        Test.stopTest();
        Task updatedTask = [SELECT Status FROM Task WHERE Id = :t.Id];
        Assert.areEqual('Completed', updatedTask.Status, 'Task status should be Completed');
    }

    @isTest
    static void testDeleteTask(){
        Task t = createTestTask('Task to Delete', Date.today(), 'Not Started');
        Test.startTest();
        TaskController.deleteTask(t.Id);
        Test.stopTest();
        List<Task> remainingTasks = [SELECT Id FROM Task WHERE Id = :t.Id];
        Assert.areEqual(0, remainingTasks.size(), 'Task should be deleted');
    }
}
