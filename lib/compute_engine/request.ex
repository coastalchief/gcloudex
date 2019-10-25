defmodule GCloudex.ComputeEngine.Request do
  alias GCloudex.Auth, as: Auth

  @moduledoc """
  
  """

  defmacro __using__(_opts) do 
    quote do 
      require Logger
	  
	  def get_project_id do
	   	{:ok, client_id} = Goth.Config.get("client_email")
	    {:ok, project_id} = Goth.Config.get(client_id, :project_id)
		project_id
	  end
	  
      @doc """
      
      """
      @spec request(verb :: atom, endpoint :: binary, headers :: [{binary, binary}], body :: binary, parameters :: binary) :: HTTPResponse.t
      def request(verb, endpoint, headers \\ [], body \\ "", parameters \\ "") do
        endpoint = 
          if parameters == "" do 
            endpoint
          else
            endpoint <> "/" <> "?" <> parameters
          end 

        HTTPoison.request(
          verb,
          endpoint,
          body,
          headers ++ [{"x-goog-project-id", get_project_id},
                      {"Authorization", "Bearer #{Auth.get_token_storage(:compute)}"}],
          []
          )
      end      

      defoverridable [request: 4, request: 5]
    end
  end
end
