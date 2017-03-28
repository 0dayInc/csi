# frozen_string_literal: true

require 'spec_helper'

describe CSI::MSF do
  it 'should return data for help method' do
    help_response = CSI::MSF.help
    expect(help_response).not_to be_nil
  end
end
