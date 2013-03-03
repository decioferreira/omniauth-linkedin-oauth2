require 'spec_helper'
require 'omniauth-linkedin-oauth2'

describe OmniAuth::Strategies::LinkedInOAuth2 do
  subject { OmniAuth::Strategies::LinkedInOAuth2.new(nil) }

  it 'should add a camelization for itself' do
    OmniAuth::Utils.camelize('linkedin_oauth2').should == 'LinkedInOAuth2'
  end

  describe '#client' do
    it 'has correct LinkedIn site' do
      subject.client.site.should eq('https://www.linkedin.com')
    end

    it 'has correct authorize url' do
      subject.client.options[:authorize_url].should eq('/uas/oauth2/authorization?response_type=code')
    end

    it 'has correct token url' do
      subject.client.options[:token_url].should eq('/uas/oauth2/accessToken')
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      subject.callback_path.should eq('/auth/linkedin_oauth2/callback')
    end
  end

  describe '#authorize_params' do
    describe 'scope' do
      it 'sets default scope' do
        subject.stub(:session => {})
        subject.authorize_params['scope'].should eq('r_fullprofile r_emailaddress r_network')
      end
    end
  end
end
