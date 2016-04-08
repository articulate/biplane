require "commander"
require "./mixins/paint"

module Biplane
  $COLORIZE = true

  class CLI
    def initialize
      setup = Setup.new

      color_flag = Commander::Flag.new do |flag|
        flag.name = "raw"
        flag.long = "--raw"
        flag.default = setup.get_bool("raw", false)
        flag.description = "Print output without color"
      end

      stdin_flag = Commander::Flag.new do |flag|
        flag.name = "stdin"
        flag.long = "--stdin"
        flag.default = false
        flag.description = "Accept config files from stdin"
      end

      uri_flag = Commander::Flag.new do |flag|
        flag.name = "uri"
        flag.long = "--uri"
        flag.default = setup.get_string("kong.uri", "")
        flag.description = "Kong uri (schema, host, port). Will override host/port/no-https flags."
      end

      host_flag = Commander::Flag.new do |flag|
        flag.name = "host"
        flag.short = "-H"
        flag.long = "--host"
        flag.default = setup.get_string("kong.host", "")
        flag.description = "Kong host"
      end

      port_flag = Commander::Flag.new do |flag|
        flag.name = "port"
        flag.short = "-p"
        flag.long = "--port"
        flag.default = setup.get_int("kong.port", 8001)
        flag.description = "Kong admin port"
      end

      https_flag = Commander::Flag.new do |flag|
        flag.name = "disable_https"
        flag.long = "--no-https"
        flag.default = setup.get_bool("kong.https", false)
        flag.description = "Disable HTTPS"
      end

      @cmd = Commander::Command.new do |cmd|
        cmd.use = "biplane"
        cmd.long = "Biplane manages your config changes to a Kong instance"

        cmd.commands.add do |cmd|
          cmd.use = "version"
          cmd.short = "Print biplane version"
          cmd.long = cmd.short

          cmd.run do |options, arguments|
            puts VERSION

            nil
          end
        end

        # Config settings
        cmd.commands.add do |cmd|
          cmd.use = "config [cmd] [options]"
          cmd.short = "Set biplane configuration options"
          cmd.long = <<-DESC
          Commands available:
            `set key=value [key=value...]`
            `get key [key...]`
            `remove key [key...]`
          DESC

          cmd.run do |options, arguments|
            if arguments.empty?
              values = setup.show
              if values.empty?
                puts "(nothing set)"
              else
                puts values
              end
              exit(0)
            end

            cmd = arguments.shift

            case cmd
            when "set"
              setup.set(arguments)
            when "get"
              values = setup.gets(arguments)

              if values.empty?
                puts "(nothing found)"
              else
                puts arguments.zip(values).map(&.join("=")).join("\n")
              end
            when "remove"
              setup.remove(arguments)
            else
              puts "'#{cmd}' is not a valid config action. Available actions are show, get, set and remove".colorize(:yellow)
            end
          end
        end

        # Apply config to api
        cmd.commands.add do |cmd|
          cmd.use = "apply [filename]"
          cmd.short = "Apply config to Kong instance"
          cmd.long = cmd.short

          cmd.flags.add host_flag, port_flag, https_flag, uri_flag, color_flag, stdin_flag

          cmd.flags.add do |flag|
            flag.name = "format"
            flag.long = "--format"
            flag.short = "-f"
            flag.default = "nested"
            flag.description = "Output format for diff output (nested, flat)"
          end
          cmd.run do |options, arguments|
            set_global_flags(options)
            use_stdin = options.bool["stdin"]

            file = use_stdin ? STDIN : arguments[0] as String
            client = create_client(options)

            manifest = ApiManifest.new(client)
            config = ConfigManifest.new(file)

            diff = manifest.diff(config)

            DiffApplier.new(client).apply(diff)

            nil
          end
        end

        # Dump api
        cmd.commands.add do |cmd|
          cmd.use = "dump [filename]"
          cmd.short = "Retrieve current Kong config"
          cmd.long = cmd.short

          cmd.flags.add host_flag, port_flag, https_flag, uri_flag
          cmd.flags.add do |flag|
            flag.name = "format"
            flag.long = "--format"
            flag.short = "-f"
            flag.default = "yaml"
            flag.description = "Output format for API dump (json, yaml)"
          end

          cmd.run do |options, arguments|
            filename = "STDOUT"
            format = options.string["format"]

            puts "Dumping API to #{filename}"

            client = create_client(options)
            serialized = ApiManifest.new(client).serialize

            if arguments.empty?
              puts serialized.to_pretty_json
              exit(0)
            end

            filename = arguments[0] as String
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

        # Diff api
        cmd.commands.add do |cmd|
          cmd.use = "diff [filename]"
          cmd.short = "Diff Kong instance with local config"
          cmd.long = cmd.short

          cmd.flags.add host_flag, port_flag, https_flag, uri_flag, color_flag, stdin_flag
          cmd.flags.add do |flag|
            flag.name = "format"
            flag.long = "--format"
            flag.short = "-f"
            flag.default = "nested"
            flag.description = "Output format for diff output (nested, flat)"
          end
          cmd.run do |options, arguments|
            set_global_flags(options)
            use_stdin = options.bool["stdin"]

            file = use_stdin ? STDIN : arguments[0] as String
            format = options.string["format"]

            client = create_client(options)

            manifest = ApiManifest.new(client)
            config = ConfigManifest.new(file)

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

    private def set_global_flags(options)
      $COLORIZE = !options.bool["raw"]
    end

    private def create_client(options)
      uri = URI.parse(options.string["uri"]) unless options.string["uri"].empty?

      uri ||= URI.new.tap do |uri|
        uri.scheme = options.bool["disable_https"] ? "http" : "https"
        uri.host = options.string["host"]
        uri.port = options.int["port"].to_i32
      end

      puts "Running against Kong at #{uri.host}:#{uri.port}"
      KongClient.new(uri)
    end
  end
end
