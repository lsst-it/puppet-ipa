# frozen_string_literal: true

require 'spec_helper_acceptance'

# server/replica is only supported on Redhat
if fact_on('master', 'os.family') == 'RedHat'
  describe 'ipa master' do
    include_examples 'the example', 'master.pp', 'master'
  end

  describe 'ipa replica' do
    include_examples 'the example', 'replica.pp', 'replica'
  end

  describe 'ipa client' do
    include_examples 'the example', 'client.pp', 'client'
  end
end
