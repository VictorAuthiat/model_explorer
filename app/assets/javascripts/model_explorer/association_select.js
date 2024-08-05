class AssociationSelect {
  constructor({selectId, ContainerId, parentId = null}) {
    this.selectElement = document.getElementById(selectId);
    this.associationContainer = document.getElementById(ContainerId);

    if (parentId) {
      this.parent = document.getElementById(parentId);
    }
  }

  initialize(manager, options = {}) {
    if (!this.selectElement) return;

    new TomSelect(
      this.selectElement,
      {
        ...options,
        onItemAdd: (item) => manager.addAssociation(this, item),
        onItemRemove: (item) => manager.removeAssociation(this, item)
      }
    );
  }
}
