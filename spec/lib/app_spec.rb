RSpec.describe App do
  include RequestHelper

  let(:instance) { described_class.new(config) }

  let(:config) do
    Config.new(
      login:    'username',
      password: 'password',
      domain:   'example.com',
      type:     'TXT',
      record:   'hello',
      value:    'world',
      logger:   Logger.new('/dev/null')
    )
  end

  let(:code_success) { 1000 }
  let(:code_failure) { 1111 }

  describe '#run' do
    before do
      stub_login(login_code)
    end

    context 'when the login is failing' do
      let(:login_code) { code_failure }

      it 'raises an error' do
        expect { instance.run }.to raise_error App::Error, 'Failed in nameserver.login call'
      end
    end

    context 'when the login is working' do
      let(:login_code) { code_success }

      context 'when there is a tan configured' do
        before do
          config.tan = 'TAN'
          stub_unlock(unlock_code)
        end

        context 'when the unlock call fails' do
          let(:unlock_code) { code_failure }

          it 'raises an error' do
            expect { instance.run }.to raise_error App::Error, 'Failed in account.unlock call'
          end
        end
      end

      shared_examples 'creating the record' do
        before do
          stub_create(create_result)
        end

        context 'when the create call fails' do
          let(:create_result) { code_failure }

          it 'raises an error' do
            expect { instance.run }.to raise_error App::Error, 'Failed in nameserver.createRecord call'
          end
        end

        context 'when the create call works' do
          let(:create_result) { code_success }

          it 'returns true' do
            expect(instance.run).to be true
          end
        end
      end

      context 'when there are existing entries' do
        let(:record_one) { 9001 }
        let(:record_two) { 9002 }

        before do
          stub_info([record_one, record_two])
        end

        context 'when one of the delete calls fails' do
          before do
            stub_delete(record_one, code_success)
            stub_delete(record_two, code_failure)
          end

          it 'raises an error' do
            expect { instance.run }.to raise_error App::Error, 'Failed in nameserver.deleteRecord call'
          end
        end

        context 'when all delete calls work' do
          before do
            stub_delete(record_one, code_success)
            stub_delete(record_two, code_success)
          end

          include_examples 'creating the record'
        end
      end

      context 'when there are no existing records' do
        before do
          stub_info([])
        end

        include_examples 'creating the record'
      end
    end
  end
end
