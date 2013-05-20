require 'rubygems'

ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factories/factories'

class Ability
  include RSpec::Matchers

  def must_be_able_to( action, instance)
    self.can?(action, instance).should be_true
  end

  def must_not_be_able_to( action, instance)
    self.cannot?(action, instance).should be_true
  end
end

DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/factories"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.include Devise::TestHelpers, type: :controller
  config.include FactoryGirl::Syntax::Methods

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  # config.infer_base_class_for_anonymous_controllers = true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  # config.order = "random"

  # config.before :suite do
  # end

  # config.before :all do
  # end

  # config.before(:each, :js => true) do
  # end

  config.before :each do
    DatabaseCleaner.start
  end

  config.after :each do
    DatabaseCleaner.clean
  end
end
