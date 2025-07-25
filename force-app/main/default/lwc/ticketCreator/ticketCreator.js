import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getProjects from '@salesforce/apex/TicketController.getProjects';
import getEpics from '@salesforce/apex/TicketController.getEpics';
import getWorks from '@salesforce/apex/TicketController.getWorks';
import saveTicket from '@salesforce/apex/TicketController.saveTicket';
import getProductTags from '@salesforce/apex/TicketController.getProductTags';

const DEFAULT_PROJECT_ID = 'a5E2E000000EaCIUA0';

export default class TicketCreator extends LightningElement {
    @track projectOptions = [];
    @track epicOptions = [];
    @track workOptions = [];
    @track selectedProjectId = DEFAULT_PROJECT_ID;
    @track selectedEpicId = '';
    @track selectedWorkId = '';
    @track showNewEpicInput = false;
    @track showNewWorkInput = false;
    @track newEpicName = '';
    @track newWorkName = '';
    @track description = '';
    @track assigneeId = '';
    @track isSubmitting = false;
    @track productTagOptions = [];
    @track selectedProductTagId = '';

    get isDescriptionRequired() {
        return this.showNewWorkInput || !this.selectedWorkId;
    }

    connectedCallback() {
        this.loadProjects();
        this.loadProductTags();
    }

    loadProjects() {
        getProjects()
            .then(result => {
                this.projectOptions = result.map(p => ({ label: p.Name, value: p.Id }));
                if (!this.selectedProjectId && this.projectOptions.length) {
                    this.selectedProjectId = DEFAULT_PROJECT_ID;
                }
                this.loadEpics();
            })
            .catch(error => {
                this.showError('Error loading projects', error);
            });
    }

    loadEpics() {
        getEpics({ projectId: this.selectedProjectId })
            .then(result => {
                this.epicOptions = result.map(e => ({ label: e.Name, value: e.Id }));
                this.epicOptions.push({ label: '+ New Epic', value: 'NEW' });
                this.selectedEpicId = '';
                this.showNewEpicInput = false;
                this.loadWorks();
            })
            .catch(error => {
                this.showError('Error loading epics', error);
            });
    }

    loadWorks() {
        if (!this.selectedEpicId || this.selectedEpicId === 'NEW') {
            this.workOptions = [{ label: '+ New Work', value: 'NEW' }];
            this.selectedWorkId = 'NEW';
            this.showNewWorkInput = true;
            return;
        }
        getWorks({ epicId: this.selectedEpicId })
            .then(result => {
                this.workOptions = result.map(w => ({ label: w.Name, value: w.Id }));
                this.workOptions.push({ label: '+ New Work', value: 'NEW' });
                this.selectedWorkId = '';
                this.showNewWorkInput = false;
            })
            .catch(error => {
                this.showError('Error loading works', error);
            });
    }

    loadProductTags() {
        getProductTags()
            .then(result => {
                this.productTagOptions = result.map(tag => ({ label: tag.name, value: tag.id }));
                if (this.productTagOptions.length && !this.selectedProductTagId) {
                    this.selectedProductTagId = this.productTagOptions[0].value;
                }
            })
            .catch(error => {
                this.showError('Error loading product tags', error);
            });
    }

    handleProjectChange(event) {
        this.selectedProjectId = event.detail.value;
        this.selectedEpicId = '';
        this.selectedWorkId = '';
        this.loadEpics();
    }

    handleEpicChange(event) {
        this.selectedEpicId = event.detail.value;
        this.showNewEpicInput = this.selectedEpicId === 'NEW';
        this.selectedWorkId = '';
        this.loadWorks();
    }

    handleWorkChange(event) {
        this.selectedWorkId = event.detail.value;
        this.showNewWorkInput = this.selectedWorkId === 'NEW';
    }

    handleNewEpicNameChange(event) {
        this.newEpicName = event.detail.value;
    }

    handleNewWorkNameChange(event) {
        this.newWorkName = event.detail.value;
    }

    handleDescriptionChange(event) {
        this.description = event.detail.value;
    }

    handleAssigneeChange(event) {
        this.assigneeId = event.detail.value;
    }

    handleProductTagChange(event) {
        this.selectedProductTagId = event.detail.value;
    }

    handleSubmit() {
        this.isSubmitting = true;
        const epicIdOrNew = this.selectedEpicId || 'NEW';
        const workIdOrNew = this.selectedWorkId || 'NEW';
        saveTicket({
            projectId: this.selectedProjectId,
            epicIdOrNewLabel: epicIdOrNew,
            workIdOrNewLabel: workIdOrNew,
            description: this.description,
            assigneeId: this.assigneeId,
            productTagId: this.selectedProductTagId
        })
            .then(url => {
                this.showSuccess('Ticket saved', 'Click to view', url);
                this.resetForm();
            })
            .catch(error => {
                this.showError('Error saving ticket', error);
            })
            .finally(() => {
                this.isSubmitting = false;
            });
    }

    showSuccess(title, message, url) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message,
                messageData: [
                    {
                        url,
                        label: 'View Ticket'
                    }
                ],
                variant: 'success',
                mode: 'sticky'
            })
        );
    }

    showError(title, error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title,
                message: this.reduceError(error),
                variant: 'error',
                mode: 'sticky'
            })
        );
    }

    reduceError(error) {
        if (Array.isArray(error.body)) {
            return error.body.map(e => e.message).join(', ');
        } else if (typeof error.body.message === 'string') {
            return error.body.message;
        }
        return error.message || JSON.stringify(error);
    }

    resetForm() {
        this.selectedEpicId = '';
        this.selectedWorkId = '';
        this.showNewEpicInput = false;
        this.showNewWorkInput = false;
        this.newEpicName = '';
        this.newWorkName = '';
        this.description = '';
        this.assigneeId = '';
        this.loadProjects();
    }
} 