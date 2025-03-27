import { LightningElement, api } from 'lwc';

export default class TaskItem extends LightningElement {
    @api task;
    handleDelete() {
        this.dispatchEvent(new CustomEvent('delete', { detail: this.task.Id }));
    }
    
}
