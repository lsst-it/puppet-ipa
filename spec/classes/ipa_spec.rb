# frozen_string_literal: true

require 'spec_helper'

describe 'ipa', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          networking: {
            fqdn: 'ipa.rpsec.example.lan',
          }
        )
      end

      if facts[:os]['family'] == 'RedHat'
        let(:client_package) { 'ipa-client' }
      else
        let(:client_package) { 'freeipa-client' }
      end

      context 'as bad_val role' do
        let(:params) do
          {
            ipa_role: 'bad_val',
            domain: 'rspec.example.lan',
          }
        end

        it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.escape("Enum['client', 'master', 'replica']"))) }
      end

      context 'as master' do
        let(:params) do
          {
            ipa_role:                    'master',
            domain:                      'rspec.example.lan',
            admin_password:              'rspec-admin-password',
            directory_services_password: 'rspedc-ds-password',
          }
        end

        context 'with defaults' do
          it { is_expected.to contain_class('ipa::server') }
          it { is_expected.to contain_class('ipa::server::master') }

          it { is_expected.not_to contain_class('ipa::server::replica') }
          it { is_expected.not_to contain_class('ipa::client') }

          it { is_expected.to contain_package('ipa-server-dns') }
          it { is_expected.to contain_package('bind-dyndb-ldap') }
          it { is_expected.to contain_package('kstart') }
          it { is_expected.to contain_package('ipa-server') }

          it { is_expected.not_to contain_package(client_package) }
        end

        context 'with idmax' do
          let(:params) do
            super().merge(idstart: 10_000,
                          idmax:   20_000)
          end

          it do
            is_expected.to contain_exec('ipa-server-install').with(
              environment: [
                'IPA_ADMIN_PASSWORD=rspec-admin-password',
                'IPA_DS_PASSWORD=rspedc-ds-password',
              ],
              logoutput: 'on_failure'
            ).
              with_command(%r{--idstart=10000}).
              with_command(%r{--idmax=20000})
          end
        end

        context 'without idmax' do
          let(:params) do
            super().merge(idstart: 10_000)
          end

          it do
            is_expected.to contain_exec('ipa-server-install').with(
              environment: [
                'IPA_ADMIN_PASSWORD=rspec-admin-password',
                'IPA_DS_PASSWORD=rspedc-ds-password',
              ],
              logoutput: 'on_failure'
            ).with_command(%r{--idstart=10000})
            is_expected.not_to contain_exec('ipa-server-install').with_command(%r{--idmax})
          end
        end

        context 'configure_ssh' do
          context 'true' do
            let(:params) do
              super().merge(configure_ssh: true)
            end

            it { is_expected.not_to contain_exec('ipa-server-install').with_command(%r{--no-ssh(?!d)}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_ssh: false)
            end

            it {
              is_expected.to contain_exec('ipa-server-install').with(
                environment: [
                  'IPA_ADMIN_PASSWORD=rspec-admin-password',
                  'IPA_DS_PASSWORD=rspedc-ds-password',
                ],
                logoutput: 'on_failure'
              ).with_command(%r{--no-ssh(?!d)})
            }
          end
        end

        context 'configure_sshd' do
          context 'true' do
            let(:params) do
              super().merge(configure_sshd: true)
            end

            it { is_expected.not_to contain_exec('ipa-server-install').with_command(%r{--no-sshd}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_sshd: false)
            end

            it {
              is_expected.to contain_exec('ipa-server-install').with(
                environment: [
                  'IPA_ADMIN_PASSWORD=rspec-admin-password',
                  'IPA_DS_PASSWORD=rspedc-ds-password',
                ],
                logoutput: 'on_failure'
              ).with_command(%r{--no-sshd})
            }
          end
        end

        context 'with idstart out of range' do
          let(:params) do
            super().merge(idstart: 100)
          end

          it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.quote('expects an Integer[10000]'))) }
        end

        context 'with idstart greater than idmax' do
          let(:params) do
            super().merge(idstart: 44_444,
                          idmax:   33_333)
          end

          it { is_expected.to raise_error(Puppet::Error, %r{"idmax" must be an integer greater than parameter "idstart"}) }
        end

        context 'without admin_password' do
          let(:params) do
            super().merge(admin_password: nil)
          end

          it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.quote('expects a value of type Undef or String[8]'))) }
        end

        context 'without directory_services_password' do
          let(:params) do
            super().merge(directory_services_password: nil)
          end

          it { is_expected.to raise_error(Puppet::Error, Regexp.new(Regexp.quote('expects a value of type Undef or String[8]'))) }
        end

        context 'with bad ip_address' do
          let(:params) do
            super().merge(ip_address: 'not_an_ip')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{expects a.*Stdlib::IP::Address}) }
        end

        context 'with bad domain' do
          let(:params) do
            super().merge(domain: 'not_a_domain')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Fqdn}) }
        end

        context 'with bad realm' do
          let(:params) do
            super().merge(realm: 'not_a_realm')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{a match for Stdlib::Fqdn}) }
        end
      end

      context 'as replica' do
        let(:params) do
          {
            ipa_role: 'replica',
            domain: 'rspec.example.lan',
            ipa_master_fqdn: 'ipa-server-1.rspec.example.lan',
            admin_password: 'rspec-admin-password',
          }
        end

        context 'with defaults' do
          it { is_expected.to contain_class('ipa::server') }
          it { is_expected.to contain_class('ipa::server::replica') }

          it { is_expected.not_to contain_class('ipa::server::master') }
          it { is_expected.not_to contain_class('ipa::client') }

          it { is_expected.to contain_package('ipa-server-dns') }
          it { is_expected.to contain_package('bind-dyndb-ldap') }
          it { is_expected.to contain_package('kstart') }
          it { is_expected.to contain_package('ipa-server') }

          it { is_expected.not_to contain_package(client_package) }
        end

        context 'configure_ssh' do
          context 'true' do
            let(:params) do
              super().merge(configure_ssh: true)
            end

            it { is_expected.not_to contain_exec('ipa-replica-install').with_command(%r{--no-ssh(?!d)}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_ssh: false)
            end

            it {
              is_expected.to contain_exec('ipa-replica-install').with(
                environment: ['IPA_ADMIN_PASSWORD=rspec-admin-password'],
                logoutput: 'on_failure'
              ).with_command(%r{--no-ssh(?!d)})
            }
          end
        end

        context 'configure_sshd' do
          context 'true' do
            let(:params) do
              super().merge(configure_sshd: true)
            end

            it { is_expected.not_to contain_exec('ipa-replica-install').with_command(%r{--no-sshd}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_sshd: false)
            end

            it {
              is_expected.to contain_exec('ipa-replica-install').with(
                environment: ['IPA_ADMIN_PASSWORD=rspec-admin-password'],
                logoutput: 'on_failure'
              ).with_command(%r{--no-sshd})
            }
          end
        end

        context 'missing ipa_master_fqdn' do
          let(:params) do
            super().reject { |k| k == :ipa_master_fqdn }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn cannot be empty}) }
        end

        context 'with bad ipa_master_fqdn' do
          let(:params) do
            super().merge(ipa_master_fqdn: 'not_an_fqdn')
          end

          it { is_expected.to raise_error(Puppet::Error, %r{expects a match for Stdlib::Fqdn}) }
        end

        context 'missing admin_password' do
          let(:params) do
            super().reject { |k| k == :admin_password }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{admin_password cannot be empty}) }
        end
      end

      context 'as client' do
        let(:params) do
          {
            ipa_role: 'client',
            domain: 'rspec.example.lan',
            ipa_master_fqdn: 'ipa-server-1.rspec.example.lan',
            domain_join_password: 'rspec-domain-join-password',
          }
        end

        context 'with defaults' do
          it { is_expected.to contain_class('ipa::client') }

          it { is_expected.not_to contain_class('ipa::server') }
          it { is_expected.not_to contain_class('ipa::server::master') }
          it { is_expected.not_to contain_class('ipa::server::replica') }

          it { is_expected.to contain_package(client_package).that_comes_before('Exec[ipa-client-install]') }
          it { is_expected.to contain_package('kstart') }
          it { is_expected.not_to contain_package('ipa-server-dns') }
          it { is_expected.not_to contain_package('bind-dyndb-ldap') }
          it { is_expected.not_to contain_package('ipa-server') }
        end

        context 'configure_ssh' do
          context 'true' do
            let(:params) do
              super().merge(configure_ssh: true)
            end

            it { is_expected.not_to contain_exec('ipa-client-install').with_command(%r{--no-ssh(?!d)}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_ssh: false)
            end

            it {
              is_expected.to contain_exec('ipa-client-install').with(
                environment: 'IPA_DOMAIN_JOIN_PASSWORD=rspec-domain-join-password',
                logoutput: 'on_failure'
              ).with_command(%r{--no-ssh(?!d)})
            }
          end
        end

        context 'configure_sshd' do
          context 'true' do
            let(:params) do
              super().merge(configure_sshd: true)
            end

            it { is_expected.not_to contain_exec('ipa-client-install').with_command(%r{--no-sshd}) }
          end

          context 'false' do
            let(:params) do
              super().merge(configure_sshd: false)
            end

            it {
              is_expected.to contain_exec('ipa-client-install').with(
                environment: 'IPA_DOMAIN_JOIN_PASSWORD=rspec-domain-join-password',
                logoutput: 'on_failure'
              ).with_command(%r{--no-sshd})
            }
          end
        end

        context 'missing ipa_master_fqdn' do
          let(:params) do
            super().reject { |k| k == :ipa_master_fqdn }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named ipa_master_fqdn cannot be empty}) }
        end

        context 'missing domain_join_password' do
          let(:params) do
            super().reject { |k| k == :domain_join_password }
          end

          it { is_expected.to raise_error(Puppet::Error, %r{parameter named domain_join_password cannot be empty}) }
        end
      end
    end
  end
end
