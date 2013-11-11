# coding: utf-8
namespace :puma do

  desc "Start puma instance for this application"
  task :start do
    on roles fetch(:puma_roles) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          execute :bundle, "exec puma -b '#{puma_socket}'",
            " -e #{stage} ",
            "--control '#{pumactl_socket}'",
            "-S #{puma_state}",
            fetch(:puma_flags),
            ">> #{puma_log} 2>&1 &"
        end
      end
    end
  end

  desc "Stop puma instance for this application"
  task :stop do
    on roles fetch(:puma_roles) do
      within release_path do
        execute :bundle, "exec pumactl -S #{puma_state} stop"
      end
    end
  end

  desc "Restart puma instance for this application"
  task :restart do
    on roles fetch(:puma_roles) do
      within release_path do
        execute :bundle, "exec pumactl -S #{puma_state} restart"
      end
    end
  end

  desc "Show status of puma for this application"
  task :status do
    on roles fetch(:puma_roles) do
      within release_path do
        execute :bundle, "exec pumactl -S #{puma_state} stats"
      end
    end
  end

  desc "Show status of puma for all applications"
  task :overview do
    on roles fetch(:puma_roles) do
      within release_path do
        execute :bundle, "exec puma status"
      end
    end
  end

end

namespace :load do
  task :defaults do
    set :sockets_path, -> { shared_path.join('tmp/sockets/') }
    set :puma_roles, -> { :app }
    set :puma_socket, -> { "unix://#{sockets_path.join('puma.sock')}" }
    set :pumactl_socket, -> { "unix://#{sockets_path.join('pumactl.sock')}" }
    set :puma_state, -> { sockets_path.join('puma.state') }
    set :puma_log, -> { shared_path.join("log/puma-#{stage}.log") }
    set :puma_flags, -> { nil }
  end
end
