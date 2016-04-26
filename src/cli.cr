require "commander"
require "./biplane"

$COLORIZE = true

include Biplane
include Mixins::Paint

# Helper methods

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

private def read_env_file(options)
  env_file = options.string["env_file"]

  return {} of String => String if env_file.empty?

  case env_file
  when .ends_with?(".ini")
    EnvTranspose.transpose_ini_file(env_file)
  when .ends_with?(".json")
    EnvTranspose.transpose_json_file(env_file)
  else
    puts paint("Env var file must be a .json or .ini file.", :red)
    exit(1)
  end
rescue e : Errno
  puts paint("Env var file not found: '#{env_file}' does not exist.", :red)
  exit(1)
end

# Read config file
setup = Setup.new

# Define reusable flags
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

env_flag = Commander::Flag.new do |flag|
  flag.name = "env_file"
  flag.short = "-e"
  flag.long = "--env-file"
  flag.default = ""
  flag.description = "File to load env vars from (JSON or INI formats allowed)"
end

# Commander CLI definition
cmd = Commander::Command.new do |cmd|
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
    cmd.use = "apply [hash] <filename>"
    cmd.short = "Apply config to Kong instance"
    cmd.long = cmd.short

    cmd.flags.add host_flag, port_flag, https_flag, uri_flag, color_flag, stdin_flag, env_flag

    cmd.flags.add do |flag|
      flag.name = "format"
      flag.long = "--format"
      flag.short = "-F"
      flag.default = "nested"
      flag.description = "Output format for diff output (nested, flat)"
    end
    cmd.flags.add do |flag|
      flag.name = "checksum"
      flag.long = "--checksum"
      flag.short = "-c"
      flag.default = ""
      flag.description = "Checksum from diff, required for apply"
    end
    cmd.flags.add do |flag|
      flag.name = "force"
      flag.long = "--force"
      flag.short = "-f"
      flag.default = false
      flag.description = "Force apply without a checksum"
    end
    cmd.run do |options, arguments|
      set_global_flags(options)
      use_stdin = options.bool["stdin"] || arguments.size == 0
      checksum = options.string["checksum"]
      force = options.bool["force"]

      context = read_env_file(options)

      if checksum.empty? && !force
        puts paint("Must provide checksum.", :red)
        exit(1)
      end

      file = use_stdin ? STDIN : arguments[0] as String

      client = create_client(options)
      manifest = ApiManifest.new(client)
      config = ConfigManifest.new(file)

      diff = manifest.diff(config)
      diff_check = DiffHash.new(diff)

      if force || diff_check.equals?(checksum)
        DiffApplier.new(client).apply(diff)
      else
        puts paint("Given checksum (#{checksum}) does not equal checksum of current diff (#{diff_check.hash}).\nPlease run `diff` command again then re-run `apply` with new checksum.", :red)
        exit(1)
      end

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

    cmd.flags.add host_flag, port_flag, https_flag, uri_flag, color_flag, stdin_flag, env_flag
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

      context = read_env_file(options)
      config_yaml = Interpolate.new(file).apply(context)
      puts config_yaml

      manifest = ApiManifest.new(client)
      config = ConfigManifest.from_yaml(config_yaml)

      diff = manifest.diff(config)

      Printer.new(diff, format).print
      DiffHash.new(diff).print unless diff.empty?

      nil
    end
  end
end

Commander.run(cmd, ARGV)
