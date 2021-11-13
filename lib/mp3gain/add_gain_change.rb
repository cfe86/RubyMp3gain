# frozen_string_literal: true

module Mp3gain
  # data Object when gain is added
  class AddGainChange

    def initialize(file_path, gain_change)
      @file_path = file_path
      @gain_change = gain_change
    end
  end
end
