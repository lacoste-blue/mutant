RSpec.describe Mutant::Mutation do

  class TestMutation < Mutant::Mutation
    SYMBOL = 'test'.freeze
  end

  let(:object)  { TestMutation.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }
  let(:context) { double('Context')                                             }

  let(:mutation_subject) do
    double(
      'Subject',
      identification: 'subject',
      context: context,
      source: 'original',
      tests:  [test_a, test_b]
    )
  end

  let(:test_a) { double('Test A') }
  let(:test_b) { double('Test B') }

  describe '#kill' do
    let(:isolation) { double('Isolation')                                                     }
    let(:object)    { Mutant::Mutation::Evil.new(mutation_subject, Mutant::AST::Nodes::N_NIL) }

    let(:test_result_a) { double('Test Result A', passed: false) }

    before do
      expect(test_a).to receive(:kill).with(isolation, object).and_return(test_result_a)
    end

    subject { object.kill(isolation) }

    it { should eql(Mutant::Result::Mutation.new(index: nil, mutation: object, test_results: [test_result_a])) }
  end

  describe '#code' do
    subject { object.code }

    it { should eql('8771a') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#original_source' do
    subject { object.original_source }

    it { should eql('original') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#insert' do
    subject { object.insert }

    let(:wrapped_node) { double('Wrapped Node') }

    before do
      expect(mutation_subject).to receive(:public?).ordered.and_return(true)
      expect(mutation_subject).to receive(:prepare).ordered
      expect(context).to receive(:root).ordered.with(s(:nil)).and_return(wrapped_node)
      expect(Mutant::Loader::Eval).to receive(:call).ordered.with(wrapped_node, mutation_subject).and_return(nil)
    end

    it_should_behave_like 'a command method'
  end

  describe '#source' do
    subject { object.source }

    it { should eql('nil') }

    it_should_behave_like 'an idempotent method'
  end

  describe '#identification' do

    subject { object.identification }

    it { should eql('test:subject:8771a') }

    it_should_behave_like 'an idempotent method'
  end
end
