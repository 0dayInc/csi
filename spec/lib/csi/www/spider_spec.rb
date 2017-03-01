# frozen_string_literal: true
require 'spec_helper'

describe CSI::WWW::Spider do
  it 'should display information for authors' do
    authors_response = CSI::WWW::Spider
    expect(authors_response).to respond_to :authors
  end

  it 'should display information for existing help method' do
    help_response = CSI::WWW::Spider
    expect(help_response).to respond_to :help
  end
end
