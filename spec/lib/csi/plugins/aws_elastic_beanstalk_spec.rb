require 'spec_helper'

describe CSI::Plugins::AWSElasticBeanstalk do
  it "should display information for authors" do
    authors_response = CSI::Plugins::AWSElasticBeanstalk
    expect(authors_response).to respond_to :authors
  end

  it "should display information for existing help method" do
    help_response = CSI::Plugins::AWSElasticBeanstalk
    expect(help_response).to respond_to :help
  end
end
