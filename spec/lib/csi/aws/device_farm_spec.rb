# frozen_string_literal: true
require 'spec_helper'

describe CSI::AWS::DeviceFarm do
  it "should display information for authors" do
    authors_response = CSI::AWS::DeviceFarm
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::AWS::DeviceFarm
    expect(help_response).to respond_to :help
  end
end
