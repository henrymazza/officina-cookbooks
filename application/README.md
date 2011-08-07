
Recipes
=======

The application cookbook contains the following recipes.

default
-------

Searches the `apps` data bag and checks that a server role in the app exists on this node, adds the app to the run state and uses the role for the app to locate the recipes that need to be used. The recipes listed in the "type" part of the data bag are included by this recipe, so only the "application" recipe needs to be in the node or role `run_list`.

See below regarding the application data bag structure.

rails
-----

Using the node's `run_state` that contains the current application in the search, this recipe will:

* install required packages and gems
* set up the deployment scaffolding
* creates database and memcached configurations if required
* performs a revision-based deploy.

This recipe can be used on nodes that are going to run the application, or on nodes that need to have the application code checkout available such as supporting utility nodes or a configured load balancer that needs static assets stored in the application repository.

For Gem Bundler: include `bundler` or `bundler08` in the gems list.  `bundle install` or `gem bundle` will be run before migrations.  The `bundle install` command is invoked with the `--deployment` and `--without` flags following [Bundler best practices](http://gembundler.com/deploying.html).

For config.gem in environment: `rake gems:install RAILS_ENV=<node environment>` will be run when a Gem Bundler command is not.

In order to manage running database migrations (rake db:migrate), you can use a role that sets the `run_migrations` attribute for the application (`my_app`, below) in the correct environment (production, below). Note the data bag item needs to have migrate set to true. See the data bag example below.

    {
      "name": "my_app_run_migrations",
      "description": "Run db:migrate on demand for my_app",
      "json_class": "Chef::Role",
      "default_attributes": {
      },
      "override_attributes": {
        "apps": {
          "my_app": {
            "production": {
              "run_migrations": true
            }
          }
        }
      },
      "chef_type": "role",
      "run_list": [
      ]
    }

Simply apply this role to the node's run list when it is time to run migrations, and the recipe will remove the role when done.


Application Data Bag 
=====================

The applications data bag expects certain values in order to configure parts of the recipe. Below is a paste of the JSON, where the value is a description of the key. Use your own values, as required. Note that this data bag is also used by the `database` cookbook, so it will contain database information as well. Items that may be ambiguous have an example.

The application used in examples is named `my_app` and the environment is `production`. Most top-level keys are Arrays, and each top-level key has an entry that describes what it is for, followed by the example entries. Entries that are hashes themselves will have the description in the value. In order to use the environment `production` you must create the environment as described below under __Usage__.

Note about "type": the recipes listed in the "type" will be included in the run list via `include_recipe` in the application default recipe based on the type matching one of the `server_roles` values.

Note about packages, the version is optional. If specified, the version will be passed as a parameter to the resource. Otherwise it will use the latest available version per the default `:install` action for the package provider.

Rail's version additional notes
-------------------------------

Note about `databases`, the data specified will be rendered as the `database.yml` file. In the `database` cookbook, this information is also used to set up privileges for the application user, and create the databases.

Note about gems, the version is optional. If specified, the version will be passed as a parameter to the resource. Otherwise it will use the latest available version per the default `:install` action for the package provider.

An example is data bag item is included in this cookbook at `examples/data_bags/apps/rails_app.json`.

Usage
=====

To use the application cookbook, we recommend creating a role named after the application, e.g. `my_app`. This role should match one of the `server_roles` entries, that will correspond to a `type` entry, in the databag. Create a Ruby DSL role in your chef-repo, or create the role directly with knife.

    % knife role show my_app -Fj
    {
      "name": "my_app",
      "chef_type": "role",
      "json_class": "Chef::Role",
      "default_attributes": {
      },
      "description": "",
      "run_list": [
        "recipe[application]"
      ],
      "override_attributes": {
      }
    }

Also recommended is a cookbook named after the application, e.g. `my_app`, for additional application specific setup such as other config files for queues, search engines and other components of your application. The `my_app` recipe can be used in the run list of the role, if it includes the `application` recipe.

You should also create an environment. We use `production` in the examples and the documentation above. An example is in the source code's "examples" directory, and the JSON for an environment is below:

    % knife environment show production -Fj
    {
      "name": "production",
      "description": "",
      "cookbook_versions": {
      },
      "json_class": "Chef::Environment",
      "chef_type": "environment",
      "default_attributes": {
      },
      "override_attributes": {
      }
    }

License and Author
==================

Author:: Adam Jacob (<adam@opscode.com>)
Author:: Joshua Timberman (<joshua@opscode.com>)
Author:: Seth Chisamore (<schisamo@opscode.com>)

Copyright 2009-2011, Opscode, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
