defmodule Twex.TwitchClient do
  @moduledoc false

  use OAuth2.Strategy

  @config Application.get_env(:twex, __MODULE__)

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: @config[:client_id],
      client_secret: @config[:client_secret],
      redirect_url: "http://localhost/auth/call",
      site: "https://id.twitch.tv",
      authorize_url: "/oauth2/authorize",
      token_url: "/oauth2/token"
    ])
    |> OAuth2.Client.put_serializer("application/json", Jason)
  end

  def authorize_url! do
    OAuth2.Client.authorize_url!(client(), scope: "channel_read user:read:broadcast")
  end

  def get_token!(params \\ [], headers \\ [], opts \\ []) do
    OAuth2.Client.get_token!(client(), params, headers, opts)
  end

  @impl true
  def authorize_url(_client, _params) do
    raise OAuth2.Error, reason: "This strategy does not implement `authorize_url`."
  end

  @impl true
  def get_token(client, params, headers) do
    client
    |> put_param(:grant_type, "client_credentials")
    |> put_param(:client_id, client.client_id)
    |> put_param(:client_secret, client.client_secret)
    |> merge_params(params)
    |> put_headers(headers)
  end
end
