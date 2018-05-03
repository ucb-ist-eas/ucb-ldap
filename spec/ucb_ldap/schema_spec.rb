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
    expect(Schema::SCHEMA_BASE_URL.class).to eq(String)
  end

  it "schema_base_url() should default to SCHEMA_BASE_URL constant" do
    expect(Schema.schema_base_url).to eq(Schema::SCHEMA_BASE_URL)
  end

  it "schema_base_url() can be reset" do
    Schema.schema_base_url = "foo"
    expect(Schema.schema_base_url).to eq("foo")
  end

  it "schema_content_path() should default to SCHEMA_CONTENT_PATH constant" do
    expect(Schema.schema_content_path).to eq(Schema::SCHEMA_CONTENT_PATH)
  end

  it "schema_content_path() can be reset" do
    Schema.schema_content_path = "foo"
    expect(Schema.schema_content_path).to eq("foo")
  end

  it "should get schema yaml from url" do
    @yaml = Schema.yaml_from_url
    %w{person: org:}.each do |entity|
      expect(@yaml).to include(entity)
    end
  end

  it "should load attributes from url" do
    expect(Schema.schema_hash_i).to be_nil
    allow(Schema).to receive(:yaml_from_url).and_return(@schema_yaml)
    Schema.load_attributes_from_url
    verify_schema_hash
  end

  it "should define SCHEMA_FILE" do
    expect(Schema::SCHEMA_FILE.class).to eq(String)
  end

  it "schema_file() should default to SCHEMA_FILE constant" do
    expect(Schema.schema_file).to eq(Schema::SCHEMA_FILE)
  end

  it "schema_file() can be reset" do
    Schema.schema_file = "foo"
    expect(Schema.schema_file).to eq("foo")
  end

  it "should get schema yaml from file" do
    yaml = Schema.yaml_from_file
    verify_yaml(yaml)
  end

  it "should load attributes from file" do
    expect(Schema.schema_hash_i).to be_nil
    Schema.load_attributes_from_file
    verify_schema_hash
  end

  it "should load_attributes from url if available" do
    expect(Schema.schema_hash_i).to be_nil
    allow(Schema).to receive(:yaml_from_url).and_return(@schema_yaml)
    expect(Schema).not_to receive(:load_attributes_from_file)
    UCB::LDAP::Schema.load_attributes(true)
    verify_schema_hash
  end

  it "should load_attributes from local file if url data not available" do
    expect(Schema.schema_hash_i).to be_nil
    expect(Schema).to receive(:load_attributes_from_url).and_raise("schema unavailable from url")
    Schema.load_attributes(true)
    verify_schema_hash
  end

  # Verify we have something that looks like the schema yaml file
  def verify_yaml(yaml)
    expect(yaml).to be_instance_of(String)
    expect(yaml.length).to be >= 40_000
    %w{person: personAddress: syntax:}.each{|s| expect(yaml).to include(s)}
  end

  # Verify schema_hash looks right
  def verify_schema_hash
    expect(Schema.schema_hash_i).to be_instance_of(Hash)
    %w{person org}.each{|e| expect(Schema.schema_hash.keys).to include(e)}
  end

end
