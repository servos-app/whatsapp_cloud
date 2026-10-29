require_relative "lib/whatsapp_cloud/version"

Gem::Specification.new do |spec|
  spec.name = "whatsapp_cloud"
  spec.version = WhatsappCloud::VERSION
  spec.authors = ["SERVOS"]
  spec.email = ["a@asgerbehnckejacobsen.dk"]

  spec.summary = "Ruby client for Meta's WhatsApp Cloud API, for Tech Providers"
  spec.description = "Onboards a business through Embedded Signup (code exchange, granted accounts, webhook " \
    "subscription, number registration) and verifies Meta's signed webhooks. Plain Ruby, no runtime dependencies."
  spec.homepage = "https://github.com/servos-app/whatsapp_cloud"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.4"

  spec.files = Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]
end
