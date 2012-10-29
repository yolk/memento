### dev

[full changelog](http://github.com/yolk/valvat/compare/v0.4.0...master)

### 0.4.0 / 2012-10-29

[full changelog](http://github.com/yolk/valvat/compare/v0.3.7...v0.4.0)

* Memento is a Module now, not a Singleton: Use Memento directly and not Memento.instance
* Memento module is threadsafe now
* Changed main api: instead of Memento.memento() use Memento.watch() or Memento()
* Some code cleanup

### 0.3.7 / 2012-08-13

[full changelog](http://github.com/yolk/valvat/compare/v0.3.6...v0.3.7)

* Removed usage of ActiveRecord::Base#update_attribute for Rails 3.2.7 compatibility

### 0.3.6 / 2012-02-06

[full changelog](http://github.com/yolk/valvat/compare/v0.3.5...v0.3.6)

* Fixed deprecation warning: set_table_name => self.table_name = ...

### 0.3.5 / 2012-02-06

[full changelog](http://github.com/yolk/valvat/compare/v0.3.4...v0.3.5)

* Compatiblity with Rails 3.2