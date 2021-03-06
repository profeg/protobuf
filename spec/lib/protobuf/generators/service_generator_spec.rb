require 'spec_helper'

require 'protobuf/generators/service_generator'

RSpec.describe ::Protobuf::Generators::ServiceGenerator do

  let(:methods) do
    [
      { :name => 'Search', :input_type => 'FooRequest', :output_type => 'FooResponse' },
      { :name => 'FooBar', :input_type => '.foo.Request', :output_type => '.bar.Response' },
    ]
  end
  let(:service_fields) do
    {
      :name => 'TestService',
      :method => methods,
    }
  end

  let(:service) { ::Google::Protobuf::ServiceDescriptorProto.new(service_fields) }

  subject { described_class.new(service) }

  describe '#compile' do
    let(:compiled) do
      'class TestService < ::Protobuf::Rpc::Service
  rpc :search, FooRequest, FooResponse
  rpc :foo_bar, ::Foo::Request, ::Bar::Response
end

'
    end

    it 'compiles the service and it\'s rpc methods' do
      subject.compile
      expect(subject.to_s).to eq(compiled)
    end
  end

  describe '#build_method' do
    it 'returns a string identifying the given method descriptor' do
      expect(subject.build_method(service.method.first)).to eq("rpc :search, FooRequest, FooResponse")
    end

    context 'with PB_USE_RAW_RPC_NAMES in the environemnt' do
      before { allow(ENV).to receive(:key?).with('PB_USE_RAW_RPC_NAMES').and_return(true) }

      it 'uses the raw RPC name and does not underscore it' do
        expect(subject.build_method(service.method.first)).to eq("rpc :Search, FooRequest, FooResponse")
        expect(subject.build_method(service.method.last)).to eq("rpc :FooBar, ::Foo::Request, ::Bar::Response")
      end
    end
  end

end
