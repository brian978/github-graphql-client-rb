# frozen_string_literal: true

require "./spec/spec_helper"

RSpec.describe Github::Http::Client do
  describe ".new" do
    context "when the arguments are passed correctly" do
      it "will initialise the object" do
        obj = described_class.new("something", Github::Http::Client::ENDPOINT)

        expect(obj).to be_a(described_class)
      end
    end
  end
end
