if ENV['RACK_ENV'] == 'development'
  worker_processes 1
else
  worker_processes 4
  timeout 30
end

preload_app true
