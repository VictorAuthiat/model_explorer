class AssociationManager {
  constructor({ templateId }) {
    this.template = document.getElementById(templateId);
  }

  async addAssociation(associationSelect, association) {
    try {
      const option = associationSelect.selectElement.querySelector(`option[value="${association}"]`);
      const modelName = option.dataset.model || option.value;
      const response = await fetch(`/model_explorer/models/${modelName}`);
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
    this._populateSelect(newContainer, data.associations, associationId);
    this._initializeNewAssociationSelect(newContainer, associationId, associationSelect);
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

  _populateSelect(container, associations, associationId) {
    const select = container.querySelector('select');

    select.setAttribute('data-relation', associationId);

    associations.forEach(assoc => {
      const option = document.createElement('option');
      option.value = assoc.name;
      option.textContent = assoc.name;
      option.dataset.model = assoc.model;
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
}
