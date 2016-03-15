require "commander"

module Biplane
  class CLI
    @@host_flag = Commander::Flag.new do |flag|
      flag.name = "host"
      flag.short = "-H"
      flag.long = "--host"
      flag.default = ""
      flag.description = "Kong host"
    end

    @@port_flag = Commander::Flag.new do |flag|
      flag.name = "port"
      flag.short = "-p"
      flag.long = "--port"
      flag.default = 8001
      flag.description = "Kong admin port"
    end

    @@https_flag = Commander::Flag.new do |flag|
      flag.name = "disable_https"
      flag.long = "--no-https"
      flag.default = false
      flag.description = "Disable HTTPS"
    end

    def initialize
      @cmd = Commander::Command.new do |cmd|
        cmd.use = "biplane"
        cmd.long = "Biplane manages your config changes to a Kong instance"

        cmd.commands.add do |cmd|
          cmd.use = "apply config.yaml"
          cmd.short = "Apply config to Kong instance"
          cmd.long = cmd.short
          cmd.run do |options, arguments|
            # Do application
            nil
          end
        end

        cmd.commands.add do |cmd|
          cmd.use = "dump [filename]"
          cmd.short = "Retrieve current Kong config"
          cmd.long = cmd.short

          cmd.flags.add @@host_flag, @@port_flag, @@https_flag
          cmd.flags.add do |flag|
            flag.name = "format"
            flag.long = "--format"
            flag.short = "-f"
            flag.default = "yaml"
            flag.description = "Output format for API dump (json, yaml)"
          end

          cmd.run do |options, arguments|
            filename = arguments[0] as String
            host = options.string["host"]
            port = options.int["port"]
            format = options.string["format"]

            puts "Dumping API from #{host}:#{port} to #{filename}"

            client = KongClient.new(host, port, !options.bool["disable_https"])
            serialized = ApiManifest.new(client).serialize

            File.open(filename, "w") do |f|
              case format
              when "json"
                f.puts serialized.to_json
              when "yaml"
                f.puts YAML.dump(serialized)
              else
                raise "Format '#{format}' is not allowed. Use 'json' or 'yaml'."
              end
            end

            nil
          end
        end

        cmd.commands.add do |cmd|
          cmd.use = "diff [filename]"
          cmd.short = "Diff Kong instance with local config"
          cmd.long = cmd.short

          cmd.flags.add @@host_flag, @@port_flag, @@https_flag
          cmd.flags.add do |flag|
            flag.name = "format"
            flag.long = "--format"
            flag.short = "-f"
            flag.default = "nested"
            flag.description = "Output format for diff output (nested, flat)"
          end
          cmd.run do |options, arguments|
            filename = arguments[0] as String
            host = options.string["host"]
            port = options.int["port"]
            format = options.string["format"]

            puts "Diffing API from #{host}:#{port} to #{filename}"

            client = KongClient.new(host, port, !options.bool["disable_https"])

            manifest = ApiManifest.new(client)
            config = ConfigManifest.new(filename)

            diff = manifest.diff(config)

            Printer.new(diff, format).print

            nil
          end
        end
      end
    end

    def run(args : Array(String))
      Commander.run(@cmd, args)
    end
  end
end
