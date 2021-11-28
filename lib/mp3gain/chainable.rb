# frozen_string_literal: true

module Mp3gain
  # Offers methods like path, target_db etc. to be chained together
  module Chainable

    attr_accessor :mp3gain

    def path(mp3_gain_path)
      raise ArgumentError, 'Mp3gain path can\'t be null' if mp3_gain_path.nil?

      @mp3gain = Mp3gain.new(mp3_gain_path)
      @mp3gain.mp3gain = @mp3gain
    end

    def with_target_db(target_db)
      raise 'Please set a path first.' if @mp3gain.nil?

      @mp3gain.target_db = target_db
      @mp3gain
    end

    def do_preserve_timestamp(preserve: true)
      raise 'Please set a path first.' if @mp3gain.nil?

      @mp3gain.preserve_timestamp = preserve
      @mp3gain
    end
  end
end
