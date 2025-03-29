import { LightningElement, api, track } from 'lwc';

export default class TaskItem extends LightningElement{
    @api task;
    @api statusOptions;
    selectedStatus;
    connectedCallback(){
        this.selectedStatus = this.task.Status;
    }

    handleStatusChange(event){
        this.selectedStatus = event.target.value; 
    }

    handleSaveStatus(){
        if (!this.task.Id || !this.selectedStatus){
            return;
        }
        this.dispatchEvent(new CustomEvent('updatestatus', {
            detail: { taskId: this.task.Id, newStatus: this.selectedStatus },
            bubbles: true
        }));
    }

    handleDelete(){
        this.dispatchEvent(new CustomEvent('delete', { detail: this.task.Id }));
    }
}