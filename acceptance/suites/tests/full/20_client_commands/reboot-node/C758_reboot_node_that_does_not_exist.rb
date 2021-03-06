# -*- encoding: utf-8 -*-
# this is required because of the use of eval interacting badly with require_relative
require 'razor/acceptance/utils'
confine :except, :roles => %w{master dashboard database frictionless}

test_name 'Reboot node that does not exist'
step 'https://testrail.ops.puppetlabs.net/index.php?/cases/view/758'

reset_database

razor agents, 'reboot-node --name does-not-exist', nil, exit: 1 do |agent, output|
  assert_match /name must be the name of an existing node, but is 'does-not-exist'/, output
end
