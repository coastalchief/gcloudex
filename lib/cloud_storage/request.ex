defmodule GCloudex.CloudStorage.Request do
  alias HTTPoison, as: HTTP
  alias HTTPoison.HTTPResponse
  alias GCloudex.Auth, as: Auth

  @moduledoc """
  Offers HTTP requests to be used in by the Google Cloud Storage wrapper.
  """

  defmacro __using__(_opts) do 
    quote do

      @endpoint "storage.googleapis.com"
	  
	  def get_project_id() do
	   	{:ok, client_id} = Goth.Config.get("client_email")
	   	{:ok, project_id} = Goth.Config.get(client_id, :project_id)
		project_id
	  end

      @doc"""
      Sends an HTTP request according to the Service resource in the Google Cloud
      Storage documentation.
      """
      @spec request_service :: HTTPResponse.t
      def request_service do
        HTTP.request(
          :get,
          @endpoint,
          "",
          [
            {"x-goog-project-id", get_project_id()},
            {"Authorization", "Bearer #{Auth.get_token_storage(:full_control)}"}
          ],
          []
        )
      end

      @doc"""
      Sends an HTTP request without any query parameters.
      """
      @spec request(atom, binary, list(tuple), binary) :: HTTPResponse.t
      def request(verb, bucket, headers \\ [], body \\ "") do
        HTTP.request(
          verb,
          bucket <> "." <> @endpoint,
          body,
          headers ++ [{"Authorization",
                       "Bearer #{Auth.get_token_storage(:full_control)}"}],
          []
        )
      end

      @doc"""
      Sends an HTTP request with the specified query parameters.
      """
      @spec request_query(atom, binary, list(tuple), binary, binary) :: HTTPResponse.t
      def request_query(verb, bucket, headers \\ [], body \\ "", parameters) do
        HTTP.request(
          verb,
          bucket <> "." <> @endpoint <> "/" <> parameters,
          body,
          headers ++ [{"Authorization",
                       "Bearer #{Auth.get_token_storage(:full_control)}"}],
          [timeout: 50_000, recv_timeout: 50_000]
        )
      end

      defoverridable [
        request_service: 0, 
        request: 3,
        request: 4, 
        request_query: 5
      ]
    end
  end
end
