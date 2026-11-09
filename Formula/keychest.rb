class Keychest < Formula
  desc "Generate obfuscated Swift secrets from Keychain, 1Password or env vars"
  homepage "https://github.com/parth0072/keychest"
  url "https://github.com/parth0072/keychest/archive/refs/tags/v1.1.0.tar.gz"
  sha256 "27d0d618a9678fce2d77950d26f8cf73c8cad9c7a4c1caad0720d82797bf913f"
  license "MIT"
  head "https://github.com/parth0072/keychest.git", branch: "main"

  depends_on xcode: ["15.0", :build]
  depends_on :macos

  def install
    system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", "keychest"
    bin.install ".build/release/keychest"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/keychest --version")

    (testpath/".keychest.yml").write <<~YAML
      backend: env
      environments: [Debug]
      environment_secrets: [apiKey]
    YAML

    with_env("apiKeyDebug" => "brew-test-value") do
      system bin/"keychest", "generate"
      system bin/"keychest", "generate", "--platforms", "kotlin"
    end

    swift = testpath/"KeychestKeys/Sources/KeychestKeys/Secrets.swift"
    assert_path_exists swift
    refute_includes swift.read, "brew-test-value"

    kotlin = testpath/"keychest-keys/src/main/kotlin/keychest/keys/Secrets.kt"
    assert_path_exists kotlin
    refute_includes kotlin.read, "brew-test-value"
  end
end
