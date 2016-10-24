require 'spec_helper'

describe CSI::AWS do
  it "should return data for help method" do
    help_response = CSI::AWS.help
    expect(help_response).not_to be_nil
  end
end
