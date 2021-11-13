# frozen_string_literal: true

module Mp3gain
  # data object when gain is applied
  class ApplyGainChange

    attr_reader :file_path, :mp3_gain, :db_gain, :max_amplitude, :max_global_gain, :min_global_gain

    def initialize(file_path, mp3_gain, db_gain, max_amplitude, max_global_gain, min_global_gain)
      @file_path = file_path
      @mp3_gain = mp3_gain
      @db_gain = db_gain
      @max_amplitude = max_amplitude
      @max_global_gain = max_global_gain
      @min_global_gain = min_global_gain
    end

    def clipping?
      # if > 31000 -> clipping
      @max_amplitude > 31_000
    end
  end
end
