require 'spec_helper'

describe CSI::Plugins::AWSDatabaseMigrationService do
  it "should display information for authors" do
    authors_response = CSI::Plugins::AWSDatabaseMigrationService
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::Plugins::AWSDatabaseMigrationService
    expect(help_response).to respond_to :help
  end
end
