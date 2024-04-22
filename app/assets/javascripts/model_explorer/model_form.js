class ModelForm {
  constructor({formId, recordDetailsId, noRecordId}) {
    this.form = document.getElementById(formId);
    this.recordDetails = document.getElementById(recordDetailsId);
    this.recordDetailsPre = this.recordDetails.querySelector('pre');
    this.noRecord = document.getElementById(noRecordId);
  }

  initialize() {
    this.form.addEventListener('submit', async (event) => {
      this.form.classList.add('was-validated');

      if (this.form.checkValidity() === false) {
        event.preventDefault();
        event.stopPropagation();
        return;
      } else {
        event.preventDefault();
      }

      const response = await fetch(this.form.action, {
        method: this.form.method,
        body: new FormData(this.form)
      });

      const json = await response.text();

      this.recordDetailsPre.textContent = JSON.stringify(JSON.parse(json), null, 3);
      Prism.highlightElement(this.recordDetailsPre);
      this.noRecord.classList.add('d-none');
      this.recordDetails.classList.remove('d-none');
    });
  }
}
