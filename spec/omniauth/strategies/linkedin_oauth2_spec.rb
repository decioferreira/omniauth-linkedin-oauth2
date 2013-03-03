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

  describe '#uid' do
    before :each do
      subject.stub(:raw_info) { { 'id' => 'uid' } }
    end

    it 'returns the id from raw_info' do
      subject.uid.should eq('uid')
    end
  end

  describe '#info' do
    before :each do
      subject.stub(:raw_info) { {} }
    end

    context 'and therefore has all the necessary fields' do
      it { subject.info.should have_key :name }
      it { subject.info.should have_key :email }
      it { subject.info.should have_key :nickname }
      it { subject.info.should have_key :first_name }
      it { subject.info.should have_key :last_name }
      it { subject.info.should have_key :location }
      it { subject.info.should have_key :description }
      it { subject.info.should have_key :image }
      it { subject.info.should have_key :urls }
    end
  end

  describe '#extra' do
    before :each do
      subject.stub(:raw_info) { { :foo => 'bar' } }
    end

    it { subject.extra['raw_info'].should eq({ :foo => 'bar' }) }
  end

  describe '#raw_info' do
    before :each do
      response = double('response', :parsed => { :foo => 'bar' })
      subject.stub(:linkedin_access_token) { double('access token', :get => response) }
    end

    it 'returns parsed response from access token' do
      subject.raw_info.should eq({ :foo => 'bar' })
    end
  end

  describe '#authorize_params' do
    describe 'scope' do
      before :each do
        subject.stub(:session => {})
      end

      it 'sets default scope' do
        subject.authorize_params['scope'].should eq('r_fullprofile r_emailaddress r_network')
      end
    end
  end
end
