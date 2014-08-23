# chef-cs3357-cookbook

Chef cookbook to install/configure the CS 3357 infrastructure.  Really only useful for my own purposes.

## Supported Platforms

Ubuntu 14.04

## Usage with `chef-solo`

Install `chef-solo`:

```
sudo apt-get update
sudo apt-get install language-pack-en git-core
cd /tmp

wget https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.2.0-2_amd64.deb
sudo dpkg -i chefdk_0.2.0-2_amd64.deb

git clone https://github.com/jeffshantz/chef-cs3357.git
cd chef-cs3357
berks package

sudo -i
mkdir /root/chef
cd !$
# Use the filename from the output of the 'berks package' command
tar zxvf /tmp/chef-cs3357/cookbooks-1408690620.tar.gz
```

Create a file `/root/chef/solo.rb`:

```
ssl_verify_mode :verify_peer
log_level :info

cookbook_path [
  "/root/chef/cookbooks"
]
```

Finally, create a `json` file according to one of the recipes below, and then run `chef-solo`:

```
chef-solo -c solo.rb -j web.json
```

### cs3357::web

Create a file `/root/chef/web.json`:

```
{
  "torquebox": {
    "version": "3.1.1"
  },
  "cs3357": {
    "database": {
      "root_password": "secret",
      "name": "db_name",
      "user": "db_user",
      "password": "db_password"
    }
  },
  "run_list": [ "recipe[cs3357::web]" ]
}
```

## License and Authors

Author:: Jeff Shantz (<jeff@csd.uwo.ca>)

```text
Copyright:: 2014, Jeff Shantz

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

