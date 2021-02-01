# frozen_string_literal: true

class Levelcard < Card
  validates :title, :description, :image, :action, :type, presence: true
end
