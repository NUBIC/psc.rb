shared_context 'middleware' do
  let(:app) { mock('app') }
  let(:env) { { :request_headers => ::Faraday::Utils::Headers.new } }
  let(:headers) { env[:request_headers] }

  before { app.stub!(:call) }

  def do_call
    subject.call(env)
  end
end

shared_examples 'unconditional middleware' do
  it 'continues the chain' do
    app.should_receive(:call)
    subject.call(env)
  end
end
