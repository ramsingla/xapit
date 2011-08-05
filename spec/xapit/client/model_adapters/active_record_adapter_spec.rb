if ENV["MODEL_ADAPTER"].nil? || ENV["MODEL_ADAPTER"] == "active_record"
  require "spec_helper"

  RSpec.configure do |config|
    config.extend WithModel
  end

  ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

  describe Xapit::Client::ActiveRecordAdapter do
    with_model :article do
      table do |t|
        t.string "name"
      end
    end

    before(:each) do
      load_xapit_database
    end

    it "is only for active record classes" do
      Xapit::Client::ActiveRecordAdapter.should_not be_for_class(Object)
      Xapit::Client::ActiveRecordAdapter.should be_for_class(Article)
      Xapit::Client::AbstractModelAdapter.adapter_class(Article).should == Xapit::Client::ActiveRecordAdapter
    end

    it "creates document when saved" do
      Article.xapit { text :name }
      article = Article.create!(:name => "Foo Bar")
      Article.all.should eq([article])
      Article.search("Foo Bar").records.should eq([article])
    end
  end
end
