import { LightningElement } from 'lwc';

export default class TaskSearch extends LightningElement{
    searchKey = '';

    handleSearchChange(event){
        this.searchKey = event.target.value;
    }

    handleSearch(){
        if(this.searchKey.trim() !== ''){
            this.dispatchEvent(new CustomEvent('search', { 
                detail: this.searchKey.trim(),
                bubbles: true, 
                composed: true 
            }));
        }
    }
}
