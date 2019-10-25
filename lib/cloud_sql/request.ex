defmodule GCloudex.CloudSQL.Request do
  alias HTTPoison, as: HTTP
  alias HTTPoison.HTTPResponse
  alias GCloudex.Auth, as: Auth

  @moduledoc """
  Offers HTTP requests to be used in by the Google Cloud SQL wrapper.
  """

  defmacro __using__(_opts) do 
    quote do 

  	  def get_project_id() do
  	   	{:ok, client_id} = Goth.Config.get("client_email")
  	    {:ok, project_id} = Goth.Config.get(client_id, :project_id)
  		project_id
  	  end

      @doc """
      Sends a HTTP request with the given 'verb', 'headers' and 'body' to the 
      specified 'endpoint'. The authorization and google project headers are 
      added automatically.
      """
      @spec request(verb :: atom, endpoint :: binary, headers :: [{key :: binary, value :: binary}], body :: binary) :: HTTPResponse.t
      def request(verb, endpoint, headers \\ [], body \\ "") do 
        HTTP.request(
          verb,
          endpoint,
          body,
          headers ++ [{"x-goog-project-id", get_project_id()},
                      {"Authorization", "Bearer #{Auth.get_token_storage(:sql_admin)}"}],
          []
          )
      end

      @doc """
      Sends a HTTP request with the given 'verb', 'headers', 'body' and query
      'parameters' to the specified 'endpoint'. The authorization and google 
      project headers are added automatically.
      """
      @spec request_query(verb :: atom, endpoint :: binary, headers :: [{key :: binary, value :: binary}], body :: binary, parameters :: binary) :: HTTPResponse.t
      def request_query(verb, endpoint, headers \\ [], body \\ "", parameters) do 
        HTTP.request(
          verb,
          endpoint <> "/" <> parameters,
          body,
          headers ++ [{"x-goog-project-id", get_project_id()},
                      {"Authorization", "Bearer #{Auth.get_token_storage(:sql_admin)}"}],
          []
          )
      end

      defoverridable [
        request: 3,
        request: 4,
        request_query: 5
      ]
    end
  end
end