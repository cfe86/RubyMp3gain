# frozen_string_literal: true

module Mp3gain
  # data object for the recommended gain change
  class RecommendedGainChange

    attr_reader :file_path, :track_mp3_gain, :track_db_gain, :max_amplitude, :max_global_gain
    attr_accessor :album_changes

    def initialize(file_path, track_mp3_gain, track_db_gain, max_amplitude, max_global_gain, min_global_gain)
      @file_path = file_path
      @track_mp3_gain = track_mp3_gain
      @track_db_gain = track_db_gain
      @max_amplitude = max_amplitude
      @max_global_gain = max_global_gain
      @min_global_gain = min_global_gain
      @album_changes = nil
    end

    def clipping?
      # if > 31000 -> clipping
      @max_amplitude > 31_000
    end
  end
end
