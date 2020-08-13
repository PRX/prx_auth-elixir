defmodule PrxAuthTest do
  use ExUnit.Case, async: true

  import PrxAuth

  def mkuser(resource_id, scopes) do
    PrxAuth.User.unpack(%{
      "sub" => 1234,
      "scope" => "profile email",
      "aur" => %{ resource_id => scopes }
    })
  end

  test "is_authorized? queries user for scope" do
    user = mkuser("123", "foo bar")
    
    assert is_authorized?(user, "123", :foo)
    assert is_authorized?(user, "123", :bar)
    
    refute is_authorized?(user, "123", :baz)
    refute is_authorized?(user, "456", :foo)
  end

  test "is_authorized? matches namespaced and unnamespaced queries" do
    user = mkuser("123", "foo ns1:bar")
    
    assert is_authorized?(user, "123", :foo)
    assert is_authorized?(user, "123", :ns1, :bar)

    assert is_authorized?(user, "123", :ns1, :foo)
    assert is_authorized?(user, "123", :ns2, :foo)

    refute is_authorized?(user, "123", :bar)
    refute is_authorized?(user, "123", :ns2, :bar)
  end

  test "is_authorized? matches wildcard resources" do
    user = mkuser("*", "foo ns1:bar")
    
    assert is_authorized?(user, "notintoken", :foo)
    assert is_authorized?(user, "atleastbyname", :ns1, :bar)

    refute is_authorized?(user, "lastone", :baz)
  end

  test "is_globally_authorized? matches wildcard resources" do
    user = mkuser("*", "foo ns1:bar")
    
    assert is_globally_authorized?(user, :foo)
    assert is_globally_authorized?(user, :ns1, :bar)
    refute is_globally_authorized?(user, :baz)
  end

  test "authorized_resources finds matching resource ids" do
    user = mkuser("123", "foo ns1:bar")
    assert authorized_resources(user, :foo) == ["123"]
    assert authorized_resources(user, :ns1, :bar) == ["123"]

    user = mkuser("456", "foo ns1:bar")
    assert authorized_resources(user, :ns2, :foo) == ["456"]

    user = mkuser("*", "foo")
    assert authorized_resources(user, :foo) == []
  end

end