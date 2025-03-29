@isTest
private class TaskControllerTest{
    @isTest
    static void testGetTasks(){
        Task t1 = new Task(Subject = 'Test Task 1', ActivityDate = Date.today(), Status = 'Not Started');
        Task t2 = new Task(Subject = 'Test Task 2', ActivityDate = Date.today().addDays(3), Status = 'In Progress');
        insert new List<Task>{ t1, t2 };
        List<Task> tasks = TaskController.getTasks('Inbox');
        System.assertNotEquals(0, tasks.size());
        System.assert(tasks[0].Subject.contains('Test Task'));
    }

    @isTest
    static void testCreateTask(){
        Test.startTest();
        TaskController.createTask('New Task', Date.today().addDays(2));
        Test.stopTest();
        Task insertedTask = [SELECT Id, Subject, ActivityDate, Status FROM Task WHERE Subject = 'New Task' LIMIT 1];
        System.assertNotEquals(null, insertedTask);
        System.assertEquals('Not Started', insertedTask.Status);
    }

    @isTest
    static void testUpdateTaskStatus(){
        Task t = new Task(Subject = 'Task to Update', ActivityDate = Date.today(), Status = 'Not Started');
        insert t;
        Test.startTest();
        TaskController.updateTaskStatus(t.Id, 'Completed');
        Test.stopTest();
        Task updatedTask = [SELECT Status FROM Task WHERE Id = :t.Id];
        System.assertEquals('Completed', updatedTask.Status);
    }

    @isTest
    static void testDeleteTask(){
        Task t = new Task(Subject = 'Task to Delete', ActivityDate = Date.today(), Status = 'Not Started');
        insert t;
        Test.startTest();
        TaskController.deleteTask(t.Id);
        Test.stopTest();
        List<Task> remainingTasks = [SELECT Id FROM Task WHERE Id = :t.Id];
        System.assertEquals(0, remainingTasks.size());
    }
}
