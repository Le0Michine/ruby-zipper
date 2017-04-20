require "zipper/version"
require "zipper/fileEntryType"
require "zipper/fileEntry"
require "zipper/zipEntry"
require "zipper/JsonConfigKey"
require "zipper/cli"
require "zip"

module Zipper
    class ZipFileGenerator
        # Initialize with the json config.
        def initialize(json_config)
            @entries = json_config[JsonConfigKey::Entries]
            @ignore_entries = json_config[JsonConfigKey::IgnoreEntries]
            @output_file = json_config[JsonConfigKey::Name]
        end

        # Zip the input entries.
        def write
            buffer = create_zip(@entries, @ignore_entries)

            puts "\nwrite file #{@output_file}"
            File.open(@output_file, "wb") {|f| f.write buffer.string }
        end

        private

        # True if +fileEntry+ isn't included into +ignore_entries+ array
        # Params:
        # +file_entry_name+:: name of the entry
        # +file_entry_type+:: type of the entry
        # +ignore_entries+:: array of entries for which should be excluded (false returned)
        def filter_entries(file_entry_name, file_entry_type, ignore_entries)
            return true if ignore_entries == nil
            ignore_entries.each do |entry|
                return false if (file_entry_type.casecmp(FileEntryType::FILE) == 0) && (file_entry_name.include? entry)
            end
            return true
        end

        # Creates +FileEntry+ for file or array of entries for directory and subdirectories
        # Params:
        # +directory_or_file+:: path to directory or file
        # +entry_path+:: path with which the entry should be put into zip
        def get_entries(directory_or_file, entry_path, ignore_entries)
            if File.directory? directory_or_file
                get_dir_entries_recursively(directory_or_file, entry_path, ignore_entries)
            else
                FileEntry.new(directory_or_file, false, entry_path)
            end
        end

        # Collects all files from directory recursively
        # Params:
        # +dir+:: start directory
        # +entry_path+:: path with which file should be placed into zip
        # +replace_path+:: part of path which is being replaced by +entry_path+
        def get_dir_entries_recursively(dir, entry_path, ignore_entries, replace_path = nil)
            replace_path = dir.clone if replace_path.nil?
            (Dir.entries(dir) - %w(. ..)).map { |v| File.join(dir, v) }.select { |path| filter_entries path, FileEntryType::FILE, ignore_entries }.map { |path|
                if File.directory? path
                    get_dir_entries_recursively(path, entry_path, ignore_entries, replace_path)
                else
                    entry_path_in_zip = (entry_path.nil? ? path : path.sub(replace_path, entry_path)).gsub(/^[\/\\]+/, "")
                    FileEntry.new(path, false, entry_path_in_zip)
                end
            }
        end

        # Creates zip file in memory from passed +FileEntry+ array, returns StringIO as result
        # Params:
        # +entries+:: array of +FileEntry+ and +ZipEntry+ objects
        def compress(entries)
            puts "\nadding the following entries into zip package"
            puts "#{ entries.map{ |x| x.name }.join("\n")}"
            buffer = Zip::File.add_buffer do |zio|
                entries.each do |file|
                    if file.is_a? FileEntry
                        zio.add(file.path == nil ? file.name : file.path, file.name)
                    else
                        zio.get_output_stream(file.name) { |os| os.write file.buffer.string }
                    end
                end
            end
        end

        # Creates from json array of entries
        # Params:
        # +entries+:: input entries to compress
        # +ignore_entries+:: entries which should be ignored
        def create_zip(entries, ignore_entries)
            compress(entries.map { |x|
                if x.is_a? String
                    get_entries(x, nil, ignore_entries)
                elsif x[JsonConfigKey::Type].nil? || x[JsonConfigKey::Type].casecmp(FileEntryType::FILE) == 0
                    get_entries(x[JsonConfigKey::Name], x[JsonConfigKey::Path], ignore_entries)
                elsif x[JsonConfigKey::Type].casecmp(FileEntryType::ZIP) == 0
                    ZipEntry.new(x[JsonConfigKey::Name], create_zip(x[JsonConfigKey::Entries], x[JsonConfigKey::IgnoreEntries]))
                end
            }.flatten.select{ |f| f.is_a?(ZipEntry) || filter_entries(f.name, FileEntryType::FILE, ignore_entries) }.uniq{ |f| f.name })
        end
    end
end
