require 'spec_helper'

describe CSI::AWS::CloudWatch do
  it "should display information for authors" do
    authors_response = CSI::AWS::CloudWatch
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::AWS::CloudWatch
    expect(help_response).to respond_to :help
  end
end
