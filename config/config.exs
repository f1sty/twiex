import Config

config :twex, Twex.TwitchClient,
  client_id: System.get_env("TW_CLIENT_ID"),
  client_secret: System.get_env("TW_CLIENT_SECRET")

# config :oauth2, debug: true
