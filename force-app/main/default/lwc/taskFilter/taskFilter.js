import { LightningElement } from 'lwc';

export default class TaskFilter extends LightningElement {
    handleFilterChange(event) {
        const filterValue = event.target.dataset.filter;
        this.dispatchEvent(new CustomEvent('filterchange', { detail: filterValue }));
    }
}
