require 'spec_helper'
require 'omniauth-linkedin-oauth2'

describe OmniAuth::Strategies::LinkedIn do
  subject { OmniAuth::Strategies::LinkedIn.new(nil) }

  it 'should add a camelization for itself' do
    OmniAuth::Utils.camelize('linkedin').should == 'LinkedIn'
  end

  describe '#client' do
    it 'has correct LinkedIn site' do
      subject.client.site.should eq('https://api.linkedin.com')
    end

    it 'has correct authorize url' do
      subject.client.options[:authorize_url].should eq('https://www.linkedin.com/uas/oauth2/authorization?response_type=code')
    end

    it 'has correct token url' do
      subject.client.options[:token_url].should eq('https://www.linkedin.com/uas/oauth2/accessToken')
    end
  end

  describe '#callback_path' do
    it 'has the correct callback path' do
      subject.callback_path.should eq('/auth/linkedin/callback')
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

  describe '#access_token' do
    before :each do
      subject.stub(:oauth2_access_token) { double('oauth2 access token', :expires_in => 3600, :expires_at => 946688400).as_null_object }
    end

    it { subject.access_token.expires_in.should eq(3600) }
    it { subject.access_token.expires_at.should eq(946688400) }
  end

  describe '#raw_info' do
    before :each do
      response = double('response', :parsed => { :foo => 'bar' })
      subject.stub(:access_token) { double('access token', :get => response) }
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
        subject.authorize_params['scope'].should eq('r_basicprofile r_emailaddress')
      end
    end
  end
end
