class Keychest < Formula
  desc "Generate obfuscated Swift secrets from Keychain, 1Password or env vars"
  homepage "https://github.com/parth0072/keychest"
  url "https://github.com/parth0072/keychest/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "0075a7ff44e5ba55084c319c389f4f02f23876bbe2e595697fde8f46403351b5"
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
    end

    generated = testpath/"KeychestKeys/Sources/KeychestKeys/Secrets.swift"
    assert_path_exists generated
    refute_includes generated.read, "brew-test-value"
  end
end
