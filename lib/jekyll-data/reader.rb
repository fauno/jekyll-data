# encoding: UTF-8
require "csv"

module JekyllData
  class Reader < Jekyll::Reader
    def initialize(site)
      @site = site
      @theme = site.theme
      @theme_data_files = Dir[File.join(site.theme.root,
        site.config["data_dir"], "**", "*.{yaml,yml,json,csv}")]
    end

    # Read data files within theme-gem.
    #
    # Returns nothing.
    def read
      super
      read_theme_data
    end

    # Read data files within a theme gem and add them to internal data
    #
    # Returns a hash appended with new data
    def read_theme_data
      if @theme.data_path
        #
        # show contents of "<theme>/_data/" dir being read while degugging.
        inspect_theme_data
        theme_data = ThemeDataReader.new(site).read(site.config["data_dir"])
        @site.data = Jekyll::Utils.deep_merge_hashes(theme_data, @site.data)
        #
        # show contents of merged site.data hash while debugging with
        # additional --data switch.
        inspect_merged_hash if site.config["data"] && site.config["verbose"]
      end
    end

    private

    # Private:
    # (only while debugging)
    #
    # Print a list of data file(s) within the theme-gem
    def inspect_theme_data
      print_clear_line
      print "Reading:", "Theme Data Files..."
      @theme_data_files.each { |file| print_value file }
      print_clear_line
      print "Merging:", "Theme Data Hash..."

      unless site.config["data"] && site.config["verbose"]
        print_value "use --data with --verbose to output merged " \
                    "Data Hash.".cyan
        print_clear_line
      end
    end

    # Private:
    # (only while debugging)
    #
    # Print contents of the merged data hash
    def inspect_merged_hash
      print "Inspecting:", "Site Data >>"
      inspect_hash @site.data
      print_clear_line
    end

    # Private helper methods to inspect data hash and output contents
    # to logger at level debugging.

    # Dissect the (merged) site.data hash and print its contents
    #
    # - Print the key string(s)
    # - Individually analyse the hash[key] values and extract contents
    #   to output.
    def inspect_hash(hash)
      hash.each do |key, value|
        print_key key
        if value.is_a? Hash
          inspect_inner_hash value
        elsif value.is_a? Array
          print_label key
          extract_hashes_and_print value
        else
          print_value "'#{value}'"
        end
      end
    end

    # Analyse deeper hashes and extract contents to output
    def inspect_inner_hash(hash)
      hash.each do |key, value|
        if value.is_a? Array
          print_label key
          extract_hashes_and_print value
          print_clear_line
        elsif value.is_a? Hash
          print_subkey_and_value key, value
        else
          print_hash key, value
        end
      end
    end

    # If an array of strings, print. Otherwise assume as an
    # array of hashes (sequences) that needs further analysis.
    def extract_hashes_and_print(array)
      array.each do |entry|
        if entry.is_a? String
          print "-", entry
        else
          inspect_inner_hash entry
        end
      end
    end

    # Private methods for formatting log messages while debugging and a
    # method to issue conflict alert and abort site.process

    # Prints key as logger[topic] and value as [message]
    def print_hash(key, value)
      print "#{key}:", value
    end

    # Prints the site.data[key] in color
    def print_key(key)
      @dashes = "------------------------"
      print_value @dashes.to_s.cyan
      print "Data Key:", key.to_s.cyan
      print_value @dashes.to_s.cyan
    end

    # Prints label, keys and values of mappings
    def print_subkey_and_value(key, value)
      print_label key
      value.each do |subkey, val|
        print_hash subkey, val
      end
      print_dashes
    end

    # Print only logger[message], [topic] = nil
    def print_value(value)
      if value.is_a? Array
        extract_hashes_and_print value
      else
        print "", value
      end
    end

    # Print only logger[topic] appended with a colon
    def print_label(key)
      print "#{key}:"
    end

    def print_dashes
      print "", @dashes
    end

    def print_clear_line
      print ""
    end

    # Redefine Jekyll Loggers
    def print(arg1, arg2 = "")
      Jekyll.logger.debug arg1, arg2
    end
  end
end