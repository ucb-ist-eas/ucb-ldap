# UC Berkeley LDAP

UCB::LDAP is a wrapper module around Net::LDAP intended to simplify searching the UC Berkeley
LDAP directory: http://directory.berkeley.edu

## Introduction to LDAP
If you are blissfully ignorant of LDAP, you should familiarize yourself with some of the basics.
Here is a great online resource: http://www.zytrax.com/books/ldap

The RDoc for the ruby-net-ldap Gem (http://rubyfurnace.com/docs/ruby-net-ldap-0.16.1/classes/Net/LDAP.html) also has a good introduction to LDAP.

## Upgrading To Version 3

Version 3 and higher of this gem support changes made to LDAP in 2017 [as described here.](https://calnetweb.berkeley.edu/calnet-technologists/ldap-directory-service/ldap-simplification-and-standardization) This involved a substantial reduction of data that had been available in older versions.

To upgrade, point your Gemfile to the latest version of ucb-ldap, run your test suite and look for deprecation warnings. All of the methods that wrapped deprecated LDAP attributes are still in place, but they will emit warnings and will be remove in version 4.

Most of the `Person` attributes are still in place, but the following classes have been deprecated completely:

  * `Address`
  * `JobAppointment`
  * `Namespace`
  * `Service`
  * `StudentTerm`

If you need access to any data that used to be in these modules, check with other campus resources (e.g. HCM)

## Examples

### General Search

Search the directory specifying tree base and filter, getting back generic `UCB::LDAP::Entry` instances:

```ruby
  entries = UCB::LDAP::Entry.search(:base => "ou=people,dc=berkeley,dc=edu", :filter => {:uid => 123})
  entries.class            #=> Array
  entries[0].class         #=> UCB::LDAP::Entry
  entries[0].uid           #=> '123'
  entries[0].givenname     #=> 'John'
  entries[0].sn            #=> 'Doe'
```

See `UCB::LDAP::Entry` for more information.

### Person Search

Search the Person tree getting back UCB::LDAP::Person instances:

```ruby
  person = UCB::LDAP::Person.find_by_uid("123")
  person.firstname           #=> "John"
  person.affiliations        #=> ['EMPLOYEE-TYPE-STAFF']
  person.employee?           #=> true
  person.employee_staff?     #=> true
  person.employee_academic?  #=> false
  person.student?            #=> false
```

See `UCB::LDAP::Person` for more information.

### Org Unit Search

Search the Org Unit tree getting back `UCB::LDAP::Org` instances:

``` ruby
  dept = UCB::LDAP::Org.org_by_ou('jkasd')
  dept.deptid         #=> "JKASD"
  dept.name           #=> "Administrative Systems Dept"
```

See `UCB::LDAP::Org` for more information.

### Privileged Binds

If you want access the directory anonymously, no credentials are required.
If you want to access via a privileged bind, authenticate before querying:

```ruby
  p = UCB::LDAP::Person.find_by_uid("123")
  p.non_public_attr    #=> NoMethodError

  UCB::LDAP.authenticate("mybind", "mypassword")
  p = UCB::LDAP::Person.find_by_uid("123")
  p.non_public_attr    #=> "some value"
```

## Dependencies

* Net::LDAP
* Ruby 2.2 or higher

## Maintainers

* Steven Hansen
* Steve Downey
* Darin Wilson
