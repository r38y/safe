require File.expand_path(File.dirname(__FILE__) + '/../example_helper')

describe Astrails::Safe::Mysqldump do

  def def_config
    {
      :options => "OPTS",
      :host => "localhost",
      :port => 21017,
      :db => "test",
      :out => ".",
      :collection => "test"
    }
  end
  
  def mongodb_dump(id = :foo, config = def_config)
    Astrails::Safe::MongodbDump.new(id, Astrails::Safe::Config::Node.new(nil, config))
  end

  before(:each) do
    stub(Time).now.stub!.strftime {"NOW"}
  end

  after(:each) { Astrails::Safe::TmpFile.cleanup }

  describe :backup do
    before(:each) do
      @mongodb = mongodb_dump
      # stub(@mysql).mysql_password_file {"/tmp/pwd"}
    end

    {
      :id => "foo",
      :kind => "mongodbdump",
      :extension => ".mongodb.dump",
      :filename => "mongodbdump-foo.NOW",
      :command => "mongodump OPTS --host localhost --port 21017 --db test --out . --collection test",
    }.each do |k, v|
      it "should set #{k} to #{v}" do
        @mongodb.backup.send(k).should == v
      end
    end

  end
end