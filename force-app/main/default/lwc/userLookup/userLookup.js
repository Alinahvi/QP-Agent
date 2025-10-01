import { LightningElement, wire, track } from 'lwc';
import findUsers from '@salesforce/apex/UserLookupController.findUsers';

export default class UserLookup extends LightningElement {
    @track searchTerm = '';
    @track users = [];
    @track selectedUserId = '';

    @wire(findUsers, { searchTerm: '$searchTerm' })
    wiredUsers({ error, data }) {
        if (data) {
            this.users = data;
        } else if (error) {
            this.users = [];
        }
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSelect(event) {
        this.selectedUserId = event.target.value;
        this.dispatchEvent(new CustomEvent('userchange', { detail: { value: this.selectedUserId } }));
    }
} 