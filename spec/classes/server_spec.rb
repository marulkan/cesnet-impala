require 'spec_helper'

describe 'impala::server' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      path = '/etc/impala/conf'
      context "on #{os}" do
        let(:facts) do
          facts.merge({
            :concat_basedir => '/dne',
          })
        end

        context "without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('impala::server') }

          it { is_expected.to contain_class('impala::server::install').that_comes_before('impala::server::config') }
          it { is_expected.to contain_class('impala::server::config') }
          it { is_expected.to contain_class('impala::server::service').that_subscribes_to('impala::server::config') }

          it { should contain_file(path + '/core-site.xml') }
          it { should contain_file(path + '/hdfs-site.xml') }

          it { is_expected.to contain_service('impala-server') }
          it { is_expected.to contain_package('impala-server') }
        end
      end
    end
  end
end
