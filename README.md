SpreeAdminRolesAndAccess [![Code Climate](https://codeclimate.com/github/vinsol/spree_admin_roles_and_access.png)](https://codeclimate.com/github/vinsol/spree_admin_roles_and_access) [![Build Status](https://travis-ci.org/vinsol/spree_admin_roles_and_access.png?branch=master)](https://travis-ci.org/vinsol/spree_admin_roles_and_access)
========================

This spree extension is build on CanCan to dynamically add new roles and define its access through permissions.

Installation
------------

Add spree_admin_roles_and_access to your Gemfile:

```ruby
gem 'spree_admin_roles_and_access'
```

But if you are using older version of spree


```ruby
# Spree 2.4.0-rc3
gem 'spree_admin_roles_and_access', '1.3.0'
```


```ruby
# Spree 2.1.x
gem 'spree_admin_roles_and_access', '1.1.0'
```

```ruby
# Spree 2.0.x
gem 'spree_admin_roles_and_access', '1.0.0'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_admin_roles_and_access:install
bundle exec rake spree_roles:permissions:populate # To populate user and admin roles with their permissions
```

Usage
-----

From Admin end, there is a role menu in configuration tab(admin end).
A new Role can be added and its corresponding permissions can also be selected there.
Permission to be chosen can be made only with rails console or a ruby script.

Types of Permission

  1. Default Permission - Basic permissions required by a user to perform task on user end, like creating an order etc. Every role should be provided with this permissions.

  2. Default Admin Permission - Because of this permission an admin can go to '/admin' route.

  3. Can Manage All - Role with this permission can do everything. This permission is also invisible at admin end. And it should only be given to admin and super admin.

Pattern of the permissions :-

  1. Can/cannot - specifies whether the user with that permission can do or cannot do that task.
  2. Action - specifies the action which can be done by that model or subject like update, index, create etc. There is a special action called manage which matches every action.
  3. Subject - specified the model like products, users etc. of which the permission is given. There is an special subject called all which matches every subject.
  4. Attributes - specifies the attributes for which the permission is specified. Read-only actions shouldn't require this like index, read etc. But it is more secure if we specify them in other actions like create or update.

Some Examples :-

  1. can-manage-spree/product - can perform every action on Spree::Product but not on any other model or subject.
  2. can-update-all - can update all models or subjects.
  3. can-update-spree/product - can update only products, and not users, orders and other things.
  4. can-update-spree/product-price - can update only price of products.
  5. can-manage-all - can perform every action on all models.

Points to remember

  1. If the controller doesn't have any model associated with it, then we will provide the full controller path like :-
    can-read-spree/admin/pos

  2. Every Role should also have admin permission of that particular controller. For eg:-
    To create a product, can-admin-spree/product is also needed along with can-create-spree/product.

  3. To define custom cancan permissions, which can not be made with the pattern adopted.
    Override a module Permission. And define the permission in a method, and create a permission in the database.


Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

Contributing
------------

1. Fork the repo.
2. Clone your repo.
3. Run `bundle install`.
4. Run `bundle exec rake test_app` to create the test application in `spec/test_app`.
5. Make your changes.
6. Ensure specs pass by running `bundle exec rspec spec`.
7. Submit your pull request.

Sample Application
------------------

A sample application with the extension already implemented can be found [here](https://spree-demo.domain4now.com).
Admin Credentials - admin@spreedemo.com / spree_admin


Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2014 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
