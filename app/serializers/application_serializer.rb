# frozen_string_literal: true

class ApplicationSerializer
  def to_h
    raise NotImplementedError
  end

  def to_json(*)
    to_h.to_json
  end
end
