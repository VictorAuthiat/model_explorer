class AssociationManager {
  constructor({ templateId }) {
    this.template = document.getElementById(templateId);
  }

  async addAssociation(associationSelect, association) {
    try {
      const option = associationSelect.selectElement.querySelector(`option[value="${association}"]`);
      const parent = associationSelect.selectElement.dataset.relation;
      const modelName = option.dataset.model || option.value;
      const macroName = option.dataset.macro;
      const response = await fetch(`/model_explorer/models/${modelName}?macro=${macroName}&parent=${parent}`);
      const data = await response.json();

      this.addAssociationsSelect(option, associationSelect, data);
    } catch (error) {
      console.error("Failed to add association:", error);
    }
  }

  addAssociationsSelect(option, associationSelect, data) {
    if (data.associations.length === 0) return;

    const templateClone = this.template.content.cloneNode(true);
    const newContainer = document.createElement('div');
    const relationName = this._constructRelationName(option.value);
    const associationId = this._constructId(associationSelect.selectElement.dataset.relation, relationName);

    newContainer.appendChild(templateClone);
    newContainer.innerHTML = newContainer.innerHTML.replace(/TEMP_ID/g, associationId);
    newContainer.querySelector('.card-header').textContent = option.value;

    this._populateInputs(newContainer, associationSelect, option);
    this._populateAssociationsSelect(newContainer, data.associations, associationId);
    this._initializeNewAssociationSelect(newContainer, associationId, associationSelect);
    this._populateScopesSelect(newContainer, data.scopes, associationId);
    this._initializeNewScopeSelect(newContainer, associationId, associationSelect);

    this._populateColumnsSelect(newContainer, data.columns, associationId);
    this._initializeNewColumnsSelect(newContainer, associationId, associationSelect);
  }

  removeAssociation(associationSelect, association) {
    const parentRelation = associationSelect.selectElement.dataset.relation;

    if (!parentRelation) {
      document.getElementById(`associations-accordion-${this._constructRelationName(association)}`).remove();
    } else {
      const fullAssociation = `${parentRelation}-${association}`;
      document.getElementById(`associations-accordion-${fullAssociation}`).remove();
    }
  }

  _constructRelationName(name) {
    return name
      .replace(/::/g, '_')
      .replace(/([A-Z])/g, (match, offset) => offset > 0 ? '_' + match.toLowerCase() : match.toLowerCase())
  }

  _constructName(input, associationSelect) {
    if (associationSelect.parent) {
      const parentRelation = associationSelect.selectElement.dataset.relation;
      const parentInput = document.getElementById(`associations-input-${parentRelation}`);
      const parentName = parentInput.name.replace('[name]', '');
      const inputIndex = input.dataset.index;

      return `${parentName}[associations][${inputIndex}][association_attributes][name]`;
    } else {
      return 'association_attributes[name]';
    }
  }

  _constructId(parentRelation, relationName) {
    return parentRelation ? `${parentRelation}-${relationName}` : relationName;
  }

  _populateInputs(container, associationSelect, option) {
    const parentInputs = associationSelect.associationContainer.querySelectorAll('input:not([id*="ts-control"])');
    const input = container.querySelector('input');

    input.setAttribute('data-index', parentInputs.length);
    input.name = this._constructName(input, associationSelect);
    input.value = option.value;
  }

  _populateAssociationsSelect(container, associations, associationId) {
    const select = container.querySelector(`#associations-select-${associationId}`);

    select.setAttribute('data-relation', associationId);

    associations.forEach(assoc => {
      const option = document.createElement('option');
      option.value = assoc.name;
      option.textContent = assoc.name;
      option.dataset.model = assoc.model;
      option.dataset.macro = assoc.macro;
      select.appendChild(option);
    });
  }

  _populateScopesSelect(container, scopes, associationId) {
    const select = container.querySelector(`#scopes-select-${associationId}`);

    select.setAttribute('data-relation', associationId);

    scopes.forEach(scope => {
      const option = document.createElement('option');
      option.value = scope;
      option.textContent = scope;
      select.appendChild(option);
    });
  }

  _initializeNewAssociationSelect(container, associationId, associationSelect) {
    associationSelect.associationContainer.appendChild(container);

    const newAssociationSelect = new AssociationSelect({
      selectId: `associations-select-${associationId}`,
      ContainerId: `associations-container-${associationId}`,
      parentId: associationSelect.selectElement.id
    });

    newAssociationSelect.initialize(this, { maxItems: 5 });
  }

  _initializeNewScopeSelect(container, associationId, associationSelect) {
    const parentInputs = associationSelect.associationContainer.querySelectorAll('input:not([id*="ts-control"])');
    const select = container.querySelector(`#scopes-select-${associationId}`);

    if (select.children.length === 0 || (parentInputs.length - 1) === 0) {
      select.remove();
      return;
    }

    select.setAttribute('data-index', parentInputs.length - 1);
    const name = this._constructName(select, associationSelect).replace('[name]', '[scopes][]');
    select.name = name

    associationSelect.associationContainer.appendChild(container);
    new TomSelect(`#scopes-select-${associationId}`, { maxItems: 5 });
  }

  _populateColumnsSelect(container, columns, associationId) {
    const select = container.querySelector(`#columns-select-${associationId}`);

    select.setAttribute('data-relation', associationId);

    columns.forEach(column => {
      const option = document.createElement('option');
      option.value = column;
      option.textContent = column;
      select.appendChild(option);
    });
  }

  _initializeNewColumnsSelect(container, associationId, associationSelect) {
    const parentInputs = associationSelect.associationContainer.querySelectorAll('input:not([id*="ts-control"])');
    const select = container.querySelector(`#columns-select-${associationId}`);

    select.setAttribute('data-index', parentInputs.length - 1);

    let name;

    if ((parentInputs.length - 1) === 0) {
      name = 'columns[]';
    } else {
      name = this._constructName(select, associationSelect).replace('[name]', '[columns][]');
    }

    select.name = name

    associationSelect.associationContainer.appendChild(container);
    new TomSelect(`#columns-select-${associationId}`);
  }
}
