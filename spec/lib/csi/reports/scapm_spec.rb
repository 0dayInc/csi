require 'spec_helper'

describe CSI::Reports::SCAPM do
  it "should display information for authors" do
    authors_response = CSI::Reports::SCAPM
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::Reports::SCAPM
    expect(help_response).to respond_to :help
  end
end
