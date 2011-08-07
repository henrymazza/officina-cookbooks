maintainer       "Opscode, Inc."
maintainer_email "cookbooks@opscode.com"
license          "Apache 2.0"
description      "Deploys and configures a variety of applications defined from databag 'apps'"

version          "0.0.1"

recipe           "application::rails", "Deploys a Rails application specified in a data bag with the deploy_revision resource"

depends "nginx::passenger"
