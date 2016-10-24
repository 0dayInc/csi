require 'spec_helper'

describe CSI::AWS::Route53 do
  it "should display information for authors" do
    authors_response = CSI::AWS::Route53
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::AWS::Route53
    expect(help_response).to respond_to :help
  end
end
