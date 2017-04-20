module Zipper
    class FileEntry
        def initialize(file_name, flatten_structure = false, file_path = nil)
            @name = file_name
            @path = file_path
            @flatten = flatten_structure
        end

        # Entry name, used as a real path in file system
        def name
            @name
        end

        # True if existing directory structure shouldn't be preserved'
        def flatten
            @flatten
        end

        # Path of entry in a zip archive
        def path
            @path
        end
    end
end
