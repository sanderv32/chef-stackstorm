# TODO: support customizable workers, default to 10 via package
default['stackstorm']['action_runners'] = 10

# The roles attribute should be specifically defined.
default['stackstorm']['roles'] = []
default['stackstorm']['on_config_update'] = :restart

# Will be populated automaticaly when roles use, unless overrided.
default['stackstorm']['components'] = %w(st2common)
default['stackstorm']['service_binary'] = {}

default['stackstorm']['component_provides'] = {
  st2actions: %w(st2actionrunner st2resultstracker st2notifier),
  st2api: %w(st2api),
  st2reactor: %w(st2rulesengine st2sensorcontainer)
}

# It's recommended to use the install_repo
default['stackstorm']['install_repo']['suite'] = 'stable'
default['stackstorm']['install_repo']['packages'] = %w(st2)
