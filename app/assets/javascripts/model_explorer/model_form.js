class ModelForm {
  constructor({ formId, recordDetailsId, noRecordId, recordDetailsLinkId, downloadLinkId }) {
    this.form = document.getElementById(formId);
    this.recordDetails = document.getElementById(recordDetailsId);
    this.recordDetailsPre = this.recordDetails.querySelector('pre');
    this.noRecord = document.getElementById(noRecordId);
    this.viewRecordDetailsLink = document.getElementById(recordDetailsLinkId);
    this.downloadLink = document.getElementById(downloadLinkId);
  }

  initialize() {
    this.form.addEventListener('submit', async (event) => {
      this._handleFormValidation(event);

      const response = await fetch(
        this._collectFormData(),
        { method: 'GET' }
      ).then(response => response.text()).then(json => JSON.parse(json));

      this._updateRecordDetails(response);
    });
  }

  _handleFormValidation(event) {
    this.form.classList.add('was-validated');
    if (!this.form.checkValidity()) {
      event.preventDefault();
      event.stopPropagation();
    } else {
      event.preventDefault();
    }
  }

  _collectFormData() {
    const url = new URL(this.form.action);
    const params = new URLSearchParams();
    Array.from(this.form.elements).forEach(element => {
      if (element.name && element.value) {
        params.append(element.name, element.value);
      }
    });
    url.search = params.toString();
    return url;
  }

  _updateRecordDetails(parsedResponse) {
    const content = parsedResponse.error === undefined ? parsedResponse.export : parsedResponse;

    this.downloadLink.href = parsedResponse.path;
    this.viewRecordDetailsLink.href = parsedResponse.path;
    this.recordDetailsPre.textContent = JSON.stringify(content, null, 3);
    Prism.highlightElement(this.recordDetailsPre);
    this.noRecord.classList.add('d-none');
    this.recordDetails.classList.remove('d-none');
  }
}
