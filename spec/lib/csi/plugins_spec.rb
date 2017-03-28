# frozen_string_literal: true

require 'spec_helper'

describe CSI::Plugins do
  it 'should return data for help method' do
    help_response = CSI::Plugins.help
    expect(help_response).not_to be_nil
  end
end
