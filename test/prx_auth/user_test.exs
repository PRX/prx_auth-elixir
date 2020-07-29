defmodule PrxAuth.UserTest do
  use ExUnit.Case, async: true

  import PrxAuth.User

  test "decodes claims" do
    user = unpack(%{
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
    assert Map.keys(user.auths["123"]) == ["bar", "email", "foo", "profile"]
    assert Map.keys(user.auths["456"]) == ["admin", "email", "foo:bar", "profile", "something"]
    assert Map.keys(user.auths["789"]) == ["admin", "email", "foo:bar", "profile"]
    assert Map.keys(user.wildcard) == []
  end

  test "defaults lack of claims data" do
    user = unpack(%{})
    assert user.id == nil
    assert user.auths == %{}
  end

  test "handles $ only" do
    user = unpack(%{
      "scope" => "email",
      "aur" => %{
        "$" => %{
          "admin" => [123, "456"],
          "read" => "123 789"
        }
      }
    })
    assert Map.keys(user.auths) == ["123", "456", "789"]
    assert Map.keys(user.auths["123"]) == ["admin", "email", "read"]
    assert Map.keys(user.auths["456"]) == ["admin", "email"]
    assert Map.keys(user.auths["789"]) == ["email", "read"]
  end

  test "handles aur only" do
    user = unpack(%{
      "aur" => %{
        "123" => "some stuff",
      }
    })
    assert Map.keys(user.auths) == ["123"]
    assert Map.keys(user.auths["123"]) == ["some", "stuff"]
  end

  test "extracts wildcards" do
    user = unpack(%{
      "sub" => 1234,
      "scope" => "profile",
      "aur" => %{
        "*" => "",
        "123" => "foo",
        "$" => %{"admin foo:bar" => [123, "*"]}
      }
    })

    assert Map.keys(user.auths) == ["123"]
    assert Map.keys(user.auths["123"]) == ["admin", "foo", "foo:bar", "profile"]
    assert Map.keys(user.wildcard) == ["admin", "foo:bar", "profile"]
  end
end
