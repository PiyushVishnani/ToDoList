import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getTasks from '@salesforce/apex/TaskController.getTasks';
import createTask from '@salesforce/apex/TaskController.createTask';
import deleteTask from '@salesforce/apex/TaskController.deleteTask';
import updateTaskStatus from '@salesforce/apex/TaskController.updateTaskStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TodoList extends LightningElement {
    @track tasks = [];
    newTaskName = '';
    newTaskDueDate = '';
    @track filterType = 'Inbox'; 
    wiredTasksResult;

    statusOptions = [
        { label: 'Not Started', value: 'Not Started' },
        { label: 'In Progress', value: 'In Progress' },
        { label: 'Completed', value: 'Completed' },
    ];

    @wire(getTasks, { filterType: '$filterType' })
    wiredTasks(result) {
        this.wiredTasksResult = result;
        
        if (result.data) {
            this.tasks = Array.isArray(result.data) ? result.data : [];
        } else {
            this.tasks = [];
        }
    }

    get filteredTasks() {
        return this.tasks?.length ? this.tasks : [];
    }

    get isTaskListEmpty() {
        return this.tasks?.length === 0;
    }


    handleFilterChange(event) {
        this.filterType = event.target.dataset.filter;
        this.refreshTasks();
    }

    async refreshTasks() {
        try {
            refreshApex(this.wiredTasksResult);
        } catch (error) {
            console.error('Error refreshing tasks:', error);
        }
    }

    handleTaskName(event) {
        this.newTaskName = event.target.value.trim();
    }

    handleTaskDueDate(event) {
        this.newTaskDueDate = event.target.value;
    }

    async handleAddTask() {
        if (!this.newTaskName) {
            this.showToast('Error', 'Task name cannot be empty', 'error');
            return;
        }

        if (!this.newTaskDueDate) {
            this.showToast('Error', 'Due Date is required', 'error');
            return;
        }

        const formattedDueDate = new Date(this.newTaskDueDate).toISOString().split('T')[0];

        try {
            createTask({ taskName: this.newTaskName, dueDate: formattedDueDate });
            this.showToast('Success', 'Task added successfully', 'success');
            this.newTaskName = '';
            this.newTaskDueDate = '';
            this.refreshTasks();
        } catch (error) {
            this.showToast('Error', 'Failed to add task', 'error');
        }
    }

    handleDelete(event) {
        const taskId = event.currentTarget.dataset.id;

        if (!taskId || taskId.length !== 18) { 
            this.showToast('Error', 'Invalid Task ID', 'error');
            return;
        }

        try {
            deleteTask({ taskId });
            this.showToast('Success', 'Task deleted successfully', 'success');
            this.refreshTasks();
        } catch (error) {
            this.showToast('Error', 'Failed to delete task', 'error');
        }
    }

    handleStatusChange(event) {
        const taskId = event.target.dataset.id;
        const newStatus = event.target.value;

        this.tasks = this.tasks.map(task => {
            if (task.Id === taskId) {
                return { ...task, Status: newStatus };
            }
            return task;
        });
    }

    handleUpdateStatus(event) {
        const taskId = event.target.dataset.id;
        const updatedTask = this.tasks.find(task => task.Id === taskId);

        if (!updatedTask) return;

        try {
            updateTaskStatus({ taskId, newStatus: updatedTask.Status });
            this.showToast('Success', 'Task status updated', 'success');
            this.refreshTasks();
        } catch (error) {
            this.showToast('Error', 'Failed to update task status', 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
