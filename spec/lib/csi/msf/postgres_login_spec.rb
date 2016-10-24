require 'spec_helper'

describe CSI::MSF::PostgresLogin do
  it "exploit method should exist" do
    exploit_response = CSI::MSF::PostgresLogin
    expect(exploit_response).to respond_to :exploit
  end

  it "should display information for nist_800_53_requirements" do
    nist_800_53_requirements_response = CSI::MSF::PostgresLogin
    expect(nist_800_53_requirements_response).to respond_to :nist_800_53_requirements
  end

  it "should display information for authors" do
    authors_response = CSI::MSF::PostgresLogin
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::MSF::PostgresLogin
    expect(help_response).to respond_to :help
  end
end
