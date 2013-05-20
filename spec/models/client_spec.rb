require 'spec_helper'

describe Client do

  describe 'methods' do
    subject do
      u = Client.new
    end

    describe 'associations' do
      it { should have_many(:users)}
      it { should have_many(:agreements)}
      it { should belong_to(:purchasing_system)}
      it { should belong_to(:system_version)}
    end

    describe 'fields' do
      it { should respond_to(:name)}
      it { should respond_to(:ac_number)}
      it { should respond_to(:authentication_key)}
      it { should respond_to(:purchasing_system)}
      it { should respond_to(:system_version)}
      it { should respond_to(:category_schema)}
      it { should respond_to(:account_status)}
      it { should respond_to(:comment)}
      it { should respond_to :deleted_at }
    end

    describe 'methods' do
      it { should respond_to(:products)}
    end
  end

  describe 'auto generated fields' do
    subject do
      u = create :client
    end

    it { subject.ac_number.should_not be_nil }
    it 'should be the same after save' do
      supplier = subject
      n = supplier.ac_number
      supplier.name = 'asd'
      supplier.save
      supplier.ac_number.should == n
    end
  end

  describe 'validations' do

    describe 'negative' do
      it { FactoryGirl.build( :client, :name => nil).valid?.should_not be_true }
      it { FactoryGirl.build( :client, :name => 'a' *201).valid?.should_not be_true }
      it { FactoryGirl.build( :client, :authentication_key => nil).valid?.should_not be_true }
    end

    describe 'positive' do
      it { FactoryGirl.build( :client, :name => 'a' *200).valid?.should be_true }
    end
  end

end
