require_relative "../spec_helper"


describe "UCB::LDAP::Schema" do
  before(:all) do
    @schema_yaml = IO.read(Schema::SCHEMA_FILE)
  end
  
  before(:each) do
    Schema.schema_hash = nil
    Schema.schema_file = nil
    Schema.schema_base_url = nil
    Schema.schema_content_path = nil 
  end
  
  it "should define SCHEMA_URL" do
    Schema::SCHEMA_BASE_URL.class.should == String
  end
  
  it "schema_base_url() should default to SCHEMA_BASE_URL constant" do
    Schema.schema_base_url.should == Schema::SCHEMA_BASE_URL  
  end
  
  it "schema_base_url() can be reset" do
    Schema.schema_base_url = "foo"
    Schema.schema_base_url.should == "foo"  
  end
  
  it "schema_content_path() should default to SCHEMA_CONTENT_PATH constant" do
    Schema.schema_content_path.should == Schema::SCHEMA_CONTENT_PATH  
  end
  
  it "schema_content_path() can be reset" do
    Schema.schema_content_path = "foo"
    Schema.schema_content_path.should == "foo"  
  end
  
  it "should get schema yaml from url" do
    @yaml = Schema.yaml_from_url
    %w{person: org:}.each do |entity|
      @yaml.should include(entity)
    end
  end
  
  it "should load attributes from url" do
    Schema.schema_hash_i.should be_nil
    Schema.should_receive(:yaml_from_url).and_return(@schema_yaml)
    Schema.load_attributes_from_url
    verify_schema_hash
  end
  
  it "should define SCHEMA_FILE" do
    Schema::SCHEMA_FILE.class.should == String
  end
  
  it "schema_file() should default to SCHEMA_FILE constant" do
    Schema.schema_file.should == Schema::SCHEMA_FILE
  end
  
  it "schema_file() can be reset" do
    Schema.schema_file = "foo"
    Schema.schema_file.should == "foo"  
  end
  
  it "should get schema yaml from file" do
    yaml = Schema.yaml_from_file
    verify_yaml(yaml)
  end
  
  it "should load attributes from file" do
    Schema.schema_hash_i.should be_nil
    Schema.load_attributes_from_file
    verify_schema_hash
  end
  
  it "should load_attributes from url if available" do
    Schema.schema_hash_i.should be_nil
    Schema.should_receive(:yaml_from_url).and_return(@schema_yaml)
    Schema.should_not_receive(:load_attributes_from_file)
    UCB::LDAP::Schema.load_attributes
    verify_schema_hash
  end

  it "should load_attributes from local file if url data not available" do
    Schema.schema_hash_i.should be_nil
    Schema.should_receive(:load_attributes_from_url).and_raise("schema unavailable from url")
    Schema.load_attributes
    verify_schema_hash
  end

  # Verify we have something that looks like the schema yaml file
  def verify_yaml(yaml)
    yaml.should be_instance_of(String)
    yaml.should have_at_least(40_000).characters
    %w{person: personAddress: syntax:}.each{|s| yaml.should include(s)}
  end

  # Verify schema_hash looks right
  def verify_schema_hash
    Schema.schema_hash_i.should be_instance_of(Hash)
    %w{person org}.each{|e| Schema.schema_hash.keys.should include(e)}
  end

end
