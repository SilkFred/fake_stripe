require 'fake_stripe/configuration'
require 'fake_stripe/initializers/webmock'
require 'fake_stripe/stub_app'
require 'fake_stripe/stub_stripe_js'

module FakeStripe
  extend Configuration

  VALID_CARD_NUMBER = '4242424242424242'
  STRIPE_OBJECTS = %w{card charge coupon customer invoice invoiceitem plan
    recipient refund subscription token transfer}.freeze
  CARD_OBJECT_TYPE = "card"
  BANK_ACCOUNT_OBJECT_TYPE = "bank_account"
  DEFAULT_API_KEY = 'FAKE_STRIPE_API_KEY'

  STRIPE_OBJECTS.each do |object|
    define_singleton_method "#{object}_count" do
      instance_variable_get("@#{object}_count")
    end

    define_singleton_method "#{object}_count=" do |count|
      instance_variable_set("@#{object}_count", count)
    end
  end

  def self.reset
    STRIPE_OBJECTS.each do |object|
      instance_variable_set("@#{object}_count", 0)
    end
  end

  def self.stub_stripe
    Stripe.api_key = ENV.fetch('STRIPE_SECRET_KEY', DEFAULT_API_KEY)
    FakeStripe.reset
    FakeStripe::StubStripeJS.boot_once
    stub_request(:any, /api.stripe.com/).to_rack(FakeStripe::StubApp)
  end
end

STRIPE_JS_HOST = "http://localhost:#{FakeStripe::StubStripeJS.server_port}"
