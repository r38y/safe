require File.expand_path(File.dirname(__FILE__) + '/../example_helper')

describe Astrails::Safe::Mongodbdump do

  def def_config
    {
      :options => "OPTS",
      :host => "localhost",
      :port => 21017,
      :database => "test",
      :out => ".",
      :collection => "test"
    }
  end
  
  def mongodb_dump(id = :foo, config = def_config)
    Astrails::Safe::Mongodbdump.new(id, Astrails::Safe::Config::Node.new(nil, config))
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
      :extension => ".mongodb.dump.tgz",
      :filename => "mongodbdump-foo.NOW",
      :command => "mongodump OPTS --db foo --host localhost --port 21017 --out . --collection test",
    }.each do |k, v|
      it "should set #{k} to #{v}" do
        @mongodb.backup.send(k).should == v
      end
    end

  end
end