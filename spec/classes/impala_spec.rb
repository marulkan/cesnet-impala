require 'spec_helper'

describe 'impala' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
          {
            :concat_basedir => '/dne',
          }
        end

        context "impala class without any parameters" do
          let(:params) {{ }}

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_class('impala') }

          it { is_expected.to contain_class('impala::params') }
        end
      end
    end
  end

#  context 'unsupported operating system' do
#    describe 'impala class without any parameters on Solaris/Nexenta' do
#      let(:facts) {{
#        :osfamily        => 'Solaris',
#        :operatingsystem => 'Nexenta',
#      }}
#
#      it { expect { is_expected.to contain_class('impala') }.to raise_error(Puppet::Error, /Solaris.Nexenta not supported/) }
#    end
#  end
end
