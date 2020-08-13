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

  def is_authorized?(%PrxAuth.User{} = user, resource_id, scope) do
    user.auths[to_string(resource_id)][PrxAuth.User.normalize_scope(to_string(scope))] ||
      is_globally_authorized?(user, scope)
  end

  def is_authorized?(%PrxAuth.User{} = user, resource_id, namespace, scope) do
    is_authorized?(user, resource_id, "#{namespace}:#{scope}") ||
      is_authorized?(user, resource_id, scope)
  end

  def is_globally_authorized?(%PrxAuth.User{} = user, scope) do
    user.wildcard[PrxAuth.User.normalize_scope(to_string(scope))]
  end

  def is_globally_authorized?(%PrxAuth.User{} = user, namespace, scope) do
    is_globally_authorized?(user, "#{namespace}:#{scope}") ||
      is_globally_authorized?(user, scope)
  end

  def authorized_resources(%PrxAuth.User{} = user, scope) do
    Enum.filter(Map.keys(user.auths), fn resource_id ->
      is_authorized?(user, resource_id, scope)
    end)
  end

  def authorized_resources(%PrxAuth.User{} = user, namespace, scope) do
    Enum.filter(Map.keys(user.auths), fn resource_id ->
      is_authorized?(user, resource_id, namespace, scope)
    end)
  end
end
