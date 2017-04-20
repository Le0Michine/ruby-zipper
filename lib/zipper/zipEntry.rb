module Zipper
    class ZipEntry
        def initialize(file_name, buffer)
            @name = file_name
            @buffer = buffer
        end

        def name
            @name
        end

        def buffer
            @buffer
        end
    end
end
