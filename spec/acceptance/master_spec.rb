# frozen_string_literal: true

require 'spec_helper_acceptance'

# server/replica is only supported on Redhat
if fact_on('master', 'os.family') == 'RedHat'
  describe 'easy_ipa class' do
    include_examples 'the example', 'master.pp', 'master'
  end
end

if fact_on('client', 'os.family') == 'RedHat'
  describe 'easy_ipa class' do
    include_examples 'the example', 'client.pp', 'client'
  end
end
