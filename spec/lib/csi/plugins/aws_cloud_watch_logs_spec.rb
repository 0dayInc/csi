require 'spec_helper'

describe CSI::Plugins::AWSCloudWatchLogs do
  it "should display information for authors" do
    authors_response = CSI::Plugins::AWSCloudWatchLogs
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::Plugins::AWSCloudWatchLogs
    expect(help_response).to respond_to :help
  end
end
