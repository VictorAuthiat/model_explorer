class ModelsController {
  constructor() {
    this.modelForm = new ModelForm({
      recordDetailsId: 'json-data',
      noRecordId: 'no-record',
      formId: 'export-form'
    });

    this.associationSelect = new AssociationSelect({
      ContainerId: 'associations-container',
      selectId: 'association-select',
      parentId: null
    });

    this.associationManager = new AssociationManager({
      templateId: 'associations-select-template'
    });

    this.recordDetailsCopyButton = new CopyButton({
      copyButtonId: 'copy-record-details',
      targetId: 'json-data'
    });
  }

  connect() {
    this.modelForm.initialize();
    this.associationSelect.initialize(this.associationManager, { maxItems: 1});
    this.recordDetailsCopyButton.initialize();

    document.querySelectorAll('select option').forEach(option => {
      option.setAttribute('data-model', option.value);
      option.setAttribute('data-relation', option.value.replace(/::/g, '_').toLowerCase());
    });
  }
}

document.addEventListener('DOMContentLoaded', function () {
  const modelsController = new ModelsController();

  modelsController.connect();
});
