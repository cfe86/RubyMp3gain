# frozen_string_literal: true

require 'open3'

require 'mp3gain/chainable'
require 'mp3gain/add_gain_change'
require 'mp3gain/apply_gain_change'
require 'mp3gain/recommended_gain_change'

# wrapper for mp3gain http://mp3gain.sourceforge.net/
module Mp3gain
  extend Chainable

  def self.init(mp3gain_path,
                target_db = 89,
                preserve_timestamp: true)
    Mp3gain.new(mp3gain_path, target_db, preserve_timestamp: preserve_timestamp)
  end

  # Mp3gain entity to analyze and apply gain
  class Mp3gain
    include Chainable

    MAX_FILES = 15

    attr_accessor :mp3gain_path, :target_db, :preserve_timestamp

    # constructor
    #
    # @param [String] mp3gain_path - path to mp3gain binary
    # @param [Integer] target_db - the target db, default is 89 for mp3gain
    # @param [Boolean] preserve_timestamp - keeps the existing timestamps when changing gain
    def initialize(mp3gain_path,
                   target_db = 89,
                   preserve_timestamp: true)
      @mp3gain_path = mp3gain_path
      @target_db = target_db
      @preserve_timestamp = preserve_timestamp
    end

    # returns the version of mp3gain
    #
    # @return the version as a String, e.g. 1.4.7
    def version
      cmd = [@mp3gain_path, '-v']

      status, result = nil
      Open3.popen3(*cmd) do |_, _, stderr, thread|
        while (line = stderr.gets)
          result = line.split.last
        end

        status = thread.value
      end

      throw RuntimeError.new('Could not determine version.') if status != 0 || result.nil?

      result
    end

    # deletes the stored tag infos of the given files
    #
    # @param [Array<String>] files - given files
    #
    # @return [Boolean] true if deleted, else false
    def delete_stored_tag_info(files)
      file_size?(files)

      cmd = [@mp3gain_path, '-s', 'd']
      cmd << '-p' if @preserve_timestamp
      cmd += files

      status = nil
      Open3.popen3(*cmd) do |_, _, _, thread|
        status = thread.value
      end

      # rubocop:disable Style/NumericPredicate
      status == 0
      # rubocop:enable Style/NumericPredicate
    end

    # applies  the track gain to the given files
    #
    # @param [Array<String>] files - the given files
    # @param [Boolean] until_no_clipping - ignores clipping warnings if false, otherwise stops if clipping occurred
    #
    # @return [Array<ApplyGainChange>] list of ApplyGainChange items
    def apply_track_gain(files, until_no_clipping: false)
      file_size?(files)

      cmd = [@mp3gain_path, '-r', '-o', '-c']
      cmd << '-p' if @preserve_timestamp
      cmd << '-k' if until_no_clipping
      cmd << '-d' << (@target_db - 89).to_s if !until_no_clipping && @target_db != 89
      cmd += files

      apply_gain(cmd)
    end

    # applies  the album gain to the given files
    #
    # @param [Array<String>] files - the given files
    # @param [Boolean] until_no_clipping - ignores clipping warnings if false, otherwise stops if clipping occurred
    #
    # @return [Array<ApplyGainChange>] list of ApplyGainChange items
    def apply_album_gain(files, until_no_clipping: false)
      file_size?(files)

      cmd = [@mp3gain_path, '-a', '-o', '-c']
      cmd << '-p' if @preserve_timestamp
      cmd << '-k' if until_no_clipping
      cmd << '-d' << (@target_db - 89).to_s if !until_no_clipping && @target_db != 89
      cmd += files

      apply_gain(cmd)
    end

    # analyzes the given files and recommends the gain changes that should be applied
    #
    # @param [Array<String>] files - the given files to analyze
    #
    # @return [Array<RecommendGainChange>] a list oaf RecommendedGainChange items
    def analyze_gain(files)
      file_size?(files)

      cmd = [@mp3gain_path, '-s', 'r', '-o']
      cmd << '-p' if @preserve_timestamp
      cmd << '-d' << (@target_db - 89).to_s if @target_db != 89
      cmd += files

      status = nil
      result = []
      album_changes = nil
      Open3.popen3(*cmd) do |_, stdout, _, thread|
        while (line = stdout.gets)
          entries = line.strip.split("\t")
          next if entries.length != 6 || entries[0] == 'File'

          if entries[0] == '"Album"'
            album_changes = RecommendedGainChange.new(nil, entries[1].to_i, entries[2].to_f, entries[3].to_f,
                                                      entries[4].to_i, entries[5].to_i)
            next
          end

          result << RecommendedGainChange.new(entries[0], entries[1].to_i, entries[2].to_f, entries[3].to_f,
                                              entries[4].to_i, entries[5].to_i)
        end

        status = thread.value
      end

      throw RuntimeError.new('Could not analyze gain.') if status != 0

      # apply album changes
      result.each { |it| it.album_changes = album_changes }

      result
    end

    # adds the specified gain to the given files
    #
    # @param [Array<String>] files - the given files
    # @param [Integer] gain - the gain to add to each file
    #
    # @return [Array<AddGainChange>] a list of AddGain items
    def add_gain(files, gain)
      cmd = [@mp3gain_path, '-g', gain.to_s]
      cmd << '-p' if @preserve_timestamp
      cmd += files

      status = nil
      Open3.popen3(*cmd) do |_, _, _, thread|
        status = thread.value
      end

      throw RuntimeError.new('Could not apply gain.') if status != 0

      files.map { |file| AddGainChange.new(file, gain) }
    end

    # helper method to apply gain changes by executing the given command and parsing the output
    #
    # @param [Array<String>] cmd - the command to execute
    #
    # @return [Array<ApplyGainChange>] a list of ApplyGainChange items containing the change for each file
    def apply_gain(cmd)
      status = nil
      result = []
      Open3.popen3(*cmd) do |_, stdout, _, thread|
        while (line = stdout.gets)
          entries = line.strip.split("\t")
          next if entries.length != 6 || entries[0] == 'File' || entries[0] == '"Album"'

          result << ApplyGainChange.new(entries[0], entries[1].to_i, entries[2].to_f, entries[3].to_f,
                                        entries[4].to_i, entries[5].to_i)
        end

        status = thread.value
      end

      throw RuntimeError.new('Could not apply gain.') if status != 0

      result
    end

    # checks if the given list of files has less than 15 elements
    #
    # @param [Array<String>] files - given files
    #
    # @return [Boolean] true if size is ok, else false
    def file_size?(files)
      # rubocop:disable Style/GuardClause
      if MAX_FILES < files.length
        throw ArgumentError.new("Only max #{MAX_FILES} can be processed at once. Found #{files.length}")
      end
      # rubocop:enable Style/GuardClause
    end

    private :apply_gain, :file_size?
  end
end


