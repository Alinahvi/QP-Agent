export interface UtteranceEvent {
  utterance: string;
  meta?: {
    topicId?: string;
    subflowId?: string;
    actionId?: string;
    [key: string]: any;
  };
}

export const sendUtterance = (utterance: string, meta?: Record<string, any>) => {
  const event = new CustomEvent('agent:utterance', { 
    detail: { utterance, meta } as UtteranceEvent 
  });
  window.dispatchEvent(event);
};

export const copyToClipboard = async (text: string): Promise<boolean> => {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (err) {
    // Fallback for older browsers
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.focus();
    textArea.select();
    try {
      document.execCommand('copy');
      document.body.removeChild(textArea);
      return true;
    } catch (fallbackErr) {
      document.body.removeChild(textArea);
      return false;
    }
  }
};
