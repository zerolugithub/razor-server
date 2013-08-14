require_relative '../spec_helper'
require_relative '../../app'

describe "create policy command" do
  include Rack::Test::Methods

  let(:app) { Razor::App }

  context "/api/create_policy" do
    before :each do
      use_installer_fixtures
      header 'content-type', 'application/json'
    end

    let(:image)  { Fabricate(:image) }
    let(:broker) { Fabricate(:broker) }

    let (:tag1) { Tag.create(:name => "tag1" ) }

    let(:policy_hash) do
      # FIXME: Once we have proper helpers to generate these URL's,
      # use them in these tests
      { :name          => "test policy",
        :image         => { "name" => image.name },
        :installer     => { "name" => "some_os" },
        :broker        => { "name" => broker.name },
        :hostname      => "host${id}.example.com",
        :root_password => "geheim",
        :line_number   => 100,
        :tags          => [ { "name" => tag1.name } ]
      }
    end

    def create_policy(input = nil)
      input ||= policy_hash.to_json
      post '/api/create_policy', input
    end

    # Successful creation
    it "should return 202, and the URL of the policy" do
      create_policy

      last_response.status.should == 202
      last_response.json?.should be_true
      last_response.json.keys.should =~ %w[name obj_id spec url]

      last_response.json["url"].should =~ %r'/api/collections/policies/test%20policy\Z'
    end

    it "should fail if a nonexisting tag is referenced" do
      policy_hash[:tags] = [ { "name" => "not_a_tag"} ]
      create_policy
      last_response.status.should == 400
    end

    it "should fail if a nonexisting image is referenced" do
      policy_hash[:image] = { "name" => "not_an_image" }
      create_policy
      last_response.status.should == 400
    end

    it "should create a policy in the database" do
      create_policy

      Razor::Data::Policy[:name => policy_hash[:name]].should be_an_instance_of Razor::Data::Policy
    end
  end
end