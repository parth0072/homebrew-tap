class Keychest < Formula
  desc "Generate obfuscated Swift and Kotlin secrets from Keychain, 1Password or env"
  homepage "https://github.com/parth0072/keychest"
  url "https://github.com/parth0072/keychest/releases/download/v1.1.0/keychest-1.1.0-macos-universal.tar.gz"
  sha256 "9d00a55b1fc69052029f843730c5866a92361f1ce226cfbaad024a7b873d0588"
  license "MIT"

  # `brew install --HEAD` builds from source and needs Xcode; the release download does not.
  head "https://github.com/parth0072/keychest.git", branch: "main" do
    depends_on xcode: ["15.0", :build]
  end

  depends_on macos: :monterey

  def install
    if build.head?
      system "swift", "build", "--disable-sandbox", "--configuration", "release", "--product", "keychest"
      bin.install ".build/release/keychest"
    else
      bin.install "keychest"
    end
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
