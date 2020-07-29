defmodule PrxAuth.User do

  defstruct id: nil, scopes: %{}, auths: %{}, wildcard: %{}

  @wildcard "*"

  def unpack(claims \\ %{}) do
    claims = claims
      |> Map.put_new("sub", nil)
      |> Map.put_new("aur", %{})
      |> Map.put_new("scope", "")

    # first, gather all resource ids (under aur[id] or aur[$][scope][id])
    normal_ids = claims["aur"]
      |> Map.delete("$")
      |> Map.delete("")
      |> Map.keys()
    dollar_ids = (Map.get(claims["aur"], "$") || %{})
      |> Map.values()
      |> Enum.map(&listify_strings/1)
      |> Enum.concat()
    ids = Enum.concat(normal_ids, dollar_ids)
      |> Enum.map(&stringify_numbers/1)
      |> Enum.uniq()

    # now map ids to their scopes
    auths = ids
      |> Enum.map(&aur_scopes(&1, claims["aur"]))
      |> Enum.map(&dollar_scopes(&1, Map.get(claims["aur"], "$")))
      |> Enum.map(&mapify_scopes/1)
      |> Enum.into(%{})

    # break out wildcard and struct-ify!
    %PrxAuth.User{
      id: claims["sub"],
      scopes: global_scopes(claims["scope"]),
      auths: Map.delete(auths, @wildcard),
      wildcard: Map.get(auths, @wildcard, %{})
    }
  end

  defp listify_strings("" <> scopes), do: String.split(scopes)
  defp listify_strings(scopes), do: scopes

  defp stringify_numbers(num) when is_integer(num), do: Integer.to_string(num)
  defp stringify_numbers(str), do: str

  defp mapify_scopes({id, scopes}) do
    {
      id,
      scopes |> Enum.map(fn(s) -> {s, true} end) |> Enum.into(%{})
    }
  end

  defp global_scopes(scopes) do
    listify_strings(scopes || "") |> Enum.map(fn(s) -> {s, true} end) |> Enum.into(%{})
  end

  defp aur_scopes(id, aur) do
    aur_scopes = Map.to_list(aur)
      |> Enum.map(fn({id, scopes}) -> {stringify_numbers(id), scopes} end)
      |> Enum.into(%{})
      |> Map.get(id)
    {id, listify_strings(aur_scopes || [])}
  end

  defp dollar_scopes(auth, nil), do: auth
  defp dollar_scopes({id, scopes}, dollar) do
    xtra_scopes = Enum.reduce(Map.to_list(dollar), [], fn {key, val}, acc ->
      if in_scope(val, id) do
        acc ++ listify_strings(key)
      else
        acc
      end
    end)

    {id, scopes ++ xtra_scopes}
  end

  defp in_scope(ids, id) do
    listify_strings(ids) |> Enum.map(&stringify_numbers/1) |> Enum.member?(stringify_numbers(id))
  end
end
