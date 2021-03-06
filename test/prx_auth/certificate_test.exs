defmodule PrxAuth.CertificateTest do
  use PrxAuth.HttpCase

  import PrxAuth.Certificate

  setup do
    PrxAuth.CertificateCache.cache_clear()
    on_exit fn -> PrxAuth.CertificateCache.cache_clear() end
    []
  end

  test "gets certificates from the default location" do
    with_http %{certificates: %{one: "foobar"}} do
      assert fetch() == "foobar"
      assert called HTTPoison.get("https://id.prx.org/api/v1/certs", :_, :_)
    end
  end

  test "gets from a custom location" do
    with_http %{certificates: %{one: "foobar"}} do
      assert fetch("http://foo.bar/certs") == "foobar"
      assert called HTTPoison.get("http://foo.bar/certs", :_, :_)
    end
  end

  test "gets the first certificate sorting by keys" do
    with_http "{\"certificates\":{\"2\":\"second\",\"1\":\"first\"}}" do
      assert fetch() == "first"
    end
  end

  test "caches cert responses" do
    with_http_fn (fn() -> %{certificates: %{one: UUID.uuid4()}} end) do
      val1 = fetch()
      assert fetch() == val1
      assert fetch() == val1
      PrxAuth.CertificateCache.cache_clear()
      assert fetch() != val1
    end
  end

  test "throws errors when cert not found" do
    with_http %{} do
      try do
        fetch("http://some.where/foobar")
        flunk("should have thrown an error")
      rescue
        e in RuntimeError ->
          assert e.message =~ ~r/no certificates in/i
      end
    end
  end
end
