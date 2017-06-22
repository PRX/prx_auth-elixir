defmodule PrxAuth do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    children = [
      worker(PrxAuth.CertificateCache, [[name: PrxAuth.CertificateCache]])
    ]
    opts = [strategy: :one_for_one, name: PrxAuth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
