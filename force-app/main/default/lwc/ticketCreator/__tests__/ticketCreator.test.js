import TicketCreator from '../ticketCreator';

describe('TicketCreator JS helpers', () => {
    let element;
    beforeEach(() => {
        element = new TicketCreator();
    });

    it('reduces array errors', () => {
        const error = { body: [{ message: 'Error 1' }, { message: 'Error 2' }] };
        expect(element.reduceError(error)).toBe('Error 1, Error 2');
    });

    it('reduces string error', () => {
        const error = { body: { message: 'Apex error' } };
        expect(element.reduceError(error)).toBe('Apex error');
    });

    it('reduces fallback error', () => {
        const error = { message: 'Other error' };
        expect(element.reduceError(error)).toBe('Other error');
    });

    it('reduces unknown error', () => {
        const error = {};
        expect(element.reduceError(error)).toBe(JSON.stringify(error));
    });
}); 