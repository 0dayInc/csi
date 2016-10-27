# frozen_string_literal: true
require 'spec_helper'

describe CSI::AWS::ACM do
  it "should display information for authors" do
    authors_response = CSI::AWS::ACM
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::AWS::ACM
    expect(help_response).to respond_to :help
  end
end
