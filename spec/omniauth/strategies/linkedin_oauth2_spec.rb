require 'spec_helper'
require 'omniauth-linkedin-oauth2'

describe OmniAuth::Strategies::LinkedIn do
  let(:request) { double('Request', :params => {}, :cookies => {}, :env => {}) }
  let(:app) {
    lambda do
      [200, {}, ["Hello."]]
    end
  }

  subject do
    OmniAuth::Strategies::LinkedIn.new(app, 'appid', 'secret', @options || {}).tap do |strategy|
      strategy.stub(:request) {
        request
      }
    end
  end

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

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

  describe '#raw_info' do
    before :each do
      response = double('response', :parsed => { :foo => 'bar' })
      subject.stub(:access_token) { double('access token', :get => response) }
    end

    it 'returns parsed response from access token' do
      subject.raw_info.should eq({ :foo => 'bar' })
    end
  end

  describe "#authorize_options" do
    [:scope, :state].each do |k|
      it "should support #{k}" do
        @options = {k => 'http://someval'}
        subject.authorize_params[k.to_s].should eq('http://someval')
      end
    end

    describe 'redirect_uri' do
      it 'should default to nil' do
        @options = {}
        subject.authorize_params['redirect_uri'].should eq(nil)
      end

      it 'should set the redirect_uri parameter if present' do
        @options = {:redirect_uri => 'https://example.com'}
        subject.authorize_params['redirect_uri'].should eq('https://example.com')
      end
    end

    describe 'scope' do
      it 'should set default scope to r_basicprofile r_emailaddress' do
        subject.authorize_params['scope'].should eq('r_basicprofile r_emailaddress')
      end
    end

    describe 'state' do
      it 'should set the state parameter' do
        @options = {:state => 'some_state'}
        subject.authorize_params['state'].should eq('some_state')
        subject.session['omniauth.state'].should eq('some_state')
      end

      it 'should set the omniauth.state dynamically' do
        subject.stub(:request) { double('Request', {:params => {'state' => 'some_state'}, :env => {}}) }
        subject.authorize_params['state'].should eq('some_state')
        subject.session['omniauth.state'].should eq('some_state')
      end
    end

    describe "overrides" do
      it 'should include top-level options that are marked as :authorize_options' do
        @options = {:authorize_options => [:scope, :foo, :request_visible_actions], :scope => 'http://bar', :foo => 'baz', :hd => "wow", :request_visible_actions => "something"}
        subject.authorize_params['scope'].should eq('http://bar')
        subject.authorize_params['foo'].should eq('baz')
        subject.authorize_params['hd'].should eq(nil)
        subject.authorize_params['request_visible_actions'].should eq('something')
      end

      describe "request overrides" do
        [:scope, :state].each do |k|
          context "authorize option #{k}" do
            let(:request) { double('Request', :params => {k.to_s => 'http://example.com'}, :cookies => {}, :env => {}) }

            it "should set the #{k} authorize option dynamically in the request" do
              @options = {k => ''}
              subject.authorize_params[k.to_s].should eq('http://example.com')
            end
          end
        end

        describe "custom authorize_options" do
          let(:request) { double('Request', :params => {'foo' => 'something'}, :cookies => {}, :env => {}) }

          it "should support request overrides from custom authorize_options" do
            @options = {:authorize_options => [:foo], :foo => ''}
            subject.authorize_params['foo'].should eq('something')
          end
        end
      end
    end
  end
end
