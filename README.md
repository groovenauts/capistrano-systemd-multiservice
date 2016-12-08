# capistrano-systemd-multiservice

This gem adds capistrano tasks to control multiple services with systemd.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'capistrano-systemd-multiservice', require: false
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano-systemd-multiservice

## Usage

Add these lines to your Capfile:

```ruby
require "capistrano/systemd/multiservice"
install_plugin Capistrano::Systemd::MultiService.new("example1")
install_plugin Capistrano::Systemd::MultiService.new("example2")
```

And put `config/systemd/example1.service.erb` (and `config/systemd/example2.service.erb`, ...) like this
(see [systemd.service(5)](https://www.freedesktop.org/software/systemd/man/systemd.service.html) for details) :

```
[Unit]
Description = <%= fetch(:application) %> application server example1

[Service]
Environment = RAILS_ENV=<%= fetch(:rails_env) %>
Environment = PWD=<%= current_path %>
WorkingDirectory = <%= current_path %>
ExecStart = bundle exec some-application-server start
User = exampleuser
Group = examplegroup

[Install]
WantedBy = multi-user.target
```

And add these lines to config/deploy.rb (if you want to reload/restart services on deploy):

```ruby
after 'deploy:publishing', 'systemd:example1:restart'
after 'deploy:publishing', 'systemd:example2:reload-or-restart'
```

And deploy.

```shell
# Install systemd service unit files before deploy
cap STAGE systemd:example1:setup systemd:example2:setup

# Deploy as usual
cap STAGE deploy
```

## Capistrano Tasks

With `install_plugin Capistrano::Systemd::MultiService.new("example1")`,
following tasks are defined.

- `systemd:example1:setup`
- `systemd:example1:remove`
- `systemd:example1:validate`
- `systemd:example1:daemon-reload`
- `systemd:example1:start`
- `systemd:example1:stop`
- `systemd:example1:reload`
- `systemd:example1:restart`
- `systemd:example1:reload-or-restart`
- `systemd:example1:enable`
- `systemd:example1:disable`

## Systemd template unit file support

TBD... (No document is better than no code, see spec/capistrano/systemd/multiservice\_spec.rb)

## Configuration Variables

With `install_plugin Capistrano::Systemd::MultiService.new("example1")`,
following Configuration variables are defined.

- `:systemd_example1_role`
- `:systemd_example1_units_src`
- `:systemd_example1_units_dir`
- `:systemd_example1_units_dest`
- `:systemd_example1_instances`
- `:systemd_example1_service`
- `:systemd_example1_instance_services`

TBD... (No document is better than no code, see lib/capistrano/systemd/multiservice.rb)

## Examples

### Rails application with unicorn and delayed\_job

TBD... (No document is better than no code)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/capistrano-systemd-multiservice.

