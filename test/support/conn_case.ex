defmodule PrxAuth.ConnCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      import Plug.Conn
    end
  end

  setup _tags do
    {:ok, conn: Plug.Adapters.Test.Conn.conn(%Plug.Conn{}, :get, "/", nil)}
  end
end
