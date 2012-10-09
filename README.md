on_destroy
=====

This is a Rails 3.x ActiveRecord enhancement that allows you to:
* use `:do_not_delete` option to not call the delete callback on destroy by sending an empty block to `run_callbacks(:destroy)`.
* use `:set_column` to specify the column to update.
* use `:to` to specify the value to set the column to.

So, basically it will let you update a column/attribute of a model without actually deleting the record.

Also take a look at [acts_as_paranoid][acts_as_paranoid] [rails3_acts_as_paranoid][rails3_acts_as_paranoid], [soft_destroyable][soft_destroyable], [paranoia][paranoia], and other similar gems to be sure this is what you are looking for. The difference is that this gem does nothing with scoping, it just lets you mark a record as deleted without deleting it when you call destroy. This is just meant to provide a shortcut and slight safeguard in the situations where you want the client side to do the filtering of deleted records so that you can retain references to old models and maybe just color them differently in the UI to indicate that they are no longer active.

Add to your Gemfile:

    gem 'on_destroy'

Then run:

    bundle install

In your model you could include one of the following. You must ensure that the column exists and supports the value you are trying to set on it:

    on_destroy :do_not_delete, set: :some_column, to: 'some string value'
    on_destroy :do_not_delete, set: :some_column, to: nil
    on_destroy :do_not_delete, set: :some_column, to: false
    on_destroy :do_not_delete, set: :some_column, to: 1
    on_destroy :do_not_delete, set: :some_column, to: lambda {Time.now}

Something similar to light version of rails3_acts_as_paranoid could be produced by the following (note: default_scope is not implemented or affected by this plugin, I'm just using it for an example):

    default_scope where("deleted_at IS NOT NULL")
    on_destroy :do_not_delete, set: :deleted_at, to: lambda {Time.now}

If you have the same deleted column and process for all models, instead of using on_destroy in every model, use configure:

    # Do it for everything
    OnDestroy.configure do
      self.do_not_delete = true
      self.on_destroy_options = [:do_not_delete, {set: :deleted_at, to: lambda {Time.now}]
    end

If you want control over how it intuits how something is deleted (which is to look at the deleted date) use `:is_deleted_if` which can be a value, nil, or a Proc that takes the attribute value:

    on_destroy :do_not_delete, set: :some_column, to: lambda {Time.now}, is_deleted_if: {|c|Time.now > c} # provide time-travel resistent behavior of destroyed?/deleted?
    on_destroy :do_not_delete, set: :some_column, to: 1, is_deleted_if: 1 # this is not necessary, as it will already check for 1 since you specified it in the :to

If you use a proc to set the value and a value of nil indicates that it should be deleted (which is kind of wierd), you'll need to set:

    on_destroy :do_not_delete, set: :some_column, to: lambda {nil}, is_deleted_if: nil

To call a normal-ish `destroy` method, use the `really_destroy` method. I think this is better than using `destroy!` because all of the other bang methods on ActiveRecord.base tend to just throw errors, not behave that differently, despite the `destroy!` method being a naming convention from acts_as_paranoid.

### License

Copyright (c) 2012 Gary S. Weaver, released under the [MIT license][lic].

[paranoia]: https://github.com/radar/paranoia
[soft_destroyable]: https://github.com/rockrep/soft_destroyable
[acts_as_paranoid]: http://github.com/technoweenie/acts_as_paranoid
[rails3_acts_as_paranoid]: https://github.com/goncalossilva/rails3_acts_as_paranoid
[lic]: http://github.com/garysweaver/on_destroy/blob/master/LICENSE
