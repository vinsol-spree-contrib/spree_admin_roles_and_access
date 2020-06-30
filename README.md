SpreeAdminRolesAndAccess [![Code Climate](https://codeclimate.com/github/vinsol/spree_admin_roles_and_access.png)](https://codeclimate.com/github/vinsol/spree_admin_roles_and_access) [![Build Status](https://travis-ci.org/vinsol/spree_admin_roles_and_access.png?branch=master)](https://travis-ci.org/vinsol/spree_admin_roles_and_access)
========================

This spree extension is built on CanCan to dynamically add new roles and define its access through permissions.

Demo
----
Try Spree Admin Roles and Access for Spree master with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-admin-roles-and-access-master)

Try Spree Admin Roles and Access for Spree 4-1 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-admin-roles-and-access-4-1)

Try Spree Admin Roles and Access for Spree 3-4 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-admin-roles-and-access-3-4)

Try Spree Admin Roles and Access for Spree 3-1 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-admin-roles-and-access-3-1)

Screenshots
-----------

![Permission Sets](/screenshots/admin1.png "Creating Permission Sets")
![Roles](/screenshots/admin2.png "Creating Roles from permission sets")


Installation
------------

Add spree_admin_roles_and_access to your Gemfile:

  #### Spree >= 3.2

```ruby
gem 'spree_admin_roles_and_access', github: 'vinsol-spree-contrib/spree_admin_roles_and_access'
```

  #### Spree < 3.2

```ruby
gem 'spree_admin_roles_and_access', github: 'vinsol-spree-contrib/spree_admin_roles_and_access', branch: 'X-X-stable'
```
**Note** Please use 3-1-stable-updated branch for spree-3-1

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_admin_roles_and_access:install
bundle exec rake spree_roles:permissions:populate # To populate user and admin roles with their permissions
bundle exec rake spree_roles:permissions:populate_permission_sets # To set up some convenient permission sets.
```

Usage
-----

From Admin end, There are three menu's in the configuration Tab:

  1. **Permission:** Describes what the user can do.
  2. **Permission Set:** A collection of permission describing an aspect of role.
  3. **Role:** Collection of multiple permission sets which describe the role of user in the organisation. A role can be marked as `admin_accessible` in the role edit page.
     A role marked as such will get a default admin dashboard page in case they land on an admin page on which they do not have access.

Types of Permission
-------------------

  1. **Default Permission** - Basic permissions required by a user to perform task on user end, like creating an order etc. Every role should be provided with this permissions.
  2. **Can Manage All** - Role with this permission can do everything. This permission is also invisible at admin end. And it should only be given to admin and super admin.
  3. **Resource Manage Permission** - Each Resource has an associated admin permission that is required for accessing it. i.e. `can-admin-spree/products`
  4. **Resource Permission** - What the user is allowed to do with the resource. i.e. `Create`, `Update`, `Delete`, `List` or `Show`.



Pattern of the permissions
--------------------------

  1. **Can/cannot** - specifies whether the user with that permission can do or cannot do that task.
  2. **Action** - specifies the action which can be done by that model or subject like update, index, create etc. There is a special action called manage which matches every action.
  3. **Subject** - specified the model like products, users etc. of which the permission is given. There is an special subject called all which matches every subject.
  4. **Attributes** - specifies the attributes for which the permission is specified. Read-only actions shouldn't require this like index, read etc. But it is more secure if we specify them in other actions like create or update.

Some Examples
-------------

  1. **can-manage-spree/product** - can perform every action on Spree::Product but not on any other model or subject.
  2. **can-update-all** - can update all models or subjects.
  3. **can-update-spree/product** - can update only products, and not users, orders and other things.
  4. **can-update-spree/product-price** - can update only price of products.
  5. **can-manage-all** - can perform every action on all models.


Permission Sets
---------------

Once permissions are created you can organize groups of them into permission sets, These permission sets can then be assigned to the user's role which requires them.


Points to remember

  1. If the controller doesn't have any model associated with it, then we will provide the full controller path like :-
    can-read-spree/admin/pos

  2. Every Role should also have admin permission of that particular controller. For eg:-
    To create a product, can-admin-spree/product is also needed along with can-create-spree/product.

  3. To define custom cancan permissions, which can not be made with the pattern adopted.
    Override the module Permission. And define the permission in a method, and create a permission in the database. See example of `default-permission`.


Migration from older version
----------------------------

__v3.2.1 introduces some breaking changes.__

After updating the gem version. Run `rails g spree_admin_roles_and_access:install` to get the latest migrations. This includes a migration that generates a permission set per user role. With this, you should be able to continue using the original roles as you were earlier.

Additionally you may want to run the rake task `populate_permission_sets` to seed some initial permission sets. You can now gradually opt into seperating user role permissions into appropriate permission sets.

The original relationship between roles and permissions can be accessed via, `legacy_roles` & `legacy_permissions`. They are not supported or editable via the admin interfaces and are only mantained for use in our migration task.

**Note in the previous version read action was only for show. That has been superseded by read action now implying both show and index.**

Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

For older versions of spree
----------------------------

If you are using older version of spree. You can use the following version, please check the relavent readme for version specific installation guide.


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

## See It In Action

<a href="http://www.youtube.com/watch?feature=player_embedded&v=jKgSKx636Es
" target="_blank"><img src="http://img.youtube.com/vi/jKgSKx636Es/0.jpg" 
alt="Youtube Video Tutorial" /></a>

Contributing
------------

1. Fork the repo.
2. Clone your repo.
3. Run `bundle install`.
4. Run `bundle exec rake test_app` to create the test application in `spec/test_app`.
5. Make your changes.
6. Ensure specs pass by running `bundle exec rspec spec`.
7. Submit your pull request.


Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2017 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
