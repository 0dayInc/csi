# frozen_string_literal: true
require 'spec_helper'

describe CSI::AWS::DynamoDB do
  it 'should display information for authors' do
    authors_response = CSI::AWS::DynamoDB
    expect(authors_response).to respond_to :authors
  end

  it 'should display information for existing help method' do
    help_response = CSI::AWS::DynamoDB
    expect(help_response).to respond_to :help
  end
end
