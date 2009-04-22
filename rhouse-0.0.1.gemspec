# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rhouse}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Fernand Galiana"]
  s.date = %q{2009-04-21}
  s.description = %q{Rhouse allows you to enhance your LinuxMCE home automation system using ruby. The gem builds on top of LinuxMCE( http://linuxmce.com ) and provides for taping into the it's c++ core using ruby. Using this gem, you will be able to intercept various  device events, such as lights, Tv, sensors... and take necessary action using ruby.  It packs a light web service component that allows you to control devices in your home from from anywhere around the world...}
  s.email = %q{fernand.galiana@gmail.com}
  s.executables = ["rh_console", "rh_interceptor", "rh_rhouse", "rh_send_msg", "rh_ws_client"]
  s.extra_rdoc_files = ["History.txt", "README.txt", "bin/rh_console", "bin/rh_interceptor", "bin/rh_rhouse", "bin/rh_send_msg", "bin/rh_ws_client"]
  s.files = ["History.txt", "README.txt", "Rakefile", "bin/rh_console", "bin/rh_interceptor", "bin/rh_rhouse", "bin/rh_send_msg", "bin/rh_ws_client", "config/database.yml", "config/interceptor.yml", "config/rhouse.yml", "lib/rhouse.rb", "lib/rhouse/command.rb", "lib/rhouse/error.rb", "lib/rhouse/event_listener.rb", "lib/rhouse/event_parser.rb", "lib/rhouse/logger.rb", "lib/rhouse/message_send.rb", "lib/rhouse/models.rb", "lib/rhouse/models/array.rb", "lib/rhouse/models/command.rb", "lib/rhouse/models/command_category.rb", "lib/rhouse/models/command_command_parameter.rb", "lib/rhouse/models/command_group.rb", "lib/rhouse/models/command_parameter.rb", "lib/rhouse/models/criteria_orbiter.rb", "lib/rhouse/models/design_object.rb", "lib/rhouse/models/device.rb", "lib/rhouse/models/device_category.rb", "lib/rhouse/models/device_command_group.rb", "lib/rhouse/models/device_command_group_command.rb", "lib/rhouse/models/device_data.rb", "lib/rhouse/models/device_device_data.rb", "lib/rhouse/models/device_template.rb", "lib/rhouse/models/device_template_device_command_group.rb", "lib/rhouse/models/event.rb", "lib/rhouse/models/event_category.rb", "lib/rhouse/models/event_event_parameter.rb", "lib/rhouse/models/event_parameter.rb", "lib/rhouse/models/floor_plan_object_type.rb", "lib/rhouse/models/floor_plan_type.rb", "lib/rhouse/models/icon.rb", "lib/rhouse/models/installation.rb", "lib/rhouse/models/parameter_type.rb", "lib/rhouse/models/room.rb", "lib/rhouse/models/room_type.rb", "lib/rhouse/models/template.rb", "lib/rhouse/worker.rb", "lib/rhouse/ws_client.rb", "public/.DS_Store", "public/images/.DS_Store", "public/images/RHouse1.png", "public/stylesheets/rhouse.css", "scripts/beanstalk.init.d", "spec/command_spec.rb", "spec/config/test_worker.yml", "spec/device_spec.rb", "spec/event_listener_spec.rb", "spec/event_parser_spec.rb", "spec/logger_spec.rb", "spec/message_send_spec.rb", "spec/models/command_spec.rb", "spec/models/device_spec.rb", "spec/models/event_spec.rb", "spec/rhouse_spec.rb", "spec/spec_helper.rb", "spec/worker_spec.rb", "spec/ws_client_spec.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rhouse.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake", "views/command.erb", "views/error.erb", "views/layout.erb"]
  s.has_rdoc = true
  s.homepage = %q{FIXME (project homepage)}
  s.rdoc_options = ["-SHN", "-f", "darkfish", "--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ }
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Rhouse allows you to enhance your LinuxMCE home automation system using ruby}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, ["~> 2.2.0"])
      s.add_runtime_dependency(%q<logging>, [">= 0.9.0"])
      s.add_runtime_dependency(%q<rfuzz>, [">= 0.9"])
      s.add_runtime_dependency(%q<sinatra>, ["~> 0.9.0"])
      s.add_runtime_dependency(%q<beanstalk-client>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<main>, ["~> 2.8.2"])
      s.add_development_dependency(%q<bones>, [">= 2.4.0"])
    else
      s.add_dependency(%q<activerecord>, ["~> 2.2.0"])
      s.add_dependency(%q<logging>, [">= 0.9.0"])
      s.add_dependency(%q<rfuzz>, [">= 0.9"])
      s.add_dependency(%q<sinatra>, ["~> 0.9.0"])
      s.add_dependency(%q<beanstalk-client>, ["~> 1.0.0"])
      s.add_dependency(%q<main>, ["~> 2.8.2"])
      s.add_dependency(%q<bones>, [">= 2.4.0"])
    end
  else
    s.add_dependency(%q<activerecord>, ["~> 2.2.0"])
    s.add_dependency(%q<logging>, [">= 0.9.0"])
    s.add_dependency(%q<rfuzz>, [">= 0.9"])
    s.add_dependency(%q<sinatra>, ["~> 0.9.0"])
    s.add_dependency(%q<beanstalk-client>, ["~> 1.0.0"])
    s.add_dependency(%q<main>, ["~> 2.8.2"])
    s.add_dependency(%q<bones>, [">= 2.4.0"])
  end
end
