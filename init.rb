require "heroku/command/base"

class Heroku::Command::SharedConfig < Heroku::Command::Base

  # sharedconfig:set KEY=VALUE
  #
  # set the value of a shared config var
  #
  def set
    unless args.size == 1
      error("Usage: heroku sharedconfig:set KEY=VALUE")
    end

    key, value = args.first.split('=')

    if key.nil? || value.nil?
      error("Usage: heroku sharedconfig:set KEY=VALUE")
    end

    attachment =  api.get_attachments(app).body.find {|a| a['config_var'] == key }
    resource_name = attachment['resource']['name']

    if attachment.nil?
      error "#{key} is not a shared config var"
    end

    client = RestClient::Resource.new(
      "https://sharedconfig.herokuapp.com/set",
      #"http://localhost:3000/set",
      user: Heroku::Auth.user,
      password: Heroku::Auth.password
    )

    action("Setting shared config vars and restarting all apps") do
      client[resource_name].post value
    end
  end
end
