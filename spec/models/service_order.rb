require 'rails_helper'

RSpec.describe ServiceOrder, type: :model do
  it { should belong_to(:tenant) }
  it { should belong_to(:secretary) }

  it { should belong_to(:property).optional }
  it { should belong_to(:producer).optional }
  it { should belong_to(:service_provider).optional }
  it { should belong_to(:requested_by).optional }
  it { should belong_to(:assigned_to).optional }

  it do
    should define_enum_for(:status)
      .with_values(pending: 0, scheduled: 1, in_progress: 2, completed: 3, cancelled: 4)
      .with_prefix
  end

  it do
    should define_enum_for(:priority)
      .with_values(low: 0, normal: 1, high: 2, urgent: 3)
      .with_prefix
  end

  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:deadline) }
end
