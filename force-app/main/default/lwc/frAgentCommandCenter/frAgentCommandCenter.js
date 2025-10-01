import { LightningElement, track } from 'lwc';

export default class FrAgentCommandCenter extends LightningElement {
    showBuilder = false;
    selectedPurpose = null;
    @track steps = [
        { key: 'create', label: 'Create Audience', status: 'pending' },
        { key: 'add', label: 'Add Members', status: 'pending' },
        { key: 'assignChecklist', label: 'Assign Checklist', status: 'pending' },
        { key: 'schedule', label: 'Schedule Sessions', status: 'pending' }
    ];

    @track messages = [];

    // Preview & Review tab data
    @track previewRows = [];
    previewColumns = [
        { label: 'Name', fieldName: 'name' },
        { label: 'Email', fieldName: 'email' },
        { label: 'Title', fieldName: 'title' },
        { label: 'Division', fieldName: 'division' },
        { label: 'Manager', fieldName: 'managerName' },
        { label: 'Country', fieldName: 'country' },
        { label: 'Hire Date', fieldName: 'hireDate', type: 'date' }
    ];

    handlePreviewUpdate(event) {
        const { loaded, total, rows } = event.detail || {};
        if (Array.isArray(rows)) {
            this.previewRows = rows;
        }
        if (typeof total === 'number') {
            this.addMessage(`Live Preview: ${loaded || 0} of ${total} learners in scope.`);
        } else {
            this.addMessage(`Live Preview: ${loaded || 0} learners in scope.`);
        }
    }

    handleIntent(event) {
        const val = event.detail && event.detail.value;
        if (!val) return;
        this.selectedPurpose = val;
        this.showBuilder = true;
        // Pass purpose to child builder after render
        Promise.resolve().then(() => {
            const builder = this.template.querySelector('c-audience-builder');
            if (builder && builder.setPurpose) builder.setPurpose(this.selectedPurpose);
        });
    }

    handleProvisionStart() {
        this.resetSteps();
        this.addMessage('Provisioning started…');
        this.setStep('create', 'in_progress');
    }

    handleProvisionProgress(event) {
        const { step, status, message } = event.detail || {};
        if (step && status) this.setStep(step, status);
        if (message) this.addMessage(message);
    }

    handleProvisionComplete(event) {
        const { success, message } = event.detail || {};
        if (message) this.addMessage(message);
        // Mark remaining plan items accordingly
        if (success) {
            this.completeUpTo('add');
            this.addMessage('MVP complete. Checklist assignment and scheduling are placeholders.');
        } else {
            this.addMessage('Provisioning finished with errors.');
        }
    }

    setStep(key, status) {
        this.steps = this.steps.map(s => (s.key === key ? { ...s, status } : s));
    }

    completeUpTo(key) {
        let reached = false;
        this.steps = this.steps.map(s => {
            if (s.key === key) reached = true;
            return { ...s, status: reached ? s.status : 'completed' };
        });
    }

    resetSteps() {
        this.steps = this.steps.map(s => ({ ...s, status: 'pending' }));
    }

    addMessage(text) {
        const timestamp = new Date().toLocaleTimeString();
        this.messages = [{ id: `${Date.now()}-${Math.random()}`, text: `[${timestamp}] ${text}` }, ...this.messages];
    }
}