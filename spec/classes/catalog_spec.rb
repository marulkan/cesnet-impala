require 'spec_helper'

describe 'impala::catalog' do
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
          it { is_expected.to contain_class('impala::catalog') }

          it { is_expected.to contain_class('impala::catalog::install').that_comes_before('impala::catalog::config') }
          it { is_expected.to contain_class('impala::catalog::config') }
          it { is_expected.to contain_class('impala::catalog::service').that_subscribes_to('impala::catalog::config') }

          it { should contain_file(path + '/core-site.xml') }
          it { should contain_file(path + '/hdfs-site.xml') }

          it { is_expected.to contain_service('impala-catalog') }
          it { is_expected.to contain_package('impala-catalog') }
        end
      end
    end
  end
end
