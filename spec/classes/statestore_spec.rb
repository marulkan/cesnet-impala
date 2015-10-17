require 'spec_helper'

describe 'impala::statestore' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      path = '/etc/impala/conf'
      context "on #{os}" do
        let(:facts) do
          facts
          {
            :concat_basedir => '/dne',
          }
        end

        context "without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('impala::statestore') }

          it { is_expected.to contain_class('impala::statestore::install').that_comes_before('impala::statestore::config') }
          it { is_expected.to contain_class('impala::statestore::config') }
          it { is_expected.to contain_class('impala::statestore::service').that_subscribes_to('impala::statestore::config') }

          it { should contain_file(path + '/core-site.xml') }
          it { should contain_file(path + '/hdfs-site.xml') }

          it { is_expected.to contain_service('impala-state-store') }
          it { is_expected.to contain_package('impala-state-store') }
        end
      end
    end
  end
end
