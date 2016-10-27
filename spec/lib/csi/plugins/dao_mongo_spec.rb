# frozen_string_literal: true
require 'spec_helper'

describe CSI::Plugins::DAOMongo do
  it 'should display information for authors' do
    authors_response = CSI::Plugins::DAOMongo
    expect(authors_response).to respond_to :authors
  end

  it 'should display information for existing help method' do
    help_response = CSI::Plugins::DAOMongo
    expect(help_response).to respond_to :help
  end
end
