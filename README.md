# ruby-nub
Collection of ruby utils I've used in several of my projects and wanted re-usable

[![Build Status](https://travis-ci.org/phR0ze/ruby-nub.svg)](https://travis-ci.org/phR0ze/ruby-nub)
[![Gem Version](https://badge.fury.io/rb/nub.svg)](https://badge.fury.io/rb/nub)

### Table of Contents
* [Classes](#classes)
    * [cmds](#cmds)
* [Ruby Gem Creation](#ruby-gem-creation)
    * [Package Layout](#package-layout)
    * [Build Gem](#build-gem)
    * [Install Gem](#install-gem)
    * [Push Gem](#push-gem)
* [Integrate with Travis-CI](#integrate-with-travis-ci)
    * [Install Travis Client](#install-travis-client)
    * [Deploy Ruby Gem on Tag](#deploy-ruby-gem-on-tag)
 
## Classes <a name="classes"></a>
Different classes provided with the gem are explained below

### cmds <a name="cmds"></a>
Command like syntax for Ruby command line parameters

## Ruby Gem Creation <a name="ruby-gem-creation"></a>
http://guides.rubygems.org/make-your-own-gem/

This is my first ruby gem and am documenting what I did here

### Package Layout <a name="package-layout"></a>
All the ruby code will be in the sub directory ***lib***

* ***lib*** is where your gem's actual code should reside
* ***nub.gemspec*** is your interface to RubyGems.org all the data provided here is used by the gem
repo

### Build Gem <a name="build-gem"></a>
```
gem build nub.gemspec
```

### Install Gem <a name="install-gem"></a>
```
gem install nub-0.0.1.gem
```

### Push Gem <a name="push-gem"></a>
Once you've built and tested your gem and are happy with it push it to RubyGems.org

```bash
# Download your user credentials
curl -u phR0ze https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials
# Enter host password for user 'phR0ze':
# Revoke read permission from everyone but you
chmod og-r ~/.gem/credentials
# Push gem
gem push nub-0.0.1.gem
# List out your gems takes about a min
gem list -r nub
```

## Integrate with Travis-CI <a name="integrate-with-travis-ci"></a>

### Install Travis Client <a name="install-travis-client"></a>
```bash
sudo gem install travis --no-user-install
```

### Deploy Ruby Gem on Tag <a name="deploy-ruby-gem-on-tag"></a>
Create the file ***.travis.yml***

* Using ***cache: bundler*** builds the dependencies once and then reuses them in future builds.
* Script ***rake*** is actually the default for ***ruby*** but calling it out for clarity to run unit tests
* Deploying using the ***rubygems*** provider on tags

```yaml
language: ruby
sudo: false
cache: bundler
rvm:
  - 2.5.0
before_install:
  - gem update --system
script:
  - rake
deploy:
  provider: rubygems
  api_key:
    secure: <encrypted key>
  gem: nub
  on:
    tags: true
notifications:
  email: false
```

