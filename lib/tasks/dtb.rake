namespace :dtb do
  class DTBShell
    require "thor"
    attr_reader :sh

    def initialize
      @sh = Thor.new
    end

    def warn_file_existance(filename)
      return false unless File.exists?(filename)

      sh.say_status "ignore", "already exists #{filename}", :yellow
      return true
    end

    def create_file_from_template(dest_path, binding)
      template = ERB.new(File.open(dest_path + ".template").read, nil, "-")

      begin
        File.open(dest_path, "w", 0600) do |file|
          file.write(template.result(binding))
        end
        sh.say_status "ok", "create #{dest_path}", :green
      rescue StandardError => e
        sh.say_status "failed", "#{e.message.split(' @').first} #{dest_path}", :red
      end
    end
  end

  task :install => [:install_application_settings, :install_secrets, :install_scripts]

  task :install_application_settings do
    engine = DTBShell.new
    sh = engine.sh
    path = "config/application_settings.yml"

    sh.say_status "info", "Setting up #{path}..."
    next if engine.warn_file_existance(path)

    # setup variables required in template
    config = {
      description:   "This file is created by bundle exec rake dtb:install_application_settings.",
      toggl_token:   sh.ask("Toggl API token:")
    }

    engine.create_file_from_template(path, binding)
  end

  task :install_secrets do
    engine = DTBShell.new
    sh = engine.sh
    path = "config/secrets.yml"

    sh.say_status "info", "Setting up #{path}..."
    next if engine.warn_file_existance(path)

    # setup variables required in template
    config = {
      secret_key_base: SecureRandom.hex(64)
    }
    engine.create_file_from_template(path, binding)
  end

  task :install_scripts do
    engine = DTBShell.new
    sh = engine.sh

    path = "lib/file_history_scripts/get_number_of_focused_window"

    sh.say_status "info", "Setting up #{path}..."
    next if engine.warn_file_existance(path)

    begin
      `g++ -w -o #{path} -framework ApplicationServices #{path}.cc`
      sh.say_status "ok", "create #{path}", :green
    rescue StandardError => e
      sh.say_status "failed", "#{e.message.split(' @').first} #{path}", :red
    end
  end
end
