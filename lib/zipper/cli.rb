require "zipper"
require "thor"
require "json"
require "zipper"

module Zipper
    class CLI < Thor
        desc "zip CONFIG [options]", "creates a zip package according to given configuration file"
        def zip( config )
            puts "Build with config #{config}"
            file = File.read(config)
            json_config = JSON.parse(file)

            generator = Zipper::ZipFileGenerator.new(json_config)
            generator.write
        end
    end
end
