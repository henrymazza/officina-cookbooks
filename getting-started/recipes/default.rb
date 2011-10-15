#
# Cookbook Name:: getting-started
# Recipe:: default
#
# Copyright 2010, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'aws/s3'

s3_file "/tmp/manto-system.tar.bz2" do
  bucket "officina-mantostore"
  object_name "20110815191152.backup_shared_system.tar.gz"
  aws_access_key_id "AKIAIKLAZHM3GFTB7HSQ"
  aws_secret_access_key "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"
  mode "644"
  not_if "test -e /tmp/manto-system.tar.bz2"
end

s3_file "/tmp/manto-mysql.tar.bz2" do
  bucket "officina-mantostore"
  object_name "20110815210721.mysql_backup_s3.sql.gz"
  aws_access_key_id "AKIAIKLAZHM3GFTB7HSQ"
  aws_secret_access_key "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"
  mode "644"
  not_if "test -e /tmp/manto-mysql.tar.bz2"
end
