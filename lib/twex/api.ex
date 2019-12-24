defmodule Twex.Api do
  @moduledoc """
  Twitch API client
  """

  alias Twex.TwitchClient

  # @v5_api "https://api.twitch.tv/kraken"
  @users_url "https://api.twitch.tv/helix/users"
  @videos_url "https://api.twitch.tv/helix/videos"

  @typep parsed_response :: {[map()], nil | String.t()}

  @doc """
  Retreive JSON data on all VODs, available for specified `username` streamer.
  """
  @spec get_videos(username :: String.t()) :: [map()]
  def get_videos(username) do
    with client <- TwitchClient.get_token!(),
         user_id <- name_to_id(username, client) do
      get_videos(user_id, client, [], :start)
    end
  end

  @spec get_videos(
          user_id :: String.t(),
          client :: OAuth2.Client.t(),
          acc :: list(),
          cursor :: :start | nil | String.t()
        ) :: [map()]
  defp get_videos(_, _, videos, nil), do: videos

  defp get_videos(user_id, client, videos, cursor) do
    params =
      case cursor do
        :start -> [user_id: user_id, first: 100, type: "archive"]
        cursor -> [after: cursor, user_id: user_id, first: 100, type: "archive"]
      end

    {videos_batch, cursor} = get(client, @videos_url, params)

    get_videos(user_id, client, videos_batch ++ videos, cursor)
  end

  @spec parse_response(response :: OAuth2.Response.t()) :: parsed_response()
  defp parse_response(%OAuth2.Response{body: %{"data" => data} = body}) do
    {data, body["pagination"]["cursor"]}
  end

  @spec get(client :: OAuth2.Client.t(), url :: String.t(), params :: Keyword.t()) ::
          parsed_response()
  defp get(client, url, params) do
    client
    |> OAuth2.Client.get!(url, [], params: params)
    |> parse_response()
  end

  @spec name_to_id(username :: String.t(), client :: OAuth2.Client.t()) :: String.t()
  defp name_to_id(username, client) do
    client
    |> get(@users_url, login: username)
    |> elem(0)
    |> hd()
    |> Map.get("id")
  end
end
