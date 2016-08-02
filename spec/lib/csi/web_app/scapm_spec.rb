require 'spec_helper'

describe CSI::WebApp::SCAPM do
  it "should display information for authors" do
    authors_response = CSI::WebApp::SCAPM
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::WebApp::SCAPM
    expect(help_response).to respond_to :help
  end
end
