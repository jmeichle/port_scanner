require "spec_helper"

RSpec.describe PortScanner do
  it "has a version number" do
    expect(PortScanner::VERSION).not_to be nil
  end
end
