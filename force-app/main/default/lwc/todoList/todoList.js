import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTasks from '@salesforce/apex/TaskController.getTasks';
import createTask from '@salesforce/apex/TaskController.createTask';
import deleteTask from '@salesforce/apex/TaskController.deleteTask';
import updateTaskStatus from '@salesforce/apex/TaskController.updateTaskStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TodoList extends LightningElement{
    @track tasks = [];  
    @track searchedTasks = []; 
    @track filterType = 'Inbox'; 
    @track taskNameError = '';
    @track dueDateError = '';
    wiredTasksResult;
    newTaskName = '';
    newTaskDueDate = '';
    statusOptions = [
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
    ];

    @wire(getTasks, { filterType: '$filterType' })
    wiredTasks(result){
        this.wiredTasksResult = result;
        if (result.data) {
            this.tasks = Array.isArray(result.data) ? result.data : [];
            this.searchedTasks = [...this.tasks]; 
        } else {
            this.tasks = [];
            this.searchedTasks = [];
        }
    }

    get filteredTasks(){
        return this.searchedTasks?.length ? this.searchedTasks : this.tasks;
    }

    get isTaskListEmpty(){
        return this.filteredTasks.length === 0;
    }

    handleFilterChange(event){
        this.filterType = event.detail;
        this.refreshTasks();
    }

    handleSearch(event){
        const searchKey = event.detail ? event.detail.toLowerCase().trim() : '';
        this.searchedTasks = searchKey
        ? this.tasks.filter(task => 
            task.Subject && task.Subject.toLowerCase().includes(searchKey)
        )
        : [...this.tasks];
    }

    async refreshTasks(){
        try{
            await refreshApex(this.wiredTasksResult);
        } catch(error){
            console.error('Error refreshing tasks:', error);
        }
    }

    handleTaskName(event){
        this.newTaskName = event.target.value.trim();
        this.taskNameError = '';
    }

    validateTaskName() {
        if (!this.newTaskName) {
            this.taskNameError = 'Task Name cannot be empty!';
        }
    }

    handleTaskDueDate(event){
        this.newTaskDueDate = event.target.value;
        this.dueDateError = '';
    }

    validateDueDate() {
        const today = new Date().toISOString().split('T')[0];
        if (!this.newTaskDueDate) {
            this.dueDateError = 'Due Date is required!';
        } else if (this.newTaskDueDate < today) {
            this.dueDateError = 'Due date cannot be in the past!';
        }
    }

    async handleAddTask(){
        if (!this.newTaskName){
            this.showToast('Error', 'Task name cannot be empty', 'error');
            return;
        }
        if (!this.newTaskDueDate){
            this.showToast('Error', 'Due Date is required', 'error');
            return;
        }
        const formattedDueDate = new Date(this.newTaskDueDate).toISOString().split('T')[0];
        const today = new Date().toISOString().split('T')[0];
        if (formattedDueDate < today) {
            return this.showToast('Error', 'Due date cannot be in the past', 'error');
        }
        try{
            await createTask({ taskName: this.newTaskName, dueDate: formattedDueDate });
            this.showToast('Success', 'Task added successfully', 'success');
            this.newTaskName = '';
            this.newTaskDueDate = '';
            await this.refreshTasks();
        } catch(error){
            if (error.body && error.body.message){
                errorMessage = error.body.message;
            }
            this.showToast('Error', 'Failed to add task', 'error');
        }
    }

    async handleDelete(event){
        const taskId = event.detail;
        try{
            await deleteTask({ taskId });
            this.showToast('Success', 'Task deleted successfully', 'success');
            await this.refreshTasks();
        } catch(error){
            this.showToast('Error', 'Failed to delete task', 'error');
        }
    }

    handleStatusUpdate(event){
        const { taskId, newStatus } = event.detail;
        if(!taskId || !newStatus){
            return;
        }
        updateTaskStatus({ taskId, newStatus })
            .then(() => {
                this.tasks = this.tasks.map(task =>
                    task.Id === taskId ? { ...task, Status: newStatus } : task
                );
                this.showToast("Success", "Task status updated successfully!", "success");
                return this.refreshTasks();
            })
            .catch(error => {
                this.showToast("Error", "Failed to update task status.", "error");
            });
    }
    
    showToast(title, message, variant){
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}