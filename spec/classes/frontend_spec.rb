require 'spec_helper'

describe 'impala::frontend' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      path = '/etc/impala/conf'
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('impala::frontend') }

          it { is_expected.to contain_class('impala::frontend::install').that_comes_before('impala::frontend::config') }
          it { is_expected.to contain_class('impala::frontend::config') }

          it { should contain_file(path + '/core-site.xml') }
          it { should contain_file(path + '/hdfs-site.xml') }
          it { should contain_file('/usr/local/bin/impala') }
          it { should contain_file('/usr/local/share/hadoop/impala-servers') }

          it { is_expected.to contain_package('impala-shell') }
        end
      end
    end
  end
end
