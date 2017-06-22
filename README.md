# PrxAuth Elixir Package

[![Hex.pm](https://img.shields.io/hexpm/v/prx_auth.svg)](https://hex.pm/packages/prx_auth)
[![Hex.pm](https://img.shields.io/hexpm/dw/prx_auth.svg)](https://hex.pm/packages/prx_auth)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](LICENSE)

## Description

Elixir plug to verify PRX-issued JSON Web Tokens (JWTs).  If the token is missing or invalid, this plug can optionally return a 401 Unauthorized.  JWTs from a different issuer will be ignored.

JWTs are set in the request Authorization header, of the form `Authorization: Bearer THE_JWT_HERE`.  For more background on this process, see the [Rack::PrxAuth](https://github.com/PRX/rack-prx_auth#usage) project.

## Installation

Add the package as a project and app dependency in your `mix.ecs` file:

```elixir
defp deps do
  [{:prx_auth, "~> 0.0.1"}, ...]
end

def application do
  [applications: [:prx_auth, ...], ...]
end
```

## Usage

If you're using Phoenix, just add the plug to your `router.ex`:

```elixir
pipeline :authorized do
  plug PrxAuth.Plug, required: true, iss: "id.prx.org"
end
```

### Options

- `required` - Optional, default `true`

  When true, this plug will halt the conn and return a `401 Unauthorized` if authorization is missing or bad.  When false, the request will continue on with `conn.prx_user = nil`.

- `iss` - Optional, default `id.prx.org`

  The [PRX ID](https://github.com/PRX/id.prx.org) issuer to validate any JWTs against.

### PRX User

If authorization succeeds, a `%PrxAuth.User` will be set at `conn.prx_user`.  This struct can be interrogated to determine what resources/roles the user has been authorized for.

```elixir
defmodule Example.SomeController do
  def index(%{prx_user: user} = conn, _params) do
    # the user's id
    user.id # 1234

    # map of string account ids -> roles
    Map.keys(user.auths) # ["98", "76", "54"]
    user.auths["98"] # ["admin", "email", "profile"]
  end
end
```

## License

[MIT License](LICENSE)

## Contributing

1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request
