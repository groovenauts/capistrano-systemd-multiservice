# This trick lets us access the Capistrano::Systemd::MultiService plugin within `on` blocks
svc = self

namespace :systemd do
  namespace svc.nsp do
    {
      setup:                "Setup %{app} systemd unit file",
      remove:               "Remove %{app} systemd unit file",
      validate:             "Validate %{app} systemd unit file",
      "daemon-reload":      "Run systemctl daemon-reload",
      start:                "Run systemctl %{task_name} for %{app}",
      stop:                 "Run systemctl %{task_name} for %{app}",
      reload:               "Run systemctl %{task_name} for %{app}",
      restart:              "Run systemctl %{task_name} for %{app}",
      "reload-or-restart":  "Run systemctl %{task_name} for %{app}",
      enable:               "Run systemctl %{task_name} for %{app}",
      disable:              "Run systemctl %{task_name} for %{app}",
    }.each do |task_name, desc_template|
      desc(desc_template % { app: svc.app, task_name: task_name})
      task task_name do
        on roles(fetch(:"#{svc.prefix}_role")) do
          svc.__send__ task_name.to_s.tr('-', '_')
        end
      end
    end
  end
end

