defmodule PrxAuth.UserTest do
  use ExUnit.Case, async: true

  import PrxAuth.User

  test "decodes claims" do
    user =
      unpack(%{
        "sub" => 1234,
        "scope" => "profile email",
        "aur" => %{
          "" => %{},
          "123" => "foo bar",
          "456" => "something admin",
          "$" => %{"admin foo:bar" => [456, 789]}
        }
      })

    assert user.id == 1234
    assert Map.keys(user.auths) == ["123", "456", "789"]
    assert user.auths["123"]["bar"] == true
    assert Map.keys(user.auths["123"]) == ["bar", "foo"]
    assert Map.keys(user.auths["456"]) == ["admin", "foo:bar", "something"]
    assert Map.keys(user.auths["789"]) == ["admin", "foo:bar"]
    assert Map.keys(user.wildcard) == []
  end

  test "defaults lack of claims data" do
    user = unpack(%{})
    assert user.id == nil
    assert user.auths == %{}
  end

  test "handles $ only" do
    user =
      unpack(%{
        "scope" => "email",
        "aur" => %{
          "$" => %{
            "admin" => [123, "456"],
            "read" => "123 789"
          }
        }
      })

    assert Map.keys(user.auths) == ["123", "456", "789"]
    assert Map.keys(user.auths["123"]) == ["admin", "read"]
    assert Map.keys(user.auths["456"]) == ["admin"]
    assert Map.keys(user.auths["789"]) == ["read"]
  end

  test "handles aur only" do
    user =
      unpack(%{
        "aur" => %{
          "123" => "some stuff"
        }
      })

    assert Map.keys(user.auths) == ["123"]
    assert Map.keys(user.auths["123"]) == ["some", "stuff"]
  end

  test "extracts wildcards" do
    user =
      unpack(%{
        "sub" => 1234,
        "scope" => "profile",
        "aur" => %{
          "*" => "",
          "123" => "foo",
          "$" => %{"admin foo:bar" => [123, "*"]}
        }
      })

    assert Map.keys(user.auths) == ["123"]
    assert Map.keys(user.auths["123"]) == ["admin", "foo", "foo:bar"]
    assert Map.keys(user.wildcard) == ["admin", "foo:bar"]
  end

  test "extracts global scopes" do
    user =
      unpack(%{
        "sub" => 1234,
        "scope" => "profile email"
      })

    assert Map.keys(user.scopes) == ["email", "profile"]
    assert user.scopes["email"] == true
    assert user.scopes["profile"] == true
  end

  test "normalizes scopes" do
    user =
      unpack(%{
        "sub" => 1234,
        "aur" => %{
          "123" => "The-End"
        }
      })

    assert user.auths["123"]["the_end"]
  end
end
