# frozen_string_literal: true

class AssociationSerializer < ApplicationSerializer
  attr_reader :association

  def initialize(association)
    @association = association
  end

  def to_h
    {
      name: association_name,
      macro: association.macro,
      model: association.class_name || association_name.classify
    }
  end

  private

  delegate :name, to: :association, prefix: true
end
