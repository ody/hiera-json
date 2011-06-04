$:.insert(0, File.join([File.dirname(__FILE__), "..", "lib"]))

require 'rubygems'
require 'rspec'
require 'hiera/backend/json_backend'
require 'rspec/mocks'
require 'mocha'

RSpec.configure do |config|
    config.mock_with :mocha
end

class Hiera
    module Backend
        describe Json_backend do
            before do
                Hiera.stubs(:warn)
                Hiera.stubs(:debug)
                Backend.stubs(:parse_string)
                Backend.stubs(:datasources).yields([])

                Backend.expects(:datadir).with(:json, {}).returns("/nonexisting")
                @backend = Json_backend.new
            end

            it "should use the configured datadir" do
                File.expects(:directory?).with("/nonexisting").returns(true)

                @backend.lookup("test", {})
            end

            it "should fail for missing data directories" do
                File.expects(:directory?).with("/nonexisting").returns(false)

                expect {
                    @backend.lookup("test", {})
                }.to raise_error("Cannot find data directory /nonexisting")
            end

            it "should look for data in all data sources" do
                File.expects(:directory?).with("/nonexisting").returns(true)
                Backend.expects(:datasources).with({}, nil).multiple_yields(["one"], ["two"])
                File.expects(:exist?).with("/nonexisting/one.json")
                File.expects(:exist?).with("/nonexisting/two.json")
                @backend.lookup("test", {})
            end

            it "should warn about missing data files and continue" do
                File.expects(:directory?).with("/nonexisting").returns(true)
                Backend.expects(:datasources).with({}, nil).multiple_yields(["one"], ["two"])
                File.expects(:exist?).with("/nonexisting/one.json").returns(false)
                File.expects(:exist?).with("/nonexisting/two.json").returns(false)

                Hiera.expects(:warn).with("Cannot find datafile /nonexisting/one.json, skipping")
                Hiera.expects(:warn).with("Cannot find datafile /nonexisting/two.json, skipping")

                @backend.lookup("test", {})
            end

            it "should parse string data for interprolation" do
                File.expects(:directory?).with("/nonexisting").returns(true)
                Backend.expects(:datasources).with({}, nil).yields("one")
                File.expects(:exist?).with("/nonexisting/one.json").returns(true)
                File.expects(:read).with("/nonexisting/one.json").returns('{"test":"data"}')
                Backend.expects(:parse_string).with("data", {})

                @backend.lookup("test", {})
            end

            it "should return the first answer found" do
                File.expects(:directory?).with("/nonexisting").returns(true)
                Backend.expects(:datasources).with({}, nil).multiple_yields(["one"], ["two"])
                File.expects(:exist?).with("/nonexisting/one.json").returns(true)
                File.expects(:read).with("/nonexisting/one.json").returns('{"test":"data1"}')
                Backend.expects(:parse_string).with("data1", {}).returns("data1")

                File.expects(:exist?).with("/nonexisting/two.json").never
                File.expects(:read).with("/nonexisting/two.json").never

                @backend.lookup("test", {}).should == "data1"
            end
        end
    end
end
